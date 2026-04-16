import 'package:get/get.dart';

import '../../data/models/demo_models.dart';
import '../../data/providers/demo_api_client.dart';
import '../../data/services/session_service.dart';

class OrdersController extends GetxController {
  final DemoApiClient _apiClient = Get.find<DemoApiClient>();
  final SessionService _session = Get.find<SessionService>();

  final RxList<OrderSummary> orders = <OrderSummary>[].obs;
  final Rxn<OrderStage> selectedStage = Rxn<OrderStage>();
  final RxBool isLoading = false.obs;

  List<OrderSummary> get visibleOrders {
    final stage = selectedStage.value;
    if (stage == null) {
      return orders;
    }
    return orders
        .where((order) => order.stage == stage)
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    final user = _session.currentUser.value;
    if (user == null) {
      orders.clear();
      return;
    }

    isLoading.value = true;
    orders.assignAll(await _apiClient.fetchOrders(user.email));
    isLoading.value = false;
  }

  void setStage(OrderStage? stage) {
    selectedStage.value = stage;
  }
}
