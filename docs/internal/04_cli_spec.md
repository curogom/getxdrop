# 04. CLI Specification

## 1) v0.2 기본 명령

현재 public command는 아래 3개만 노출한다.

```bash
getxdrop doctor
getxdrop audit
getxdrop report
```

아래 명령은 future work로만 남겨두고 v0.2에서는 구현하지 않는다.

```bash
getxdrop scaffold
getxdrop apply-safe
```

## 2) 커맨드 정의

### `getxdrop doctor`
프로젝트 형태와 현재 PATH runtime을 진단한다.

검사 대상:
- project root validity
- `pubspec.yaml`
- `lib/`
- active Dart SDK
- active Flutter SDK

출력:
- summary lines
- `config: <path>` 또는 `config: not found`
- `issues:` section
- `warnings:` section

정책:
- CLI runtime은 PATH의 `dart`와 `flutter`를 기준으로 한다.
- verified family:
  - Dart `3.11.x`
  - Flutter `3.41.x`
- recommended exact:
  - Dart `3.11.4`
  - Flutter `3.41.6`
- verified family 내부 patch drift는 `warnings:`로 출력한다.
- verified family 밖 버전 또는 미설치는 `issues:`로 출력한다.

예시:

```bash
getxdrop doctor --project .
```

### `getxdrop audit`
프로젝트를 분석하고 normalized inventory를 생성한다.

예시:

```bash
getxdrop audit --project . --out build/getxdrop --format both
```

옵션:
- `--project <path>`
- `--out <path>`
- `--format markdown|json|both`
- `--include-test`
- `--no-include-test`
- `--ignore <glob>`
- `--dry-run`

출력:
- `inventory.json`
- `summary.json`
- optional `migration_report.md`
- optional `migration_report.json`
- compact stdout summary
- top hotspot lines in compact stdout

### `getxdrop report`
이전에 생성된 inventory 또는 즉시 분석 결과를 바탕으로 리포트를 생성한다.

예시:

```bash
getxdrop report --project . --out build/getxdrop --format both
```

옵션:
- `--project <path>`
- `--format markdown|json|both`
- `--out <path>`

출력:
- `summary.json`
- selected report artifacts
- compact stdout summary

## 3) `getxdrop.yaml`

프로젝트 루트 `<project>/getxdrop.yaml` 을 optional config file로 지원한다.

shape:

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

규칙:
- 파일은 optional
- project root에서만 찾는다
- precedence는 `CLI > getxdrop.yaml > built-in default`
- `output.path`는 project root 기준 relative resolve
- `audit.ignore`는 config 값과 CLI `--ignore`를 merge
- `report.format`은 `report` command의 default format에만 적용
- invalid config는 blocking issue로 처리하고 exit code `2`

## 4) 출력 계약

### `inventory.json`
`AuditResult` wire shape를 사용한다.

top-level:
- `schemaVersion`
- `inventory`
- `parseFailures`

### `summary.json`
`CommandSummary` wire shape를 사용한다.

top-level:
- `schemaVersion`
- `command`
- `project`
- `status`
- `exitCode`
- `summary`
- `riskSummary`
- `categoryCounts`
- `planningCounts`
- `topHotspots`

### `migration_report.json`
`ProjectInventory` wire shape를 사용한다.

top-level:
- `schemaVersion`
- `project`
- `summary`
- `riskSummary`
- `categories`
- `routeInventory`
- `networkInventory`
- `controllerInventory`
- `findingDrillDowns`
- `recommendedOrder`
- `findings`

### `migration_report.md`
사람이 읽는 보고서다.

필수 섹션:
- Summary
- Risk Summary
- Categories
- Route Inventory
- Network Inventory
- Controller Inventory
- Explainable Findings
- Recommended Order
- Parse Failures
- Findings

## 5) exit code

- `0`: success
- `1`: generic failure
- `2`: invalid project 또는 blocking toolchain issue
- `3`: analysis partial with recoverable issues

## 6) CLI summary UX

- `audit`와 `report`는 compact summary block을 stdout에 고정 포맷으로 출력한다.
- summary에는 최소 아래가 포함된다:
  - `project`
  - `findings`
  - `parse failures`
  - `risk: low / medium / high`
  - route / network / controller / recommended step count
  - top hotspot lines
  - artifact path
- `dry-run`은 같은 summary를 출력하고 artifact path는 `would write`로 표시한다.

## 7) 향후 커맨드 후보

- `getxdrop scaffold`
- `getxdrop apply-safe`
- `getxdrop explain <finding-id>`
- `getxdrop diff`
- `getxdrop stats`
- `getxdrop config validate`

## 8) CLI UX 규칙

- 기본은 보수적으로 동작
- 출력 계약은 schema-first로 유지
- partial analysis라도 가능한 결과는 남긴다
- 자동 수정 기능은 v0.2에서 노출하지 않는다
