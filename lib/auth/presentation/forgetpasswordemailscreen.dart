import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app_colore/app_colore.dart';
import '../../app_text/app_text.dart';
import '../controller/forget_password_controller.dart';

class Forgetpasswordemailscreen extends StatelessWidget {
  const Forgetpasswordemailscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgetPasswordController>();

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Center(
                child: Column(
                  children: [
                    Text(
                      AppText.forgotPasswordTitle,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primaryDark,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        AppText.forgotPasswordSubtitle,
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
              SizedBox(height: 48.h),
              Text(
                AppText.emailLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primaryDark,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
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
              SizedBox(height: 32.h),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submit,
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
                          AppText.sendBtn,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
