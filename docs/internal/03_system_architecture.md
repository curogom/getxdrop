# 03. System Architecture

## 1) 모노레포 구조 제안

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
  .github/
```

## 2) 패키지별 역할

### `packages/cli`
- 사용자 진입점
- argument parsing
- subcommand dispatch
- config loading
- output routing

### `packages/analyzer_core`
- Dart AST 기반 패턴 탐지
- GetX 사용 분류
- file-level / symbol-level 진단 정보 수집
- risk scoring input 생성

### `packages/codemod_core`
- 안전한 rewrite만 담당
- edit plan 생성
- dry-run diff 출력
- TODO comment 삽입

### `packages/report_core`
- `migration_report.md` 생성
- `migration_report.json` 생성
- 통계 요약 / 우선순위 / 권장 순서 정리

### `packages/templates`
- scaffold 파일 템플릿 저장
- GoRouter, Dio, Riverpod 3 기본 스켈레톤
- feature module 템플릿

## 3) 데이터 흐름

1. CLI가 프로젝트 루트를 입력받음
2. analyzer_core가 Dart 파일 집합을 스캔
3. 탐지 결과를 normalized model로 변환
4. report_core가 markdown/json 생성
5. scaffold command는 templates를 기반으로 파일 생성
6. apply-safe는 analyzer result를 바탕으로 codemod_core에서 편집안 작성
7. dry-run 또는 실제 write 적용

## 4) 내부 도메인 모델 예시

### Entity: `Finding`
- id
- category
- subcategory
- filePath
- lineStart
- lineEnd
- snippet
- riskLevel
- recommendation
- confidence

### Entity: `ProjectInventory`
- stateFindings[]
- diFindings[]
- routingFindings[]
- uiFindings[]
- networkFindings[]
- summaryStats
- riskSummary

### Entity: `ScaffoldPlan`
- filesToCreate[]
- notes[]
- featureModules[]

### Entity: `RewriteCandidate`
- filePath
- description
- safetyLevel
- patchPreview
- requiresManualReview

## 5) 기술 방향

### AST 기반 우선
문자열 치환보다 `package:analyzer` 기반 AST 탐지를 우선한다.

이유:
- `.obs`, generic type, method chain 감지가 필요하다.
- `Get.toNamed`와 단순 문자열 검색을 구분해야 한다.
- import alias와 namespace 사용도 감지해야 한다.
- false positive를 줄여야 한다.

### 설정 파일
향후 `getxdrop.yaml` 같은 프로젝트 설정 파일을 고려한다.

예시:
- feature root path
- ignore globs
- legacy DI bridge allow
- route strategy
- report format defaults

## 6) 패턴 분류 축

### State
- Rx field
- reactive widget
- controller lifecycle
- async state

### DI
- direct registration
- lazy registration
- lookup usage
- route-scoped binding

### Routing
- app-level router
- route declaration
- route invocation
- argument passing

### UI Helper
- dialog
- snackbar
- bottom sheet
- global context access

### Network
- client declaration
- endpoint call
- auth hook
- response transform
- decoder

## 7) 타깃 스택 생성 원칙

### GoRouter
- route inventory 생성
- typed params 후보 생성
- 기존 named route에서 path tree 초안 생성

### Dio
- client
- interceptor
- auth refresh placeholder
- repository shell

### Riverpod 3
- stateful 대상은 Notifier / AsyncNotifier 후보
- 단순 인프라 객체는 plain provider 또는 plain constructor injection 후보
- DI 전용 사용을 강제하지 않음
