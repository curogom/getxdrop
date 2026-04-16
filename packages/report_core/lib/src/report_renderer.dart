import 'package:getxdrop_analyzer_core/getxdrop_analyzer_core.dart';

class ReportRenderer {
  const ReportRenderer();

  String renderMarkdown(
    ProjectInventory inventory, {
    List<ParseFailure> parseFailures = const <ParseFailure>[],
  }) {
    final buffer = StringBuffer()
      ..writeln('# GetXDrop Migration Report')
      ..writeln()
      ..writeln('## Summary')
      ..writeln('- project root: `${inventory.project.rootPath}`')
      ..writeln(
        '- generated at: `${inventory.project.generatedAt.toUtc().toIso8601String()}`',
      )
      ..writeln('- total dart files: ${inventory.summary.totalDartFiles}')
      ..writeln('- analyzed files: ${inventory.summary.analyzedFiles}')
      ..writeln('- parse failures: ${inventory.summary.parseFailures}')
      ..writeln('- findings: ${inventory.summary.totalFindings}')
      ..writeln()
      ..writeln('## Risk Summary')
      ..writeln('- low: ${inventory.riskSummary.low}')
      ..writeln('- medium: ${inventory.riskSummary.medium}')
      ..writeln('- high: ${inventory.riskSummary.high}')
      ..writeln()
      ..writeln('## Categories');

    for (final category in FindingCategory.values) {
      final findings =
          inventory.categoryGroups[category.wireName] ?? const <Finding>[];
      buffer
        ..writeln('### ${_categoryLabel(category)}')
        ..writeln('- count: ${findings.length}');
      for (final finding in findings.take(5)) {
        buffer.writeln(
          '- `${finding.id}` ${finding.subcategory} · ${finding.filePath}:${finding.lineStart}',
        );
      }
      if (findings.isEmpty) {
        buffer.writeln('- no findings');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Recommended Order');
    if (inventory.recommendedOrder.isEmpty) {
      buffer.writeln('1. No recommended steps were generated.');
    } else {
      for (var index = 0; index < inventory.recommendedOrder.length; index++) {
        final step = inventory.recommendedOrder[index];
        buffer.writeln('${index + 1}. ${step.title} — ${step.reason}');
      }
    }

    if (parseFailures.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Parse Failures');
      for (final failure in parseFailures) {
        buffer.writeln('- `${failure.filePath}`: ${failure.message}');
      }
    }

    buffer
      ..writeln()
      ..writeln('## Findings');
    for (final finding in inventory.findings) {
      buffer
        ..writeln('### Finding ${finding.id}')
        ..writeln('- category: ${finding.category.wireName}')
        ..writeln('- subcategory: ${finding.subcategory}')
        ..writeln(
          '- file: `${finding.filePath}:${finding.lineStart}-${finding.lineEnd}`',
        )
        ..writeln('- risk: ${finding.riskLevel.wireName}')
        ..writeln('- confidence: ${finding.confidence.wireName}')
        ..writeln('- recommended target: ${finding.recommendedTarget}')
        ..writeln('- requires manual review: ${finding.requiresManualReview}')
        ..writeln('- description: ${finding.description}')
        ..writeln('- migration hint: ${finding.migrationHint}')
        ..writeln('- snippet: `${finding.snippet}`')
        ..writeln();
    }

    return buffer.toString().trimRight();
  }

  String renderJson(ProjectInventory inventory) => inventory.toPrettyJson();

  String _categoryLabel(FindingCategory category) => switch (category) {
    FindingCategory.state => 'State',
    FindingCategory.di => 'DI',
    FindingCategory.routing => 'Routing',
    FindingCategory.uiHelper => 'UI Helper',
    FindingCategory.network => 'Network',
  };
}
