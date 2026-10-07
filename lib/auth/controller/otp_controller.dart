import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../approut.dart';
import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';

class OtpController extends GetxController {
  // ─────────────── Email from SignUp ───────────────
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
    // Receive email from SignUp screen arguments
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
      // Auto-advance to next field
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move back on delete
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

  // ─────────────── Verify OTP API ───────────────
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
        url: ApiUrls.verifyOtp,
        method: HttpMethod.post,
        body: {'email': email, 'otp': otp},
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message ?? 'OTP verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        // Unfocus keyboard before navigating
        Get.focusScope?.unfocus();
        Get.offAllNamed(AppRoute.login);
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

  // ─────────────── Resend OTP API ───────────────
  Future<void> resendOtp() async {
    if (isResending.value) return;
    isResending.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      final ApiResponse response = await networkCaller.request(
        url: ApiUrls.resendOtp,
        method: HttpMethod.post,
        body: {'email': email},
      );

      if (response.success) {
        // Clear OTP fields
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
    // Note: TextEditingControllers and FocusNodes are NOT manually disposed
    // here because the page transition animation may still reference them
    // after onClose fires, causing "used after being disposed" errors.
    // Dart's GC will clean them up once the controller is fully unreachable.
    super.onClose();
  }
}
