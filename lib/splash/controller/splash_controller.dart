import 'package:get/get.dart';
import '../../approut.dart';
import '../../core/services/session_manager.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final session = Get.find<SessionManager>();

    if (session.isLoggedIn) {
      // Token exists → go directly to Home
      Get.offAllNamed(AppRoute.home);
    } else if (session.isOnboardingCompleted) {
      // Onboarding done but not logged in → go to Login
      Get.offAllNamed(AppRoute.login);
    } else {
      // First launch → show Onboarding
      Get.offNamed(AppRoute.onboarding);
    }
  }
}
