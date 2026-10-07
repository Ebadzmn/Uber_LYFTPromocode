import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../approut.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/services/session_manager.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ─────────────────── Validation ─────────────────────────
  String? _validate() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) return 'Please enter your email.';
    if (!GetUtils.isEmail(email)) return 'Please enter a valid email address.';
    if (password.isEmpty) return 'Please enter your password.';

    return null;
  }

  // ─────────────────── Login API Call ─────────────────────
  Future<void> login() async {
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

      final ApiResponse response = await networkCaller.request(
        url: '/auth/login',
        method: HttpMethod.post,
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      if (response.success && response.data != null) {
        final data = response.data;

        // Parse tokens from response
        if (data is Map<String, dynamic>) {
          final responseData = data['data'] ?? data;

          final accessToken = responseData['accessToken']?.toString() ?? '';
          final refreshToken = responseData['refreshToken']?.toString() ?? '';
          final userData = responseData['user'];

          // Extract user profile info
          final userName = userData is Map<String, dynamic>
              ? userData['name']?.toString()
              : null;
          final profilePhoto = userData is Map<String, dynamic>
              ? userData['profilePhoto']?.toString()
              : null;
          final createdAt = userData is Map<String, dynamic>
              ? userData['createdAt']?.toString()
              : null;

          // 3. Save session
          final sessionManager = Get.find<SessionManager>();
          await sessionManager.saveSession(
            accessToken: accessToken,
            refreshToken: refreshToken,
            userData: userData != null ? jsonEncode(userData) : null,
            userName: userName,
            profilePhoto: profilePhoto,
            createdAt: createdAt,
            userEmail: emailController.text.trim(),
          );

          Get.snackbar(
            'Success',
            response.message ?? 'Logged in successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );

          // 4. Navigate to Home
          Get.offAllNamed(AppRoute.home);
        } else {
          Get.snackbar(
            'Error',
            'Unexpected response format.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
        }
      } else {
        // ❌ Failure
        Get.snackbar(
          'Login Failed',
          response.message ?? 'Invalid email or password.',
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
      // 5. Stop loading
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
