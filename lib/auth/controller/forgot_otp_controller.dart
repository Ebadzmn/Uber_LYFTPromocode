import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../approut.dart';
import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';

class ForgotOtpController extends GetxController {
  // ─────────────── Email passed from Forgot Password screen ───────────────
  late final String email;

  // ─────────────── OTP Text Controllers & Focus Nodes ───────────────
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  // ─────────────── Observable State ───────────────
  var isLoading = false.obs;
  var isResending = false.obs;
  var countdown = 120.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    _startCountdown();
  }

  // ─────────────── Countdown Timer ───────────────
  void _startCountdown() {
    _timer?.cancel();
    countdown.value = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  String get formattedCountdown {
    final minutes = (countdown.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdown.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ─────────────── OTP Input Handling ───────────────
  void onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  // ─────────────── Validation ───────────────
  String? _validate() {
    final otp = otpControllers.map((c) => c.text.trim()).join();
    if (otp.isEmpty) return 'Please enter the OTP.';
    if (otp.length != 4) return 'Please enter all 4 digits.';
    if (!GetUtils.isNumericOnly(otp)) return 'OTP must be numeric.';
    return null;
  }

  // ─────────────── Verify OTP for Forgot Password ───────────────
  Future<void> verifyOtp() async {
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
      final otp = int.parse(otpControllers.map((c) => c.text.trim()).join());

      final ApiResponse response = await networkCaller.request(
        url: ApiUrls.forgotOtpVerify,
        method: HttpMethod.post,
        body: {'email': email, 'otp': otp},
      );

      if (response.success && response.data != null) {
        final data = response.data;
        String? resetToken;

        if (data is Map<String, dynamic>) {
          // Token is in the "data" field of the response body
          resetToken = data['data']?.toString();
        }

        Get.snackbar(
          'Verified',
          response.message ?? 'OTP verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );

        Get.focusScope?.unfocus();
        // Navigate to Reset Password and pass the token
        Get.toNamed(
          AppRoute.createNewPassword,
          arguments: {'token': resetToken ?? ''},
        );
      } else {
        Get.snackbar(
          'Verification Failed',
          response.message ?? 'Invalid OTP. Please try again.',
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

  // ─────────────── Resend OTP ───────────────
  Future<void> resendOtp() async {
    if (isResending.value || countdown.value > 0) return;
    isResending.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      final ApiResponse response = await networkCaller.request(
        url: ApiUrls.forgetPassword,
        method: HttpMethod.post,
        body: {'email': email},
      );

      if (response.success) {
        for (final c in otpControllers) {
          c.clear();
        }
        focusNodes[0].requestFocus();
        _startCountdown();

        Get.snackbar(
          'Code Sent',
          response.message ?? 'A new OTP has been sent to your email.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          'Resend Failed',
          response.message ?? 'Could not resend OTP. Please try again.',
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
      isResending.value = false;
    }
  }

  // ─────────────── Cleanup ───────────────
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
