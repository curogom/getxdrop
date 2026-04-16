import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/demo_models.dart';
import '../../data/providers/demo_api_client.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';

class CatalogController extends GetxController {
  final DemoApiClient _apiClient = Get.find<DemoApiClient>();
  final CartController _cartController = Get.find<CartController>();

  final RxList<Product> products = <Product>[].obs;
  final Rx<ProductCategory> selectedCategory = ProductCategory.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  List<Product> get visibleProducts {
    final query = searchQuery.value.trim().toLowerCase();
    return products
        .where((product) {
          final matchesCategory =
              selectedCategory.value == ProductCategory.all ||
              product.category == selectedCategory.value;
          final matchesQuery =
              query.isEmpty ||
              product.title.toLowerCase().contains(query) ||
              product.tags.any((tag) => tag.toLowerCase().contains(query));
          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    isLoading.value = true;
    products.assignAll(await _apiClient.fetchProducts());
    isLoading.value = false;
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  Future<void> openFilters() async {
    final context = Get.context;
    final surfaceColor = context == null
        ? Colors.white
        : Theme.of(context).colorScheme.surface;

    final selected = await Get.bottomSheet<ProductCategory>(
      SafeArea(
        child: Material(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              runSpacing: 12,
              children: [
                Text(
                  'Filter catalog',
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                for (final category in ProductCategory.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(category.label),
                    trailing: category == selectedCategory.value
                        ? const Icon(Icons.check_circle_rounded)
                        : null,
                    onTap: () => Get.back(result: category),
                  ),
                TextButton(
                  onPressed: () => Get.back(result: ProductCategory.all),
                  child: const Text('Reset filter'),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );

    if (selected != null) {
      selectedCategory.value = selected;
    }
  }

  void openDetail(Product product) {
    Get.toNamed(AppRoutes.productDetail, arguments: product);
  }

  void addToCart(Product product) {
    _cartController.addProduct(product);
    Get.snackbar(
      'Added to cart',
      '${product.title} is now queued for checkout.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
