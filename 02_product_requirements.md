# 02. Product Requirements

## 1) 제품 범위

GetXDrop는 크게 4개 기능을 제공한다.

1. Audit
2. Report
3. Scaffold
4. Safe Apply

## 2) 기능 요구사항

### A. Audit
프로젝트를 스캔해서 GetX 사용 패턴을 분류한다.

감지 대상 예시:
- `.obs`
- `Rx<T>`
- `Obx`
- `GetBuilder`
- `GetxController`
- `Get.put`
- `Get.find`
- `Bindings`
- `GetMaterialApp`
- `Get.to*`
- `Get.dialog`
- `Get.snackbar`
- `GetConnect`

출력:
- usage count
- file location
- code snippet or line references
- risk level
- recommended migration path

### B. Report
사람이 읽을 수 있는 markdown 리포트와 기계가 읽을 수 있는 json 리포트를 생성한다.

출력 포맷:
- `migration_report.md`
- `migration_report.json`

### C. Scaffold
기존 코드를 무리하게 바꾸지 않고 목표 구조의 기본 파일을 생성한다.

예시:
- `lib/app/router/app_router.dart`
- `lib/core/network/dio_client.dart`
- `lib/core/network/interceptors/`
- `lib/features/<feature>/presentation/providers/`
- `lib/features/<feature>/application/`
- `lib/features/<feature>/data/`

### D. Safe Apply
정말 안전한 변경만 자동 적용한다.

예시:
- 의존성 추가 힌트
- import 변경 후보
- 간단한 앱 엔트리 scaffolding
- low-risk rewrite
- TODO comment 삽입

## 3) 비기능 요구사항

- Dry-run 지원
- 분석 결과 재현 가능
- Flutter monorepo 일부까지 고려한 구조
- CI에서 실행 가능한 CLI
- 실패 시 부분 리포트라도 남길 것
- 큰 프로젝트에서도 동작할 수 있도록 점진적 분석 가능

## 4) 비목표

- 의미 분석이 필요한 복합 controller 자동 재작성
- 네비게이션 동작 보존 100% 보장
- 비즈니스 규칙을 이해한 수준의 API 클라이언트 자동 변환
- Bindings 수명주기 완전 복제
- 모든 프로젝트 스타일 가이드 자동 준수

## 5) Persona

### Persona A: 레거시 Flutter 팀
- GetX를 오래 썼다.
- 코드가 크고 복잡하다.
- 한 번에 갈아엎을 수 없다.
- 어디서부터 정리해야 할지 모르겠다.

### Persona B: 신규 이관 팀
- Riverpod 3 / GoRouter / Dio를 쓰고 싶다.
- GetX를 걷어내고 싶지만 리스크가 무섭다.
- 안전한 이관 순서와 리포트가 필요하다.

### Persona C: 오픈소스 / 컨설팅 사용자
- 고객사 프로젝트를 진단하고 싶다.
- 자동변환보다 구조 진단 리포트가 더 중요하다.

## 6) 성공 지표

v0.1 기준:
- `audit`만으로도 유의미한 구조 분석 가능
- markdown/json 리포트 생성 성공
- 샘플 GetX 앱에서 핵심 패턴 분류 가능

v0.2 기준:
- scaffold 생성으로 초기 마이그레이션 작업량 감소
- route inventory / network inventory / state inventory 생성

v0.3 기준:
- low-risk codemod 일부 적용 가능
- 간단한 `.obs` 계열은 후보 scaffold 생성 가능
