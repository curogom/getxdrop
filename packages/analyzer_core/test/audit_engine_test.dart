import 'dart:convert';

import 'package:getxdrop_analyzer_core/getxdrop_analyzer_core.dart';
import 'package:test/test.dart';

void main() {
  group('AuditEngine', () {
    final engine = AuditEngine();

    test('detects state patterns and avoids unrelated code', () {
      final result = engine.auditSources(<String, String>{
        'lib/state_demo.dart': '''
            import 'package:get/get.dart';

            class DemoController extends GetxController {
              final count = 0.obs;
              final Rx<int> total = Rx<int>(0);

              @override
              void onInit() {
                super.onInit();
              }
            }

            class DemoView {
              Widget build() {
                return Obx(() => GetBuilder<DemoController>(builder: (_) => const Placeholder()));
              }
            }
          ''',
        'lib/plain.dart': 'class PlainState { final value = 1; }',
      }, projectRoot: '/repo');

      final subcategories = result.inventory.findings.map(
        (item) => item.subcategory,
      );
      expect(
        subcategories,
        containsAll(<String>[
          'obs',
          'rxType',
          'getxController',
          'lifecycle',
          'obx',
          'getBuilder',
        ]),
      );
      expect(
        result.inventory.findings.where(
          (item) => item.filePath == 'lib/plain.dart',
        ),
        isEmpty,
      );
    });

    test('detects DI rules including alias import lookups', () {
      final result = engine.auditSources(<String, String>{
        'lib/di_demo.dart': '''
            import 'package:get/get.dart' as gx;

            class DemoBinding extends gx.Bindings {
              @override
              void dependencies() {
                gx.Get.put(Service());
                gx.Get.lazyPut<Service>(() => Service());
                gx.Get.find<Service>();
              }
            }

            class Service {}
          ''',
      }, projectRoot: '/repo');

      final subcategories = result.inventory.findings
          .map((item) => item.subcategory)
          .toList();
      expect(
        subcategories,
        containsAll(<String>['bindings', 'getPut', 'getLazyPut', 'getFind']),
      );
    });

    test('detects routing, middleware, UI helper, and network patterns', () {
      final result = engine.auditSources(<String, String>{
        'lib/app.dart': '''
            import 'package:get/get.dart' as gx;

            class AuthGuard extends gx.GetMiddleware {}

            final root = gx.GetMaterialApp(
              getPages: <gx.GetPage<dynamic>>[
                gx.GetPage(
                  name: '/home',
                  page: HomePage.new,
                  middlewares: <gx.GetMiddleware>[AuthGuard()],
                ),
              ],
            );

            void openRoute() {
              gx.Get.toNamed('/detail');
              gx.Get.offAllNamed('/home');
              final args = gx.Get.arguments;
              final c = gx.Get.context;
              final o = gx.Get.overlayContext;
              gx.Get.snackbar('a', 'b');
              gx.Get.dialog(const Placeholder());
              gx.Get.bottomSheet(const Placeholder());
            }

            class ApiClient extends gx.GetConnect {
              @override
              void onInit() {
                httpClient.addRequestModifier<dynamic>((request) => request);
                httpClient.addAuthenticator<dynamic>((request) async => request);
                httpClient.defaultDecoder = (body) => body;
                super.onInit();
              }
            }

            class HomePage extends Placeholder {
              const HomePage();
            }
          ''',
      }, projectRoot: '/repo');

      final subcategories = result.inventory.findings
          .map((item) => item.subcategory)
          .toList();
      expect(
        subcategories,
        containsAll(<String>[
          'getMaterialApp',
          'getPage',
          'middleware',
          'getTo',
          'getOff',
          'getArguments',
          'context',
          'overlayContext',
          'snackbar',
          'dialog',
          'bottomSheet',
          'getConnect',
          'requestModifier',
          'authenticator',
          'decoder',
        ]),
      );
    });

    test('detects specialized Rx types including inferred constructors', () {
      final result = engine.auditSources(<String, String>{
        'lib/session_service.dart': '''
            import 'package:get/get.dart';

            class SessionService extends GetxService {
              final Rxn<String> currentUserId = Rxn<String>();
              final RxnString accessToken = RxnString();
              final refreshToken = RxnString();
            }
          ''',
      }, projectRoot: '/repo');

      final rxTypeFindings = result.inventory.findings
          .where((item) => item.subcategory == 'rxType')
          .toList(growable: false);

      expect(rxTypeFindings, hasLength(3));
      expect(
        rxTypeFindings.map((item) => item.snippet),
        containsAll(<String>[
          'final Rxn<String> currentUserId = Rxn<String>();',
          'final RxnString accessToken = RxnString();',
          'final refreshToken = RxnString();',
        ]),
      );
    });

    test('builds route and network inventories for guided planning', () {
      final result = engine.auditSources(<String, String>{
        'lib/app.dart': '''
            import 'package:get/get.dart' as gx;

            class AuthGuard extends gx.GetMiddleware {}

            class LoginBinding extends gx.Bindings {
              @override
              void dependencies() {}
            }

            final pages = <gx.GetPage<dynamic>>[
              gx.GetPage(
                name: '/login',
                page: LoginPage.new,
                binding: LoginBinding(),
                middlewares: <gx.GetMiddleware>[AuthGuard()],
              ),
            ];

            void openRoute() {
              gx.Get.toNamed('/detail', arguments: 1);
              gx.Get.offAllNamed('/home');
              final args = gx.Get.arguments;
            }

            class ApiClient extends gx.GetConnect {
              @override
              void onInit() {
                httpClient.addRequestModifier<dynamic>((request) => request);
                httpClient.addAuthenticator<dynamic>((request) async => request);
                httpClient.defaultDecoder = (body) => body;
                super.onInit();
              }

              Future<String> fetchUser() async => 'ok';
              Future<void> submitOrder() async {}
            }

            class LoginPage {
              const LoginPage();
            }
          ''',
      }, projectRoot: '/repo');

      expect(result.inventory.routeInventory.declarations, hasLength(1));
      expect(result.inventory.routeInventory.invocations, hasLength(2));
      expect(result.inventory.routeInventory.argumentAccesses, hasLength(1));
      expect(
        result.inventory.routeInventory.declarations.single.routeName,
        '/login',
      );
      expect(
        result.inventory.routeInventory.declarations.single.binding,
        'LoginBinding()',
      );
      expect(
        result.inventory.routeInventory.declarations.single.middlewares,
        contains('AuthGuard()'),
      );
      expect(
        result.inventory.routeInventory.invocations.map(
          (item) => item.routeName,
        ),
        containsAll(<String>['/detail', '/home']),
      );
      expect(
        result.inventory.networkInventory.clients.single.clientName,
        'ApiClient',
      );
      expect(
        result.inventory.networkInventory.clients.single.publicMethods,
        containsAll(<String>['fetchUser', 'submitOrder']),
      );
      expect(
        result.inventory.networkInventory.clients.single.hasRequestModifier,
        isTrue,
      );
      expect(
        result.inventory.networkInventory.clients.single.hasAuthenticator,
        isTrue,
      );
      expect(
        result.inventory.networkInventory.clients.single.hasDecoder,
        isTrue,
      );
      final networkFinding = result.inventory.findings.firstWhere(
        (item) => item.subcategory == 'getConnect',
      );
      final drillDown = result.inventory.findingDrillDowns.firstWhere(
        (item) => item.findingId == networkFinding.id,
      );
      expect(drillDown.relatedSteps, contains('Network abstraction migration'));
      expect(drillDown.evidence, anyElement(contains('ApiClient')));
    });

    test('scores controller complexity for migration planning', () {
      final result = engine.auditSources(<String, String>{
        'lib/catalog_controller.dart': '''
            import 'package:get/get.dart';

            class DemoApiClient {
              Future<void> fetchProducts() async {}
            }

            class DemoCartController {
              void addProduct(Object value) {}
            }

            class CatalogController extends GetxController {
              final DemoApiClient _apiClient = Get.find<DemoApiClient>();
              final DemoCartController _cartController = Get.find<DemoCartController>();

              final RxList<String> products = <String>[].obs;
              final RxBool isLoading = false.obs;

              @override
              void onInit() {
                super.onInit();
                loadCatalog();
              }

              Future<void> loadCatalog() async {
                isLoading.value = true;
                await _apiClient.fetchProducts();
                isLoading.value = false;
              }

              Future<void> openFilters() async {
                await Get.bottomSheet('filters');
              }

              void openDetail(String product) {
                Get.toNamed('/detail', arguments: product);
              }

              void addToCart(String product) {
                _cartController.addProduct(product);
                Get.snackbar('Added', product);
              }
            }
          ''',
      }, projectRoot: '/repo');

      expect(result.inventory.controllerInventory.controllers, hasLength(1));

      final controller =
          result.inventory.controllerInventory.controllers.single;
      expect(controller.controllerName, 'CatalogController');
      expect(controller.dependencyCount, 2);
      expect(controller.reactiveFieldCount, 2);
      expect(controller.lifecycleMethodCount, 1);
      expect(controller.navigationCallCount, 1);
      expect(controller.apiCallCount, 1);
      expect(controller.globalLookupCount, 2);
      expect(controller.uiHelperCallCount, 2);
      expect(controller.riskLevel, RiskLevel.high);
      expect(controller.totalScore, greaterThanOrEqualTo(12));
      expect(
        controller.hotspots,
        containsAll(<String>[
          'dependencies',
          'api',
          'navigation',
          'uiHelper',
          'lifecycle',
        ]),
      );
    });

    test('falls back to string scan for parse failure files', () {
      final result = engine.auditSources(<String, String>{
        'lib/broken.dart': '''
            import 'package:get/get.dart';

            void broken( {
              final count = 0.obs;
              Get.toNamed('/detail');
            }
          ''',
      }, projectRoot: '/repo');

      expect(result.parseFailures, hasLength(1));
      expect(
        result.inventory.findings.every(
          (item) => item.confidence == ConfidenceLevel.low,
        ),
        isTrue,
      );
      expect(
        result.inventory.findings.map((item) => item.subcategory),
        containsAll(<String>['obs', 'getTo']),
      );
    });

    test('serializes and deserializes inventory JSON', () {
      final result = engine.auditSources(
        <String, String>{
          'lib/sample.dart': '''
            import 'package:get/get.dart';
            final count = 0.obs;
          ''',
        },
        projectRoot: '/repo',
        flutterVersion: '3.41.6',
        dartVersion: '3.11.4',
      );

      final decoded =
          jsonDecode(result.inventory.toPrettyJson()) as Map<String, Object?>;
      final decodedAuditResult =
          jsonDecode(result.toPrettyJson()) as Map<String, Object?>;
      final roundTrip = ProjectInventory.fromJson(decoded);
      final auditRoundTrip = AuditResult.fromJson(decodedAuditResult);

      expect(decoded['schemaVersion'], 1);
      expect(decodedAuditResult['schemaVersion'], 1);
      expect(roundTrip.project.flutterVersion, '3.41.6');
      expect(roundTrip.project.dartVersion, '3.11.4');
      expect(roundTrip.findings.single.subcategory, 'obs');
      expect(roundTrip.routeInventory.declarations, isEmpty);
      expect(roundTrip.networkInventory.clients, isEmpty);
      expect(roundTrip.controllerInventory.controllers, isEmpty);
      expect(decoded, contains('hotspotInventory'));
      expect(roundTrip.findingDrillDowns.single.findingId, 'GXD-STATE-001');
      expect(auditRoundTrip.inventory.findings.single.subcategory, 'obs');
    });
  });
}
