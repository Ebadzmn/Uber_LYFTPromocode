import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app_colore/app_colore.dart';
import '../controller/reset_password_controller.dart';

class Creatnewpassword extends StatelessWidget {
  const Creatnewpassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResetPasswordController>();

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Center(
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 40.h,
                width: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF475569),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Create New Password',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryDark,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Choose a strong password to\nsecure your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.textGray,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              // ── New Password ──────────────────────────────────────
              Text(
                'New Password',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryDark,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => TextField(
                  controller: controller.newPasswordController,
                  obscureText: !controller.isNewPasswordVisible.value,
                  onChanged: controller.validatePassword,
                  decoration: InputDecoration(
                    hintText: 'enter your password',
                    hintStyle: TextStyle(
                      color: AppColor.textHint,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF94A3B8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isNewPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                    filled: true,
                    fillColor: AppColor.fieldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.fieldBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.fieldBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.primaryDark),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // ── Confirm Password ──────────────────────────────────
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryDark,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: 'enter your password',
                    hintStyle: TextStyle(
                      color: AppColor.textHint,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF94A3B8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    filled: true,
                    fillColor: AppColor.fieldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.fieldBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.fieldBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.primaryDark),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // ── Password Requirements Card ────────────────────────
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password must contain:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryDark,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => Column(
                        children: [
                          _buildRequirementItem(
                            'At least 8 characters',
                            controller.has8Chars.value,
                          ),
                          SizedBox(height: 12.h),
                          _buildRequirementItem(
                            'One uppercase letter',
                            controller.hasUppercase.value,
                          ),
                          SizedBox(height: 12.h),
                          _buildRequirementItem(
                            'One number',
                            controller.hasNumber.value,
                          ),
                          SizedBox(height: 12.h),
                          _buildRequirementItem(
                            'One special character',
                            controller.hasSpecialChar.value,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              // ── Save Button ───────────────────────────────────────
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryDark,
                    disabledBackgroundColor: AppColor.primaryDark.withOpacity(
                      0.6,
                    ),
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Save Change',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      children: [
        Container(
          height: 20.h,
          width: 20.w,
          decoration: BoxDecoration(
            color: isMet ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
            shape: BoxShape.circle,
          ),
          child: isMet
              ? Icon(Icons.check, color: Colors.white, size: 14.sp)
              : null,
        ),
        SizedBox(width: 12.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: isMet ? AppColor.primaryDark : AppColor.textGray,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
