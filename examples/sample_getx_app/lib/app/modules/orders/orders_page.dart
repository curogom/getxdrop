import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/demo_models.dart';
import '../../data/services/session_service.dart';
import 'orders_controller.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final session = Get.find<SessionService>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: controller.selectedStage.value == null,
                onSelected: (_) => controller.setStage(null),
              ),
              for (final stage in OrderStage.values)
                FilterChip(
                  label: Text(stage.label),
                  selected: controller.selectedStage.value == stage,
                  onSelected: (_) => controller.setStage(stage),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = controller.visibleOrders;
          if (orders.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No orders for the selected filter.'),
            );
          }

          return Column(
            children: orders
                .map((order) {
                  final isHighlighted =
                      session.lastCompletedOrderId.value == order.id;
                  return Card(
                    elevation: 0,
                    color: isHighlighted
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(order.id),
                      subtitle: Text(
                        '${order.stage.label} · ${order.lineTitles.join(', ')}',
                      ),
                      trailing: Text('\$${order.total.toStringAsFixed(0)}'),
                    ),
                  );
                })
                .toList(growable: false),
          );
        }),
      ],
    );
  }
}
