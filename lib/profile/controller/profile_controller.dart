import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../approut.dart';
import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/services/session_manager.dart';
import '../../homescreen/controller/homescreen_controller.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var profilePhoto = ''.obs;
  var joinDate = ''.obs;

  var registeredEmail = ''.obs;

  var promoCode = ''.obs;
  var promoSource = ''.obs;
  var promoDiscountValue = ''.obs;
  var promoDiscountType = ''.obs;
  var promoExpiredAt = ''.obs;
  var promoFormattedExpiry = ''.obs;
  var promoStatus = ''.obs;
  var hasCoupon = false.obs;
  var promoDiscountInfo = ''.obs;
  final isUpdatingPhoto = false.obs;
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _loadCouponData();
  }

  void _loadUserInfo() {
    final session = Get.find<SessionManager>();

    userName.value = session.userName ?? 'User';
    profilePhoto.value = session.profilePhoto ?? '';

    registeredEmail.value = session.registeredEmail ?? '';

    String? createdAt = session.createdAt;
    if (session.userData != null) {
      try {
        final userMap = jsonDecode(session.userData!) as Map<String, dynamic>;
        _userId = userMap['id']?.toString() ?? userMap['_id']?.toString();
        if (createdAt == null || createdAt.isEmpty) {
          createdAt = userMap['createdAt']?.toString();
        }
      } catch (_) {}
    }
    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        joinDate.value =
            'Member since ${date.day} ${months[date.month - 1]} ${date.year}';
      } catch (_) {
        joinDate.value = '';
      }
    }
  }

  Future<void> changeProfilePhoto() async {
    if (isUpdatingPhoto.value) return;

    if (_userId == null || _userId!.isEmpty) {
      Get.snackbar(
        'Error',
        'User information not available. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Could not open gallery.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null) {
      return;
    }

    final filePath = result.files.first.path!;

    isUpdatingPhoto.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();
      
      // We use Multipart upload for profile photo
      final ApiResponse response = await networkCaller.uploadRequest(
        url: ApiUrls.userById(_userId!),
        method: HttpMethod.patch,
        files: {'image': filePath},
      );

      debugPrint('📸 Upload Response: ${response.data}');

      if (response.success) {
        String? newUrl;
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          // Check various possible response structures
          final innerData = data['data'] ?? data;
          final user = (innerData is Map<String, dynamic>) 
              ? (innerData['user'] ?? innerData) 
              : null;
              
          if (user is Map<String, dynamic>) {
            newUrl = user['profilePhoto']?.toString();
          } else if (innerData is Map<String, dynamic> && innerData.containsKey('profilePhoto')) {
            newUrl = innerData['profilePhoto']?.toString();
          }
        }

        if (newUrl != null && newUrl.isNotEmpty) {
          // Ensure it's a full URL if it's relative
          if (!newUrl.startsWith('http')) {
            newUrl = '${ApiUrls.baseUrl.split('/api/v1')[0]}/$newUrl';
          }
          
          final session = Get.find<SessionManager>();
          await session.setProfilePhoto(newUrl);
          profilePhoto.value = newUrl;
          
          try {
            final home = Get.find<HomescreenController>();
            home.profilePhoto.value = newUrl;
          } catch (_) {}
          
          Get.snackbar(
            'Success',
            'Profile picture updated successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
          );
        } else {
          // Even if URL is missing in response, try to reload user info
          _loadUserInfo();
          Get.snackbar(
            'Success',
            'Profile updated. Please refresh if photo doesn\'t appear.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Could not update profile picture.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdatingPhoto.value = false;
    }
  }

  void _loadCouponData() {
    final session = Get.find<SessionManager>();
    final coupon = session.couponData;

    if (coupon == null) {
      hasCoupon.value = false;
      return;
    }

    hasCoupon.value = true;
    promoCode.value = coupon['promoCode']?.toString() ?? '';
    promoSource.value = coupon['source']?.toString() ?? '';
    promoDiscountValue.value = coupon['discountValue']?.toString() ?? '';
    promoDiscountType.value = coupon['discountType']?.toString() ?? '';
    promoExpiredAt.value = coupon['expiredAt']?.toString() ?? '';

    // Discount info string
    if (promoDiscountValue.value.isNotEmpty) {
      promoDiscountInfo.value =
          '${promoDiscountValue.value} ${promoDiscountType.value} OFF – ${promoSource.value}';
    }

    // Format expiry + determine status
    if (promoExpiredAt.value.isNotEmpty) {
      try {
        final date = DateTime.parse(promoExpiredAt.value);
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        promoFormattedExpiry.value =
            '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';

        // Status: Active or Expired
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final expiryDate = DateTime(date.year, date.month, date.day);
        promoStatus.value = todayDate.isAfter(expiryDate)
            ? 'Expired'
            : 'Active';
      } catch (_) {
        promoFormattedExpiry.value = promoExpiredAt.value;
        promoStatus.value = 'Unknown';
      }
    }
  }

  void changeUserInfo() {
    Get.toNamed(AppRoute.changeName);
  }

  void changePassword() {
    Get.toNamed(AppRoute.changePassword);
  }
}
