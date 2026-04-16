# GetXDrop

언어:
[English](README.md) |
[한국어](README.ko.md) |
[日本語](README.ja.md) |
[简体中文](README.zh-Hans.md) |
[Español](README.es.md) |
[Português (BR)](README.pt-BR.md)

기본 공개 README는 영어 문서입니다. 이 문서는 한국어 사용자용 요약 버전입니다.

GetXDrop는 레거시 GetX 기반 Flutter 앱을 위한 CLI 중심 마이그레이션 워크벤치입니다.

원클릭 변환을 약속하지 않습니다. 대신 먼저 아래 두 질문에 답할 수 있게 돕습니다.

- 무엇이 위험한가?
- 무엇부터 옮겨야 하는가?

현재 GetXDrop는 `doctor`, `audit`, `report`에 집중합니다. GetX 사용 패턴을 분석하고, machine-readable artifact를 생성하며, route / network / controller / finding 단위 planning context가 담긴 migration report를 만듭니다.

- 저장소: [github.com/curogom/getxdrop](https://github.com/curogom/getxdrop)
- 이슈: [github.com/curogom/getxdrop/issues](https://github.com/curogom/getxdrop/issues)
- 토론: [github.com/curogom/getxdrop/discussions](https://github.com/curogom/getxdrop/discussions)
- 사이트: [curogom.github.io/getxdrop](https://curogom.github.io/getxdrop/)

## 현재 제공 기능 (`v0.1`)

- `doctor`
- `audit`
- `report`
- route inventory
- network inventory
- controller complexity scoring
- explainable finding drill-down
- sample app regression coverage
- analyze / test CI baseline

아직 제공하지 않는 것:

- `getxdrop scaffold`
- `getxdrop apply-safe`
- one-click full migration

## 60초 체험

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

그다음 아래 파일을 확인하면 됩니다.

- `build/getxdrop/inventory.json`
- `build/getxdrop/migration_report.json`
- `build/getxdrop/migration_report.md`

## 공개 명령

```bash
getxdrop doctor
getxdrop audit
getxdrop report
```

루트 워크스페이스 helper:

```bash
fvm dart run melos run analyze
fvm dart run melos run test
fvm dart run melos run audit:sample
```

## 출력 계약

기본 출력 경로는 `build/getxdrop` 입니다.

- `inventory.json`
  top-level `schemaVersion`, `inventory`, `parseFailures`
- `migration_report.md`
  사람이 읽는 report
- `migration_report.json`
  top-level `schemaVersion`, `project`, `summary`, `riskSummary`, `categories`, `routeInventory`, `networkInventory`, `controllerInventory`, `findingDrillDowns`, `recommendedOrder`, `findings`

현재 schema version:

- `inventory.json`: `1`
- `migration_report.json`: `1`

## 배포 정책

`v0.1.x`는 GitHub 우선 공개 라인입니다.

- 공개 홈: GitHub 저장소
- 릴리즈 채널: GitHub Releases
- 사이트: GitHub Pages
- pub.dev: 아직 미배포

현재 CLI는 `getxdrop_analyzer_core`, `getxdrop_report_core`에 의존하므로, pub.dev 공개는 실행 패키지 하나가 아니라 의존 패키지 묶음 전체 전략이 필요합니다.

## 로드맵

### Now

- `doctor`, `audit`, `report`
- stable report artifacts
- route / network / controller planning slices
- explainable finding drill-down

### Next

- `getxdrop.yaml`
- schema versioning / validation
- CI / PR-friendly summaries

### Later

- `scaffold`
- `apply-safe`
- richer `explain`, `diff`, `stats`

## 문서

공개 문서:

- [docs/README.md](docs/README.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/master_plan.md](docs/master_plan.md)
- [docs/public_release_checklist.md](docs/public_release_checklist.md)
- [docs/distribution_strategy.md](docs/distribution_strategy.md)
- [docs/github_launch_runbook.md](docs/github_launch_runbook.md)

내부 설계 문서:

- [docs/internal/README.md](docs/internal/README.md)

## 기여

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [CHANGELOG.md](CHANGELOG.md)
