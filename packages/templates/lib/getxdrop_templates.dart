library;

import 'package:meta/meta.dart';

@immutable
class ScaffoldGenerationInput {
  const ScaffoldGenerationInput({
    required this.projectRoot,
    required this.featureModules,
    this.notes = const <String>[],
  });

  final String projectRoot;
  final List<String> featureModules;
  final List<String> notes;
}
