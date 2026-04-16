# 07. Execution Plan

## 1) 개발 단계

### Phase 0: 저장소 초기화
목표:
- mono package layout 생성
- basic README 작성
- sample app skeleton 추가

완료 기준:
- repo bootstrapped
- package graph 정리
- CI placeholder 생성

### Phase 1: Audit MVP
목표:
- GetX 핵심 패턴 분석
- markdown/json report 생성
- sample app 회귀 검증 고정
- CI 검증 연결

포함:
- `.obs`
- `Rx*`
- `Obx`
- `GetxController`
- `Get.put`
- `Get.find`
- `GetMaterialApp`
- `Get.to*`
- route middleware
- `GetConnect`

완료 기준:
- sample project에서 meaningful report 생성
- parse failure handling 존재
- `inventory.json` / `migration_report.json` 계약 고정
- `melos run analyze` / `melos run test` 기준 green

### Phase 2: Scaffold MVP
목표:
- target architecture 기본 파일 생성

포함:
- GoRouter shell
- Dio client shell
- Riverpod provider shell

완료 기준:
- 생성 파일이 Flutter 프로젝트 내에서 자연스러운 위치에 들어감
- dry-run 지원

### Phase 3: Safe Apply MVP
목표:
- low-risk rewrite 일부 적용

포함:
- import hints
- TODO comment insertion
- app entry scaffolding hints
- simple low-risk candidate rewrite

완료 기준:
- dry-run diff 가능
- write mode 명시적 opt-in

## 2) 우선 작업 순서

1. repo 구조 생성
2. analyzer_core의 finding model 정의
3. audit command 구현
4. report core 구현
5. example app 작성
6. sample app 회귀 테스트 고정
7. CI 연결
8. scaffold command 구현
9. safe apply 일부 구현

## 3) 샘플 앱 요구사항

샘플 앱은 너무 단순하면 안 된다.
아래 요소를 반드시 포함한다.

- `GetMaterialApp`
- route declaration
- route middleware
- simple `Get.toNamed`
- `GetxController`
- `.obs`
- `Rx*`
- `Obx`
- `Get.put` / `Get.find`
- `GetConnect` 또는 최소 network wrapper 예시

이 샘플이 있어야 audit 품질을 검증할 수 있다.

## 4) 리스크 관리

### 리스크 A: 범위 폭주
대응:
- v0.1은 `doctor + audit + report + sample app regression + CI`까지로 고정

### 리스크 B: false positive
대응:
- AST 우선
- confidence 표기
- parse failure fallback 구분

### 리스크 C: codemod 신뢰도 부족
대응:
- apply-safe는 low-risk만
- dry-run 기본
- write 명시 opt-in

### 리스크 D: 사용자 기대 과장
대응:
- README에서 one-click migration 아님을 강하게 명시

## 5) 권장 이슈 보드

### Epic 1: Foundation
- repo bootstrap
- package boundaries
- CI
- config model

### Epic 2: Analysis
- finding model
- AST visitors
- rule registry
- risk scoring

### Epic 3: Reporting
- markdown report
- json schema
- summary tables
- ordering algorithm

### Epic 4: Scaffolding
- templates
- generation strategy
- overwrite policy

### Epic 5: Safe Apply
- edit plan
- diff preview
- TODO insertion

## 6) Definition of Done

각 기능은 아래를 만족해야 done으로 본다.

- example app에서 동작
- CLI help 존재
- error handling 존재
- dry-run 또는 preview 가능
- README 또는 docs 반영 완료
- TDD / `Red -> Green -> Refactor` 순서로 구현됨
