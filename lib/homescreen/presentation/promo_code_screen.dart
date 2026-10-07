import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app_colore/app_colore.dart';
import '../../approut.dart';
import '../controller/promo_code_controller.dart';

class PromoCodeScreen extends GetView<PromoCodeController> {
  const PromoCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PromoCodeController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // ── Loading State ──
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error State ──
          if (controller.hasError.value) {
            return _buildErrorState();
          }

          // ── Cooldown State (Already Claimed This Month) ──
          if (controller.isCooldownActive.value) {
            return _buildCooldownContent();
          }

          // ── Success / Freshly Claimed State ──
          return _buildSuccessContent();
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Error State
  // ═══════════════════════════════════════════════

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade300),
            SizedBox(height: 16.h),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.primaryDark,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: controller.retry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                "Retry",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryDark,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Cooldown Content (30-Day Limit Active)
  // ═══════════════════════════════════════════════

  Widget _buildCooldownContent() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Get.offAllNamed(AppRoute.home),
                    icon: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColor.primaryDark,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
                // Cooldown Clock Icon
                Center(
                  child: Container(
                    height: 100.r,
                    width: 100.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7), // Warm amber background
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_clock_rounded,
                        color: const Color(0xFFD97706),
                        size: 48.r,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
                Text(
                  "Monthly Promo Already Claimed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primaryDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "1 promo code claim is allowed per 30-day window",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: AppColor.textGray),
                ),

                SizedBox(height: 24.h),
                // Countdown Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: const Color(0xFFB45309),
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Obx(
                            () => Text(
                              "Next Claim in ${controller.daysRemaining.value} Days",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (controller.formattedNextAvailableDate.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          "Available on: ${controller.formattedNextAvailableDate}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFFB45309),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // If previous promo code is available, show it
                if (controller.promoCode.value.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  _buildPromoCard(title: "Your Last Claimed Code"),
                ],

                const Spacer(),
                SizedBox(height: 20.h),
                // Back to Home Button
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoute.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Back to Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Success Content (Freshly Claimed Code)
  // ═══════════════════════════════════════════════

  Widget _buildSuccessContent() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Get.offAllNamed(AppRoute.home),
                    icon: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColor.primaryDark,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
                // Top Icon Section
                _buildSuccessIcon(),

                SizedBox(height: 24.h),
                // Title and Subtitle
                Text(
                  "You're making a safe choice",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primaryDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Your exclusive promo code is ready to use",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: AppColor.textGray),
                ),

                SizedBox(height: 36.h),
                // Promo Code Card
                _buildPromoCard(title: "Your Promo Code"),

                const Spacer(),
                // Info Box at the bottom
                _buildInfoBox(),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Center(
      child: Stack(
        children: [
          Container(
            height: 110.r,
            width: 110.r,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECCC), // Light orange outer circle
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Container(
                height: 82.r,
                width: 82.r,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.shield, color: Colors.white, size: 36.r),
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
              child: Icon(Icons.check, color: Colors.white, size: 16.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({String title = "Your Promo Code"}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Obx(
                () => Text(
                  controller.promoCode.value.isNotEmpty
                      ? controller.promoCode.value
                      : "---",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          // Discount Info
          Obx(
            () => controller.discountInfo.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          color: const Color(0xFF2563EB),
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          controller.discountInfo,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(height: 10.h),
          // Expiry Date
          Obx(
            () => controller.formattedExpiry.value.isNotEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.grey[500],
                        size: 15.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Valid until ${controller.formattedExpiry.value}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: controller.copyToClipboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.copy_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8.w),
                Text(
                  "Copy Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: const Color(0xFF2563EB), size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Apply the code inside the ride app before booking",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "1 code claim is allowed per 30 days rolling window",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF1E40AF),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
