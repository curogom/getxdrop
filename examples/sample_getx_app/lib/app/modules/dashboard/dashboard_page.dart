import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../catalog/catalog_page.dart';
import '../orders/orders_page.dart';
import '../profile/profile_page.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    final cartController = Get.find<CartController>();

    return GetBuilder<DashboardController>(
      builder: (controller) {
        final pages = [
          const CatalogPage(),
          const OrdersPage(),
          const ProfilePage(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(controller.title),
            actions: [
              Obx(
                () => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Badge(
                    label: Text('${cartController.itemCount}'),
                    isLabelVisible: cartController.itemCount > 0,
                    child: IconButton(
                      onPressed: () => Get.toNamed(AppRoutes.cart),
                      icon: const Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(28),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Obx(
                  () => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${session.currentUser.value?.name ?? 'Unknown user'}'
                      ' · ${session.currentUser.value?.role ?? 'Signed out'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[controller.currentTab],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.currentTab,
            onDestinationSelected: controller.changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_customize_outlined),
                label: 'Catalog',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
