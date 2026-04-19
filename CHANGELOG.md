# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, with lightweight entries until the public repository cadence stabilizes.

## [0.2.0] - 2026-04-20

### Added

- optional project config support via `getxdrop.yaml`
- default `summary.json` artifact for `audit` and `report`
- compact CLI summary output for CI logs and PR copy-paste
- config validation with blocking exit code `2`
- hotspot ranking across files, controllers, route modules, categories, and subcategories
- `hotspotInventory` in `migration_report.json`
- `topHotspots` in `summary.json`

### Changed

- `audit` now supports both `--include-test` and `--no-include-test`
- `report` can use config-backed default output path and report format
- public docs now position `v0.2.0` as the Guided Planning completion release

## [0.1.0] - 2026-04-17

### Added

- `doctor`, `audit`, and `report` CLI workflow
- JSON and markdown migration artifacts
- route inventory for declared routes, invocations, and `Get.arguments` access
- network inventory for `GetConnect` clients and transport hooks
- controller complexity scoring for migration planning
- explainable finding drill-down output
- sample GetX app fixture and regression coverage
- CI for workspace analyze and test
