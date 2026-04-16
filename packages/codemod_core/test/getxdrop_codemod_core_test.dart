import 'package:getxdrop_codemod_core/getxdrop_codemod_core.dart';
import 'package:test/test.dart';

void main() {
  test('placeholder codemod plan types are available', () {
    const plan = EditPlan(
      candidates: <RewriteCandidate>[
        RewriteCandidate(
          filePath: 'lib/example.dart',
          description: 'Placeholder rewrite candidate',
          safetyLevel: 'low',
          patchPreview: '--- preview ---',
          requiresManualReview: false,
        ),
      ],
    );

    expect(plan.candidates, hasLength(1));
  });
}
