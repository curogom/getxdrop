import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cart_controller.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Obx(() {
        if (controller.lines.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Cart is empty. Add tasks from the catalog first.'),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final line in controller.lines)
              Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(line.product.title),
                  subtitle: Text(
                    'Qty ${line.quantity} · \$${line.subtotal.toStringAsFixed(0)}',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        onPressed: () => controller.updateQuantity(
                          line.product,
                          line.quantity - 1,
                        ),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      IconButton(
                        onPressed: () => controller.updateQuantity(
                          line.product,
                          line.quantity + 1,
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Obx(
          () => FilledButton(
            onPressed: controller.isCheckingOut.value
                ? null
                : controller.checkout,
            child: controller.isCheckingOut.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Checkout \$${controller.total.toStringAsFixed(0)}'),
          ),
        ),
      ),
    );
  }
}
