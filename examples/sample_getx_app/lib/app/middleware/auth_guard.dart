import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/session_service.dart';
import '../routes/app_routes.dart';

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<SessionService>();
    if (!session.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
