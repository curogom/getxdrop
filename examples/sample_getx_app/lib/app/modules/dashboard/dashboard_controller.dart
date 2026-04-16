import 'package:get/get.dart';

import '../orders/orders_controller.dart';

class DashboardController extends GetxController {
  int currentTab = 0;

  String get title {
    switch (currentTab) {
      case 0:
        return 'Migration Backlog';
      case 1:
        return 'Orders';
      case 2:
        return 'Profile';
      default:
        return 'GetXDrop Sample';
    }
  }

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args['tabIndex'] is int) {
      currentTab = args['tabIndex'] as int;
      update();
    }
    if (currentTab == 1) {
      Get.find<OrdersController>().loadOrders();
    }
  }

  void changeTab(int index) {
    currentTab = index;
    update();
    if (index == 1) {
      Get.find<OrdersController>().loadOrders();
    }
  }
}
