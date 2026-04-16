import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:collection/collection.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'model.dart';

class AuditEngine {
  Future<AuditResult> audit(AuditConfig config) async {
    final projectDir = Directory(config.projectPath);
    final sources = <String, String>{};

    if (!await projectDir.exists()) {
      throw ArgumentError.value(
        config.projectPath,
        'projectPath',
        'Project directory does not exist.',
      );
    }

    await for (final entity in projectDir.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final relativePath = p.posix.normalize(
        p.relative(entity.path, from: config.projectPath).replaceAll('\\', '/'),
      );
      if (!_shouldIncludePath(
        relativePath,
        includeTest: config.includeTest,
        ignoreGlobs: config.ignoreGlobs,
      )) {
        continue;
      }

      sources[relativePath] = await entity.readAsString();
    }

    return auditSources(
      sources,
      projectRoot: config.projectPath,
      flutterVersion: config.flutterVersion,
      dartVersion: config.dartVersion,
    );
  }

  AuditResult auditSources(
    Map<String, String> sources, {
    required String projectRoot,
    String? flutterVersion,
    String? dartVersion,
  }) {
    final parseFailures = <ParseFailure>[];
    final findings = <_FindingDraft>[];
    var analyzedFiles = 0;

    for (final entry in sources.entries.sortedBy((entry) => entry.key)) {
      final result = parseString(
        content: entry.value,
        path: entry.key,
        throwIfDiagnostics: false,
      );

      if (result.errors.isNotEmpty) {
        parseFailures.add(
          ParseFailure(
            filePath: entry.key,
            message: result.errors.map((error) => error.message).join('; '),
          ),
        );
        findings.addAll(
          _FallbackScanner.scan(filePath: entry.key, content: entry.value),
        );
        continue;
      }

      analyzedFiles++;
      final visitor = _GetxAuditVisitor(
        filePath: entry.key,
        content: entry.value,
        lineInfo: result.lineInfo,
      );
      result.unit.visitChildren(visitor);
      findings.addAll(visitor.findings);
    }

    final finalizedFindings = _finalizeFindings(findings);
    final riskSummary = RiskSummary(
      low: finalizedFindings
          .where((item) => item.riskLevel == RiskLevel.low)
          .length,
      medium: finalizedFindings
          .where((item) => item.riskLevel == RiskLevel.medium)
          .length,
      high: finalizedFindings
          .where((item) => item.riskLevel == RiskLevel.high)
          .length,
    );

    final summary = SummaryStats(
      totalDartFiles: sources.length,
      analyzedFiles: analyzedFiles,
      parseFailures: parseFailures.length,
      totalFindings: finalizedFindings.length,
    );

    final inventory = ProjectInventory(
      project: ProjectMetadata(
        rootPath: projectRoot,
        generatedAt: DateTime.now().toUtc(),
        flutterVersion: flutterVersion,
        dartVersion: dartVersion,
      ),
      summary: summary,
      riskSummary: riskSummary,
      findings: finalizedFindings,
      recommendedOrder: _buildRecommendedOrder(finalizedFindings),
    );

    return AuditResult(inventory: inventory, parseFailures: parseFailures);
  }

  bool _shouldIncludePath(
    String relativePath, {
    required bool includeTest,
    required List<String> ignoreGlobs,
  }) {
    final normalized = relativePath.replaceAll('\\', '/');
    const excludedSegments = <String>{
      '.dart_tool',
      'build',
      'android',
      'ios',
      'linux',
      'macos',
      'web',
      'windows',
    };

    final segments = p.posix.split(normalized);
    if (segments.any(excludedSegments.contains)) {
      return false;
    }
    if (normalized.contains('GeneratedPluginRegistrant')) {
      return false;
    }
    if (!(normalized.startsWith('lib/') ||
        (includeTest && normalized.startsWith('test/')))) {
      return false;
    }

    for (final pattern in ignoreGlobs) {
      if (Glob(pattern, context: p.posix).matches(normalized)) {
        return false;
      }
    }
    return true;
  }
}

List<Finding> _finalizeFindings(List<_FindingDraft> drafts) {
  final counters = <FindingCategory, int>{
    for (final category in FindingCategory.values) category: 0,
  };

  return drafts
      .sorted((left, right) {
        final categoryCompare = left.category.index.compareTo(
          right.category.index,
        );
        if (categoryCompare != 0) {
          return categoryCompare;
        }
        final fileCompare = left.filePath.compareTo(right.filePath);
        if (fileCompare != 0) {
          return fileCompare;
        }
        return left.lineStart.compareTo(right.lineStart);
      })
      .map((draft) {
        final next = (counters[draft.category] ?? 0) + 1;
        counters[draft.category] = next;
        final categoryCode = switch (draft.category) {
          FindingCategory.state => 'STATE',
          FindingCategory.di => 'DI',
          FindingCategory.routing => 'ROUTE',
          FindingCategory.uiHelper => 'UI',
          FindingCategory.network => 'NET',
        };
        return Finding(
          id: 'GXD-$categoryCode-${next.toString().padLeft(3, '0')}',
          category: draft.category,
          subcategory: draft.subcategory,
          filePath: draft.filePath,
          lineStart: draft.lineStart,
          lineEnd: draft.lineEnd,
          snippet: draft.snippet,
          riskLevel: draft.riskLevel,
          confidence: draft.confidence,
          description: draft.description,
          migrationHint: draft.migrationHint,
          recommendedTarget: draft.recommendedTarget,
          requiresManualReview: draft.requiresManualReview,
        );
      })
      .toList(growable: false);
}

List<RecommendedStep> _buildRecommendedOrder(List<Finding> findings) {
  final steps = <({String title, String reason, bool Function(Finding finding) predicate})>[
    (
      title: 'App router migration',
      reason:
          'Route registry and entrypoint coupling should be untangled first.',
      predicate: (finding) => finding.category == FindingCategory.routing,
    ),
    (
      title: 'Network abstraction migration',
      reason:
          'GetConnect usage hides auth and decoder behavior that affects every feature.',
      predicate: (finding) => finding.category == FindingCategory.network,
    ),
    (
      title: 'Large controller decomposition',
      reason:
          'Mixed-responsibility controllers block safe migration sequencing.',
      predicate: (finding) =>
          finding.category == FindingCategory.state &&
          (finding.subcategory == 'getxController' ||
              finding.subcategory == 'lifecycle'),
    ),
    (
      title: 'DI cleanup',
      reason:
          'Global lookups and bindings should be mapped before local rewrites.',
      predicate: (finding) => finding.category == FindingCategory.di,
    ),
    (
      title: 'Widget-level reactive cleanup',
      reason:
          'Local reactive widgets are safer once routing, network, and DI are mapped.',
      predicate: (finding) =>
          finding.category == FindingCategory.state &&
          (finding.subcategory == 'obs' ||
              finding.subcategory == 'rxType' ||
              finding.subcategory == 'obx' ||
              finding.subcategory == 'getBuilder'),
    ),
  ];

  return steps
      .map((step) {
        final related = findings
            .where(step.predicate)
            .map((finding) => finding.id)
            .toList(growable: false);
        if (related.isEmpty) {
          return null;
        }
        return RecommendedStep(
          title: step.title,
          reason: step.reason,
          relatedFindingIds: related,
        );
      })
      .whereType<RecommendedStep>()
      .toList(growable: false);
}

class _GetxAuditVisitor extends RecursiveAstVisitor<void> {
  _GetxAuditVisitor({
    required this.filePath,
    required this.content,
    required this.lineInfo,
  }) : _lines = content.split('\n');

  final String filePath;
  final String content;
  final LineInfo lineInfo;
  final List<String> _lines;
  final List<_FindingDraft> findings = <_FindingDraft>[];

  bool _inGetxController = false;
  bool _inBindingsClass = false;
  bool _inGetConnect = false;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final previousGetxController = _inGetxController;
    final previousBindings = _inBindingsClass;
    final previousGetConnect = _inGetConnect;

    final allTypes = <String?>[
      node.extendsClause?.superclass.name.lexeme,
      ...node.withClause?.mixinTypes.map((item) => item.name.lexeme) ??
          const Iterable<String?>.empty(),
      ...node.implementsClause?.interfaces.map((item) => item.name.lexeme) ??
          const Iterable<String?>.empty(),
    ];

    _inGetxController = allTypes.contains('GetxController');
    _inBindingsClass = allTypes.contains('Bindings');
    _inGetConnect = allTypes.contains('GetConnect');

    if (_inGetxController) {
      _record(
        node.name.offset,
        node.name.end,
        _ruleCatalog['state.getxController']!,
      );
    }
    if (_inBindingsClass) {
      _record(node.name.offset, node.name.end, _ruleCatalog['di.bindings']!);
    }
    if (_inGetConnect) {
      _record(
        node.name.offset,
        node.name.end,
        _ruleCatalog['network.getConnect']!,
      );
    }

    super.visitClassDeclaration(node);

    _inGetxController = previousGetxController;
    _inBindingsClass = previousBindings;
    _inGetConnect = previousGetConnect;
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (_inGetxController &&
        const {'onInit', 'onReady', 'onClose'}.contains(node.name.lexeme)) {
      _record(
        node.name.offset,
        node.name.end,
        _ruleCatalog['state.lifecycle']!,
      );
    }

    super.visitMethodDeclaration(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;
    final rule = switch (typeName) {
      'Obx' => _ruleCatalog['state.obx'],
      'GetBuilder' => _ruleCatalog['state.getBuilder'],
      'BindingsBuilder' => _ruleCatalog['di.bindings'],
      'GetMaterialApp' => _ruleCatalog['routing.getMaterialApp'],
      'GetPage' => _ruleCatalog['routing.getPage'],
      _ => null,
    };
    if (rule != null) {
      _record(node.offset, node.end, rule);
    }

    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitNamedType(NamedType node) {
    if (node.name.lexeme == 'Rx') {
      _record(node.offset, node.end, _ruleCatalog['state.rxType']!);
    }
    super.visitNamedType(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.propertyName.name == 'obs') {
      _record(node.offset, node.end, _ruleCatalog['state.obs']!);
    }

    if (_isGetReference(node.target)) {
      final rule = switch (node.propertyName.name) {
        'context' => _ruleCatalog['ui.context'],
        'overlayContext' => _ruleCatalog['ui.overlayContext'],
        'arguments' => _ruleCatalog['routing.getArguments'],
        _ => null,
      };
      if (rule != null) {
        _record(node.offset, node.end, rule);
      }
    }

    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (_isGetReference(node.prefix)) {
      final rule = switch (node.identifier.name) {
        'context' => _ruleCatalog['ui.context'],
        'overlayContext' => _ruleCatalog['ui.overlayContext'],
        'arguments' => _ruleCatalog['routing.getArguments'],
        _ => null,
      };
      if (rule != null) {
        _record(node.offset, node.end, rule);
      }
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (_inGetConnect &&
        node.leftHandSide.toSource().trim().endsWith('defaultDecoder')) {
      _record(node.offset, node.end, _ruleCatalog['network.decoder']!);
    }
    super.visitAssignmentExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final constructorLikeRule = switch (node.methodName.name) {
      'Obx' => _ruleCatalog['state.obx'],
      'GetBuilder' => _ruleCatalog['state.getBuilder'],
      'BindingsBuilder' => _ruleCatalog['di.bindings'],
      'GetMaterialApp' => _ruleCatalog['routing.getMaterialApp'],
      'GetPage' => _ruleCatalog['routing.getPage'],
      _ => null,
    };
    if (constructorLikeRule != null && !_isGetReference(node.target)) {
      _record(node.offset, node.end, constructorLikeRule);
    }

    if (_isGetReference(node.target)) {
      final methodName = node.methodName.name;
      final rule = switch (methodName) {
        'put' => _ruleCatalog['di.getPut'],
        'lazyPut' => _ruleCatalog['di.getLazyPut'],
        'find' => _ruleCatalog['di.getFind'],
        'snackbar' => _ruleCatalog['ui.snackbar'],
        'dialog' => _ruleCatalog['ui.dialog'],
        'bottomSheet' => _ruleCatalog['ui.bottomSheet'],
        _ when methodName.startsWith('to') => _ruleCatalog['routing.getTo'],
        _ when methodName.startsWith('off') => _ruleCatalog['routing.getOff'],
        _ => null,
      };
      if (rule != null) {
        _record(node.offset, node.end, rule);
      }
    }

    if (_inGetConnect) {
      final methodName = node.methodName.name;
      final rule = switch (methodName) {
        'addRequestModifier' => _ruleCatalog['network.requestModifier'],
        'addAuthenticator' => _ruleCatalog['network.authenticator'],
        _ => null,
      };
      if (rule != null) {
        _record(node.offset, node.end, rule);
      }
    }

    super.visitMethodInvocation(node);
  }

  bool _isGetReference(AstNode? node) {
    if (node == null) {
      return false;
    }
    if (node is SimpleIdentifier) {
      return node.name == 'Get';
    }
    if (node is PrefixedIdentifier) {
      return node.identifier.name == 'Get' || _isGetReference(node.prefix);
    }
    if (node is PropertyAccess) {
      return node.propertyName.name == 'Get' || _isGetReference(node.target);
    }
    return false;
  }

  void _record(int offset, int end, _RuleDescriptor descriptor) {
    final location = lineInfo.getLocation(offset);
    final line = location.lineNumber;
    final snippet = _lines[line - 1].trim();
    findings.add(
      _FindingDraft(
        category: descriptor.category,
        subcategory: descriptor.subcategory,
        filePath: filePath,
        lineStart: line,
        lineEnd: lineInfo.getLocation(end).lineNumber,
        snippet: snippet,
        riskLevel: descriptor.riskLevel,
        confidence: descriptor.confidence,
        description: descriptor.description,
        migrationHint: descriptor.migrationHint,
        recommendedTarget: descriptor.recommendedTarget,
        requiresManualReview: descriptor.requiresManualReview,
      ),
    );
  }
}

class _FallbackScanner {
  static final List<({String pattern, _RuleDescriptor rule})> _patterns =
      _ruleCatalog.values
          .where((rule) => rule.fallbackPattern != null)
          .map((rule) => (pattern: rule.fallbackPattern!, rule: rule))
          .toList(growable: false);

  static List<_FindingDraft> scan({
    required String filePath,
    required String content,
  }) {
    final lines = content.split('\n');
    final findings = <_FindingDraft>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      for (final entry in _patterns) {
        if (!line.contains(entry.pattern)) {
          continue;
        }
        findings.add(
          _FindingDraft(
            category: entry.rule.category,
            subcategory: entry.rule.subcategory,
            filePath: filePath,
            lineStart: index + 1,
            lineEnd: index + 1,
            snippet: line.trim(),
            riskLevel: entry.rule.riskLevel,
            confidence: ConfidenceLevel.low,
            description: entry.rule.description,
            migrationHint: entry.rule.migrationHint,
            recommendedTarget: entry.rule.recommendedTarget,
            requiresManualReview: entry.rule.requiresManualReview,
          ),
        );
      }
    }
    return findings;
  }
}

@immutable
class _FindingDraft {
  const _FindingDraft({
    required this.category,
    required this.subcategory,
    required this.filePath,
    required this.lineStart,
    required this.lineEnd,
    required this.snippet,
    required this.riskLevel,
    required this.confidence,
    required this.description,
    required this.migrationHint,
    required this.recommendedTarget,
    required this.requiresManualReview,
  });

  final FindingCategory category;
  final String subcategory;
  final String filePath;
  final int lineStart;
  final int lineEnd;
  final String snippet;
  final RiskLevel riskLevel;
  final ConfidenceLevel confidence;
  final String description;
  final String migrationHint;
  final String recommendedTarget;
  final bool requiresManualReview;
}

@immutable
class _RuleDescriptor {
  const _RuleDescriptor({
    required this.category,
    required this.subcategory,
    required this.riskLevel,
    required this.confidence,
    required this.description,
    required this.migrationHint,
    required this.recommendedTarget,
    required this.requiresManualReview,
    this.fallbackPattern,
  });

  final FindingCategory category;
  final String subcategory;
  final RiskLevel riskLevel;
  final ConfidenceLevel confidence;
  final String description;
  final String migrationHint;
  final String recommendedTarget;
  final bool requiresManualReview;
  final String? fallbackPattern;
}

const Map<String, _RuleDescriptor> _ruleCatalog = <String, _RuleDescriptor>{
  'state.obs': _RuleDescriptor(
    category: FindingCategory.state,
    subcategory: 'obs',
    riskLevel: RiskLevel.low,
    confidence: ConfidenceLevel.high,
    description: 'Reactive `.obs` wrapper detected.',
    migrationHint:
        'Classify whether this can become a local provider or a Notifier field.',
    recommendedTarget: 'riverpod_notifier',
    requiresManualReview: false,
    fallbackPattern: '.obs',
  ),
  'state.rxType': _RuleDescriptor(
    category: FindingCategory.state,
    subcategory: 'rxType',
    riskLevel: RiskLevel.low,
    confidence: ConfidenceLevel.high,
    description: 'Explicit `Rx<T>` type detected.',
    migrationHint:
        'Map the reactive type to a provider or Notifier state boundary.',
    recommendedTarget: 'riverpod_notifier',
    requiresManualReview: false,
    fallbackPattern: 'Rx<',
  ),
  'state.obx': _RuleDescriptor(
    category: FindingCategory.state,
    subcategory: 'obx',
    riskLevel: RiskLevel.low,
    confidence: ConfidenceLevel.high,
    description: '`Obx` reactive widget detected.',
    migrationHint:
        'Replace with Consumer-driven rebuilds after state ownership is mapped.',
    recommendedTarget: 'riverpod_notifier',
    requiresManualReview: false,
    fallbackPattern: 'Obx(',
  ),
  'state.getBuilder': _RuleDescriptor(
    category: FindingCategory.state,
    subcategory: 'getBuilder',
    riskLevel: RiskLevel.low,
    confidence: ConfidenceLevel.high,
    description: '`GetBuilder` widget detected.',
    migrationHint:
        'Convert isolated builder state after controller ownership is mapped.',
    recommendedTarget: 'riverpod_notifier',
    requiresManualReview: false,
    fallbackPattern: 'GetBuilder',
  ),
  'state.getxController': _RuleDescriptor(
    category: FindingCategory.state,
    subcategory: 'getxController',
    riskLevel: RiskLevel.high,
    confidence: ConfidenceLevel.high,
    description: '`GetxController` class detected.',
    migrationHint:
        'Measure dependencies and split mixed responsibilities before migration.',
    recommendedTarget: 'riverpod_notifier',
    requiresManualReview: true,
    fallbackPattern: 'GetxController',
  ),
  'state.lifecycle': _RuleDescriptor(
    category: FindingCategory.state,
    subcategory: 'lifecycle',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.medium,
    description: 'GetX lifecycle hook detected.',
    migrationHint:
        'Map the lifecycle behavior before refactoring state ownership.',
    recommendedTarget: 'riverpod_async_notifier',
    requiresManualReview: true,
    fallbackPattern: 'onInit(',
  ),
  'di.getPut': _RuleDescriptor(
    category: FindingCategory.di,
    subcategory: 'getPut',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.put` registration detected.',
    migrationHint:
        'Replace direct registration with an explicit provider graph.',
    recommendedTarget: 'legacy_di_bridge_optional',
    requiresManualReview: true,
    fallbackPattern: 'Get.put',
  ),
  'di.getLazyPut': _RuleDescriptor(
    category: FindingCategory.di,
    subcategory: 'getLazyPut',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.lazyPut` registration detected.',
    migrationHint:
        'Document lazy lifecycle expectations before replacing the binding.',
    recommendedTarget: 'legacy_di_bridge_optional',
    requiresManualReview: true,
    fallbackPattern: 'Get.lazyPut',
  ),
  'di.getFind': _RuleDescriptor(
    category: FindingCategory.di,
    subcategory: 'getFind',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.find` lookup detected.',
    migrationHint: 'Replace implicit lookup with explicit provider wiring.',
    recommendedTarget: 'legacy_di_bridge_optional',
    requiresManualReview: true,
    fallbackPattern: 'Get.find',
  ),
  'di.bindings': _RuleDescriptor(
    category: FindingCategory.di,
    subcategory: 'bindings',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: 'Bindings infrastructure detected.',
    migrationHint:
        'Map route-scoped registration and teardown behavior before removing Bindings.',
    recommendedTarget: 'legacy_di_bridge_optional',
    requiresManualReview: true,
    fallbackPattern: 'Bindings',
  ),
  'routing.getMaterialApp': _RuleDescriptor(
    category: FindingCategory.routing,
    subcategory: 'getMaterialApp',
    riskLevel: RiskLevel.high,
    confidence: ConfidenceLevel.high,
    description: '`GetMaterialApp` entrypoint detected.',
    migrationHint:
        'Migrate app-level routing first so downstream route calls have a target.',
    recommendedTarget: 'go_router_route_tree',
    requiresManualReview: true,
    fallbackPattern: 'GetMaterialApp',
  ),
  'routing.getPage': _RuleDescriptor(
    category: FindingCategory.routing,
    subcategory: 'getPage',
    riskLevel: RiskLevel.high,
    confidence: ConfidenceLevel.high,
    description: '`GetPage` route declaration detected.',
    migrationHint:
        'Convert route registry into a typed route tree before call-site rewrites.',
    recommendedTarget: 'go_router_route_tree',
    requiresManualReview: true,
    fallbackPattern: 'GetPage',
  ),
  'routing.getTo': _RuleDescriptor(
    category: FindingCategory.routing,
    subcategory: 'getTo',
    riskLevel: RiskLevel.low,
    confidence: ConfidenceLevel.medium,
    description: '`Get.to*` route invocation detected.',
    migrationHint: 'Rewrite route calls after the target route tree exists.',
    recommendedTarget: 'go_router_route_tree',
    requiresManualReview: false,
    fallbackPattern: 'Get.to',
  ),
  'routing.getOff': _RuleDescriptor(
    category: FindingCategory.routing,
    subcategory: 'getOff',
    riskLevel: RiskLevel.low,
    confidence: ConfidenceLevel.medium,
    description: '`Get.off*` route invocation detected.',
    migrationHint:
        'Rewrite destructive route transitions after the target router is ready.',
    recommendedTarget: 'go_router_route_tree',
    requiresManualReview: false,
    fallbackPattern: 'Get.off',
  ),
  'routing.getArguments': _RuleDescriptor(
    category: FindingCategory.routing,
    subcategory: 'getArguments',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.arguments` access detected.',
    migrationHint:
        'Replace implicit route payload access with typed route parameters.',
    recommendedTarget: 'go_router_route_tree',
    requiresManualReview: true,
    fallbackPattern: 'Get.arguments',
  ),
  'ui.snackbar': _RuleDescriptor(
    category: FindingCategory.uiHelper,
    subcategory: 'snackbar',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.snackbar` helper detected.',
    migrationHint:
        'Replace with route-aware messenger patterns after context ownership is clear.',
    recommendedTarget: 'manual_ui_context_refactor',
    requiresManualReview: false,
    fallbackPattern: 'Get.snackbar',
  ),
  'ui.dialog': _RuleDescriptor(
    category: FindingCategory.uiHelper,
    subcategory: 'dialog',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.dialog` helper detected.',
    migrationHint:
        'Replace with explicit dialog presentation using owned context.',
    recommendedTarget: 'manual_ui_context_refactor',
    requiresManualReview: false,
    fallbackPattern: 'Get.dialog',
  ),
  'ui.bottomSheet': _RuleDescriptor(
    category: FindingCategory.uiHelper,
    subcategory: 'bottomSheet',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.bottomSheet` helper detected.',
    migrationHint:
        'Map modal presentation to an explicit route-aware bottom sheet strategy.',
    recommendedTarget: 'manual_ui_context_refactor',
    requiresManualReview: false,
    fallbackPattern: 'Get.bottomSheet',
  ),
  'ui.context': _RuleDescriptor(
    category: FindingCategory.uiHelper,
    subcategory: 'context',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.context` global context access detected.',
    migrationHint:
        'Remove global context dependencies before UI helper migration.',
    recommendedTarget: 'manual_ui_context_refactor',
    requiresManualReview: true,
    fallbackPattern: 'Get.context',
  ),
  'ui.overlayContext': _RuleDescriptor(
    category: FindingCategory.uiHelper,
    subcategory: 'overlayContext',
    riskLevel: RiskLevel.medium,
    confidence: ConfidenceLevel.high,
    description: '`Get.overlayContext` access detected.',
    migrationHint:
        'Map overlay usage to explicit messenger or navigator ownership.',
    recommendedTarget: 'manual_ui_context_refactor',
    requiresManualReview: true,
    fallbackPattern: 'Get.overlayContext',
  ),
  'network.getConnect': _RuleDescriptor(
    category: FindingCategory.network,
    subcategory: 'getConnect',
    riskLevel: RiskLevel.high,
    confidence: ConfidenceLevel.high,
    description: '`GetConnect` client detected.',
    migrationHint:
        'Inventory endpoints and middleware before replacing the client.',
    recommendedTarget: 'dio_client_repository',
    requiresManualReview: true,
    fallbackPattern: 'GetConnect',
  ),
  'network.requestModifier': _RuleDescriptor(
    category: FindingCategory.network,
    subcategory: 'requestModifier',
    riskLevel: RiskLevel.high,
    confidence: ConfidenceLevel.high,
    description: 'GetConnect request modifier detected.',
    migrationHint: 'Translate request decoration to explicit Dio interceptors.',
    recommendedTarget: 'dio_client_repository',
    requiresManualReview: true,
    fallbackPattern: 'addRequestModifier',
  ),
  'network.authenticator': _RuleDescriptor(
    category: FindingCategory.network,
    subcategory: 'authenticator',
    riskLevel: RiskLevel.high,
    confidence: ConfidenceLevel.high,
    description: 'GetConnect authenticator detected.',
    migrationHint:
        'Model token refresh semantics before changing the networking stack.',
    recommendedTarget: 'dio_client_repository',
    requiresManualReview: true,
    fallbackPattern: 'addAuthenticator',
  ),
  'network.decoder': _RuleDescriptor(
    category: FindingCategory.network,
    subcategory: 'decoder',
    riskLevel: RiskLevel.high,
    confidence: ConfidenceLevel.high,
    description: 'GetConnect decoder customization detected.',
    migrationHint:
        'Port response decoding rules before switching the transport client.',
    recommendedTarget: 'dio_client_repository',
    requiresManualReview: true,
    fallbackPattern: 'defaultDecoder',
  ),
};
