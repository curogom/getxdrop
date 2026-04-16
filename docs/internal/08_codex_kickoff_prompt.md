# 08. Codex Kickoff Prompt

아래 프롬프트를 Codex에게 그대로 넘겨도 된다.

---

You are implementing an open-source Flutter/Dart migration workbench named **GetXDrop**.

## Project identity
- Name: GetXDrop
- Short name: GXD
- Primary package / repo / CLI name: `getxdrop`

## Product definition
GetXDrop is **not** a one-click automatic migration tool.
It is a migration workbench for legacy GetX-based Flutter apps.

Its job is to:
1. audit how GetX is used,
2. classify findings by domain,
3. generate migration reports,
4. scaffold a target architecture,
5. apply only safe codemods.

## Target architecture
- Routing: GoRouter
- Network: Dio
- State / reactive graph: Riverpod 3
- Optional legacy bridge: GetIt only behind an explicit opt-in

## Toolchain
- Use `fvm` for SDK management
- Pin the project to Flutter `3.41.6`
- Use the bundled Dart `3.11.4`
- Do not use a floating Flutter channel in project config
- Prefer `fvm flutter ...` and `fvm dart ...` over calling `flutter` or `dart` directly

## Development workflow
- Use TDD as the default development approach
- Follow the `Red -> Green -> Refactor` cycle for new features and fixes
- Start by locking behavior with tests, then implement the minimum change, then refactor

## Non-goals
- no promise of 100 percent automatic migration
- do not silently rewrite complex semantics
- do not attempt full Bindings lifecycle equivalence
- do not automatically preserve GetConnect business semantics
- do not force Riverpod to be used as DI-only infrastructure

## Immediate objective
Build **v0.1** focused on:
- `doctor`
- `audit`
- `report`
- sample app regression coverage
- CI verification

## Required commands
- `getxdrop doctor`
- `getxdrop audit`
- `getxdrop report`

## Recommended monorepo layout
```text
getxdrop/
  packages/
    cli/
    analyzer_core/
    codemod_core/
    report_core/
    templates/
  examples/
    sample_getx_app/
    migrated_sample/
  docs/
```

## First implementation priorities
1. bootstrap the repository structure
2. define finding models
3. implement audit for core GetX patterns
4. implement markdown and json reports
5. create a realistic sample GetX app
6. lock regression coverage against the sample app
7. add CI verification

## Core findings to detect
### State
- `.obs`
- `Rx*`
- `Obx`
- `GetBuilder`
- `GetxController`
- lifecycle hooks (`onInit`, `onReady`, `onClose`)

### DI
- `Get.put`
- `Get.lazyPut`
- `Get.find`
- `Bindings`

### Routing
- `GetMaterialApp`
- `GetPage`
- `Get.to*`
- `Get.off*`
- `Get.arguments`
- route middleware

### UI Helpers
- `Get.snackbar`
- `Get.dialog`
- `Get.bottomSheet`
- `Get.context`
- `Get.overlayContext`

### Network
- `GetConnect`
- request/response modifiers
- auth hooks
- decoder logic

## Output requirements
Produce:
- `inventory.json`
- `migration_report.md`
- `migration_report.json`

Each finding should include:
- id
- category
- file path
- line range
- snippet
- risk level
- confidence
- migration hint
- recommended target
- requiresManualReview flag

## Risk levels
- Low: isolated, deterministic, local patterns
- Medium: lifecycle / helper / lightweight coupling
- High: mixed responsibilities, routing lifecycle coupling, network/auth complexity, large controllers

## Architecture constraints
- AST-first analysis
- conservative write policy
- dry-run friendly
- partial failure tolerant
- clear docs
- example-driven validation

## Important product philosophy
The first success metric is not “how much code got rewritten.”
The first success metric is “whether a legacy GetX project becomes decomposable and understandable.”

## Deliverables expected from you
1. repository bootstrap
2. package boundaries
3. CLI skeleton
4. finding model
5. rule registry
6. audit implementation for initial patterns
7. report generation
8. sample app
9. CI verification
10. docs needed to run the tool locally

When implementing, prefer explicit models, small packages, testable APIs, and a conservative migration stance.

---

## Codex 작업 지시 요약

- 첫 커밋에서 욕심내지 말고 `doctor + audit + report`까지만 확실하게 만든다.
- codemod는 틀만 잡고 보수적으로 둔다.
- example app을 반드시 포함한다.
- sample app 회귀 테스트와 CI를 같이 고정한다.
- README에서 이 프로젝트가 자동변환기가 아니라는 점을 강하게 명시한다.
