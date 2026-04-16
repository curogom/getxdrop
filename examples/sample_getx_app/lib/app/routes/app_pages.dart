import 'package:get/get.dart';

import '../middleware/auth_guard.dart';
import '../modules/cart/cart_page.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_page.dart';
import '../modules/product_detail/product_detail_page.dart';
import '../modules/splash/splash_controller.dart';
import '../modules/splash/splash_page.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
    ),
    GetPage(name: AppRoutes.cart, page: () => const CartPage()),
  ];
}
