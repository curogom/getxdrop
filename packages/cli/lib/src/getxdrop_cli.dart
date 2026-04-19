import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:getxdrop_analyzer_core/getxdrop_analyzer_core.dart';
import 'package:getxdrop_report_core/getxdrop_report_core.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

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
    final loadedConfig = await _loadConfig(projectPath);
    final sdkInfo = await _SdkProbe().probe();
    final issues = <String>[
      ...validation.issues,
      ...loadedConfig.issues,
      ...sdkInfo.issues,
    ];
    final warnings = <String>[...sdkInfo.warnings];
    final isValid = issues.isEmpty;

    stdout
      ..writeln('GetXDrop Doctor')
      ..writeln('project: $projectPath')
      ..writeln('config: ${loadedConfig.displayLabel}')
      ..writeln('valid: $isValid')
      ..writeln('dart: ${sdkInfo.dartVersion ?? 'unavailable'}')
      ..writeln('flutter: ${sdkInfo.flutterVersion ?? 'unavailable'}');

    if (issues.isNotEmpty) {
      stdout.writeln('issues:');
      for (final issue in issues) {
        stdout.writeln('- $issue');
      }
    }
    if (warnings.isNotEmpty) {
      stdout.writeln('warnings:');
      for (final warning in warnings) {
        stdout.writeln('- $warning');
      }
    }
    if (issues.isNotEmpty) {
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
        defaultsTo: null,
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
    final validation = await _ProjectValidator().validate(projectPath);
    if (!validation.isValid) {
      _printIssues(validation.issues);
      return 2;
    }
    final loadedConfig = await _loadConfig(projectPath);
    if (!loadedConfig.isValid) {
      _printIssues(loadedConfig.issues);
      return 2;
    }

    final outPath = _resolveAuditOutPath(
      argResults!,
      projectPath: projectPath,
      config: loadedConfig,
    );
    final includeTest = _resolveAuditIncludeTest(argResults!, loadedConfig);
    final ignoreGlobs = _resolveAuditIgnoreGlobs(argResults!, loadedConfig);
    final format = argResults!['format'] as String?;
    final dryRun = argResults!['dry-run']! as bool;

    final sdkInfo = await _SdkProbe().probe();
    final result = await AuditEngine().audit(
      AuditConfig(
        projectPath: projectPath,
        outPath: outPath,
        includeTest: includeTest,
        ignoreGlobs: ignoreGlobs,
        dryRun: dryRun,
        flutterVersion: sdkInfo.flutterVersion,
        dartVersion: sdkInfo.dartVersion,
      ),
    );

    final output = _OutputPaths(outPath);
    final exitCode = result.hasRecoverableIssues ? 3 : 0;
    const renderer = ReportRenderer();
    final summary = renderer.buildSummary(
      result,
      command: 'audit',
      exitCode: exitCode,
    );
    if (dryRun) {
      _printCompactSummary(
        heading: 'Audit completed.',
        projectPath: projectPath,
        summary: summary,
        output: output,
        dryRun: true,
        format: format,
      );
    } else {
      await output.ensureExists();
      await File(output.inventoryPath).writeAsString(result.toPrettyJson());
      await File(output.summaryPath).writeAsString(
        renderer.renderSummaryJson(
          result,
          command: 'audit',
          exitCode: exitCode,
        ),
      );
      await _writeReports(result: result, output: output, format: format);
      _printCompactSummary(
        heading: 'Audit completed.',
        projectPath: projectPath,
        summary: summary,
        output: output,
        dryRun: false,
        format: format,
      );
    }

    return exitCode;
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
    final validation = await _ProjectValidator().validate(projectPath);
    if (!validation.isValid) {
      _printIssues(validation.issues);
      return 2;
    }
    final loadedConfig = await _loadConfig(projectPath);
    if (!loadedConfig.isValid) {
      _printIssues(loadedConfig.issues);
      return 2;
    }

    final outPath = _resolveReportOutPath(
      argResults!,
      projectPath: projectPath,
      config: loadedConfig,
    );
    final format = _resolveReportFormat(argResults!, loadedConfig);

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
          includeTest: loadedConfig.config?.auditIncludeTest ?? false,
          ignoreGlobs: loadedConfig.config?.auditIgnore ?? const <String>[],
          flutterVersion: sdkInfo.flutterVersion,
          dartVersion: sdkInfo.dartVersion,
        ),
      );
      await output.ensureExists();
      await File(output.inventoryPath).writeAsString(result.toPrettyJson());
    }

    await output.ensureExists();
    final exitCode = result.hasRecoverableIssues ? 3 : 0;
    const renderer = ReportRenderer();
    await File(output.summaryPath).writeAsString(
      renderer.renderSummaryJson(result, command: 'report', exitCode: exitCode),
    );
    await _writeReports(result: result, output: output, format: format);
    _printCompactSummary(
      heading: 'Report generation completed.',
      projectPath: projectPath,
      summary: renderer.buildSummary(
        result,
        command: 'report',
        exitCode: exitCode,
      ),
      output: output,
      dryRun: false,
      format: format,
    );

    return exitCode;
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
      summaryPath = p.join(outPath, 'summary.json'),
      markdownPath = p.join(outPath, 'migration_report.md'),
      reportJsonPath = p.join(outPath, 'migration_report.json');

  final String inventoryPath;
  final String summaryPath;
  final String markdownPath;
  final String reportJsonPath;

  Future<void> ensureExists() async {
    await Directory(p.dirname(inventoryPath)).create(recursive: true);
  }
}

class _GetXDropConfig {
  const _GetXDropConfig({
    required this.auditIncludeTest,
    required this.auditIgnore,
    required this.outputPath,
    required this.reportFormat,
  });

  final bool? auditIncludeTest;
  final List<String> auditIgnore;
  final String? outputPath;
  final String? reportFormat;
}

class _LoadedConfig {
  const _LoadedConfig({
    required this.configPath,
    required this.exists,
    this.config,
    this.issues = const <String>[],
  });

  final String configPath;
  final bool exists;
  final _GetXDropConfig? config;
  final List<String> issues;

  bool get isValid => issues.isEmpty;

  String get displayLabel => exists ? configPath : 'not found';
}

Future<_LoadedConfig> _loadConfig(String projectPath) async {
  final configPath = p.join(projectPath, 'getxdrop.yaml');
  final file = File(configPath);
  if (!await file.exists()) {
    return _LoadedConfig(configPath: configPath, exists: false);
  }

  final issues = <String>[];
  try {
    final document = loadYaml(await file.readAsString());
    if (document is! YamlMap) {
      issues.add('Invalid getxdrop.yaml: expected a top-level mapping.');
      return _LoadedConfig(
        configPath: configPath,
        exists: true,
        issues: issues,
      );
    }

    final root = _yamlToDart(document);
    if (root is! Map<String, Object?>) {
      issues.add('Invalid getxdrop.yaml: expected a top-level mapping.');
      return _LoadedConfig(
        configPath: configPath,
        exists: true,
        issues: issues,
      );
    }

    const topLevelKeys = <String>{'version', 'audit', 'output', 'report'};
    final unknownTopLevelKeys = root.keys
        .where((key) => !topLevelKeys.contains(key))
        .toList(growable: false);
    for (final key in unknownTopLevelKeys) {
      issues.add('Unknown getxdrop.yaml key: $key.');
    }

    final rawVersion = root['version'];
    if (rawVersion == null) {
      issues.add('Missing required getxdrop.yaml key: version.');
    } else if (rawVersion != 1) {
      issues.add('Unsupported getxdrop.yaml version: $rawVersion.');
    }

    final audit = _readConfigSection(
      root,
      key: 'audit',
      allowedKeys: const <String>{'include_test', 'ignore'},
      issues: issues,
    );
    final output = _readConfigSection(
      root,
      key: 'output',
      allowedKeys: const <String>{'path'},
      issues: issues,
    );
    final report = _readConfigSection(
      root,
      key: 'report',
      allowedKeys: const <String>{'format'},
      issues: issues,
    );

    bool? auditIncludeTest;
    if (audit != null && audit.containsKey('include_test')) {
      final rawValue = audit['include_test'];
      if (rawValue is bool) {
        auditIncludeTest = rawValue;
      } else {
        issues.add(
          'Invalid getxdrop.yaml value for audit.include_test: expected bool.',
        );
      }
    }

    var auditIgnore = const <String>[];
    if (audit != null && audit.containsKey('ignore')) {
      final rawValue = audit['ignore'];
      if (rawValue is List<Object?> &&
          rawValue.every((item) => item is String)) {
        auditIgnore = rawValue.cast<String>();
      } else {
        issues.add(
          'Invalid getxdrop.yaml value for audit.ignore: expected a list of strings.',
        );
      }
    }

    String? outputPath;
    if (output != null && output.containsKey('path')) {
      final rawValue = output['path'];
      if (rawValue is String) {
        outputPath = rawValue;
      } else {
        issues.add(
          'Invalid getxdrop.yaml value for output.path: expected string.',
        );
      }
    }

    String? reportFormat;
    if (report != null && report.containsKey('format')) {
      final rawValue = report['format'];
      if (rawValue is! String) {
        issues.add(
          'Invalid getxdrop.yaml value for report.format: expected string.',
        );
      } else if (!const <String>{
        'markdown',
        'json',
        'both',
      }.contains(rawValue)) {
        issues.add(
          'Invalid getxdrop.yaml value for report.format: expected one of markdown, json, both.',
        );
      } else {
        reportFormat = rawValue;
      }
    }

    return _LoadedConfig(
      configPath: configPath,
      exists: true,
      config: _GetXDropConfig(
        auditIncludeTest: auditIncludeTest,
        auditIgnore: auditIgnore,
        outputPath: outputPath,
        reportFormat: reportFormat,
      ),
      issues: issues,
    );
  } on YamlException catch (error) {
    return _LoadedConfig(
      configPath: configPath,
      exists: true,
      issues: <String>['Invalid getxdrop.yaml: ${error.message}'],
    );
  }
}

Map<String, Object?>? _readConfigSection(
  Map<String, Object?> root, {
  required String key,
  required Set<String> allowedKeys,
  required List<String> issues,
}) {
  final rawValue = root[key];
  if (rawValue == null) {
    return null;
  }
  if (rawValue is! Map<String, Object?>) {
    issues.add('Invalid getxdrop.yaml section $key: expected mapping.');
    return null;
  }
  for (final sectionKey in rawValue.keys) {
    if (!allowedKeys.contains(sectionKey)) {
      issues.add('Unknown getxdrop.yaml key: $key.$sectionKey.');
    }
  }
  return rawValue;
}

Object? _yamlToDart(Object? value) {
  if (value is YamlMap) {
    return <String, Object?>{
      for (final entry in value.entries)
        '${entry.key}': _yamlToDart(entry.value),
    };
  }
  if (value is YamlList) {
    return value.map(_yamlToDart).toList(growable: false);
  }
  return value;
}

String _resolveAuditOutPath(
  ArgResults results, {
  required String projectPath,
  required _LoadedConfig config,
}) {
  if (results.wasParsed('out')) {
    return _resolvePath(results['out']! as String);
  }
  final configuredPath = config.config?.outputPath;
  if (configuredPath != null) {
    return _resolveProjectRelativePath(projectPath, configuredPath);
  }
  return _resolvePath(results['out']! as String);
}

String _resolveReportOutPath(
  ArgResults results, {
  required String projectPath,
  required _LoadedConfig config,
}) {
  if (results.wasParsed('out')) {
    return _resolvePath(results['out']! as String);
  }
  final configuredPath = config.config?.outputPath;
  if (configuredPath != null) {
    return _resolveProjectRelativePath(projectPath, configuredPath);
  }
  return _resolvePath(results['out']! as String);
}

String _resolveProjectRelativePath(String projectPath, String inputPath) {
  return p.normalize(
    p.isAbsolute(inputPath) ? inputPath : p.join(projectPath, inputPath),
  );
}

bool _resolveAuditIncludeTest(ArgResults results, _LoadedConfig config) {
  final cliValue = results['include-test'] as bool?;
  if (results.wasParsed('include-test') && cliValue != null) {
    return cliValue;
  }
  return config.config?.auditIncludeTest ?? false;
}

List<String> _resolveAuditIgnoreGlobs(
  ArgResults results,
  _LoadedConfig config,
) {
  return <String>[
    ...config.config?.auditIgnore ?? const <String>[],
    ...(results['ignore']! as List<Object?>).cast<String>(),
  ];
}

String _resolveReportFormat(ArgResults results, _LoadedConfig config) {
  if (results.wasParsed('format')) {
    return results['format']! as String;
  }
  return config.config?.reportFormat ?? results['format']! as String;
}

void _printIssues(List<String> issues) {
  for (final issue in issues) {
    stderr.writeln(issue);
  }
}

void _printCompactSummary({
  required String heading,
  required String projectPath,
  required CommandSummary summary,
  required _OutputPaths output,
  required bool dryRun,
  required String? format,
}) {
  final prefix = dryRun ? 'would write ' : '';
  stdout
    ..writeln(heading)
    ..writeln('project: $projectPath')
    ..writeln('status: ${summary.status}')
    ..writeln('findings: ${summary.summary.totalFindings}')
    ..writeln('parse failures: ${summary.summary.parseFailures}')
    ..writeln(
      'risk: low=${summary.riskSummary.low} medium=${summary.riskSummary.medium} high=${summary.riskSummary.high}',
    )
    ..writeln('route declarations: ${summary.planningCounts.routeDeclarations}')
    ..writeln('route invocations: ${summary.planningCounts.routeInvocations}')
    ..writeln(
      'route argument accesses: ${summary.planningCounts.routeArgumentAccesses}',
    )
    ..writeln('network clients: ${summary.planningCounts.networkClients}')
    ..writeln('controllers: ${summary.planningCounts.controllers}')
    ..writeln('recommended steps: ${summary.planningCounts.recommendedSteps}')
    ..writeln('${prefix}inventory.json: ${output.inventoryPath}')
    ..writeln('${prefix}summary.json: ${output.summaryPath}');
  for (var index = 0; index < summary.topHotspots.take(3).length; index++) {
    final hotspot = summary.topHotspots[index];
    final reasonSuffix = hotspot.reasons.isEmpty
        ? ''
        : ' · ${hotspot.reasons.first}';
    stdout.writeln(
      'top hotspot ${index + 1}: ${hotspot.kind.wireName} ${hotspot.label} score=${hotspot.score} risk=${hotspot.riskLevel.wireName}$reasonSuffix',
    );
  }
  if (format == 'markdown' || format == 'both') {
    stdout.writeln('${prefix}migration_report.md: ${output.markdownPath}');
  }
  if (format == 'json' || format == 'both') {
    stdout.writeln('${prefix}migration_report.json: ${output.reportJsonPath}');
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
    final dartVersionLabel = _readActiveDartVersion();
    final dartVersion = _SemanticVersion.tryParse(dartVersionLabel);
    final flutterInfo = await _probeFlutter();
    final issues = <String>[];
    final warnings = <String>[];

    if (dartVersion == null) {
      issues.add('Unable to parse active Dart SDK version: $dartVersionLabel');
    } else if (!_verifiedDartFamily.isSameFamilyAs(dartVersion)) {
      issues.add(
        'Unsupported Dart SDK version: ${dartVersion.label}. '
        'GetXDrop verifies Dart ${_verifiedDartFamily.familyLabel} and recommends $_recommendedDartVersionLabel.',
      );
    } else if (!_recommendedDartVersion.isSameVersionAs(dartVersion)) {
      warnings.add(
        'Recommended Dart SDK is $_recommendedDartVersionLabel, '
        'but active Dart is ${dartVersion.label}.',
      );
    }

    if (flutterInfo.errorMessage != null) {
      issues.add(flutterInfo.errorMessage!);
    } else if (flutterInfo.version != null &&
        !_verifiedFlutterFamily.isSameFamilyAs(flutterInfo.version!)) {
      issues.add(
        'Unsupported Flutter SDK version: ${flutterInfo.version!.label}. '
        'GetXDrop verifies Flutter ${_verifiedFlutterFamily.familyLabel} and recommends $_recommendedFlutterVersionLabel.',
      );
    } else if (flutterInfo.version != null &&
        !_recommendedFlutterVersion.isSameVersionAs(flutterInfo.version!)) {
      warnings.add(
        'Recommended Flutter SDK is $_recommendedFlutterVersionLabel, '
        'but active Flutter is ${flutterInfo.version!.label}.',
      );
    }

    return _SdkInfo(
      dartVersion: dartVersionLabel,
      flutterVersion: flutterInfo.version?.label,
      issues: issues,
      warnings: warnings,
    );
  }

  String _readActiveDartVersion() {
    final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(Platform.version);
    return match?.group(1) ?? Platform.version.split(' ').take(2).join(' ');
  }

  Future<_FlutterProbeResult> _probeFlutter() async {
    try {
      final result = await Process.run('flutter', const <String>[
        '--version',
        '--machine',
      ]);
      if (result.exitCode != 0) {
        final stderrOutput = '${result.stderr}'.trim();
        final message = stderrOutput.isEmpty
            ? 'Unable to read Flutter SDK version from PATH.'
            : 'Unable to read Flutter SDK version: $stderrOutput';
        return _FlutterProbeResult(errorMessage: message);
      }
      final payload = jsonDecode('${result.stdout}') as Map<String, Object?>;
      final versionText =
          payload['frameworkVersion'] as String? ??
          payload['flutterVersion'] as String?;
      if (versionText == null) {
        return const _FlutterProbeResult(
          errorMessage:
              'Unable to parse Flutter SDK version from --machine output.',
        );
      }
      return _FlutterProbeResult(
        version: _SemanticVersion.tryParse(versionText),
      );
    } on ProcessException {
      return const _FlutterProbeResult(
        errorMessage: 'Flutter executable not found in PATH.',
      );
    } on FormatException {
      return const _FlutterProbeResult(
        errorMessage:
            'Unable to parse Flutter SDK version from --machine output.',
      );
    }
  }
}

class _SdkInfo {
  const _SdkInfo({
    required this.dartVersion,
    required this.flutterVersion,
    this.issues = const <String>[],
    this.warnings = const <String>[],
  });

  final String? dartVersion;
  final String? flutterVersion;
  final List<String> issues;
  final List<String> warnings;
}

class _FlutterProbeResult {
  const _FlutterProbeResult({this.version, this.errorMessage});

  final _SemanticVersion? version;
  final String? errorMessage;
}

class _SemanticVersion {
  const _SemanticVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  String get label => '$major.$minor.$patch';

  String get familyLabel => '$major.$minor.x';

  bool isSameFamilyAs(_SemanticVersion other) {
    return other.major == major && other.minor == minor;
  }

  bool isSameVersionAs(_SemanticVersion other) {
    return isSameFamilyAs(other) && other.patch == patch;
  }

  static _SemanticVersion? tryParse(String value) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(value.trim());
    if (match == null) {
      return null;
    }
    return _SemanticVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }
}

const _recommendedDartVersion = _SemanticVersion(3, 11, 4);
const _verifiedDartFamily = _SemanticVersion(3, 11, 0);
const _recommendedFlutterVersion = _SemanticVersion(3, 41, 6);
const _verifiedFlutterFamily = _SemanticVersion(3, 41, 0);
const _recommendedDartVersionLabel = '3.11.4';
const _recommendedFlutterVersionLabel = '3.41.6';
