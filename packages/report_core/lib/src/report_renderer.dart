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
      ..writeln('## Route Inventory')
      ..writeln(
        '- declarations: ${inventory.routeInventory.declarations.length}',
      )
      ..writeln('- invocations: ${inventory.routeInventory.invocations.length}')
      ..writeln(
        '- argument accesses: ${inventory.routeInventory.argumentAccesses.length}',
      );
    if (inventory.routeInventory.declarations.isEmpty) {
      buffer.writeln('- no route declarations');
    } else {
      for (final declaration in inventory.routeInventory.declarations.take(5)) {
        buffer.writeln(
          '- `${declaration.routeName}` -> `${declaration.pageBuilder}` at ${declaration.filePath}:${declaration.lineStart}',
        );
      }
    }
    if (inventory.routeInventory.invocations.isEmpty) {
      buffer.writeln('- no route invocations');
    } else {
      for (final invocation in inventory.routeInventory.invocations.take(5)) {
        buffer.writeln(
          '- `${invocation.methodName}` `${invocation.routeName}` at ${invocation.filePath}:${invocation.lineStart}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Network Inventory')
      ..writeln('- clients: ${inventory.networkInventory.clients.length}');
    if (inventory.networkInventory.clients.isEmpty) {
      buffer.writeln('- no GetConnect clients');
    } else {
      for (final client in inventory.networkInventory.clients.take(5)) {
        buffer.writeln(
          '- `${client.clientName}` methods=${client.publicMethods.join(', ')} auth=${client.hasAuthenticator} modifier=${client.hasRequestModifier} decoder=${client.hasDecoder}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Controller Inventory')
      ..writeln(
        '- controllers: ${inventory.controllerInventory.controllers.length}',
      );
    if (inventory.controllerInventory.controllers.isEmpty) {
      buffer.writeln('- no controller complexity entries');
    } else {
      for (final controller in inventory.controllerInventory.controllers.take(
        5,
      )) {
        buffer.writeln(
          '- `${controller.controllerName}` score=${controller.totalScore} risk=${controller.riskLevel.wireName} deps=${controller.dependencyCount} api=${controller.apiCallCount} nav=${controller.navigationCallCount} ui=${controller.uiHelperCallCount}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('## Explainable Findings');
    if (inventory.findingDrillDowns.isEmpty) {
      buffer.writeln('- no explainable findings');
    } else {
      for (final drillDown in inventory.findingDrillDowns) {
        buffer
          ..writeln('### ${drillDown.findingId}')
          ..writeln('- why risky: ${drillDown.whyRisky}')
          ..writeln('- next action: ${drillDown.nextAction}');
        if (drillDown.relatedSteps.isEmpty) {
          buffer.writeln('- related steps: none');
        } else {
          buffer.writeln(
            '- related steps: ${drillDown.relatedSteps.join(', ')}',
          );
        }
        for (final evidence in drillDown.evidence) {
          buffer.writeln('- evidence: $evidence');
        }
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
