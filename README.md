# GetXDrop Handoff Set

GetXDrop는 레거시 GetX 기반 Flutter 앱을 `GoRouter + Dio + Riverpod 3` 구조로 이관하기 위한 마이그레이션 워크벤치다.

이 문서 셋은 Codex가 바로 구현에 착수할 수 있도록 프로젝트 정의, 아키텍처, CLI 스펙, 분석 규칙, 리포트 스키마, 로드맵, 작업 순서를 정리한 핸드오프 패키지다.

## 문서 목록

- `01_project_overview.md`
- `02_product_requirements.md`
- `03_system_architecture.md`
- `04_cli_spec.md`
- `05_audit_rules.md`
- `06_report_schema.md`
- `07_execution_plan.md`
- `08_codex_kickoff_prompt.md`
- `docs/roadmap.md`
- `docs/master_plan.md`

## 핵심 방향

- 이름: **GetXDrop**
- 약칭: **GXD**
- 기본 repo/package/CLI: **`getxdrop`**
- 이 프로젝트는 원클릭 자동변환기가 아니다.
- 1차 목표는 **GetX 의존성을 분해 가능한 상태로 시각화**하는 것이다.
- 1차 구현 우선순위는 `audit` → `report` → `scaffold` → `apply-safe` 순서다.

## 초기 목표 스택

- Routing: GoRouter
- Network: Dio
- State / reactive dependency graph: Riverpod 3
- Optional bridge: GetIt only behind an explicit flag

## 비목표

- GetX 전체 영역 100% 자동 변환
- 의미 추론이 필요한 위젯 트리 전면 재작성
- Bindings / SmartManager / GetConnect 동작 보존의 완전 자동화
- 복잡한 네비게이션 흐름 무손실 치환

## Toolchain

- Flutter SDK manager: `fvm`
- Pinned Flutter: `3.41.6`
- Bundled Dart: `3.11.4`
- 기준: 2026-04-16 시점 stable channel latest를 exact version으로 고정

이 저장소는 floating `stable` 채널이 아니라 검증 가능한 exact version을 사용한다.
새로운 안정 버전으로 올릴 때만 `.fvmrc`를 갱신한다.

## Local Setup

`fvm`이 설치되어 있다면 아래 순서로 동일한 SDK를 맞춘다.

```bash
fvm install
fvm use
fvm flutter --version
fvm dart --version
```

직접 `flutter` 또는 `dart`를 호출하지 않고 아래 형태를 기본으로 사용한다.

```bash
fvm flutter test
fvm dart test
fvm dart run
```

루트 워크스페이스 의존성은 아래 명령으로 맞춘다.

```bash
fvm dart pub get
```

## Workspace Layout

- `packages/analyzer_core`: AST-first GetX 감사 엔진과 정규화 모델
- `packages/report_core`: markdown/json 리포트 렌더러
- `packages/cli`: `doctor`, `audit`, `report` CLI
- `packages/codemod_core`: 향후 safe-apply용 reserved contract
- `packages/templates`: 향후 scaffold용 reserved contract
- `examples/sample_getx_app`: 비교적 복잡한 GetX fixture 앱

## Current Scope

현재 구현 범위는 `Audit MVP`다.

- `doctor`: Flutter 프로젝트 형태와 로컬 toolchain 확인
- `audit`: `lib/**/*.dart` 기준 GetX 사용 패턴을 분석하고 `inventory.json` 생성
- `report`: 기존 inventory 또는 fresh audit 결과로 markdown/json 리포트 생성

기본 산출물은 아래 3개로 고정한다.

- `build/getxdrop/inventory.json`
- `build/getxdrop/migration_report.md`
- `build/getxdrop/migration_report.json`

## Run Commands

샘플 앱을 대상으로 doctor를 실행한다.

```bash
cd packages/cli
fvm dart run bin/getxdrop.dart doctor \
  --project ../../examples/sample_getx_app
```

샘플 앱을 audit하고 markdown/json 리포트를 생성한다.

```bash
cd packages/cli
fvm dart run bin/getxdrop.dart audit \
  --project ../../examples/sample_getx_app \
  --out ../../build/getxdrop \
  --format both
```

이미 생성된 inventory가 있으면 report만 다시 만들 수 있다.

```bash
cd packages/cli
fvm dart run bin/getxdrop.dart report \
  --project ../../examples/sample_getx_app \
  --out ../../build/getxdrop \
  --format both
```

Melos helper script도 같이 제공한다.

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run audit:sample
```

## Development Policy

- Toolchain은 `fvm`으로 고정한다.
- 개발 방식은 TDD를 기본으로 한다.
- 모든 구현은 `Red -> Green -> Refactor` 사이클을 따른다.
- 새 기능은 테스트, 최소 구현, 구조 정리 순서로 진행한다.
