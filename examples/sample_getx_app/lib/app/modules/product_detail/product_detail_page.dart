import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/demo_models.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  Product get _product {
    final value = Get.arguments;
    if (value is Product) {
      return value;
    }
    throw StateError('ProductDetailPage expects a Product in Get.arguments.');
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final product = _product;

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(product.description),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(product.category.label)),
                      if (product.requiresApproval)
                        const Chip(label: Text('Approval required')),
                      for (final tag in product.tags) Chip(label: Text(tag)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Why this route matters',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The page reads Get.arguments directly and then triggers '
                    'Get.offNamedUntil to jump back into the checkout flow.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  cartController.addProduct(product);
                  Get.offNamedUntil(
                    AppRoutes.cart,
                    (route) => route.settings.name == AppRoutes.dashboard,
                  );
                },
                child: const Text('Buy now'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => cartController.addProduct(product),
                child: const Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
