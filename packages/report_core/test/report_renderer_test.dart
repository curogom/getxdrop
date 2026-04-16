import 'package:getxdrop_analyzer_core/getxdrop_analyzer_core.dart';
import 'package:getxdrop_report_core/getxdrop_report_core.dart';
import 'package:test/test.dart';

void main() {
  group('ReportRenderer', () {
    final inventory = ProjectInventory(
      project: ProjectMetadata(
        rootPath: '/repo/sample',
        generatedAt: DateTime.utc(2026, 4, 16, 0, 0),
        flutterVersion: '3.41.6',
        dartVersion: '3.11.4',
      ),
      summary: const SummaryStats(
        totalDartFiles: 3,
        analyzedFiles: 2,
        parseFailures: 1,
        totalFindings: 2,
      ),
      riskSummary: const RiskSummary(low: 1, medium: 0, high: 1),
      findings: const <Finding>[
        Finding(
          id: 'GXD-STATE-001',
          category: FindingCategory.state,
          subcategory: 'obs',
          filePath: 'lib/a.dart',
          lineStart: 4,
          lineEnd: 4,
          snippet: 'final count = 0.obs;',
          riskLevel: RiskLevel.low,
          confidence: ConfidenceLevel.high,
          description: 'Reactive `.obs` wrapper detected.',
          migrationHint: 'Map this to provider state.',
          recommendedTarget: 'riverpod_notifier',
          requiresManualReview: false,
        ),
        Finding(
          id: 'GXD-NET-001',
          category: FindingCategory.network,
          subcategory: 'getConnect',
          filePath: 'lib/api.dart',
          lineStart: 8,
          lineEnd: 8,
          snippet: 'class Api extends GetConnect {}',
          riskLevel: RiskLevel.high,
          confidence: ConfidenceLevel.high,
          description: '`GetConnect` client detected.',
          migrationHint: 'Inventory network behavior first.',
          recommendedTarget: 'dio_client_repository',
          requiresManualReview: true,
        ),
      ],
      recommendedOrder: const <RecommendedStep>[
        RecommendedStep(
          title: 'Network abstraction migration',
          reason: 'GetConnect usage hides auth and decoder behavior.',
          relatedFindingIds: <String>['GXD-NET-001'],
        ),
      ],
    );

    const renderer = ReportRenderer();

    test('renders markdown snapshot with parse failures', () {
      final markdown = renderer.renderMarkdown(
        inventory,
        parseFailures: const <ParseFailure>[
          ParseFailure(
            filePath: 'lib/broken.dart',
            message: 'Expected to find ;',
          ),
        ],
      );

      expect(markdown, startsWith('# GetXDrop Migration Report'));
      expect(markdown, contains('## Summary'));
      expect(markdown, contains('### State'));
      expect(markdown, contains('### Network'));
      expect(markdown, contains('## Parse Failures'));
      expect(markdown, contains('### Finding GXD-STATE-001'));
      expect(markdown, contains('### Finding GXD-NET-001'));
    });

    test('renders json snapshot from inventory', () {
      final json = renderer.renderJson(inventory);

      expect(json, contains('"rootPath": "/repo/sample"'));
      expect(json, contains('"totalDartFiles": 3'));
      expect(json, contains('"riskLevel": "high"'));
      expect(json, contains('"recommendedOrder"'));
    });
  });
}
