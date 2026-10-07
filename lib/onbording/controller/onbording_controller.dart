import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../approut.dart';
import '../../core/services/session_manager.dart';

class OnbordingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      skip();
    }
  }

  void skip() async {
    final session = Get.find<SessionManager>();
    await session.setOnboardingCompleted();
    Get.offAllNamed(AppRoute.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
