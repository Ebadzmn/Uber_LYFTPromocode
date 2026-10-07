import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app_colore/app_colore.dart';
import '../controller/change_name_controller.dart';

class ChangeNameScreen extends GetView<ChangeNameController> {
  const ChangeNameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChangeNameController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildBackButton(),
              SizedBox(height: 32.h),
              _buildForm(),
              SizedBox(height: 32.h),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Get.back(),
      icon: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColor.primaryDark),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Change Name",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.primaryDark,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            hintText: "Type ....",
            hintStyle: TextStyle(fontSize: 13.sp, color: AppColor.textGray.withOpacity(0.5)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.all(16.r),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFF1F5F9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFF1F5F9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColor.primaryDark.withOpacity(0.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: controller.saveName,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 0,
      ),
      child: Text(
        "Save",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
