import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api/api_urls.dart';
import '../../core/networkCaller/api_response.dart';
import '../../core/networkCaller/http_method.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/services/session_manager.dart';
import '../controller/profile_controller.dart';
import '../../homescreen/controller/homescreen_controller.dart';

class ChangeNameController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final RxBool isLoading = false.obs;
  String? _userId;

  @override
  void onInit() {
    super.onInit();
    final session = Get.find<SessionManager>();
    nameController.text = session.userName ?? '';

    final rawUser = session.userData;
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final map = jsonDecode(rawUser) as Map<String, dynamic>;
        _userId = map['id']?.toString() ?? map['_id']?.toString();
      } catch (_) {
        _userId = null;
      }
    }
  }

  Future<void> saveName() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      Get.snackbar(
        'Error',
        'User information not available. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isLoading.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      final ApiResponse response = await networkCaller.request(
        url: ApiUrls.userById(_userId!),
        method: HttpMethod.patch,
        body: {'name': name},
      );

      if (response.success) {
        final session = Get.find<SessionManager>();
        await session.setUserName(name);

        try {
          final profileController = Get.find<ProfileController>();
          profileController.userName.value = name;
        } catch (_) {}

        try {
          final homeController = Get.find<HomescreenController>();
          homeController.userName.value = name;
        } catch (_) {}

        Get.snackbar(
          'Success',
          response.message ?? 'Name updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Could not update name. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
