import 'package:get/get.dart';

import '../../data/services/session_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final SessionService _session = Get.find<SessionService>();

  @override
  Future<void> onReady() async {
    super.onReady();
    await _session.restoreSession();
    if (_session.isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
      return;
    }
    Get.offAllNamed(AppRoutes.login);
  }
}
