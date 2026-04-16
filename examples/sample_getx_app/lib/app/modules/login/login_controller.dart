import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final SessionService _session = Get.find<SessionService>();

  final emailController = TextEditingController(text: 'lead@getxdrop.dev');
  final passwordController = TextEditingController(text: 'pass1234');
  final RxBool obscurePassword = true.obs;
  final RxBool isSubmitting = false.obs;

  Future<void> signIn() async {
    isSubmitting.value = true;
    final success = await _session.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    isSubmitting.value = false;

    if (!success) {
      Get.snackbar(
        'Sign-in failed',
        'Use *@getxdrop.dev with the shared demo password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.snackbar(
      'Session restored',
      'Dashboard bindings and route middleware are now active.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void useManagerPreset() {
    emailController.text = 'lead@getxdrop.dev';
    passwordController.text = 'pass1234';
  }

  void showCredentialHint() {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Demo credentials'),
        content: const Text(
          'Manager: lead@getxdrop.dev\n'
          'Analyst: analyst@getxdrop.dev\n'
          'Shared password: pass1234',
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Close'))],
      ),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
