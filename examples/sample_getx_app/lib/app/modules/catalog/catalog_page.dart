import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/demo_models.dart';
import 'catalog_controller.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CatalogController>();

    return RefreshIndicator(
      onRefresh: controller.loadCatalog,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bundle migration tasks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This tab intentionally mixes Rx state, Get.bottomSheet filters, '
                    'route navigation, and cart mutations.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search by task, domain, or tag',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: controller.updateSearch,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: controller.openFilters,
                    icon: const Icon(Icons.tune_rounded),
                    label: const Text('Filters'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final products = controller.visibleProducts;
            if (products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No products match the selected filter.'),
              );
            }

            return Column(
              children: products
                  .map(
                    (product) =>
                        _ProductCard(product: product, controller: controller),
                  )
                  .toList(growable: false),
            );
          }),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.controller});

  final Product product;
  final CatalogController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(product.category.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in product.tags) Chip(label: Text(tag)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => controller.openDetail(product),
                  child: const Text('Inspect'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => controller.addToCart(product),
                  child: Text(product.requiresApproval ? 'Queue' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
