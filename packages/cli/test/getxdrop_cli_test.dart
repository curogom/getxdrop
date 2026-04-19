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
      expect(result.stdout, contains('config: not found'));
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

    test('doctor returns exit code 2 for invalid getxdrop.yaml', () async {
      final projectDir = await _createMinimalProject(
        tempDir.path,
        'doctor_cfg',
      );
      await _writeConfig(projectDir.path, '''
version: 2
''');

      final result = await _runCli(<String>[
        'doctor',
        '--project',
        projectDir.path,
      ], environment: cliEnvironment);

      expect(result.exitCode, 2);
      expect(
        result.stdout,
        contains('config: ${p.join(projectDir.path, 'getxdrop.yaml')}'),
      );
      expect(result.stdout, contains('Unsupported getxdrop.yaml version: 2.'));
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
      expect(File(p.join(outDir, 'summary.json')).existsSync(), isTrue);
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
      final summaryJson =
          jsonDecode(File(p.join(outDir, 'summary.json')).readAsStringSync())
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
      expect(summaryJson['schemaVersion'], 1);
      expect(summaryJson['command'], 'audit');
      expect(summaryJson['status'], 'success');
      expect(summaryJson['exitCode'], 0);
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
      expect(reportJson, contains('hotspotInventory'));
      expect(summaryJson, contains('summary'));
      expect(summaryJson, contains('riskSummary'));
      expect(summaryJson, contains('categoryCounts'));
      expect(summaryJson, contains('planningCounts'));
      expect(summaryJson, contains('topHotspots'));
      expect((routeInventory['declarations']! as List<Object?>), isNotEmpty);
      expect((routeInventory['invocations']! as List<Object?>), isNotEmpty);
      expect((networkInventory['clients']! as List<Object?>), isNotEmpty);
      expect(
        (controllerInventory['controllers']! as List<Object?>),
        isNotEmpty,
      );
      expect(findingDrillDowns, isNotEmpty);
      expect(result.stdout, contains('project: $projectPath'));
      expect(result.stdout, contains('risk: low='));
      expect(result.stdout, contains('route declarations:'));
      expect(result.stdout, contains('network clients:'));
      expect(result.stdout, contains('controllers:'));
      expect(result.stdout, contains('recommended steps:'));
      expect(result.stdout, contains('top hotspot 1:'));
      expect(
        result.stdout,
        contains('summary.json: ${p.join(outDir, 'summary.json')}'),
      );
    });

    test('sample app end-to-end flow runs doctor, audit, and report', () async {
      final outDir = p.join(tempDir.path, 'e2e_out');
      final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');

      final doctor = await _runCli(<String>[
        'doctor',
        '--project',
        projectPath,
      ], environment: cliEnvironment);
      expect(doctor.exitCode, 0);
      expect(doctor.stdout, contains('checks passed.'));

      final audit = await _runCli(<String>[
        'audit',
        '--project',
        projectPath,
        '--out',
        outDir,
      ], environment: cliEnvironment);
      expect(audit.exitCode, 0);
      expect(File(p.join(outDir, 'inventory.json')).existsSync(), isTrue);
      expect(File(p.join(outDir, 'summary.json')).existsSync(), isTrue);
      expect(File(p.join(outDir, 'migration_report.md')).existsSync(), isFalse);
      expect(
        File(p.join(outDir, 'migration_report.json')).existsSync(),
        isFalse,
      );

      final auditSummary =
          jsonDecode(File(p.join(outDir, 'summary.json')).readAsStringSync())
              as Map<String, Object?>;
      expect(auditSummary['command'], 'audit');
      expect(auditSummary['status'], 'success');

      final report = await _runCli(<String>[
        'report',
        '--project',
        projectPath,
        '--out',
        outDir,
        '--format',
        'both',
      ], environment: cliEnvironment);
      expect(report.exitCode, 0);
      expect(File(p.join(outDir, 'migration_report.md')).existsSync(), isTrue);
      expect(
        File(p.join(outDir, 'migration_report.json')).existsSync(),
        isTrue,
      );

      final reportJson =
          jsonDecode(
                File(
                  p.join(outDir, 'migration_report.json'),
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final reportSummary =
          jsonDecode(File(p.join(outDir, 'summary.json')).readAsStringSync())
              as Map<String, Object?>;

      expect(reportJson['schemaVersion'], 1);
      expect(reportJson, contains('hotspotInventory'));
      expect(reportSummary['command'], 'report');
      expect(reportSummary, contains('topHotspots'));
      expect(report.stdout, contains('top hotspot 1:'));
      expect(
        report.stdout,
        contains('migration_report.md: ${p.join(outDir, 'migration_report.md')}'),
      );
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
      expect(File(p.join(outDir, 'summary.json')).existsSync(), isTrue);
      final summaryJson =
          jsonDecode(File(p.join(outDir, 'summary.json')).readAsStringSync())
              as Map<String, Object?>;
      expect(summaryJson['command'], 'report');
      expect(summaryJson['status'], 'success');
      expect(
        second.stdout,
        contains('summary.json: ${p.join(outDir, 'summary.json')}'),
      );
    });

    test('audit dry run prints planned summary artifact', () async {
      final outDir = p.join(tempDir.path, 'dry_run_out');
      final projectPath = p.join(repoRoot, 'examples', 'sample_getx_app');

      final result = await _runCli(<String>[
        'audit',
        '--project',
        projectPath,
        '--out',
        outDir,
        '--format',
        'both',
        '--dry-run',
      ], environment: cliEnvironment);

      expect(result.exitCode, 0);
      expect(File(p.join(outDir, 'summary.json')).existsSync(), isFalse);
      expect(
        result.stdout,
        contains('would write summary.json: ${p.join(outDir, 'summary.json')}'),
      );
      expect(
        result.stdout,
        contains(
          'would write inventory.json: ${p.join(outDir, 'inventory.json')}',
        ),
      );
      expect(
        result.stdout,
        contains(
          'would write migration_report.md: ${p.join(outDir, 'migration_report.md')}',
        ),
      );
      expect(
        result.stdout,
        contains(
          'would write migration_report.json: ${p.join(outDir, 'migration_report.json')}',
        ),
      );
    });

    test('audit returns exit code 2 for invalid config', () async {
      final projectDir = await _createMinimalProject(
        tempDir.path,
        'audit_cfg_invalid',
      );
      await _writeConfig(projectDir.path, '''
version: 1

report:
  format: xml
''');

      final result = await _runCli(<String>[
        'audit',
        '--project',
        projectDir.path,
      ], environment: cliEnvironment);

      expect(result.exitCode, 2);
      expect(
        result.stderr,
        contains('Invalid getxdrop.yaml value for report.format'),
      );
    });

    test('audit uses config defaults and merges CLI ignore values', () async {
      final projectDir = await _createMinimalProject(
        tempDir.path,
        'config_audit',
      );
      await _writeConfig(projectDir.path, '''
version: 1

audit:
  include_test: true
  ignore:
    - lib/ignored.dart

output:
  path: build/from-config

report:
  format: json
''');
      await _writeGetxSource(
        p.join(projectDir.path, 'lib', 'included.dart'),
        "final count = 0.obs;",
      );
      await _writeGetxSource(
        p.join(projectDir.path, 'lib', 'ignored.dart'),
        "Get.toNamed('/ignored');",
      );
      await _writeGetxSource(
        p.join(projectDir.path, 'test', 'feature_test.dart'),
        "Get.toNamed('/test');",
      );

      final result = await _runCli(<String>[
        'audit',
        '--project',
        projectDir.path,
        '--ignore',
        'test/**',
      ], environment: cliEnvironment);

      final outDir = p.join(projectDir.path, 'build', 'from-config');
      final inventory =
          jsonDecode(File(p.join(outDir, 'inventory.json')).readAsStringSync())
              as Map<String, Object?>;
      final findings =
          ((inventory['inventory']! as Map<String, Object?>)['findings']!
                  as List<Object?>)
              .cast<Map<String, Object?>>();
      final filePaths = findings
          .map((finding) => finding['filePath']! as String)
          .toSet();

      expect(result.exitCode, 0);
      expect(filePaths, contains('lib/included.dart'));
      expect(filePaths, isNot(contains('lib/ignored.dart')));
      expect(filePaths, isNot(contains('test/feature_test.dart')));
      expect(File(p.join(outDir, 'summary.json')).existsSync(), isTrue);
      expect(
        File(p.join(outDir, 'migration_report.json')).existsSync(),
        isFalse,
      );
    });

    test(
      'audit include-test flags override config in both directions',
      () async {
        final projectDir = await _createMinimalProject(
          tempDir.path,
          'include_toggle',
        );
        await _writeGetxSource(
          p.join(projectDir.path, 'test', 'feature_test.dart'),
          "Get.toNamed('/test');",
        );

        await _writeConfig(projectDir.path, '''
version: 1

audit:
  include_test: false

output:
  path: build/getxdrop
''');

        final includeResult = await _runCli(<String>[
          'audit',
          '--project',
          projectDir.path,
          '--include-test',
        ], environment: cliEnvironment);

        final includeInventory =
            jsonDecode(
                  File(
                    p.join(
                      projectDir.path,
                      'build',
                      'getxdrop',
                      'inventory.json',
                    ),
                  ).readAsStringSync(),
                )
                as Map<String, Object?>;
        final includeFindings =
            ((includeInventory['inventory']!
                        as Map<String, Object?>)['findings']!
                    as List<Object?>)
                .cast<Map<String, Object?>>();
        expect(includeResult.exitCode, 0);
        expect(
          includeFindings.map((finding) => finding['filePath']! as String),
          contains('test/feature_test.dart'),
        );

        await _writeConfig(projectDir.path, '''
version: 1

audit:
  include_test: true

output:
  path: build/getxdrop
''');

        final excludeResult = await _runCli(<String>[
          'audit',
          '--project',
          projectDir.path,
          '--no-include-test',
        ], environment: cliEnvironment);

        final excludeInventory =
            jsonDecode(
                  File(
                    p.join(
                      projectDir.path,
                      'build',
                      'getxdrop',
                      'inventory.json',
                    ),
                  ).readAsStringSync(),
                )
                as Map<String, Object?>;
        final excludeFindings =
            ((excludeInventory['inventory']!
                        as Map<String, Object?>)['findings']!
                    as List<Object?>)
                .cast<Map<String, Object?>>();
        expect(excludeResult.exitCode, 0);
        expect(
          excludeFindings.map((finding) => finding['filePath']! as String),
          isNot(contains('test/feature_test.dart')),
        );
      },
    );

    test('report uses config output path and default format', () async {
      final projectDir = await _createMinimalProject(
        tempDir.path,
        'report_cfg',
      );
      await _writeConfig(projectDir.path, '''
version: 1

output:
  path: build/custom-report

report:
  format: json
''');
      await _writeGetxSource(
        p.join(projectDir.path, 'lib', 'feature.dart'),
        "final count = 0.obs;",
      );

      final result = await _runCli(<String>[
        'report',
        '--project',
        projectDir.path,
      ], environment: cliEnvironment);

      final outDir = p.join(projectDir.path, 'build', 'custom-report');
      expect(result.exitCode, 0);
      expect(File(p.join(outDir, 'inventory.json')).existsSync(), isTrue);
      expect(File(p.join(outDir, 'summary.json')).existsSync(), isTrue);
      expect(
        File(p.join(outDir, 'migration_report.json')).existsSync(),
        isTrue,
      );
      expect(File(p.join(outDir, 'migration_report.md')).existsSync(), isFalse);
    });

    test('report returns exit code 2 for invalid config', () async {
      final projectDir = await _createMinimalProject(
        tempDir.path,
        'report_cfg_invalid',
      );
      await _writeConfig(projectDir.path, '''
version: 1

output:
  path:
    nested: nope
''');

      final result = await _runCli(<String>[
        'report',
        '--project',
        projectDir.path,
      ], environment: cliEnvironment);

      expect(result.exitCode, 2);
      expect(
        result.stderr,
        contains('Invalid getxdrop.yaml value for output.path'),
      );
    });

    test('CLI flags override config output path and report format', () async {
      final projectDir = await _createMinimalProject(
        tempDir.path,
        'report_override',
      );
      await _writeConfig(projectDir.path, '''
version: 1

output:
  path: build/from-config

report:
  format: json
''');
      await _writeGetxSource(
        p.join(projectDir.path, 'lib', 'feature.dart'),
        "final count = 0.obs;",
      );

      final explicitOut = p.join(projectDir.path, 'build', 'from-flag');
      final result = await _runCli(<String>[
        'report',
        '--project',
        projectDir.path,
        '--out',
        explicitOut,
        '--format',
        'markdown',
      ], environment: cliEnvironment);

      expect(result.exitCode, 0);
      expect(File(p.join(explicitOut, 'summary.json')).existsSync(), isTrue);
      expect(
        File(p.join(explicitOut, 'migration_report.md')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(explicitOut, 'migration_report.json')).existsSync(),
        isFalse,
      );
      expect(
        Directory(p.join(projectDir.path, 'build', 'from-config')).existsSync(),
        isFalse,
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
        final summary =
            jsonDecode(File(p.join(outDir, 'summary.json')).readAsStringSync())
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
        expect(summary['status'], 'partial');
        expect(summary['exitCode'], 3);
        expect(
          (((summary['status']! as String) == 'partial') &&
              ((summary['summary']! as Map<String, Object?>)['parseFailures']!
                      as int) >
                  0),
          isTrue,
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

Future<Directory> _createMinimalProject(String root, String name) async {
  final projectDir = await Directory(
    p.join(root, name),
  ).create(recursive: true);
  await Directory(p.join(projectDir.path, 'lib')).create(recursive: true);
  await Directory(p.join(projectDir.path, 'test')).create(recursive: true);
  await File(
    p.join(projectDir.path, 'pubspec.yaml'),
  ).writeAsString('name: $name\n');
  return projectDir;
}

Future<void> _writeConfig(String projectPath, String contents) {
  return File(p.join(projectPath, 'getxdrop.yaml')).writeAsString(contents);
}

Future<void> _writeGetxSource(String path, String body) async {
  await File(path).create(recursive: true);
  await File(path).writeAsString('''
import 'package:get/get.dart';

void fixture() {
  $body
}
''');
}
