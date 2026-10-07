import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app_colore/app_colore.dart';
import '../controller/signup_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupController>();

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
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
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
        title: Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryDark,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              _buildLabel("Name"),
              _buildTextField(
                controller: controller.nameController,
                hintText: "enter your name",
              ),
              SizedBox(height: 20.h),
              _buildLabel("Phone Number (Optional)"),
              _buildTextField(
                controller: controller.phoneController,
                hintText: "enter your number",
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20.h),
              _buildLabel("Email"),
              _buildTextField(
                controller: controller.emailController,
                hintText: "enter your email",
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),
              _buildLabel("Password"),
              Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: "enter your password",
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
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: controller.togglePasswordVisibility,
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
              SizedBox(height: 20.h),
              _buildLabel("Address (Optional)"),
              _buildTextField(
                controller: controller.addressController,
                hintText: "enter your address",
              ),
              SizedBox(height: 48.h),

              // ──────────── Sign Up Button with Loading ────────────
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.signUp,
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
                      ? SizedBox(
                          height: 24.h,
                          width: 24.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.textGray,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: AppColor.primaryDark,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.back(); // Go back to login
                          },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColor.textHint, fontSize: 14.sp),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
