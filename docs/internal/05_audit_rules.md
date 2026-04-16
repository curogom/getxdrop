# 05. Audit Rules

## 1) 분류 체계

### Category A: State
감지 대상:
- `.obs`
- `Rx*`
- `Obx`
- `GetBuilder`
- `GetxController`
- lifecycle hooks

권장 이관 방향:
- simple reactive primitives -> provider / Notifier 후보
- async loading logic -> AsyncNotifier 후보
- complex mixed controller -> scaffold only + manual migration

### Category B: DI
감지 대상:
- `Get.put`
- `Get.lazyPut`
- `Get.find`
- `Bindings`
- nested registration
- global singleton anti-pattern

권장 이관 방향:
- provider graph 우선
- 필요 시 explicit legacy bridge
- 전역 로케이터 남용은 경고

### Category C: Routing
감지 대상:
- `GetMaterialApp`
- `GetPage`
- `Get.to*`
- `Get.off*`
- `Get.arguments`
- middleware

권장 이관 방향:
- route inventory 생성
- GoRouter draft tree 생성
- call-site rewrite는 초기 버전에서는 주로 수동 처리

### Category D: UI Helper
감지 대상:
- `Get.snackbar`
- `Get.dialog`
- `Get.bottomSheet`
- `Get.context`
- `Get.overlayContext`

권장 이관 방향:
- ScaffoldMessenger
- showDialog / showModalBottomSheet
- route-aware presentation
- global context 의존성 제거

### Category E: Network
감지 대상:
- `GetConnect`
- auth hooks
- request / response modifier
- decoder
- websocket usage

권장 이관 방향:
- Dio client scaffold
- interceptor skeleton
- repository layer shell
- TODO map for manual endpoint migration

## 2) 리스크 모델

### Low
- isolated `.obs`
- simple `Get.toNamed('/foo')`
- isolated `GetBuilder`
- single-purpose tiny controller

### Medium
- controller with light lifecycle logic
- direct `Get.find` lookups across multiple widgets
- snackbar / dialog helpers
- simple Bindings

### High
- controller mixing navigation + API + state + DI
- route-scoped binding lifecycle coupling
- GetConnect auth refresh and custom decoder
- global contextless orchestration
- very large controller classes

## 3) 탐지 방식

### AST-first
가능한 한 AST로 탐지한다.

### String fallback
문법 오류 파일이나 파서 한계 파일에 대해서만 fallback 검색을 허용한다.

### Confidence
각 finding에 confidence를 붙인다.
- high
- medium
- low

## 4) finding 필드 제안

- id
- category
- symbol
- matchedPattern
- filePath
- lineStart
- lineEnd
- riskLevel
- confidence
- migrationHint
- notes

## 5) 주요 패턴 예시

### Pattern: `.obs`
설명:
- primitive 또는 object reactive wrapper

마이그레이션 힌트:
- 상태 성격에 따라 StateProvider / Notifier 후보로 분류
- complex object이면 자동 변환 금지

### Pattern: `GetxController`
설명:
- 상태, lifecycle, DI, navigation까지 섞인 가능성이 높음

마이그레이션 힌트:
- 우선 controller size, dependency count, API call count, nav call count를 측정
- score가 높으면 scaffold only

### Pattern: `GetConnect`
설명:
- 네트워크 레이어와 auth / decoder 로직이 결합될 수 있음

마이그레이션 힌트:
- endpoint inventory를 먼저 뽑고
- Dio client / interceptor / repository shell 생성
- 실제 API semantics는 자동 치환하지 않음

## 6) 우선순위 계산 힌트

우선순위는 단순 빈도보다 다음을 반영한다.

- app entrypoint 영향도
- coupling 정도
- lifecycle complexity
- route dependency
- API dependency
- global access dependency

## 7) audit 결과 해석

Codex 구현 시 리포트는 “무엇이 위험한가”만이 아니라 “무엇부터 처리하면 되는가”까지 보여줘야 한다.

예시 우선순위:
1. `GetMaterialApp` / route registry
2. `GetConnect` / network layer
3. large `GetxController`
4. DI registry cleanup
5. simple reactive widget cleanup
