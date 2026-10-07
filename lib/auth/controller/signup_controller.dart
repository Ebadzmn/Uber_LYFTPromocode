import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../approut.dart';
import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/services/device_service.dart';

class SignupController extends GetxController {
  // ─────────────────── Text Controllers ───────────────────
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();

  // ──────────────────── Observable State ───────────────────
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  // ─────────────────── Toggle Password ────────────────────
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ─────────────────── Validation ─────────────────────────
  String? _validate() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) return 'Please enter your name.';
    if (email.isEmpty) return 'Please enter your email.';
    if (!GetUtils.isEmail(email)) return 'Please enter a valid email address.';
    if (password.isEmpty) return 'Please enter a password.';
    if (password.length < 6) return 'Password must be at least 6 characters.';

    return null; // All good
  }

  // ─────────────────── Sign Up API Call ───────────────────
  Future<void> signUp() async {
    // 1. Validate
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

    // 2. Start loading
    isLoading.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();
      final String deviceId = await DeviceService.getDeviceId();

      final Map<String, dynamic> fields = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'deviceId': deviceId,
      };

      // Add optional fields if provided
      if (phoneController.text.trim().isNotEmpty) {
        fields['phone'] = phoneController.text.trim();
      }
      if (addressController.text.trim().isNotEmpty) {
        fields['address'] = addressController.text.trim();
      }

      final ApiResponse response = await networkCaller.request(
        url: ApiUrls.signUp,
        method: HttpMethod.post,
        body: fields,
      );

      if (response.success) {
        // ✅ Success → navigate to OTP verification
        Get.snackbar(
          'Success',
          response.message ??
              'Account created successfully! Please verify your OTP.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        Get.toNamed(
          AppRoute.signupOtp,
          arguments: {'email': emailController.text.trim()},
        );
      } else {
        // ❌ Failure → show error
        Get.snackbar(
          'Sign Up Failed',
          response.message ?? 'Something went wrong. Please try again.',
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
      // 3. Stop loading
      isLoading.value = false;
    }
  }

  // ─────────────────── Cleanup ────────────────────────────
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.onClose();
  }
}
