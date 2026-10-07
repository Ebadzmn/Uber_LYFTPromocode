import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../approut.dart';
import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';

class ForgetPasswordController extends GetxController {
  final emailController = TextEditingController();

  var isLoading = false.obs;

  // ─────────────── Validation ───────────────
  String? _validate() {
    final email = emailController.text.trim();
    if (email.isEmpty) return 'Please enter your email.';
    if (!GetUtils.isEmail(email)) return 'Please enter a valid email address.';
    return null;
  }

  // ─────────────── Forgot Password API ───────────────
  Future<void> submit() async {
    final error = _validate();
    if (error != null) {
      Get.snackbar(
        'Validation Error',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isLoading.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      final ApiResponse response = await networkCaller.request(
        url: ApiUrls.forgetPassword,
        method: HttpMethod.post,
        body: {'email': emailController.text.trim()},
      );

      if (response.success) {
        Get.snackbar(
          'Code Sent',
          response.message ?? 'OTP sent to your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        // Navigate to OTP screen and pass the email
        Get.toNamed(
          AppRoute.otpForgetPassword,
          arguments: {'email': emailController.text.trim()},
        );
      } else {
        Get.snackbar(
          'Failed',
          response.message ?? 'Could not send OTP. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
