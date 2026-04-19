import 'dart:convert';

import 'package:meta/meta.dart';

const int kProjectInventorySchemaVersion = 1;
const int kAuditResultSchemaVersion = 1;
const int kCommandSummarySchemaVersion = 1;

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

enum HotspotKind {
  file,
  controller,
  routeModule,
  category,
  subcategory;

  String get wireName => switch (this) {
    HotspotKind.file => 'file',
    HotspotKind.controller => 'controller',
    HotspotKind.routeModule => 'routeModule',
    HotspotKind.category => 'category',
    HotspotKind.subcategory => 'subcategory',
  };

  static HotspotKind fromWireName(String value) => switch (value) {
    'file' => HotspotKind.file,
    'controller' => HotspotKind.controller,
    'routeModule' => HotspotKind.routeModule,
    'category' => HotspotKind.category,
    'subcategory' => HotspotKind.subcategory,
    _ => throw ArgumentError.value(value, 'value', 'Unknown hotspot kind'),
  };
}

@immutable
class HotspotEntry {
  const HotspotEntry({
    required this.kind,
    required this.label,
    this.filePath,
    required this.score,
    required this.riskLevel,
    this.reasons = const <String>[],
  });

  final HotspotKind kind;
  final String label;
  final String? filePath;
  final int score;
  final RiskLevel riskLevel;
  final List<String> reasons;

  Map<String, Object?> toJson() => <String, Object?>{
    'kind': kind.wireName,
    'label': label,
    'filePath': filePath,
    'score': score,
    'riskLevel': riskLevel.wireName,
    'reasons': reasons,
  };

  factory HotspotEntry.fromJson(Map<String, Object?> json) {
    return HotspotEntry(
      kind: HotspotKind.fromWireName(json['kind']! as String),
      label: json['label']! as String,
      filePath: json['filePath'] as String?,
      score: json['score']! as int,
      riskLevel: RiskLevel.fromWireName(json['riskLevel']! as String),
      reasons: (json['reasons'] as List<Object?>? ?? const <Object?>[])
          .cast<String>(),
    );
  }
}

@immutable
class HotspotInventory {
  const HotspotInventory({
    this.topOverall = const <HotspotEntry>[],
    this.topFiles = const <HotspotEntry>[],
    this.topControllers = const <HotspotEntry>[],
    this.topRouteModules = const <HotspotEntry>[],
    this.topCategories = const <HotspotEntry>[],
    this.topSubcategories = const <HotspotEntry>[],
  });

  final List<HotspotEntry> topOverall;
  final List<HotspotEntry> topFiles;
  final List<HotspotEntry> topControllers;
  final List<HotspotEntry> topRouteModules;
  final List<HotspotEntry> topCategories;
  final List<HotspotEntry> topSubcategories;

  Map<String, Object?> toJson() => <String, Object?>{
    'topOverall': topOverall
        .map((item) => item.toJson())
        .toList(growable: false),
    'topFiles': topFiles.map((item) => item.toJson()).toList(growable: false),
    'topControllers': topControllers
        .map((item) => item.toJson())
        .toList(growable: false),
    'topRouteModules': topRouteModules
        .map((item) => item.toJson())
        .toList(growable: false),
    'topCategories': topCategories
        .map((item) => item.toJson())
        .toList(growable: false),
    'topSubcategories': topSubcategories
        .map((item) => item.toJson())
        .toList(growable: false),
  };

  factory HotspotInventory.fromJson(Map<String, Object?> json) {
    List<HotspotEntry> decodeList(String key) {
      return (json[key] as List<Object?>? ?? const <Object?>[])
          .cast<Map<String, Object?>>()
          .map(HotspotEntry.fromJson)
          .toList(growable: false);
    }

    return HotspotInventory(
      topOverall: decodeList('topOverall'),
      topFiles: decodeList('topFiles'),
      topControllers: decodeList('topControllers'),
      topRouteModules: decodeList('topRouteModules'),
      topCategories: decodeList('topCategories'),
      topSubcategories: decodeList('topSubcategories'),
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

  HotspotInventory get hotspotInventory => _buildHotspotInventory(this);

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
    'hotspotInventory': hotspotInventory.toJson(),
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

@immutable
class PlanningCounts {
  const PlanningCounts({
    required this.routeDeclarations,
    required this.routeInvocations,
    required this.routeArgumentAccesses,
    required this.networkClients,
    required this.controllers,
    required this.explainableFindings,
    required this.recommendedSteps,
  });

  final int routeDeclarations;
  final int routeInvocations;
  final int routeArgumentAccesses;
  final int networkClients;
  final int controllers;
  final int explainableFindings;
  final int recommendedSteps;

  Map<String, Object?> toJson() => <String, Object?>{
    'routeDeclarations': routeDeclarations,
    'routeInvocations': routeInvocations,
    'routeArgumentAccesses': routeArgumentAccesses,
    'networkClients': networkClients,
    'controllers': controllers,
    'explainableFindings': explainableFindings,
    'recommendedSteps': recommendedSteps,
  };

  factory PlanningCounts.fromJson(Map<String, Object?> json) {
    return PlanningCounts(
      routeDeclarations: json['routeDeclarations']! as int,
      routeInvocations: json['routeInvocations']! as int,
      routeArgumentAccesses: json['routeArgumentAccesses']! as int,
      networkClients: json['networkClients']! as int,
      controllers: json['controllers']! as int,
      explainableFindings: json['explainableFindings']! as int,
      recommendedSteps: json['recommendedSteps']! as int,
    );
  }
}

@immutable
class CommandSummary {
  const CommandSummary({
    required this.command,
    required this.project,
    required this.status,
    required this.exitCode,
    required this.summary,
    required this.riskSummary,
    required this.categoryCounts,
    required this.planningCounts,
    this.topHotspots = const <HotspotEntry>[],
  });

  final String command;
  final ProjectMetadata project;
  final String status;
  final int exitCode;
  final SummaryStats summary;
  final RiskSummary riskSummary;
  final Map<String, int> categoryCounts;
  final PlanningCounts planningCounts;
  final List<HotspotEntry> topHotspots;

  factory CommandSummary.fromAuditResult(
    AuditResult result, {
    required String command,
    required int exitCode,
  }) {
    final inventory = result.inventory;
    return CommandSummary(
      command: command,
      project: inventory.project,
      status: result.hasRecoverableIssues ? 'partial' : 'success',
      exitCode: exitCode,
      summary: inventory.summary,
      riskSummary: inventory.riskSummary,
      categoryCounts: <String, int>{
        for (final category in FindingCategory.values)
          category.wireName:
              inventory.categoryGroups[category.wireName]?.length ?? 0,
      },
      planningCounts: PlanningCounts(
        routeDeclarations: inventory.routeInventory.declarations.length,
        routeInvocations: inventory.routeInventory.invocations.length,
        routeArgumentAccesses: inventory.routeInventory.argumentAccesses.length,
        networkClients: inventory.networkInventory.clients.length,
        controllers: inventory.controllerInventory.controllers.length,
        explainableFindings: inventory.findingDrillDowns.length,
        recommendedSteps: inventory.recommendedOrder.length,
      ),
      topHotspots: inventory.hotspotInventory.topOverall,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': kCommandSummarySchemaVersion,
    'command': command,
    'project': project.toJson(),
    'status': status,
    'exitCode': exitCode,
    'summary': summary.toJson(),
    'riskSummary': riskSummary.toJson(),
    'categoryCounts': categoryCounts,
    'planningCounts': planningCounts.toJson(),
    'topHotspots': topHotspots
        .map((item) => item.toJson())
        .toList(growable: false),
  };

  factory CommandSummary.fromJson(Map<String, Object?> json) {
    _assertSupportedSchemaVersion(
      json['schemaVersion'],
      currentVersion: kCommandSummarySchemaVersion,
      shapeName: 'CommandSummary',
    );
    return CommandSummary(
      command: json['command']! as String,
      project: ProjectMetadata.fromJson(
        json['project']! as Map<String, Object?>,
      ),
      status: json['status']! as String,
      exitCode: json['exitCode']! as int,
      summary: SummaryStats.fromJson(json['summary']! as Map<String, Object?>),
      riskSummary: RiskSummary.fromJson(
        json['riskSummary']! as Map<String, Object?>,
      ),
      categoryCounts: (json['categoryCounts']! as Map<String, Object?>).map(
        (key, value) => MapEntry(key, value! as int),
      ),
      planningCounts: PlanningCounts.fromJson(
        json['planningCounts']! as Map<String, Object?>,
      ),
      topHotspots: (json['topHotspots'] as List<Object?>? ?? const <Object?>[])
          .cast<Map<String, Object?>>()
          .map(HotspotEntry.fromJson)
          .toList(growable: false),
    );
  }

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

HotspotInventory _buildHotspotInventory(ProjectInventory inventory) {
  final topFiles = _buildFileHotspots(inventory);
  final topControllers = _buildControllerHotspots(inventory);
  final topRouteModules = _buildRouteModuleHotspots(inventory);
  final topCategories = _buildCategoryHotspots(inventory);
  final topSubcategories = _buildSubcategoryHotspots(inventory);
  final topOverall = <HotspotEntry>[
    ...topFiles.take(3),
    ...topControllers.take(3),
    ...topRouteModules.take(3),
    ...topCategories.take(3),
    ...topSubcategories.take(3),
  ]..sort(_compareHotspotEntry);

  return HotspotInventory(
    topOverall: topOverall.take(5).toList(growable: false),
    topFiles: topFiles.take(5).toList(growable: false),
    topControllers: topControllers.take(5).toList(growable: false),
    topRouteModules: topRouteModules.take(5).toList(growable: false),
    topCategories: topCategories.take(5).toList(growable: false),
    topSubcategories: topSubcategories.take(5).toList(growable: false),
  );
}

List<HotspotEntry> _buildFileHotspots(ProjectInventory inventory) {
  final buckets = <String, _HotspotAccumulator>{};

  _HotspotAccumulator bucketFor(String filePath) =>
      buckets.putIfAbsent(filePath, _HotspotAccumulator.new);

  final findingCounts = <String, _RiskCounts>{};
  for (final finding in inventory.findings) {
    final bucket = bucketFor(finding.filePath);
    bucket.score += _riskWeight(finding.riskLevel);
    bucket.elevateRisk(finding.riskLevel);
    findingCounts
        .putIfAbsent(finding.filePath, _RiskCounts.new)
        .add(finding.riskLevel);
  }

  final controllerScores = <String, int>{};
  for (final controller in inventory.controllerInventory.controllers) {
    final bucket = bucketFor(controller.filePath);
    bucket.score += controller.totalScore;
    bucket.elevateRisk(controller.riskLevel);
    controllerScores.update(
      controller.filePath,
      (value) => value + controller.totalScore,
      ifAbsent: () => controller.totalScore,
    );
  }

  final routeContexts = <String, _RouteCounts>{};
  for (final declaration in inventory.routeInventory.declarations) {
    final bucket = bucketFor(declaration.filePath);
    final context = routeContexts.putIfAbsent(
      declaration.filePath,
      _RouteCounts.new,
    );
    context.declarations++;
    if (declaration.binding != null) {
      context.bindings++;
    }
    context.middlewares += declaration.middlewares.length;
    final routeScore =
        4 +
        (declaration.binding != null ? 2 : 0) +
        (declaration.middlewares.length * 2);
    bucket.score += routeScore;
    bucket.elevateRisk(_scoreToRiskLevel(routeScore));
  }
  for (final invocation in inventory.routeInventory.invocations) {
    final bucket = bucketFor(invocation.filePath);
    final context = routeContexts.putIfAbsent(
      invocation.filePath,
      _RouteCounts.new,
    );
    context.invocations++;
    if (invocation.passesArguments) {
      context.argumentPassingInvocations++;
    }
    final routeScore = 2 + (invocation.passesArguments ? 1 : 0);
    bucket.score += routeScore;
    bucket.elevateRisk(_scoreToRiskLevel(routeScore));
  }
  for (final access in inventory.routeInventory.argumentAccesses) {
    final bucket = bucketFor(access.filePath);
    final context = routeContexts.putIfAbsent(
      access.filePath,
      _RouteCounts.new,
    );
    context.argumentAccesses++;
    bucket.score += 2;
    bucket.elevateRisk(RiskLevel.medium);
  }

  final networkScores = <String, int>{};
  for (final client in inventory.networkInventory.clients) {
    final bucket = bucketFor(client.filePath);
    final hookCount =
        (client.hasRequestModifier ? 1 : 0) +
        (client.hasAuthenticator ? 1 : 0) +
        (client.hasDecoder ? 1 : 0);
    final networkScore = 5 + (hookCount * 2) + client.publicMethods.length;
    bucket.score += networkScore;
    bucket.elevateRisk(_scoreToRiskLevel(networkScore));
    networkScores.update(
      client.filePath,
      (value) => value + networkScore,
      ifAbsent: () => networkScore,
    );
  }

  final entries = <HotspotEntry>[];
  for (final entry in buckets.entries) {
    final filePath = entry.key;
    final bucket = entry.value;
    final reasons = <String>[];
    final counts = findingCounts[filePath];
    if (counts != null) {
      if (counts.high > 0) {
        reasons.add('${counts.high} high-risk findings');
      } else if (counts.medium > 0) {
        reasons.add('${counts.medium} medium-risk findings');
      } else if (counts.low > 0) {
        reasons.add('${counts.low} low-risk findings');
      }
    }
    final controllerScore = controllerScores[filePath];
    if (controllerScore != null && controllerScore > 0) {
      reasons.add('controller complexity $controllerScore');
    }
    final routeContext = routeContexts[filePath];
    if (routeContext != null && routeContext.total > 0) {
      reasons.add(
        'route coupling ${routeContext.declarations}/${routeContext.invocations}/${routeContext.argumentAccesses}',
      );
    }
    final networkScore = networkScores[filePath];
    if (networkScore != null && networkScore > 0) {
      reasons.add('network boundary $networkScore');
    }
    entries.add(
      HotspotEntry(
        kind: HotspotKind.file,
        label: filePath,
        filePath: filePath,
        score: bucket.score,
        riskLevel: bucket.riskLevel,
        reasons: reasons.take(3).toList(growable: false),
      ),
    );
  }

  entries.sort(_compareHotspotEntry);
  return entries;
}

List<HotspotEntry> _buildControllerHotspots(ProjectInventory inventory) {
  final entries =
      inventory.controllerInventory.controllers
          .map((controller) {
            final reasons = <String>[
              if (controller.dependencyCount > 0)
                'dependencies ${controller.dependencyCount}',
              if (controller.apiCallCount > 0)
                'api calls ${controller.apiCallCount}',
              if (controller.navigationCallCount > 0)
                'navigation calls ${controller.navigationCallCount}',
              if (controller.uiHelperCallCount > 0)
                'ui helpers ${controller.uiHelperCallCount}',
              if (controller.hotspots.isNotEmpty)
                'hotspots ${controller.hotspots.join(', ')}',
            ];
            return HotspotEntry(
              kind: HotspotKind.controller,
              label: controller.controllerName,
              filePath: controller.filePath,
              score: controller.totalScore,
              riskLevel: controller.riskLevel,
              reasons: reasons.take(3).toList(growable: false),
            );
          })
          .toList(growable: false)
        ..sort(_compareHotspotEntry);
  return entries;
}

List<HotspotEntry> _buildRouteModuleHotspots(ProjectInventory inventory) {
  final contexts = <String, _RouteCounts>{};

  for (final declaration in inventory.routeInventory.declarations) {
    final context = contexts.putIfAbsent(
      declaration.filePath,
      _RouteCounts.new,
    );
    context.declarations++;
    if (declaration.binding != null) {
      context.bindings++;
    }
    context.middlewares += declaration.middlewares.length;
  }
  for (final invocation in inventory.routeInventory.invocations) {
    final context = contexts.putIfAbsent(invocation.filePath, _RouteCounts.new);
    context.invocations++;
    if (invocation.passesArguments) {
      context.argumentPassingInvocations++;
    }
  }
  for (final access in inventory.routeInventory.argumentAccesses) {
    final context = contexts.putIfAbsent(access.filePath, _RouteCounts.new);
    context.argumentAccesses++;
  }

  final entries =
      contexts.entries
          .map((entry) {
            final filePath = entry.key;
            final context = entry.value;
            final score =
                (context.declarations * 4) +
                (context.bindings * 2) +
                (context.middlewares * 2) +
                (context.invocations * 2) +
                context.argumentPassingInvocations +
                (context.argumentAccesses * 2);
            final reasons = <String>[
              if (context.declarations > 0)
                'declarations ${context.declarations}',
              if (context.invocations > 0) 'invocations ${context.invocations}',
              if (context.argumentAccesses > 0)
                'argument accesses ${context.argumentAccesses}',
              if (context.middlewares > 0) 'middlewares ${context.middlewares}',
              if (context.bindings > 0) 'bindings ${context.bindings}',
            ];
            return HotspotEntry(
              kind: HotspotKind.routeModule,
              label: filePath,
              filePath: filePath,
              score: score,
              riskLevel: _scoreToRiskLevel(score),
              reasons: reasons.take(3).toList(growable: false),
            );
          })
          .where((entry) => entry.score > 0)
          .toList(growable: false)
        ..sort(_compareHotspotEntry);

  return entries;
}

List<HotspotEntry> _buildCategoryHotspots(ProjectInventory inventory) {
  final entries = <HotspotEntry>[];
  for (final category in FindingCategory.values) {
    final findings = inventory.categoryGroups[category.wireName] ?? const [];
    if (findings.isEmpty) {
      continue;
    }
    final counts = _RiskCounts();
    var score = 0;
    for (final finding in findings) {
      counts.add(finding.riskLevel);
      score += _riskWeight(finding.riskLevel);
    }
    final reasons = <String>[
      '${findings.length} findings',
      if (counts.high > 0) '${counts.high} high-risk',
      if (counts.medium > 0) '${counts.medium} medium-risk',
    ];
    entries.add(
      HotspotEntry(
        kind: HotspotKind.category,
        label: category.wireName,
        score: score,
        riskLevel: counts.maxRiskLevel,
        reasons: reasons.take(3).toList(growable: false),
      ),
    );
  }
  entries.sort(_compareHotspotEntry);
  return entries;
}

List<HotspotEntry> _buildSubcategoryHotspots(ProjectInventory inventory) {
  final groups = <String, List<Finding>>{};
  for (final finding in inventory.findings) {
    groups.putIfAbsent(finding.subcategory, () => <Finding>[]).add(finding);
  }

  final entries =
      groups.entries
          .map((entry) {
            final findings = entry.value;
            final counts = _RiskCounts();
            var score = 0;
            for (final finding in findings) {
              counts.add(finding.riskLevel);
              score += _riskWeight(finding.riskLevel);
            }
            final reasons = <String>[
              '${findings.length} findings',
              if (counts.high > 0) '${counts.high} high-risk',
              if (counts.medium > 0) '${counts.medium} medium-risk',
            ];
            return HotspotEntry(
              kind: HotspotKind.subcategory,
              label: entry.key,
              score: score,
              riskLevel: counts.maxRiskLevel,
              reasons: reasons.take(3).toList(growable: false),
            );
          })
          .toList(growable: false)
        ..sort(_compareHotspotEntry);

  return entries;
}

int _compareHotspotEntry(HotspotEntry left, HotspotEntry right) {
  final scoreCompare = right.score.compareTo(left.score);
  if (scoreCompare != 0) {
    return scoreCompare;
  }
  final riskCompare = _riskPriority(
    right.riskLevel,
  ).compareTo(_riskPriority(left.riskLevel));
  if (riskCompare != 0) {
    return riskCompare;
  }
  final kindCompare = left.kind.wireName.compareTo(right.kind.wireName);
  if (kindCompare != 0) {
    return kindCompare;
  }
  return left.label.compareTo(right.label);
}

int _riskWeight(RiskLevel riskLevel) => switch (riskLevel) {
  RiskLevel.low => 1,
  RiskLevel.medium => 3,
  RiskLevel.high => 5,
};

int _riskPriority(RiskLevel riskLevel) => switch (riskLevel) {
  RiskLevel.low => 1,
  RiskLevel.medium => 2,
  RiskLevel.high => 3,
};

RiskLevel _scoreToRiskLevel(int score) {
  if (score >= 10) {
    return RiskLevel.high;
  }
  if (score >= 4) {
    return RiskLevel.medium;
  }
  return RiskLevel.low;
}

class _HotspotAccumulator {
  _HotspotAccumulator();

  int score = 0;
  RiskLevel riskLevel = RiskLevel.low;

  void elevateRisk(RiskLevel nextRisk) {
    if (_riskPriority(nextRisk) > _riskPriority(riskLevel)) {
      riskLevel = nextRisk;
    }
  }
}

class _RiskCounts {
  int low = 0;
  int medium = 0;
  int high = 0;

  void add(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        low++;
      case RiskLevel.medium:
        medium++;
      case RiskLevel.high:
        high++;
    }
  }

  RiskLevel get maxRiskLevel {
    if (high > 0) {
      return RiskLevel.high;
    }
    if (medium > 0) {
      return RiskLevel.medium;
    }
    return RiskLevel.low;
  }
}

class _RouteCounts {
  int declarations = 0;
  int bindings = 0;
  int middlewares = 0;
  int invocations = 0;
  int argumentPassingInvocations = 0;
  int argumentAccesses = 0;

  int get total =>
      declarations +
      bindings +
      middlewares +
      invocations +
      argumentPassingInvocations +
      argumentAccesses;
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
