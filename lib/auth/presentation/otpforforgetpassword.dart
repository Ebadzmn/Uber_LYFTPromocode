import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app_colore/app_colore.dart';
import '../controller/forgot_otp_controller.dart';

class Otpforforgetpassword extends StatelessWidget {
  const Otpforforgetpassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotOtpController>();

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
            children: [
              SizedBox(height: 20.h),
              // Logo section
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 120.r,
                      width: 120.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFECCC),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          height: 90.r,
                          width: 90.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0F172A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.shield,
                              color: Colors.white,
                              size: 40.r,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 5,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E293B),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryDark,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Enter the 4-digit code sent to your email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppColor.textGray),
              ),
              SizedBox(height: 8.h),
              // Show the email the OTP was sent to
              Text(
                controller.email,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF97316),
                ),
              ),
              SizedBox(height: 40.h),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => Container(
                    height: 56.h,
                    width: 56.w,
                    decoration: BoxDecoration(
                      color: AppColor.fieldBg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColor.fieldBorder),
                    ),
                    child: Center(
                      child: TextField(
                        controller: controller.otpControllers[index],
                        focusNode: controller.focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryDark,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) =>
                            controller.onOtpChanged(value, index),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Verify Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.verifyOtp,
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
                          'Verify',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24.h),
              // Resend Code
              Obx(
                () => GestureDetector(
                  onTap: controller.countdown.value == 0
                      ? controller.resendOtp
                      : null,
                  child: RichText(
                    text: TextSpan(
                      text: "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColor.textGray,
                      ),
                      children: [
                        TextSpan(
                          text: 'Resend Code',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: controller.countdown.value == 0
                                ? const Color(0xFFF97316)
                                : AppColor.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Timer Badge
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Code expires in ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                        controller.formattedCountdown,
                        style: TextStyle(
                          color: const Color(0xFFF97316),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              // Security Tip Banner
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF452B2B),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF97316),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.priority_high,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Tip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Never share your OTP with anyone. We will never ask for your OTP via call or email.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
