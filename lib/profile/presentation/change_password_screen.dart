import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app_colore/app_colore.dart';
import '../controller/change_password_controller.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildBackButton(),
                SizedBox(height: 32.h),
                _buildPasswordField(
                  label: "Current Password",
                  controller: controller.currentPasswordController,
                  isVisible: controller.isCurrentPasswordVisible,
                  onToggle: controller.toggleCurrentPasswordVisibility,
                ),
                SizedBox(height: 20.h),
                _buildPasswordField(
                  label: "New Password",
                  controller: controller.newPasswordController,
                  isVisible: controller.isNewPasswordVisible,
                  onToggle: controller.toggleNewPasswordVisibility,
                ),
                SizedBox(height: 20.h),
                _buildPasswordField(
                  label: "Confirm New Password",
                  controller: controller.confirmPasswordController,
                  isVisible: controller.isConfirmPasswordVisible,
                  onToggle: controller.toggleConfirmPasswordVisibility,
                ),
                SizedBox(height: 40.h),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Get.back(),
      icon: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColor.primaryDark),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryDark,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => TextField(
          controller: controller,
          obscureText: !isVisible.value,
          decoration: InputDecoration(
            hintText: "enter your password",
            hintStyle: TextStyle(fontSize: 13.sp, color: AppColor.textGray.withOpacity(0.5)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: Icon(Icons.lock_outline, size: 20.sp, color: AppColor.textGray),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20.sp,
                color: AppColor.textGray.withOpacity(0.5),
              ),
            ),
            contentPadding: EdgeInsets.all(16.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFF1F5F9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFF1F5F9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.primaryDark.withOpacity(0.2)),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: controller.savePassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 0,
      ),
      child: Text(
        "Save",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
