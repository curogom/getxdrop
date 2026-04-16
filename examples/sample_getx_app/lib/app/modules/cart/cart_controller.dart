import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/demo_models.dart';
import '../../data/providers/demo_api_client.dart';
import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';

class CartController extends GetxController {
  final DemoApiClient _apiClient = Get.find<DemoApiClient>();
  final SessionService _session = Get.find<SessionService>();

  final RxList<CartLine> lines = <CartLine>[].obs;
  final RxBool isCheckingOut = false.obs;

  int get itemCount =>
      lines.fold<int>(0, (count, line) => count + line.quantity);

  double get total => lines.fold<double>(0, (sum, line) => sum + line.subtotal);

  void addProduct(Product product) {
    final index = lines.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      lines.add(CartLine(product: product, quantity: 1));
      return;
    }
    final line = lines[index];
    lines[index] = line.copyWith(quantity: line.quantity + 1);
  }

  void updateQuantity(Product product, int quantity) {
    final index = lines.indexWhere((line) => line.product.id == product.id);
    if (index == -1) {
      return;
    }
    if (quantity <= 0) {
      lines.removeAt(index);
      return;
    }
    lines[index] = lines[index].copyWith(quantity: quantity);
  }

  void clear() {
    lines.clear();
  }

  Future<void> checkout() async {
    if (lines.isEmpty) {
      Get.snackbar(
        'Cart is empty',
        'Add at least one migration task before submitting.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirm =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Submit order'),
            content: Text(
              'Push ${lines.length} line items into the approval queue for '
              '\$${total.toStringAsFixed(0)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Submit'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) {
      return;
    }

    final actor = _session.currentUser.value;
    if (actor == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    final hasOverlayContext = Get.overlayContext != null;

    isCheckingOut.value = true;
    try {
      final order = await _apiClient.createOrder(
        actor: actor,
        lines: lines.toList(growable: false),
      );
      lines.clear();
      _session.rememberCompletedOrder(order.id);
      final overlayTone = hasOverlayContext ? 'available' : 'none';
      Get.snackbar(
        'Checkout queued',
        'Order ${order.id} entered ${order.stage.label}. Overlay tone: $overlayTone',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.dashboard, arguments: {'tabIndex': 1});
    } finally {
      isCheckingOut.value = false;
    }
  }
}
