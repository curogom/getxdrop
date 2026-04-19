# GetXDrop

[![CI](https://github.com/curogom/getxdrop/actions/workflows/ci.yml/badge.svg)](https://github.com/curogom/getxdrop/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-0b8a74.svg)](https://github.com/curogom/getxdrop/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/curogom/getxdrop?display_name=tag)](https://github.com/curogom/getxdrop/releases)

Languages:
[English](README.md) |
[한국어](README.ko.md) |
[日本語](README.ja.md) |
[简体中文](README.zh-Hans.md) |
[Español](README.es.md) |
[Português (BR)](README.pt-BR.md)

GetXDrop is a CLI-first migration workbench for legacy GetX-based Flutter apps.

It is not a one-click rewrite tool. It helps teams answer the two questions that matter first:

- What in this codebase is risky?
- What should we migrate first?

Today, GetXDrop focuses on `doctor`, `audit`, and `report`. It analyzes GetX usage, writes machine-readable artifacts, and turns that analysis into a migration report with route, network, controller, and finding-level planning context.

- Repository: [github.com/curogom/getxdrop](https://github.com/curogom/getxdrop)
- Issues: [github.com/curogom/getxdrop/issues](https://github.com/curogom/getxdrop/issues)
- Discussions: [github.com/curogom/getxdrop/discussions](https://github.com/curogom/getxdrop/discussions)
- Latest release: [GetXDrop v0.2.0](https://github.com/curogom/getxdrop/releases/tag/v0.2.0)
- Site: [curogom.github.io/getxdrop](https://curogom.github.io/getxdrop/)

![GetXDrop preview](https://curogom.github.io/getxdrop/assets/og-preview.svg)

## Why

When a widely used package becomes uncertain, teams need a response path immediately.

GetXDrop is built for that first response window:

- inspect a real GetX app quickly
- surface migration hotspots without pretending the rewrite is trivial
- give teams enough structure to plan a staged move to `GoRouter + Dio + Riverpod 3`

## Available Now (`v0.2`)

- `doctor` for project and toolchain validation
- `audit` for GetX usage analysis
- `report` for markdown and JSON migration reports
- optional `getxdrop.yaml` project config
- default `summary.json` artifact for `audit` and `report`
- compact stdout summaries for CI and PR logs
- hotspot ranking for files, controllers, route modules, categories, and subcategories
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage
- dedicated sample app CLI end-to-end flow coverage
- CI baseline for analyze and test

Not shipped in `v0.2`:

- `getxdrop scaffold`
- `getxdrop apply-safe`
- one-click full GetX migration

## Try It In 60 Seconds

```bash
git clone https://github.com/curogom/getxdrop
cd getxdrop
fvm install && fvm use && fvm dart pub get
cd packages/cli
fvm dart run bin/getxdrop.dart audit \
  --project ../../examples/sample_getx_app \
  --out ../../build/getxdrop \
  --format both
```

Then open:

- `build/getxdrop/inventory.json`
- `build/getxdrop/summary.json`
- `build/getxdrop/migration_report.json`
- `build/getxdrop/migration_report.md`

Optional project config:

```yaml
version: 1

audit:
  include_test: false
  ignore: []

output:
  path: build/getxdrop

report:
  format: both
```

## Commands

Public commands in `v0.2`:

```bash
getxdrop doctor
getxdrop audit
getxdrop report
```

Development helpers from the repository root:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run audit:sample
```

## Output Contracts

Default output directory: `build/getxdrop`

- `inventory.json`
  `AuditResult` wire shape with top-level `schemaVersion`, `inventory`, and `parseFailures`
- `summary.json`
  `CommandSummary` wire shape with top-level `schemaVersion`, `command`, `project`, `status`, `exitCode`, `summary`, `riskSummary`, `categoryCounts`, `planningCounts`, and `topHotspots`
- `migration_report.md`
  human-readable migration report
- `migration_report.json`
  `ProjectInventory` wire shape with top-level `schemaVersion`, `project`, `summary`, `riskSummary`, `categories`, `routeInventory`, `networkInventory`, `controllerInventory`, `hotspotInventory`, `findingDrillDowns`, `recommendedOrder`, and `findings`

Schema policy:

- current `inventory.json` schema version: `1`
- current `summary.json` schema version: `1`
- current `migration_report.json` schema version: `1`
- additive changes should prefer forward-compatible extension
- incompatible wire-shape changes must be called out explicitly in release notes and docs

## Config Precedence

`getxdrop.yaml` is optional and only loaded from the project root passed to the CLI.

- precedence: `CLI flags > getxdrop.yaml > built-in defaults`
- `output.path` is resolved relative to the project root
- `audit.ignore` merges config values with CLI `--ignore`
- `report.format` sets the default format for `getxdrop report`
- `audit` keeps its existing behavior: report artifacts are only written when `--format` is provided

Blocking config problems are reported as exit code `2`.

## Toolchain Policy

CLI runtime uses the `dart` and `flutter` available in `PATH`.

- verified Dart family: `3.11.x`
- verified Flutter family: `3.41.x`
- recommended Dart exact version: `3.11.4`
- recommended Flutter exact version: `3.41.6`

`doctor` behavior:

- verified-family patch drift is reported as `warnings:`
- unsupported family or missing tooling is reported as `issues:`
- blocking issues return exit code `2`

Repository development remains pinned through `fvm` for reproducibility.

## Distribution Policy

`v0.2.x` is GitHub-first.

- primary public home: GitHub repository
- primary release channel: GitHub Releases
- public site: GitHub Pages
- current package registry stance: not published to pub.dev yet

This is intentional: the current CLI depends on `getxdrop_analyzer_core` and `getxdrop_report_core`, so a future pub.dev release needs a package-level publication strategy for the dependency set, not just the executable wrapper.

## Public Roadmap

### Now

- `doctor`, `audit`, `report`
- `getxdrop.yaml` config support
- stable artifacts: `inventory.json`, `summary.json`, `migration_report.*`
- hotspot ranking and top-hotspot summaries
- route / network / controller planning slices
- explainable finding drill-down
- compact CI / PR-friendly CLI summaries

### Next

- `scaffold` assistant for `GoRouter + Dio + Riverpod 3`
- `apply-safe` dry-run-first rewrite candidates

### Later

- richer `explain`, `diff`, and `stats` workflows
- baseline compare and team-friendly CI integrations

## Repository Layout

- `packages/analyzer_core`: audit engine and normalized inventory models
- `packages/report_core`: report renderers
- `packages/cli`: CLI entrypoint
- `packages/codemod_core`: reserved future safe-apply contracts
- `packages/templates`: reserved future scaffold contracts
- `examples/sample_getx_app`: fixture app for regression coverage
- `site/`: static public landing page
- `docs/`: public roadmap, release, operations, and internal docs

## Docs

Public project docs:

- [docs/README.md](docs/README.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/master_plan.md](docs/master_plan.md)
- [docs/launch_kit.md](docs/launch_kit.md)
- [docs/public_release_checklist.md](docs/public_release_checklist.md)
- [docs/maintainer_operations.md](docs/maintainer_operations.md)
- [docs/release_and_support_policy.md](docs/release_and_support_policy.md)
- [docs/distribution_strategy.md](docs/distribution_strategy.md)
- [docs/github_launch_runbook.md](docs/github_launch_runbook.md)

Internal design and implementation docs:

- [docs/internal/README.md](docs/internal/README.md)

## Contributing

See:

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [CHANGELOG.md](CHANGELOG.md)
