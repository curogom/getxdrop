import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('getxdrop CLI', () {
    late Directory tempDir;
    late String packageDir;
    late String repoRoot;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('getxdrop_cli_test_');
      packageDir = Directory.current.path;
      repoRoot = p.normalize(p.join(packageDir, '..', '..'));
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('doctor succeeds for the sample Flutter app', () async {
      final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');
      final result = await _runCli(<String>[
        'doctor',
        '--project',
        projectPath,
      ]);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('checks passed.'));
    });

    test('doctor returns exit code 2 for invalid projects', () async {
      final result = await _runCli(<String>[
        'doctor',
        '--project',
        p.join(tempDir.path, 'missing'),
      ]);

      expect(result.exitCode, 2);
      expect(result.stdout, contains('valid: false'));
    });

    test('audit writes inventory and reports for the sample app', () async {
      final outDir = p.join(tempDir.path, 'out');
      final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');

      final result = await _runCli(<String>[
        'audit',
        '--project',
        projectPath,
        '--out',
        outDir,
        '--format',
        'both',
      ]);

      expect(result.exitCode, 0);
      expect(File(p.join(outDir, 'inventory.json')).existsSync(), isTrue);
      expect(File(p.join(outDir, 'migration_report.md')).existsSync(), isTrue);
      expect(
        File(p.join(outDir, 'migration_report.json')).existsSync(),
        isTrue,
      );

      final inventory =
          jsonDecode(File(p.join(outDir, 'inventory.json')).readAsStringSync())
              as Map<String, Object?>;
      final findings =
          ((inventory['inventory']! as Map<String, Object?>)['findings']!
                  as List<Object?>)
              .cast<Map<String, Object?>>();
      final categories = findings
          .map((finding) => finding['category']! as String)
          .toSet();
      final subcategories = findings
          .map((finding) => finding['subcategory']! as String)
          .toSet();
      final risks = findings
          .map((finding) => finding['riskLevel']! as String)
          .toSet();

      expect(
        categories,
        containsAll(<String>['state', 'di', 'routing', 'uiHelper', 'network']),
      );
      expect(
        subcategories,
        containsAll(<String>[
          'obs',
          'obx',
          'getPut',
          'getFind',
          'getMaterialApp',
          'getTo',
          'getArguments',
          'getConnect',
        ]),
      );
      expect(risks, containsAll(<String>['low', 'medium', 'high']));
    });

    test('report reuses inventory when it already exists', () async {
      final outDir = p.join(tempDir.path, 'out');
      final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');

      final first = await _runCli(<String>[
        'audit',
        '--project',
        projectPath,
        '--out',
        outDir,
      ]);
      expect(first.exitCode, 0);

      final second = await _runCli(<String>[
        'report',
        '--project',
        projectPath,
        '--out',
        outDir,
        '--format',
        'both',
      ]);

      expect(second.exitCode, 0);
      expect(
        File(p.join(outDir, 'migration_report.md')).readAsStringSync(),
        contains('# GetXDrop Migration Report'),
      );
    });

    test(
      'audit returns exit code 3 and preserves fallback findings for parse errors',
      () async {
        final projectDir = Directory(p.join(tempDir.path, 'broken_project'));
        await Directory(p.join(projectDir.path, 'lib')).create(recursive: true);
        await File(
          p.join(projectDir.path, 'pubspec.yaml'),
        ).writeAsString('name: broken_project\n');
        await File(p.join(projectDir.path, 'lib', 'broken.dart')).writeAsString(
          '''
        import 'package:get/get.dart';

        void broken( {
          final count = 0.obs;
          Get.toNamed('/x');
        }
      ''',
        );

        final outDir = p.join(tempDir.path, 'out');
        final result = await _runCli(<String>[
          'audit',
          '--project',
          projectDir.path,
          '--out',
          outDir,
        ]);

        expect(result.exitCode, 3);
        final inventory =
            jsonDecode(
                  File(p.join(outDir, 'inventory.json')).readAsStringSync(),
                )
                as Map<String, Object?>;
        final parseFailures = (inventory['parseFailures']! as List<Object?>);
        final findings =
            ((inventory['inventory']! as Map<String, Object?>)['findings']!
                    as List<Object?>)
                .cast<Map<String, Object?>>();
        expect(parseFailures, isNotEmpty);
        expect(
          findings.map((finding) => finding['subcategory']! as String),
          containsAll(<String>['obs', 'getTo']),
        );
      },
    );
  });
}

Future<ProcessResult> _runCli(List<String> arguments) {
  final packageDir = Directory.current.path;
  final repoRoot = p.normalize(p.join(packageDir, '..', '..'));
  final dartExecutable =
      p.join(repoRoot, '.fvm', 'flutter_sdk', 'bin', 'dart');
  return Process.run(dartExecutable, <String>[
    'run',
    'bin/getxdrop.dart',
    ...arguments,
  ], workingDirectory: packageDir);
}
