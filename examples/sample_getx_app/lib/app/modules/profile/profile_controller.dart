import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';

class ProfileController extends GetxController {
  final SessionService _session = Get.find<SessionService>();
  final CartController _cartController = Get.find<CartController>();

  final RxBool notificationsEnabled = true.obs;

  Future<void> showSupportSheet() async {
    final context = Get.context;
    final tone = context == null
        ? Colors.white
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    await Get.bottomSheet<void>(
      SafeArea(
        child: Material(
          color: tone,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              runSpacing: 12,
              children: [
                Text(
                  'Support actions',
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Escalate blocked controller'),
                  subtitle: const Text(
                    'Queues a manual review task for a mixed-responsibility controller.',
                  ),
                  onTap: Get.back,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Open migration checklist'),
                  subtitle: const Text(
                    'Shows the runbook for safe cutover steps.',
                  ),
                  onTap: Get.back,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> confirmLogout() async {
    final shouldLogout =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Leave the sample session?'),
            content: const Text(
              'This will clear the cart, drop the token, and send you back through '
              'the login route.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) {
      return;
    }

    _cartController.clear();
    _session.logout();
    Get.offAllNamed(AppRoutes.login);
    Get.snackbar(
      'Signed out',
      'Global session state and cart state were both cleared.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
