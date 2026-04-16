# sample_getx_app

GetXDrop의 `audit` 대상 검증용으로 만든 복합 GetX 샘플 앱이다.

## 포함한 흐름

- splash -> login
- dashboard with tabs
- catalog -> product detail -> cart -> checkout
- orders review
- profile / logout / support actions

## 의도적으로 포함한 GetX 패턴

- `GetMaterialApp`
- `GetPage`
- `Bindings`
- `Get.put`, `Get.lazyPut`, `Get.find`
- `.obs`, `Rx<T>`, `Rxn<T>`
- `Obx`, `GetBuilder`
- `Get.toNamed`, `Get.offNamedUntil`, `Get.offAllNamed`
- `Get.arguments`
- `Get.snackbar`, `Get.dialog`, `Get.bottomSheet`
- `Get.context`, `Get.overlayContext`
- `GetConnect` with request modifier, authenticator, decoder

## 데모 계정

- `lead@getxdrop.dev`
- `analyst@getxdrop.dev`
- password: `pass1234`
