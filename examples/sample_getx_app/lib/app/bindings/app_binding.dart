import 'package:get/get.dart';

import '../data/providers/demo_api_client.dart';
import '../data/services/session_service.dart';
import '../modules/cart/cart_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SessionService(), permanent: true);
    Get.put(DemoApiClient(), permanent: true);
    Get.put(CartController(), permanent: true);
  }
}
