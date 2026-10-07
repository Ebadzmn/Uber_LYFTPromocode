import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';

class ChangePasswordController extends GetxController {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  void toggleCurrentPasswordVisibility() => isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  void toggleNewPasswordVisibility() => isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  String? _validate() {
    final currentPw = currentPasswordController.text.trim();
    final newPw = newPasswordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();

    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      return 'All fields are required';
    }
    if (newPw.length < 8) {
      return 'New password must be at least 8 characters';
    }
    if (newPw != confirmPw) {
      return 'New passwords do not match';
    }
    if (currentPw == newPw) {
      return 'New password must be different from current password';
    }
    return null;
  }

  Future<void> savePassword() async {
    final error = _validate();
    if (error != null) {
      Get.snackbar(
        'Error',
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
        url: ApiUrls.changePassword,
        method: HttpMethod.patch,
        body: {
          'currentPassword': currentPasswordController.text.trim(),
          'newPassword': newPasswordController.text.trim(),
          'confirmPassword': confirmPasswordController.text.trim(),
        },
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'Password updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Could not update password. Please try again.',
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
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
