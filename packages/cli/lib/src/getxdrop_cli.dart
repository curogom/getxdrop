import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:getxdrop_analyzer_core/getxdrop_analyzer_core.dart';
import 'package:getxdrop_report_core/getxdrop_report_core.dart';
import 'package:path/path.dart' as p;

class GetXDropCli {
  Future<int> run(List<String> arguments) async {
    final runner =
        CommandRunner<int>(
            'getxdrop',
            'Audit GetX-based Flutter apps and generate migration reports.',
          )
          ..addCommand(_DoctorCommand())
          ..addCommand(_AuditCommand())
          ..addCommand(_ReportCommand());

    try {
      return await runner.run(arguments) ?? 0;
    } on UsageException catch (error) {
      stderr
        ..writeln(error)
        ..writeln()
        ..writeln(error.usage);
      return 1;
    } catch (error, stackTrace) {
      stderr
        ..writeln('GetXDrop failed: $error')
        ..writeln(stackTrace);
      return 1;
    }
  }
}

class _DoctorCommand extends Command<int> {
  @override
  String get description =>
      'Validate project shape and local Dart/Flutter toolchain.';

  @override
  String get name => 'doctor';

  _DoctorCommand() {
    argParser.addOption(
      'project',
      mandatory: true,
      help: 'Flutter project root to validate.',
    );
  }

  @override
  Future<int> run() async {
    final projectPath = _resolvePath(argResults!['project']! as String);
    final validation = await _ProjectValidator().validate(projectPath);
    final sdkInfo = await _SdkProbe().probe();

    stdout
      ..writeln('GetXDrop Doctor')
      ..writeln('project: $projectPath')
      ..writeln('valid: ${validation.isValid}')
      ..writeln('dart: ${sdkInfo.dartVersion ?? 'unavailable'}')
      ..writeln('flutter: ${sdkInfo.flutterVersion ?? 'unavailable'}');

    if (validation.issues.isNotEmpty) {
      stdout.writeln('issues:');
      for (final issue in validation.issues) {
        stdout.writeln('- $issue');
      }
      return 2;
    }

    stdout.writeln('checks passed.');
    return 0;
  }
}

class _AuditCommand extends Command<int> {
  @override
  String get description =>
      'Analyze a Flutter project and write inventory and optional reports.';

  @override
  String get name => 'audit';

  _AuditCommand() {
    argParser
      ..addOption(
        'project',
        mandatory: true,
        help: 'Flutter project root to analyze.',
      )
      ..addOption(
        'out',
        defaultsTo: 'build/getxdrop',
        help: 'Output directory for generated files.',
      )
      ..addOption(
        'format',
        allowed: const <String>['markdown', 'json', 'both'],
        help: 'Also generate report output in the selected format.',
      )
      ..addFlag(
        'include-test',
        negatable: false,
        help: 'Include test/**/*.dart in the audit scan.',
      )
      ..addMultiOption(
        'ignore',
        help: 'Additional glob patterns to exclude from the scan.',
      )
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Do not write files, only print the planned outputs.',
      );
  }

  @override
  Future<int> run() async {
    final projectPath = _resolvePath(argResults!['project']! as String);
    final outPath = _resolvePath(argResults!['out']! as String);
    final validation = await _ProjectValidator().validate(projectPath);
    if (!validation.isValid) {
      for (final issue in validation.issues) {
        stderr.writeln(issue);
      }
      return 2;
    }

    final sdkInfo = await _SdkProbe().probe();
    final result = await AuditEngine().audit(
      AuditConfig(
        projectPath: projectPath,
        outPath: outPath,
        includeTest: argResults!['include-test']! as bool,
        ignoreGlobs: (argResults!['ignore']! as List<Object?>).cast<String>(),
        dryRun: argResults!['dry-run']! as bool,
        flutterVersion: sdkInfo.flutterVersion,
        dartVersion: sdkInfo.dartVersion,
      ),
    );

    final output = _OutputPaths(outPath);
    if (argResults!['dry-run']! as bool) {
      stdout
        ..writeln('Dry run complete.')
        ..writeln('Would write ${output.inventoryPath}');
      final format = argResults!['format'] as String?;
      if (format == 'markdown' || format == 'both') {
        stdout.writeln('Would write ${output.markdownPath}');
      }
      if (format == 'json' || format == 'both') {
        stdout.writeln('Would write ${output.reportJsonPath}');
      }
    } else {
      await output.ensureExists();
      await File(output.inventoryPath).writeAsString(result.toPrettyJson());
      await _writeReports(
        result: result,
        output: output,
        format: argResults!['format'] as String?,
      );
    }

    stdout
      ..writeln('Audit completed.')
      ..writeln('findings: ${result.inventory.summary.totalFindings}')
      ..writeln('parse failures: ${result.inventory.summary.parseFailures}');

    return result.hasRecoverableIssues ? 3 : 0;
  }
}

class _ReportCommand extends Command<int> {
  @override
  String get description =>
      'Generate markdown/json reports from an existing inventory or a fresh audit.';

  @override
  String get name => 'report';

  _ReportCommand() {
    argParser
      ..addOption(
        'project',
        mandatory: true,
        help: 'Flutter project root to analyze.',
      )
      ..addOption(
        'out',
        defaultsTo: 'build/getxdrop',
        help: 'Output directory for generated files.',
      )
      ..addOption(
        'format',
        allowed: const <String>['markdown', 'json', 'both'],
        defaultsTo: 'both',
        help: 'Report output format.',
      );
  }

  @override
  Future<int> run() async {
    final projectPath = _resolvePath(argResults!['project']! as String);
    final outPath = _resolvePath(argResults!['out']! as String);
    final validation = await _ProjectValidator().validate(projectPath);
    if (!validation.isValid) {
      for (final issue in validation.issues) {
        stderr.writeln(issue);
      }
      return 2;
    }

    final output = _OutputPaths(outPath);
    AuditResult result;
    if (await File(output.inventoryPath).exists()) {
      final json =
          jsonDecode(await File(output.inventoryPath).readAsString())
              as Map<String, Object?>;
      result = AuditResult.fromJson(json);
    } else {
      final sdkInfo = await _SdkProbe().probe();
      result = await AuditEngine().audit(
        AuditConfig(
          projectPath: projectPath,
          outPath: outPath,
          flutterVersion: sdkInfo.flutterVersion,
          dartVersion: sdkInfo.dartVersion,
        ),
      );
      await output.ensureExists();
      await File(output.inventoryPath).writeAsString(result.toPrettyJson());
    }

    await output.ensureExists();
    await _writeReports(
      result: result,
      output: output,
      format: argResults!['format']! as String,
    );

    stdout
      ..writeln('Report generation completed.')
      ..writeln('markdown: ${output.markdownPath}')
      ..writeln('json: ${output.reportJsonPath}');

    return result.hasRecoverableIssues ? 3 : 0;
  }
}

Future<void> _writeReports({
  required AuditResult result,
  required _OutputPaths output,
  required String? format,
}) async {
  if (format == null) {
    return;
  }

  const renderer = ReportRenderer();
  if (format == 'markdown' || format == 'both') {
    await File(output.markdownPath).writeAsString(
      renderer.renderMarkdown(
        result.inventory,
        parseFailures: result.parseFailures,
      ),
    );
  }
  if (format == 'json' || format == 'both') {
    await File(
      output.reportJsonPath,
    ).writeAsString(renderer.renderJson(result.inventory));
  }
}

String _resolvePath(String path) {
  return p.normalize(
    p.isAbsolute(path) ? path : p.join(Directory.current.path, path),
  );
}

class _OutputPaths {
  _OutputPaths(String outPath)
    : inventoryPath = p.join(outPath, 'inventory.json'),
      markdownPath = p.join(outPath, 'migration_report.md'),
      reportJsonPath = p.join(outPath, 'migration_report.json');

  final String inventoryPath;
  final String markdownPath;
  final String reportJsonPath;

  Future<void> ensureExists() async {
    await Directory(p.dirname(inventoryPath)).create(recursive: true);
  }
}

class _ProjectValidator {
  Future<_ValidationResult> validate(String projectPath) async {
    final issues = <String>[];
    final projectDir = Directory(projectPath);
    if (!await projectDir.exists()) {
      issues.add('Project directory does not exist: $projectPath');
      return _ValidationResult(issues: issues);
    }

    final pubspec = File(p.join(projectPath, 'pubspec.yaml'));
    if (!await pubspec.exists()) {
      issues.add('Missing pubspec.yaml in $projectPath');
    }

    final libDir = Directory(p.join(projectPath, 'lib'));
    if (!await libDir.exists()) {
      issues.add('Missing lib directory in $projectPath');
    }

    return _ValidationResult(issues: issues);
  }
}

class _ValidationResult {
  const _ValidationResult({required this.issues});

  final List<String> issues;

  bool get isValid => issues.isEmpty;
}

class _SdkProbe {
  Future<_SdkInfo> probe() async {
    final flutterVersion =
        await _readPinnedFlutterVersion() ??
        await _runVersionCommand(
          executable: 'fvm',
          arguments: const <String>['flutter', '--version'],
        );
    final dartVersion = Platform.version.split(' ').take(2).join(' ');
    return _SdkInfo(dartVersion: dartVersion, flutterVersion: flutterVersion);
  }

  Future<String?> _readPinnedFlutterVersion() async {
    final versionFile = _findPinnedFlutterVersionFile();
    if (versionFile == null || !await File(versionFile).exists()) {
      return null;
    }

    try {
      final json =
          jsonDecode(await File(versionFile).readAsString())
              as Map<String, Object?>;
      final flutterVersion = json['flutterVersion'];
      final channel = json['channel'];
      final repositoryUrl = json['repositoryUrl'];
      if (flutterVersion is! String || channel is! String) {
        return null;
      }
      final repositorySuffix = repositoryUrl is String ? ' • $repositoryUrl' : '';
      return 'Flutter $flutterVersion • channel $channel$repositorySuffix';
    } on FormatException {
      return null;
    }
  }

  String? _findPinnedFlutterVersionFile() {
    var current = Directory.current.absolute;
    while (true) {
      final candidate = p.join(
        current.path,
        '.fvm',
        'flutter_sdk',
        'bin',
        'cache',
        'flutter.version.json',
      );
      if (File(candidate).existsSync()) {
        return candidate;
      }

      final parent = current.parent;
      if (parent.path == current.path) {
        return null;
      }
      current = parent;
    }
  }

  Future<String?> _runVersionCommand({
    required String executable,
    required List<String> arguments,
  }) async {
    try {
      final result = await Process.run(executable, arguments);
      if (result.exitCode != 0) {
        return null;
      }
      final lines = '${result.stdout}'.trim().split('\n');
      return lines.isEmpty ? null : lines.first.trim();
    } on ProcessException {
      return null;
    }
  }
}

class _SdkInfo {
  const _SdkInfo({required this.dartVersion, required this.flutterVersion});

  final String? dartVersion;
  final String? flutterVersion;
}
