import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('getxdrop CLI', () {
    late Directory tempDir;
    late String packageDir;
    late String repoRoot;
    late Map<String, String> cliEnvironment;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('getxdrop_cli_test_');
      packageDir = Directory.current.path;
      repoRoot = p.normalize(p.join(packageDir, '..', '..'));
      final fakeBinDir = await Directory(
        p.join(tempDir.path, 'fake_bin'),
      ).create(recursive: true);
      await _writeFakeFlutter(directory: fakeBinDir, version: '3.41.6');
      cliEnvironment = _environmentWithPath(fakeBinDir.path);
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
      ], environment: cliEnvironment);

      expect(result.exitCode, 0);
      expect(result.stdout, contains('checks passed.'));
    });

    test(
      'doctor returns exit code 0 with warnings for supported family drift',
      () async {
        final fakeBinDir = await Directory(
          p.join(tempDir.path, 'drift_bin'),
        ).create(recursive: true);
        await _writeFakeFlutter(directory: fakeBinDir, version: '3.41.4');
        final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');
        final result = await _runCli(<String>[
          'doctor',
          '--project',
          projectPath,
        ], environment: _environmentWithPath(fakeBinDir.path));

        expect(result.exitCode, 0);
        expect(result.stdout, contains('warnings:'));
        expect(result.stdout, contains('Recommended Flutter SDK is 3.41.6'));
        expect(result.stdout, contains('checks passed.'));
      },
    );

    test('doctor returns exit code 2 for invalid projects', () async {
      final result = await _runCli(<String>[
        'doctor',
        '--project',
        p.join(tempDir.path, 'missing'),
      ], environment: cliEnvironment);

      expect(result.exitCode, 2);
      expect(result.stdout, contains('valid: false'));
    });

    test(
      'doctor returns exit code 2 when flutter is missing from PATH',
      () async {
        final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');
        final emptyPathDir = await Directory(
          p.join(tempDir.path, 'empty_path'),
        ).create(recursive: true);
        final result = await _runCli(<String>[
          'doctor',
          '--project',
          projectPath,
        ], environment: _environmentWithPath(emptyPathDir.path));

        expect(result.exitCode, 2);
        expect(
          result.stdout,
          contains('Flutter executable not found in PATH.'),
        );
      },
    );

    test(
      'doctor returns exit code 2 for unsupported flutter versions',
      () async {
        final fakeBinDir = await Directory(
          p.join(tempDir.path, 'unsupported_bin'),
        ).create(recursive: true);
        await _writeFakeFlutter(directory: fakeBinDir, version: '2.10.5');
        final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');
        final result = await _runCli(<String>[
          'doctor',
          '--project',
          projectPath,
        ], environment: _environmentWithPath(fakeBinDir.path));

        expect(result.exitCode, 2);
        expect(result.stdout, contains('Unsupported Flutter SDK version'));
      },
    );

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
      ], environment: cliEnvironment);

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
      final reportJson =
          jsonDecode(
                File(
                  p.join(outDir, 'migration_report.json'),
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final findings =
          ((inventory['inventory']! as Map<String, Object?>)['findings']!
                  as List<Object?>)
              .cast<Map<String, Object?>>();
      final routeInventory =
          (reportJson['routeInventory']! as Map<String, Object?>);
      final networkInventory =
          (reportJson['networkInventory']! as Map<String, Object?>);
      final controllerInventory =
          (reportJson['controllerInventory']! as Map<String, Object?>);
      final findingDrillDowns =
          (reportJson['findingDrillDowns']! as List<Object?>);
      final categories = findings
          .map((finding) => finding['category']! as String)
          .toSet();
      final subcategories = findings
          .map((finding) => finding['subcategory']! as String)
          .toSet();
      final risks = findings
          .map((finding) => finding['riskLevel']! as String)
          .toSet();

      expect(inventory['schemaVersion'], 1);
      expect(reportJson['schemaVersion'], 1);
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
          'middleware',
          'rxType',
          'getConnect',
        ]),
      );
      expect(risks, containsAll(<String>['low', 'medium', 'high']));
      expect(inventory, contains('inventory'));
      expect(inventory, contains('parseFailures'));
      expect(reportJson, contains('project'));
      expect(reportJson, isNot(contains('inventory')));
      expect((routeInventory['declarations']! as List<Object?>), isNotEmpty);
      expect((routeInventory['invocations']! as List<Object?>), isNotEmpty);
      expect((networkInventory['clients']! as List<Object?>), isNotEmpty);
      expect(
        (controllerInventory['controllers']! as List<Object?>),
        isNotEmpty,
      );
      expect(findingDrillDowns, isNotEmpty);
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
      ], environment: cliEnvironment);
      expect(first.exitCode, 0);

      final second = await _runCli(<String>[
        'report',
        '--project',
        projectPath,
        '--out',
        outDir,
        '--format',
        'both',
      ], environment: cliEnvironment);

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
        ], environment: cliEnvironment);

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

Future<ProcessResult> _runCli(
  List<String> arguments, {
  Map<String, String>? environment,
}) {
  return Process.run(
    Platform.resolvedExecutable,
    <String>['run', 'bin/getxdrop.dart', ...arguments],
    workingDirectory: Directory.current.path,
    environment: environment == null
        ? null
        : <String, String>{...Platform.environment, ...environment},
  );
}

Map<String, String> _environmentWithPath(String pathEntry) {
  return <String, String>{'PATH': pathEntry};
}

Future<void> _writeFakeFlutter({
  required Directory directory,
  required String version,
}) async {
  final executableName = Platform.isWindows ? 'flutter.bat' : 'flutter';
  final file = File(p.join(directory.path, executableName));
  if (Platform.isWindows) {
    await file.writeAsString(
      '@echo off\r\necho {"frameworkVersion":"$version","flutterVersion":"$version","dartSdkVersion":"3.11.4"}\r\n',
    );
  } else {
    await file.writeAsString(
      '#!/bin/sh\nprintf \'%s\\n\' \'{"frameworkVersion":"$version","flutterVersion":"$version","dartSdkVersion":"3.11.4"}\'\n',
    );
    final chmodResult = await Process.run('chmod', <String>['+x', file.path]);
    expect(chmodResult.exitCode, 0);
  }
}
