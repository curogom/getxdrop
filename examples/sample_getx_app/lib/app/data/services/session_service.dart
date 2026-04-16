import 'package:get/get.dart';

import '../models/demo_models.dart';
import '../providers/demo_api_client.dart';

class SessionService extends GetxService {
  final Rxn<UserProfile> currentUser = Rxn<UserProfile>();
  final RxnString accessToken = RxnString();
  final RxnString lastCompletedOrderId = RxnString();
  final RxBool restoringSession = false.obs;
  final RxInt loginAttempts = 0.obs;

  bool get isLoggedIn => accessToken.value != null && currentUser.value != null;

  Future<void> restoreSession() async {
    restoringSession.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    restoringSession.value = false;
  }

  Future<bool> signIn({required String email, required String password}) async {
    loginAttempts.value++;

    try {
      final profile = await Get.find<DemoApiClient>().authenticate(
        email,
        password,
      );
      currentUser.value = profile;
      accessToken.value = rotateToken();
      return true;
    } catch (_) {
      return false;
    }
  }

  String rotateToken() {
    final token = 'demo-token-${DateTime.now().millisecondsSinceEpoch}';
    accessToken.value = token;
    return token;
  }

  void rememberCompletedOrder(String orderId) {
    lastCompletedOrderId.value = orderId;
  }

  void logout() {
    accessToken.value = null;
    currentUser.value = null;
    lastCompletedOrderId.value = null;
  }
}
