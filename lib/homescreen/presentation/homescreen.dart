import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app_colore/app_colore.dart';
import '../../../approut.dart';
import '../controller/homescreen_controller.dart';
import '../../core/services/session_manager.dart';

class Homescreen extends GetView<HomescreenController> {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColor.white,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildBanner(),
              _buildHowItWorks(),
              _buildApplyFinanceHelp(),
              _buildStatsSection(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Row(
        children: [
          // Menu Button to the LEFT (3 dashed lines/menu icon)
          InkWell(
            onTap: controller.openDrawer,
            child: Icon(Icons.menu, size: 28.sp, color: AppColor.primaryDark),
          ),
          SizedBox(width: 16.w),
          // Profile Pic
          Obx(
            () => ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: controller.profilePhoto.value.isNotEmpty
                  ? Image.network(
                      controller.profilePhoto.value,
                      height: 44.h,
                      width: 44.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _defaultAvatar(22.r, 24.sp),
                    )
                  : _defaultAvatar(22.r, 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello ${controller.userName.value.isNotEmpty ? controller.userName.value : 'User'}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryDark,
                  ),
                ),
                Text(
                  "Welcome to App",
                  style: TextStyle(fontSize: 12.sp, color: AppColor.textGray),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      height: 180.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              'assets/image/careroad.png',
              width: double.infinity,
              height: 180.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: AppColor.primaryDark,
                ),
              ),
            ),
          ),
          // Content with Gradient Overlay
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose Safety, Get Home Safe.",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Watch a short video about responsible choices and unlock your ride discount",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
                InkWell(
                  onTap: controller.showEmailDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Watch Video",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Text(
            "How It Works",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primaryDark,
            ),
          ),
          SizedBox(height: 24.h),
          _buildWorkItem(
            image: 'assets/icons/email.png',
            title: "Enter Email",
            desc: "Provide your email to get started with the safety program",
          ),
          SizedBox(height: 16.h),
          _buildWorkItem(
            image: 'assets/icons/video.png',
            title: "Watch Full Video",
            desc: "View the complete safety awareness video content",
          ),
          SizedBox(height: 16.h),
          _buildWorkItem(
            icon: Icons.directions_car_filled,
            title: "Get Ride Discount",
            desc:
                "Receive your Uber or Lyft discount code for a safe ride home",
          ),
        ],
      ),
    );
  }

  Widget _buildWorkItem({
    String? image,
    IconData? icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54.h,
            width: 54.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B), // Dark box from Figma
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: image != null
                ? Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Image.asset(
                      image,
                      color: Colors.white, // Ensure icon is white
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 24.sp,
                      ),
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textGray,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyFinanceHelp() {
    return InkWell(
      onTap: controller.goToFinancialHelp,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.all(24.r),
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Apply for Financial Help",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 12.w),
            Icon(Icons.arrow_outward, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "15,000+",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primaryDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Safe Rides Funded",
                  style: TextStyle(fontSize: 12.sp, color: AppColor.textGray),
                ),
              ],
            ),
          ),
          Container(height: 40.h, width: 1, color: const Color(0xFFCBD5E1)),
          Expanded(
            child: Column(
              children: [
                Text(
                  "100%",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF22C55E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Nonprofit Initiative",
                  style: TextStyle(fontSize: 12.sp, color: AppColor.textGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 30.h,
              bottom: 30.h,
              left: 24.w,
              right: 24.w,
            ),
            color: AppColor.primaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70.h,
                  width: 70.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Obx(
                    () => ClipOval(
                      child: controller.profilePhoto.value.isNotEmpty
                          ? Image.network(
                              controller.profilePhoto.value,
                              height: 58.h,
                              width: 58.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _defaultAvatar(29.h, 30.sp),
                            )
                          : _defaultAvatar(29.h, 30.sp),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(
                  () => Text(
                    controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: "User Information",
            onTap: () {
              Get.back();
              controller.goToProfile();
            },
          ),
          SizedBox(height: 8.h),
          _buildDrawerItem(
            icon: Icons.logout,
            title: "Logout",
            onTap: () async {
              final session = Get.find<SessionManager>();
              await session.clearSession();
              Get.offAllNamed(AppRoute.login);
            },
          ),
          SizedBox(height: 8.h),
          _buildDrawerItem(
            icon: Icons.delete_outline,
            title: "Delete Account",
            color: const Color(0xFFFF4B4B),
            onTap: controller.deleteAccount,
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 40.h, left: 24.w),
            child: Text(
              "App Version 2.4.1",
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color(0xFF475569), size: 24.sp),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                color: color ?? const Color(0xFF1E293B),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar(double radius, double iconSize) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: iconSize, color: AppColor.primaryDark),
    );
  }
}
