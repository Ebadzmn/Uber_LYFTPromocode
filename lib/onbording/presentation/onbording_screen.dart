import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app_colore/app_colore.dart';
import '../../app_text/app_text.dart';
import '../controller/onbording_controller.dart';

class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("DEBUG: OnbordingScreen build called");
    final controller = Get.find<OnbordingController>();

    final List<Map<String, String>> onboardingData = [
      {
        "image": "assets/image/onbording1.png",
        "title": AppText.onbording1Title,
        "description": AppText.onbording1Desc,
        "button": AppText.continueBtn
      },
      {
        "image": "assets/image/onbording2.png",
        "title": AppText.onbording2Title,
        "description": AppText.onbording2Desc,
        "button": AppText.continueBtn
      },
      {
        "image": "assets/image/onbording3.png",
        "title": AppText.onbording3Title,
        "description": AppText.onbording3Desc,
        "button": AppText.getStartedBtn
      },
    ];

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 60.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24.r),
                            child: Image.asset(
                              onboardingData[index]["image"]!,
                              height: 340.h,
                              width: 340.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 340.h,
                                  width: 340.w,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                        SizedBox(height: 10.h),
                                        Text(
                                          "Image not found:\n${onboardingData[index]["image"]}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 40.h),
                          Text(
                            onboardingData[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primaryDark,
                              height: 30 / 22,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            onboardingData[index]["description"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColor.textGray,
                              height: 26 / 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                   Obx(() => ElevatedButton(
                        onPressed: controller.next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryDark,
                          minimumSize: Size(double.infinity, 56.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          onboardingData[controller.currentPage.value]["button"]!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.white,
                          ),
                        ),
                      )),
                  SizedBox(height: 12.h),
                  Obx(() => controller.currentPage.value < 2
                      ? TextButton(
                          onPressed: controller.skip,
                          child: Text(
                            AppText.skipBtn,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColor.textGray,
                            ),
                          ),
                        )
                      : SizedBox(height: 48.h)),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => Obx(() => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: 4.h,
                            width: controller.currentPage.value == index ? 24.w : 8.w,
                            decoration: BoxDecoration(
                              color: controller.currentPage.value == index
                                  ? AppColor.primaryDark
                                  : AppColor.indicatorInactive.withAlpha(128),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          )),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
