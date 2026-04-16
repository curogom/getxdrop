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

    test('detects routing, UI helper, and network patterns', () {
      final result = engine.auditSources(<String, String>{
        'lib/app.dart': '''
            import 'package:get/get.dart' as gx;

            final root = gx.GetMaterialApp(
              getPages: <gx.GetPage<dynamic>>[
                gx.GetPage(name: '/home', page: HomePage.new),
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
      final roundTrip = ProjectInventory.fromJson(decoded);

      expect(roundTrip.project.flutterVersion, '3.41.6');
      expect(roundTrip.project.dartVersion, '3.11.4');
      expect(roundTrip.findings.single.subcategory, 'obs');
    });
  });
}
