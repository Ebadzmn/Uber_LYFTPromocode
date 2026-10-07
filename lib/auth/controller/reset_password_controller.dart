import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../approut.dart';
import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';

class ResetPasswordController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  // ─────────────── Password Strength Checkers ───────────────
  var has8Chars = false.obs;
  var hasUppercase = false.obs;
  var hasNumber = false.obs;
  var hasSpecialChar = false.obs;

  // Token received from OTP verification
  late final String resetToken;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    resetToken = args?['token'] ?? '';
  }

  void validatePassword(String value) {
    has8Chars.value = value.length >= 8;
    hasUppercase.value = value.contains(RegExp(r'[A-Z]'));
    hasNumber.value = value.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  void toggleNewPasswordVisibility() =>
      isNewPasswordVisible.value = !isNewPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  // ─────────────── Validation ───────────────
  String? _validate() {
    final newPw = newPasswordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();

    if (newPw.isEmpty) return 'Please enter a new password.';
    if (newPw.length < 8) return 'Password must be at least 8 characters.';
    if (confirmPw.isEmpty) return 'Please confirm your password.';
    if (newPw != confirmPw) return 'Passwords do not match.';
    return null;
  }

  // ─────────────── Reset Password API ───────────────
  Future<void> resetPassword() async {
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
        url: ApiUrls.resetPassword,
        method: HttpMethod.post,
        headers: {'Authorization': resetToken},
        body: {
          'newPassword': newPasswordController.text.trim(),
          'confirmPassword': confirmPasswordController.text.trim(),
        },
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'Password reset successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        // Navigate back to login and clear the stack
        Get.offAllNamed(AppRoute.login);
      } else {
        Get.snackbar(
          'Reset Failed',
          response.message ?? 'Could not reset password. Please try again.',
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
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
