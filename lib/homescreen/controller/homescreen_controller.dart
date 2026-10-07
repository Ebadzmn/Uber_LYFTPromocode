import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app_colore/app_colore.dart';
import '../../approut.dart';
import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/services/session_manager.dart';

class HomescreenController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // ─────────────── User Info ───────────────
  var userName = ''.obs;
  var profilePhoto = ''.obs;

  // ─────────────── Loading States ───────────────
  final RxBool isEmailLoading = false.obs;
  final RxBool isOtpLoading = false.obs;

  /// Stores the email verified in Step 1 so it can be passed to Step 2.
  String _verifiedEmail = '';

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final session = Get.find<SessionManager>();
    userName.value = session.userName ?? '';
    profilePhoto.value = session.profilePhoto ?? '';
  }

  Future<void> deleteAccount() async {
    final session = Get.find<SessionManager>();
    final raw = session.userData;
    String? userId;
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        userId = map['id']?.toString() ?? map['_id']?.toString();
      } catch (_) {}
    }
    if (userId == null || userId.isEmpty) {
      _showError("User information not available. Please log in again.");
      return;
    }

    Get.back();

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final networkCaller = Get.find<NetworkCaller>();
      final ApiResponse response = await networkCaller.request(
        url: ApiUrls.userById(userId),
        method: HttpMethod.delete,
      );

      if (response.success) {
        await session.clearSession();
        Get.offAllNamed(AppRoute.login);
      } else {
        _showError(
          response.message ?? "Could not delete account. Please try again.",
        );
      }
    } catch (e) {
      _showError("An unexpected error occurred: $e");
    }
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  // ═══════════════════════════════════════════════
  //  STEP 1 — Email Check
  // ═══════════════════════════════════════════════

  void showEmailDialog() {
    emailController.clear();
    isEmailLoading.value = false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Email Address",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Provide your email to get started with the safety program",
                  style: TextStyle(fontSize: 12.sp, color: AppColor.textGray),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "jhon124@gmail.com",
                    filled: true,
                    fillColor: AppColor.fieldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.fieldBorder),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => ElevatedButton(
                    onPressed: isEmailLoading.value
                        ? null
                        : _onEmailSubmitPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryDark,
                      disabledBackgroundColor: AppColor.primaryDark.withOpacity(
                        0.6,
                      ),
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isEmailLoading.value
                        ? SizedBox(
                            height: 24.r,
                            width: 24.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Verify",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onEmailSubmitPressed() async {
    final email = emailController.text.trim();

    // Validation
    if (email.isEmpty) {
      _showError("Email is required.");
      return;
    }
    if (!GetUtils.isEmail(email)) {
      _showError("Please enter a valid email address.");
      return;
    }

    isEmailLoading.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      final response = await networkCaller.request(
        url: ApiUrls.checkEmail,
        method: HttpMethod.post,
        body: {'email': email},
      );

      if (response.success) {
        _verifiedEmail = email;
        // Store registered email locally for Profile screen
        final session = Get.find<SessionManager>();
        await session.setRegisteredEmail(email);
        Get.back(); // Close email dialog
        showOtpDialog();
      } else {
        _showError("You are not eligible");
      }
    } catch (e) {
      _showError("An unexpected error occurred: $e");
    } finally {
      isEmailLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════
  //  STEP 2 — OTP Verification
  // ═══════════════════════════════════════════════

  void showOtpDialog() {
    otpController.clear();
    isOtpLoading.value = false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECCC),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "We have sent a verification code to $_verifiedEmail",
                  style: TextStyle(fontSize: 12.sp, color: AppColor.textGray),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    hintText: "0000",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.fieldBorder),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => ElevatedButton(
                    onPressed: isOtpLoading.value ? null : _onOtpSubmitPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryDark,
                      disabledBackgroundColor: AppColor.primaryDark.withOpacity(
                        0.6,
                      ),
                      minimumSize: Size(double.infinity, 56.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isOtpLoading.value
                        ? SizedBox(
                            height: 24.r,
                            width: 24.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Verify",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onOtpSubmitPressed() async {
    final otp = otpController.text.trim();

    // Validation
    if (otp.isEmpty) {
      _showError("OTP is required.");
      return;
    }
    if (int.tryParse(otp) == null) {
      _showError("OTP must be numeric.");
      return;
    }

    isOtpLoading.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      final response = await networkCaller.request(
        url: ApiUrls.verifyEmail,
        method: HttpMethod.post,
        body: {'email': _verifiedEmail, 'oneTimeCode': int.parse(otp)},
      );

      if (response.success) {
        Get.back(); // Close OTP dialog
        Get.toNamed(AppRoute.watchVideo, arguments: {'email': _verifiedEmail});
      } else {
        _showError(response.message ?? "Invalid or expired OTP.");
      }
    } catch (e) {
      _showError("An unexpected error occurred: $e");
    } finally {
      isOtpLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════
  //  Helpers
  // ═══════════════════════════════════════════════

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void goToNotifications() {
    Get.toNamed(AppRoute.notifications);
  }

  void goToFinancialHelp() {
    Get.toNamed(AppRoute.financialHelp);
  }

  void goToProfile() {
    Get.toNamed(AppRoute.profile);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
