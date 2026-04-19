# GetXDrop Master Plan

## Summary

- Product direction is fixed as a `CLI-first OSS` for legacy Flutter teams.
- Planning is managed with aligned phases across two views:
  - Service roadmap for user value and adoption
  - Development roadmap for implementation and architecture
- The current execution slice is `v0.2.0 / Guided Planning completion`.
- The immediate target is to close Guided Planning with config support, summary artifacts, and CI-friendly summaries while keeping the public command set fixed at `doctor + audit + report`.

## Working Principles

- Toolchain is pinned with `fvm`.
- Development defaults to TDD.
- All feature work follows `Red -> Green -> Refactor`.
- New capabilities should be introduced with failing tests first, then minimal implementation, then cleanup.

## Service Roadmap

### Phase 0: Problem Validation

- Position GetXDrop as a migration workbench, not a one-click converter.
- Deliver reports that help teams decide where to start.
- Exit criteria:
  - Example app output is meaningful.
  - One or two real legacy apps confirm the report is actionable.

### Phase 1: Audit MVP

- Value:
  - Scan a local Flutter project and surface GetX usage, risk, and suggested order of work.
- UX:
  - `doctor`, `audit`, and `report` should cover the first diagnosis workflow.
- Outputs:
  - `inventory.json` as `AuditResult`
  - `summary.json` as `CommandSummary`
  - Markdown report
  - `migration_report.json` as `ProjectInventory`
  - Parse failure inventory
  - Category and risk summaries
- Success criteria:
  - The tool answers both:
    - What is risky?
    - What should be migrated first?
  - The sample app is covered by regression tests across State, DI, Routing, UI Helper, and Network.
  - The sample app has a dedicated CLI end-to-end flow test for `doctor -> audit -> report`.
  - `melos run analyze` and `melos run test` are green in CI.

### Phase 2: Guided Planning

- Value:
  - Move from raw detection to migration planning support.
- Planned features:
  - Route inventory
  - Network inventory
  - Controller complexity score
  - Explainable finding drill-down
  - `getxdrop.yaml`
- Current status:
  - Route inventory, network inventory, controller complexity, and explainable finding drill-down are present in the report output.
  - `getxdrop.yaml`, `summary.json`, compact CLI summaries, and hotspot ranking complete the planning slice in `v0.2.0`.
- Success criteria:
  - A team can derive a migration work breakdown directly from CLI output.

### Phase 3: Scaffold Assistant

- Value:
  - Reduce the cost of starting the target architecture.
- Planned features:
  - GoRouter shell generation
  - Dio client and interceptor shell
  - Riverpod 3 application and data skeletons
- Success criteria:
  - New target structure can be prepared in parallel without mutating legacy code first.

### Phase 4: Safe Apply Beta

- Value:
  - Remove repetitive low-risk work without overpromising automation.
- Planned features:
  - TODO insertion
  - Import hints
  - Simple helper and route rewrite candidates
  - Diff preview
- Success criteria:
  - Automation remains dry-run-first and does not reduce trust.

### Phase 5: Team Adoption

- Value:
  - Support repeated team use and CI adoption.
- Planned features:
  - Stable machine-readable outputs
  - CI summary support
  - Baseline comparison and diffs
  - Artifact-friendly reports
- Success criteria:
  - The tool becomes useful in team workflows, not just local diagnosis.

### Phase 6: Optional Product Expansion

- Default strategy:
  - Remain CLI-first.
- Later options:
  - Report viewer
  - Desktop UX
  - Hosted report portal
- Constraint:
  - Only evaluate after the CLI workflow and schema are stable.

## Development Roadmap

### Phase A: Foundation

- Set up root `pubspec.yaml` with `workspace` and `melos`.
- Fix package boundaries:
  - `cli`
  - `analyzer_core`
  - `report_core`
  - `codemod_core`
  - `templates`
- Keep `codemod_core` and `templates` as reserved contracts first.
- Preserve the sample GetX app as an integration fixture.

### Phase B: Analysis Core

- Define normalized core models:
  - `Finding`
  - `ProjectInventory`
  - `SummaryStats`
  - `RiskSummary`
  - `ParseFailure`
  - `RecommendedStep`
  - `AuditConfig`
  - `AuditResult`
- Build an AST-first rule engine.
- Restrict string fallback scanning to parse-failure files.
- Initial rule coverage:
  - `.obs`
  - `Rx*`
  - `Obx`
  - `GetBuilder`
  - `GetxController`
  - lifecycle methods
  - `Get.put`
  - `Get.lazyPut`
  - `Get.find`
  - `Bindings`
  - `GetMaterialApp`
  - `GetPage`
  - `Get.to*`
  - `Get.off*`
  - `Get.arguments`
  - route middleware
  - UI helpers
  - `GetConnect`

### Phase C: Report Core

- Render markdown and JSON outputs from normalized inventory.
- Fix schema shape and finding ID rules.
- Start with a rule-based recommended order.
- Stabilize:
  - Summary counts
  - Risk summary
  - Category grouping
  - Finding detail formatting

### Phase D: CLI MVP

- Expose only:
  - `doctor`
  - `audit`
  - `report`
- Do not expose:
  - `scaffold`
  - `apply-safe`
- Standardize output directory:
  - `build/getxdrop/`
- Standardize artifacts:
  - `inventory.json`
  - `summary.json`
  - `migration_report.md`
  - `migration_report.json`
- Standardize exit codes:
  - success
  - invalid project
  - partial analysis
- `doctor` should:
  - validate project shape
  - inspect PATH runtime
  - print `issues:` and `warnings:` separately
  - treat verified-family drift as warning, not failure

### Phase E: Validation and Docs

- Lock fixture expectations with integration tests.
- Document setup and execution in the repo.
- Maintain regression checks against the sample GetX app.
- Add minimal GitHub Actions for analyze and test.
- Document config precedence, summary artifacts, and CI-friendly stdout.

### Phase F: Scaffold Prep

- Define scaffold inputs and overwrite policy.
- Connect audit inventory to future scaffold generation.
- Defer actual generation to a later slice.

### Phase G: Safe Apply Prep

- Reserve:
  - `RewriteCandidate`
  - `EditPlan`
- Define low-risk safety policy and dry-run diff contract.
- Defer codemod implementation to a later slice.

## Immediate Execution Plan: Audit MVP

- Bootstrap the repository as a Melos monorepo.
- Implement working packages:
  - `packages/cli`
  - `packages/analyzer_core`
  - `packages/report_core`
- Keep `packages/codemod_core` and `packages/templates` as reserved placeholders.
- `doctor` validates:
  - Flutter project shape
  - `pubspec.yaml`
  - `lib/`
  - active PATH Flutter and Dart version visibility
  - verified family and recommended exact versions
- `audit` scans:
  - `lib/**/*.dart`
  - optionally `test/**/*.dart` with `--include-test`
- `audit` normalizes output into `ProjectInventory`.
- `report` reuses an existing inventory when present, otherwise runs a fresh audit first.
- Default exclusions:
  - `.dart_tool`
  - `build`
  - generated platform code
  - `GeneratedPluginRegistrant` variants
- Confidence policy:
  - AST direct match -> `high`
  - AST inference -> `medium`
  - fallback scan -> `low`
- Risk policy:
  - `.obs`, simple route calls -> `low`
  - lifecycle, DI lookup, UI helpers -> `medium`
  - `GetxController`, routing infra, `GetConnect` -> `high`
- This slice does not expose:
  - `scaffold`
  - `apply-safe`
- Development policy for this slice:
  - TDD by default
  - `Red -> Green -> Refactor`
  - tests before behavior changes

## Public Interfaces

### CLI Commands

- `getxdrop doctor --project <path>`
- `getxdrop audit --project <path> --out <path> [--format markdown|json|both] [--include-test|--no-include-test] [--ignore <glob>] [--dry-run]`
- `getxdrop report --project <path> --out <path> --format markdown|json|both`

### Output Files

- `inventory.json`
- `summary.json`
- `migration_report.md`
- `migration_report.json`

### Core Types

- `Finding`
- `ProjectInventory`
- `RecommendedStep`
- `AuditConfig`
- `AuditResult`

### Reserved Interfaces

- `RewriteCandidate`
- `EditPlan`
- Scaffold generation input contract

## Test Plan

### Analyzer Core

- Each rule should have at least:
  - one positive case
  - one negative case
- Include alias import and chained call cases.
- Verify fallback findings are emitted for parse-failure files only.

### Report Core

- Snapshot markdown and JSON output from a fixed inventory fixture.
- Verify:
  - finding IDs
  - risk summary
  - category grouping
  - recommended order

### CLI Integration

- `doctor` succeeds on a valid sample app.
- `doctor` returns exit code `0` with warnings for supported family drift.
- `doctor` returns exit code `2` for invalid projects.
- `audit` writes inventory and reports.
- `report` reuses existing inventory.
- Partial analysis returns recoverable exit code `3`.

### Fixture Acceptance

- `sample_getx_app` must emit findings in:
  - State
  - DI
  - Routing
  - UI Helper
  - Network
- Required detections include:
  - `.obs`
  - `Rx*`
  - `Obx`
  - `Get.put`
  - `Get.find`
  - `GetMaterialApp`
  - `Get.to*`
  - `Get.arguments`
  - route middleware
  - `GetConnect`
- The fixture must produce at least one `low`, `medium`, and `high` risk finding.

### Example App Smoke Coverage

- Existing example app tests must remain green.

## Assumptions

- Hosted SaaS is out of scope for now.
- CLI adoption and schema stability come first.
- The example app remains the main integration fixture.
- Fixture expansion happens only when audit accuracy needs broader coverage.
- The Definition of Done for this slice is:
  - meaningful audit and report generation against the example app
