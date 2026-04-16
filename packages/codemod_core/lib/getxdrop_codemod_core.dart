library;

import 'package:meta/meta.dart';

@immutable
class RewriteCandidate {
  const RewriteCandidate({
    required this.filePath,
    required this.description,
    required this.safetyLevel,
    required this.patchPreview,
    required this.requiresManualReview,
  });

  final String filePath;
  final String description;
  final String safetyLevel;
  final String patchPreview;
  final bool requiresManualReview;
}

@immutable
class EditPlan {
  const EditPlan({required this.candidates, this.notes = const <String>[]});

  final List<RewriteCandidate> candidates;
  final List<String> notes;
}
