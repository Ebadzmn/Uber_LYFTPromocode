import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../app_colore/app_colore.dart';
import '../../approut.dart';
import '../controller/watchvideoscreencontroller.dart';

class WatchVideoScreen extends GetView<WatchVideoController> {
  const WatchVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          // ── Loaded State ──
          return _buildLoadedContent();
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
  //  Loaded Content
  // ═══════════════════════════════════════════════

  Widget _buildLoadedContent() {
    return Column(
      children: [
        // Video Player Section
        _buildVideoSection(),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                // Info Card with dynamic title & description
                _buildInfoCard(),
                SizedBox(height: 24.h),
                // Progress Section
                _buildProgressSection(),
              ],
            ),
          ),
        ),

        // Continue Button (at the bottom)
        _buildContinueButton(),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Container(
      margin: EdgeInsets.all(20.r),
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GetBuilder<WatchVideoController>(
        builder: (ctrl) {
          final vc = ctrl.videoController;
          if (vc == null || !vc.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: vc.value.aspectRatio,
                child: VideoPlayer(vc),
              ),
              // Thumbnail Overlay
              if (!ctrl.hasStartedPlaying.value &&
                  ctrl.videoThumbnail.value.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    ctrl.videoThumbnail.value,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
              // Play/Pause Overlay
              if (!vc.value.isPlaying)
                InkWell(
                  onTap: ctrl.playPause,
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFF00C48C,
                        ), // Match image play button teal color
                        width: 3.w,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: const Color(0xFF0F172A),
                      size: 28.sp,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(
            () => Text(
              controller.videoTitle.value.isNotEmpty
                  ? controller.videoTitle.value
                  : "Your Safety Journey Starts Here",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Text(
              controller.videoDescription.value.isNotEmpty
                  ? controller.videoDescription.value
                  : "Please watch the full video to continue. This important safety information will help protect you and others.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Receive Code Button (styled like image)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8.w),
                Text(
                  "Receive Code",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                const Icon(Icons.open_in_new, color: Colors.white, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Progress",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
              ),
            ),
            Obx(
              () => Text(
                "${(controller.progress.value * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(
          () => ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: controller.progress.value,
              minHeight: 6.h,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF334155),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Obx(() {
        final isFinished = controller.isVideoFinished.value;
        return ElevatedButton(
          onPressed: isFinished
              ? () => Get.toNamed(
                  AppRoute.promoCode,
                  arguments: {
                    'email': controller.email,
                    'videoId': controller.videoId.value,
                  },
                )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFinished
                ? const Color(0xFF94A3B8)
                : const Color(0xFF94A3B8).withOpacity(0.5),
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: Text(
            "Continue",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
        );
      }),
    );
  }
}
