import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app_colore/app_colore.dart';
import '../../app_text/app_text.dart';
import '../controller/login_controller.dart';
import '../../approut.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/image/image_copy.png',
                      height: 160.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      AppText.welcomeBack,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryDark,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Text(
                        AppText.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.textGray,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                AppText.emailLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryDark,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  hintText: AppText.emailHint,
                  hintStyle: TextStyle(
                    color: AppColor.textHint,
                    fontSize: 14.sp,
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
              SizedBox(height: 20.h),
              Text(
                AppText.passwordLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryDark,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => TextField(
                  controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    hintText: AppText.passwordHint,
                    hintStyle: TextStyle(
                      color: AppColor.textHint,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColor.textHint,
                      size: 20.sp,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColor.textHint,
                        size: 20.sp,
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
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoute.forgotPassword),
                  child: Text(
                    AppText.forgetPassword,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.primaryDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.login,
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
                          AppText.signInBtn,
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
                    text: AppText.dontHaveAccount,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.textGray,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(
                        text: AppText.signUp,
                        style: TextStyle(
                          color: AppColor.primaryDark,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(AppRoute.signup);
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
}
