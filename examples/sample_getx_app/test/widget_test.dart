import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:sample_getx_app/app/data/providers/demo_api_client.dart';
import 'package:sample_getx_app/app/data/services/session_service.dart';
import 'package:sample_getx_app/app/modules/cart/cart_controller.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(SessionService(), permanent: true);
    Get.put(DemoApiClient(), permanent: true);
    Get.put(CartController(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  test('session service signs in demo manager and stores token', () async {
    final session = Get.find<SessionService>();

    final signedIn = await session.signIn(
      email: 'lead@getxdrop.dev',
      password: 'pass1234',
    );

    expect(signedIn, isTrue);
    expect(session.currentUser.value?.email, 'lead@getxdrop.dev');
    expect(session.accessToken.value, isNotNull);
  });

  test(
    'cart controller merges duplicate products into one line item',
    () async {
      final apiClient = Get.find<DemoApiClient>();
      final cartController = Get.find<CartController>();
      final product = (await apiClient.fetchProducts()).first;

      cartController.addProduct(product);
      cartController.addProduct(product);

      expect(cartController.itemCount, 2);
      expect(cartController.lines, hasLength(1));
      expect(cartController.lines.single.quantity, 2);
    },
  );
}
