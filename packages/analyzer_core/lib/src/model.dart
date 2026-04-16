import 'dart:convert';

import 'package:meta/meta.dart';

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
class ProjectInventory {
  const ProjectInventory({
    required this.project,
    required this.summary,
    required this.riskSummary,
    required this.findings,
    required this.recommendedOrder,
  });

  final ProjectMetadata project;
  final SummaryStats summary;
  final RiskSummary riskSummary;
  final List<Finding> findings;
  final List<RecommendedStep> recommendedOrder;

  Map<String, List<Finding>> get categoryGroups => <String, List<Finding>>{
    for (final category in FindingCategory.values)
      category.wireName: findings
          .where((item) => item.category == category)
          .toList(),
  };

  Map<String, Object?> toJson() => <String, Object?>{
    'project': project.toJson(),
    'summary': summary.toJson(),
    'riskSummary': riskSummary.toJson(),
    'categories': categoryGroups.map(
      (key, value) => MapEntry(
        key,
        value.map((finding) => finding.toJson()).toList(growable: false),
      ),
    ),
    'recommendedOrder': recommendedOrder
        .map((step) => step.toJson())
        .toList(growable: false),
    'findings': findings
        .map((finding) => finding.toJson())
        .toList(growable: false),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory ProjectInventory.fromJson(Map<String, Object?> json) {
    return ProjectInventory(
      project: ProjectMetadata.fromJson(
        json['project']! as Map<String, Object?>,
      ),
      summary: SummaryStats.fromJson(json['summary']! as Map<String, Object?>),
      riskSummary: RiskSummary.fromJson(
        json['riskSummary']! as Map<String, Object?>,
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
    'inventory': inventory.toJson(),
    'parseFailures': parseFailures
        .map((failure) => failure.toJson())
        .toList(growable: false),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory AuditResult.fromJson(Map<String, Object?> json) {
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
