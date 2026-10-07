import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app_colore/app_colore.dart';
import '../controller/notification_controller.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.notifications.isEmpty) {
                  return const Center(child: Text("No notifications"));
                }
                return ListView.separated(
                  padding: EdgeInsets.all(24.r),
                  itemCount: controller.notifications.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final item = controller.notifications[index];
                    return _buildNotificationCard(item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColor.primaryDark),
            ),
          ),
          Text(
            "Notifications",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.primaryDark,
            ),
          ),
          IconButton(
            onPressed: () => controller.markAllAsRead(),
            icon: Icon(Icons.done_all, size: 24.sp, color: AppColor.primaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final bool isSupport = item.type == NotificationType.support;
    final Color bgColor = isSupport ? const Color(0xFFF9F5F1) : const Color(0xFFEBF3FE);
    final Color iconBg = isSupport ? const Color(0xFFD4A017).withOpacity(0.8) : const Color(0xFF3B82F6).withOpacity(0.7);
    final IconData icon = isSupport ? Icons.favorite : Icons.shield_rounded;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF94A3B8),
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
