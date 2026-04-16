import 'package:get/get.dart';

import '../catalog/catalog_controller.dart';
import '../orders/orders_controller.dart';
import '../profile/profile_controller.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    Get.lazyPut<CatalogController>(() => CatalogController(), fenix: true);
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
