import 'dart:convert';

import 'package:meta/meta.dart';

const int kProjectInventorySchemaVersion = 1;
const int kAuditResultSchemaVersion = 1;

enum FindingCategory {
  state,
  di,
  routing,
  uiHelper,
  network;

  String get wireName => switch (this) {
    FindingCategory.state => 'state',
    FindingCategory.di => 'di',
    FindingCategory.routing => 'routing',
    FindingCategory.uiHelper => 'uiHelper',
    FindingCategory.network => 'network',
  };

  static FindingCategory fromWireName(String value) => switch (value) {
    'state' => FindingCategory.state,
    'di' => FindingCategory.di,
    'routing' => FindingCategory.routing,
    'uiHelper' => FindingCategory.uiHelper,
    'network' => FindingCategory.network,
    _ => throw ArgumentError.value(value, 'value', 'Unknown category'),
  };
}

enum RiskLevel {
  low,
  medium,
  high;

  String get wireName => name;

  static RiskLevel fromWireName(String value) => RiskLevel.values.firstWhere(
    (level) => level.wireName == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'Unknown risk'),
  );
}

enum ConfidenceLevel {
  low,
  medium,
  high;

  String get wireName => name;

  static ConfidenceLevel fromWireName(String value) =>
      ConfidenceLevel.values.firstWhere(
        (level) => level.wireName == value,
        orElse: () =>
            throw ArgumentError.value(value, 'value', 'Unknown confidence'),
      );
}

@immutable
class ProjectMetadata {
  const ProjectMetadata({
    required this.rootPath,
    required this.generatedAt,
    this.flutterVersion,
    this.dartVersion,
  });

  final String rootPath;
  final DateTime generatedAt;
  final String? flutterVersion;
  final String? dartVersion;

  Map<String, Object?> toJson() => <String, Object?>{
    'rootPath': rootPath,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'flutterVersion': flutterVersion,
    'dartVersion': dartVersion,
  };

  factory ProjectMetadata.fromJson(Map<String, Object?> json) {
    return ProjectMetadata(
      rootPath: json['rootPath']! as String,
      generatedAt: DateTime.parse(json['generatedAt']! as String).toUtc(),
      flutterVersion: json['flutterVersion'] as String?,
      dartVersion: json['dartVersion'] as String?,
    );
  }
}

@immutable
class SummaryStats {
  const SummaryStats({
    required this.totalDartFiles,
    required this.analyzedFiles,
    required this.parseFailures,
    required this.totalFindings,
  });

  final int totalDartFiles;
  final int analyzedFiles;
  final int parseFailures;
  final int totalFindings;

  Map<String, Object?> toJson() => <String, Object?>{
    'totalDartFiles': totalDartFiles,
    'analyzedFiles': analyzedFiles,
    'parseFailures': parseFailures,
    'totalFindings': totalFindings,
  };

  factory SummaryStats.fromJson(Map<String, Object?> json) {
    return SummaryStats(
      totalDartFiles: json['totalDartFiles']! as int,
      analyzedFiles: json['analyzedFiles']! as int,
      parseFailures: json['parseFailures']! as int,
      totalFindings: json['totalFindings']! as int,
    );
  }
}

@immutable
class RiskSummary {
  const RiskSummary({
    required this.low,
    required this.medium,
    required this.high,
  });

  final int low;
  final int medium;
  final int high;

  Map<String, Object?> toJson() => <String, Object?>{
    'low': low,
    'medium': medium,
    'high': high,
  };

  factory RiskSummary.fromJson(Map<String, Object?> json) {
    return RiskSummary(
      low: json['low']! as int,
      medium: json['medium']! as int,
      high: json['high']! as int,
    );
  }
}

@immutable
class Finding {
  const Finding({
    required this.id,
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

  final String id;
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

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'category': category.wireName,
    'subcategory': subcategory,
    'filePath': filePath,
    'lineStart': lineStart,
    'lineEnd': lineEnd,
    'snippet': snippet,
    'riskLevel': riskLevel.wireName,
    'confidence': confidence.wireName,
    'description': description,
    'migrationHint': migrationHint,
    'recommendedTarget': recommendedTarget,
    'requiresManualReview': requiresManualReview,
  };

  factory Finding.fromJson(Map<String, Object?> json) {
    return Finding(
      id: json['id']! as String,
      category: FindingCategory.fromWireName(json['category']! as String),
      subcategory: json['subcategory']! as String,
      filePath: json['filePath']! as String,
      lineStart: json['lineStart']! as int,
      lineEnd: json['lineEnd']! as int,
      snippet: json['snippet']! as String,
      riskLevel: RiskLevel.fromWireName(json['riskLevel']! as String),
      confidence: ConfidenceLevel.fromWireName(json['confidence']! as String),
      description: json['description']! as String,
      migrationHint: json['migrationHint']! as String,
      recommendedTarget: json['recommendedTarget']! as String,
      requiresManualReview: json['requiresManualReview']! as bool,
    );
  }
}

@immutable
class RecommendedStep {
  const RecommendedStep({
    required this.title,
    required this.reason,
    required this.relatedFindingIds,
  });

  final String title;
  final String reason;
  final List<String> relatedFindingIds;

  Map<String, Object?> toJson() => <String, Object?>{
    'title': title,
    'reason': reason,
    'relatedFindingIds': relatedFindingIds,
  };

  factory RecommendedStep.fromJson(Map<String, Object?> json) {
    return RecommendedStep(
      title: json['title']! as String,
      reason: json['reason']! as String,
      relatedFindingIds: (json['relatedFindingIds']! as List<Object?>)
          .cast<String>(),
    );
  }
}

@immutable
class ParseFailure {
  const ParseFailure({required this.filePath, required this.message});

  final String filePath;
  final String message;

  Map<String, Object?> toJson() => <String, Object?>{
    'filePath': filePath,
    'message': message,
  };

  factory ParseFailure.fromJson(Map<String, Object?> json) {
    return ParseFailure(
      filePath: json['filePath']! as String,
      message: json['message']! as String,
    );
  }
}

@immutable
class RouteDeclaration {
  const RouteDeclaration({
    required this.routeName,
    required this.filePath,
    required this.lineStart,
    required this.pageBuilder,
    this.binding,
    this.middlewares = const <String>[],
  });

  final String routeName;
  final String filePath;
  final int lineStart;
  final String pageBuilder;
  final String? binding;
  final List<String> middlewares;

  Map<String, Object?> toJson() => <String, Object?>{
    'routeName': routeName,
    'filePath': filePath,
    'lineStart': lineStart,
    'pageBuilder': pageBuilder,
    'binding': binding,
    'middlewares': middlewares,
  };

  factory RouteDeclaration.fromJson(Map<String, Object?> json) {
    return RouteDeclaration(
      routeName: json['routeName']! as String,
      filePath: json['filePath']! as String,
      lineStart: json['lineStart']! as int,
      pageBuilder: json['pageBuilder']! as String,
      binding: json['binding'] as String?,
      middlewares: (json['middlewares'] as List<Object?>? ?? const <Object?>[])
          .cast<String>(),
    );
  }
}

@immutable
class RouteInvocation {
  const RouteInvocation({
    required this.methodName,
    required this.routeName,
    required this.filePath,
    required this.lineStart,
    required this.passesArguments,
  });

  final String methodName;
  final String routeName;
  final String filePath;
  final int lineStart;
  final bool passesArguments;

  Map<String, Object?> toJson() => <String, Object?>{
    'methodName': methodName,
    'routeName': routeName,
    'filePath': filePath,
    'lineStart': lineStart,
    'passesArguments': passesArguments,
  };

  factory RouteInvocation.fromJson(Map<String, Object?> json) {
    return RouteInvocation(
      methodName: json['methodName']! as String,
      routeName: json['routeName']! as String,
      filePath: json['filePath']! as String,
      lineStart: json['lineStart']! as int,
      passesArguments: json['passesArguments']! as bool,
    );
  }
}

@immutable
class RouteArgumentAccess {
  const RouteArgumentAccess({required this.filePath, required this.lineStart});

  final String filePath;
  final int lineStart;

  Map<String, Object?> toJson() => <String, Object?>{
    'filePath': filePath,
    'lineStart': lineStart,
  };

  factory RouteArgumentAccess.fromJson(Map<String, Object?> json) {
    return RouteArgumentAccess(
      filePath: json['filePath']! as String,
      lineStart: json['lineStart']! as int,
    );
  }
}

@immutable
class RouteInventory {
  const RouteInventory({
    this.declarations = const <RouteDeclaration>[],
    this.invocations = const <RouteInvocation>[],
    this.argumentAccesses = const <RouteArgumentAccess>[],
  });

  final List<RouteDeclaration> declarations;
  final List<RouteInvocation> invocations;
  final List<RouteArgumentAccess> argumentAccesses;

  Map<String, Object?> toJson() => <String, Object?>{
    'declarations': declarations
        .map((item) => item.toJson())
        .toList(growable: false),
    'invocations': invocations
        .map((item) => item.toJson())
        .toList(growable: false),
    'argumentAccesses': argumentAccesses
        .map((item) => item.toJson())
        .toList(growable: false),
  };

  factory RouteInventory.fromJson(Map<String, Object?> json) {
    return RouteInventory(
      declarations:
          (json['declarations'] as List<Object?>? ?? const <Object?>[])
              .cast<Map<String, Object?>>()
              .map(RouteDeclaration.fromJson)
              .toList(growable: false),
      invocations: (json['invocations'] as List<Object?>? ?? const <Object?>[])
          .cast<Map<String, Object?>>()
          .map(RouteInvocation.fromJson)
          .toList(growable: false),
      argumentAccesses:
          (json['argumentAccesses'] as List<Object?>? ?? const <Object?>[])
              .cast<Map<String, Object?>>()
              .map(RouteArgumentAccess.fromJson)
              .toList(growable: false),
    );
  }
}

@immutable
class NetworkClient {
  const NetworkClient({
    required this.clientName,
    required this.filePath,
    required this.lineStart,
    required this.hasRequestModifier,
    required this.hasAuthenticator,
    required this.hasDecoder,
    required this.publicMethods,
  });

  final String clientName;
  final String filePath;
  final int lineStart;
  final bool hasRequestModifier;
  final bool hasAuthenticator;
  final bool hasDecoder;
  final List<String> publicMethods;

  Map<String, Object?> toJson() => <String, Object?>{
    'clientName': clientName,
    'filePath': filePath,
    'lineStart': lineStart,
    'hasRequestModifier': hasRequestModifier,
    'hasAuthenticator': hasAuthenticator,
    'hasDecoder': hasDecoder,
    'publicMethods': publicMethods,
  };

  factory NetworkClient.fromJson(Map<String, Object?> json) {
    return NetworkClient(
      clientName: json['clientName']! as String,
      filePath: json['filePath']! as String,
      lineStart: json['lineStart']! as int,
      hasRequestModifier: json['hasRequestModifier']! as bool,
      hasAuthenticator: json['hasAuthenticator']! as bool,
      hasDecoder: json['hasDecoder']! as bool,
      publicMethods:
          (json['publicMethods'] as List<Object?>? ?? const <Object?>[])
              .cast<String>(),
    );
  }
}

@immutable
class NetworkInventory {
  const NetworkInventory({this.clients = const <NetworkClient>[]});

  final List<NetworkClient> clients;

  Map<String, Object?> toJson() => <String, Object?>{
    'clients': clients.map((item) => item.toJson()).toList(growable: false),
  };

  factory NetworkInventory.fromJson(Map<String, Object?> json) {
    return NetworkInventory(
      clients: (json['clients'] as List<Object?>? ?? const <Object?>[])
          .cast<Map<String, Object?>>()
          .map(NetworkClient.fromJson)
          .toList(growable: false),
    );
  }
}

@immutable
class ControllerComplexity {
  const ControllerComplexity({
    required this.controllerName,
    required this.filePath,
    required this.lineStart,
    required this.lineCount,
    required this.dependencyCount,
    required this.reactiveFieldCount,
    required this.lifecycleMethodCount,
    required this.navigationCallCount,
    required this.apiCallCount,
    required this.globalLookupCount,
    required this.uiHelperCallCount,
    required this.totalScore,
    required this.riskLevel,
    this.hotspots = const <String>[],
  });

  final String controllerName;
  final String filePath;
  final int lineStart;
  final int lineCount;
  final int dependencyCount;
  final int reactiveFieldCount;
  final int lifecycleMethodCount;
  final int navigationCallCount;
  final int apiCallCount;
  final int globalLookupCount;
  final int uiHelperCallCount;
  final int totalScore;
  final RiskLevel riskLevel;
  final List<String> hotspots;

  Map<String, Object?> toJson() => <String, Object?>{
    'controllerName': controllerName,
    'filePath': filePath,
    'lineStart': lineStart,
    'lineCount': lineCount,
    'dependencyCount': dependencyCount,
    'reactiveFieldCount': reactiveFieldCount,
    'lifecycleMethodCount': lifecycleMethodCount,
    'navigationCallCount': navigationCallCount,
    'apiCallCount': apiCallCount,
    'globalLookupCount': globalLookupCount,
    'uiHelperCallCount': uiHelperCallCount,
    'totalScore': totalScore,
    'riskLevel': riskLevel.wireName,
    'hotspots': hotspots,
  };

  factory ControllerComplexity.fromJson(Map<String, Object?> json) {
    return ControllerComplexity(
      controllerName: json['controllerName']! as String,
      filePath: json['filePath']! as String,
      lineStart: json['lineStart']! as int,
      lineCount: json['lineCount']! as int,
      dependencyCount: json['dependencyCount']! as int,
      reactiveFieldCount: json['reactiveFieldCount']! as int,
      lifecycleMethodCount: json['lifecycleMethodCount']! as int,
      navigationCallCount: json['navigationCallCount']! as int,
      apiCallCount: json['apiCallCount']! as int,
      globalLookupCount: json['globalLookupCount']! as int,
      uiHelperCallCount: json['uiHelperCallCount']! as int,
      totalScore: json['totalScore']! as int,
      riskLevel: RiskLevel.fromWireName(json['riskLevel']! as String),
      hotspots: (json['hotspots'] as List<Object?>? ?? const <Object?>[])
          .cast<String>(),
    );
  }
}

@immutable
class ControllerInventory {
  const ControllerInventory({
    this.controllers = const <ControllerComplexity>[],
  });

  final List<ControllerComplexity> controllers;

  Map<String, Object?> toJson() => <String, Object?>{
    'controllers': controllers
        .map((item) => item.toJson())
        .toList(growable: false),
  };

  factory ControllerInventory.fromJson(Map<String, Object?> json) {
    return ControllerInventory(
      controllers: (json['controllers'] as List<Object?>? ?? const <Object?>[])
          .cast<Map<String, Object?>>()
          .map(ControllerComplexity.fromJson)
          .toList(growable: false),
    );
  }
}

@immutable
class FindingDrillDown {
  const FindingDrillDown({
    required this.findingId,
    required this.whyRisky,
    required this.nextAction,
    this.relatedSteps = const <String>[],
    this.evidence = const <String>[],
  });

  final String findingId;
  final String whyRisky;
  final String nextAction;
  final List<String> relatedSteps;
  final List<String> evidence;

  Map<String, Object?> toJson() => <String, Object?>{
    'findingId': findingId,
    'whyRisky': whyRisky,
    'nextAction': nextAction,
    'relatedSteps': relatedSteps,
    'evidence': evidence,
  };

  factory FindingDrillDown.fromJson(Map<String, Object?> json) {
    return FindingDrillDown(
      findingId: json['findingId']! as String,
      whyRisky: json['whyRisky']! as String,
      nextAction: json['nextAction']! as String,
      relatedSteps:
          (json['relatedSteps'] as List<Object?>? ?? const <Object?>[])
              .cast<String>(),
      evidence: (json['evidence'] as List<Object?>? ?? const <Object?>[])
          .cast<String>(),
    );
  }
}

@immutable
class ProjectInventory {
  const ProjectInventory({
    required this.project,
    required this.summary,
    required this.riskSummary,
    required this.findings,
    required this.recommendedOrder,
    this.routeInventory = const RouteInventory(),
    this.networkInventory = const NetworkInventory(),
    this.controllerInventory = const ControllerInventory(),
  });

  final ProjectMetadata project;
  final SummaryStats summary;
  final RiskSummary riskSummary;
  final List<Finding> findings;
  final List<RecommendedStep> recommendedOrder;
  final RouteInventory routeInventory;
  final NetworkInventory networkInventory;
  final ControllerInventory controllerInventory;

  Map<String, List<Finding>> get categoryGroups => <String, List<Finding>>{
    for (final category in FindingCategory.values)
      category.wireName: findings
          .where((item) => item.category == category)
          .toList(),
  };

  List<FindingDrillDown> get findingDrillDowns => findings
      .map((finding) => _buildFindingDrillDown(this, finding))
      .toList(growable: false);

  Map<String, Object?> toJson({
    bool includeSchemaVersion = true,
  }) => <String, Object?>{
    if (includeSchemaVersion) 'schemaVersion': kProjectInventorySchemaVersion,
    'project': project.toJson(),
    'summary': summary.toJson(),
    'riskSummary': riskSummary.toJson(),
    'categories': categoryGroups.map(
      (key, value) => MapEntry(
        key,
        value.map((finding) => finding.toJson()).toList(growable: false),
      ),
    ),
    'routeInventory': routeInventory.toJson(),
    'networkInventory': networkInventory.toJson(),
    'controllerInventory': controllerInventory.toJson(),
    'findingDrillDowns': findingDrillDowns
        .map((item) => item.toJson())
        .toList(growable: false),
    'recommendedOrder': recommendedOrder
        .map((step) => step.toJson())
        .toList(growable: false),
    'findings': findings
        .map((finding) => finding.toJson())
        .toList(growable: false),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory ProjectInventory.fromJson(Map<String, Object?> json) {
    _assertSupportedSchemaVersion(
      json['schemaVersion'],
      currentVersion: kProjectInventorySchemaVersion,
      shapeName: 'ProjectInventory',
    );
    return ProjectInventory(
      project: ProjectMetadata.fromJson(
        json['project']! as Map<String, Object?>,
      ),
      summary: SummaryStats.fromJson(json['summary']! as Map<String, Object?>),
      riskSummary: RiskSummary.fromJson(
        json['riskSummary']! as Map<String, Object?>,
      ),
      routeInventory: RouteInventory.fromJson(
        json['routeInventory'] as Map<String, Object?>? ??
            const <String, Object?>{},
      ),
      networkInventory: NetworkInventory.fromJson(
        json['networkInventory'] as Map<String, Object?>? ??
            const <String, Object?>{},
      ),
      controllerInventory: ControllerInventory.fromJson(
        json['controllerInventory'] as Map<String, Object?>? ??
            const <String, Object?>{},
      ),
      findings: (json['findings']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Finding.fromJson)
          .toList(growable: false),
      recommendedOrder: (json['recommendedOrder']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(RecommendedStep.fromJson)
          .toList(growable: false),
    );
  }
}

FindingDrillDown _buildFindingDrillDown(
  ProjectInventory inventory,
  Finding finding,
) {
  final relatedSteps = inventory.recommendedOrder
      .where((step) => step.relatedFindingIds.contains(finding.id))
      .map((step) => step.title)
      .toList(growable: false);
  final evidence = _buildFindingEvidence(inventory, finding);

  return FindingDrillDown(
    findingId: finding.id,
    whyRisky: _buildFindingRiskNarrative(finding, evidence),
    nextAction: _buildFindingNextAction(finding),
    relatedSteps: relatedSteps,
    evidence: evidence,
  );
}

String _buildFindingRiskNarrative(Finding finding, List<String> evidence) {
  final categoryContext = switch (finding.category) {
    FindingCategory.routing =>
      'Routing findings can block route-by-route migration because route names, bindings, middleware, and arguments become app-wide coupling points.',
    FindingCategory.network =>
      'Network findings are high leverage because auth, decoder, and request behavior can affect every feature using the client.',
    FindingCategory.di =>
      'DI findings hide construction and lifetime boundaries, which makes safe sequencing harder.',
    FindingCategory.uiHelper =>
      'UI helper findings couple view effects to global GetX context and navigation state.',
    FindingCategory.state
        when finding.subcategory == 'getxController' ||
            finding.subcategory == 'lifecycle' =>
      'Controller and lifecycle findings usually mean state ownership, side effects, and navigation are mixed together.',
    FindingCategory.state =>
      'Reactive state findings need ownership mapping before they can be safely rewritten.',
  };
  final evidenceContext = evidence.isEmpty
      ? ''
      : ' Evidence: ${evidence.first}.';
  return '${finding.description} $categoryContext$evidenceContext';
}

String _buildFindingNextAction(Finding finding) {
  return switch (finding.category) {
    FindingCategory.routing =>
      'Map the route registry, bindings, middleware, and argument usage before widget rewrites.',
    FindingCategory.network =>
      'Extract the network boundary first and preserve request modifier, authenticator, and decoder behavior.',
    FindingCategory.di =>
      'Replace implicit GetX registrations and lookups with explicit provider wiring.',
    FindingCategory.uiHelper =>
      'Move GetX-driven UI side effects behind a presentation or effect boundary.',
    FindingCategory.state
        when finding.subcategory == 'getxController' ||
            finding.subcategory == 'lifecycle' =>
      'Split controller responsibilities and lifecycle work before converting state primitives.',
    FindingCategory.state => finding.migrationHint,
  };
}

List<String> _buildFindingEvidence(
  ProjectInventory inventory,
  Finding finding,
) {
  final evidence = <String>[];

  final routeDeclarations = inventory.routeInventory.declarations
      .where((item) => item.filePath == finding.filePath)
      .toList(growable: false);
  if (routeDeclarations.isNotEmpty) {
    evidence.add(
      'route declarations: ${routeDeclarations.map((item) => item.routeName).join(', ')}',
    );
  }

  final routeInvocations = inventory.routeInventory.invocations
      .where((item) => item.filePath == finding.filePath)
      .toList(growable: false);
  if (routeInvocations.isNotEmpty) {
    evidence.add(
      'route invocations: ${routeInvocations.map((item) => '${item.methodName}(${item.routeName})').join(', ')}',
    );
  }

  final routeArguments = inventory.routeInventory.argumentAccesses
      .where((item) => item.filePath == finding.filePath)
      .length;
  if (routeArguments > 0) {
    evidence.add('Get.arguments accesses in file: $routeArguments');
  }

  final networkClients = inventory.networkInventory.clients
      .where((item) => item.filePath == finding.filePath)
      .toList(growable: false);
  for (final client in networkClients) {
    final hooks = <String>[
      if (client.hasRequestModifier) 'request modifier',
      if (client.hasAuthenticator) 'authenticator',
      if (client.hasDecoder) 'decoder',
    ];
    evidence.add(
      '${client.clientName} uses ${hooks.isEmpty ? 'no custom hooks' : hooks.join(', ')}',
    );
  }

  final controllers = inventory.controllerInventory.controllers
      .where((item) => item.filePath == finding.filePath)
      .toList(growable: false);
  for (final controller in controllers) {
    evidence.add(
      '${controller.controllerName} score ${controller.totalScore} (${controller.riskLevel.wireName}), hotspots: ${controller.hotspots.join(', ')}',
    );
  }

  if (evidence.isEmpty) {
    evidence.add('source: ${finding.filePath}:${finding.lineStart}');
  }

  return evidence;
}

@immutable
class AuditConfig {
  const AuditConfig({
    required this.projectPath,
    required this.outPath,
    this.includeTest = false,
    this.ignoreGlobs = const <String>[],
    this.dryRun = false,
    this.flutterVersion,
    this.dartVersion,
  });

  final String projectPath;
  final String outPath;
  final bool includeTest;
  final List<String> ignoreGlobs;
  final bool dryRun;
  final String? flutterVersion;
  final String? dartVersion;
}

@immutable
class AuditResult {
  const AuditResult({required this.inventory, required this.parseFailures});

  final ProjectInventory inventory;
  final List<ParseFailure> parseFailures;

  bool get hasRecoverableIssues => parseFailures.isNotEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': kAuditResultSchemaVersion,
    'inventory': inventory.toJson(includeSchemaVersion: false),
    'parseFailures': parseFailures
        .map((failure) => failure.toJson())
        .toList(growable: false),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory AuditResult.fromJson(Map<String, Object?> json) {
    _assertSupportedSchemaVersion(
      json['schemaVersion'],
      currentVersion: kAuditResultSchemaVersion,
      shapeName: 'AuditResult',
    );
    return AuditResult(
      inventory: ProjectInventory.fromJson(
        json['inventory']! as Map<String, Object?>,
      ),
      parseFailures: (json['parseFailures']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(ParseFailure.fromJson)
          .toList(growable: false),
    );
  }
}

void _assertSupportedSchemaVersion(
  Object? rawValue, {
  required int currentVersion,
  required String shapeName,
}) {
  if (rawValue == null) {
    return;
  }

  final parsedVersion = switch (rawValue) {
    int value => value,
    String value => int.tryParse(value),
    _ => null,
  };

  if (parsedVersion == currentVersion) {
    return;
  }

  throw ArgumentError.value(
    rawValue,
    'schemaVersion',
    'Unsupported $shapeName schema version.',
  );
}
