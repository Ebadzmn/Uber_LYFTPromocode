import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app_colore/app_colore.dart';
import '../../approut.dart';
import '../controller/financial_help_controller.dart';

class FinancialHelpScreen extends GetView<FinancialHelpController> {
  const FinancialHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FinancialHelpController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                SizedBox(height: 10.h),
                _buildLogo(),
                SizedBox(height: 32.h),
                _buildTitle(),
                SizedBox(height: 32.h),
                _buildFormSection(),
                SizedBox(height: 40.h),
                _buildSubmitButton(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
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
                  child: Icon(Icons.shield, color: Colors.white, size: 40.r),
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

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "Support for Affected Families",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: AppColor.primaryDark,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "Families impacted by drunk driving incidents can request financial assistance through our compassionate support program",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColor.textGray,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(24.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("Full Name"),
          _buildTextField(controller.nameController, "Enter your full name"),
          SizedBox(height: 20.h),
          _buildFieldLabel("Email Address"),
          _buildTextField(controller.emailController, "your.email@example.com"),
          SizedBox(height: 20.h),
          _buildFieldLabel("Phone Number"),
          _buildTextField(
            controller.phoneController,
            "Enter your phone number",
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel("Home Address"),
          _buildTextField(
            controller.addressController,
            "Enter your full home address",
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel("Description of the Incident"),
          _buildTextField(
            controller.descriptionController,
            "Please provide details about the incident and how it has affected your family",
            maxLines: 4,
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel("Required Financial Help Amount"),
          _buildTextField(
            controller.amountController,
            "0.00",
            prefixText: r"$ ",
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel("Supporting Documents"),
          _buildFileUploadArea(),
          SizedBox(height: 8.h),
          _buildSelectedFilesList(),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              "Accepted formats: PDF, DOC, DOCX, JPG, PNG\n(Max 10MB per file)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColor.textGray.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isOptional = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.primaryDark,
            ),
          ),
          if (isOptional) ...[
            SizedBox(width: 8.w),
            Text(
              "(Optional)",
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColor.textGray.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    String? prefixText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13.sp,
          color: AppColor.textGray.withOpacity(0.5),
        ),
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.primaryDark,
        ),
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
    );
  }

  Widget _buildFileUploadArea() {
    return InkWell(
      onTap: controller.pickDocument,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: AppColor.textGray.withOpacity(0.6),
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "Tap to select files",
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColor.textGray.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return Obx(() {
      if (controller.selectedFiles.isEmpty) return const SizedBox.shrink();

      return Column(
        children: List.generate(controller.selectedFiles.length, (index) {
          final file = controller.selectedFiles[index];
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  _fileIcon(file.extension ?? ''),
                  size: 20.sp,
                  color: AppColor.primaryDark,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    file.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => controller.removeFile(index),
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  IconData _fileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          disabledBackgroundColor: const Color(0xFF0F172A).withOpacity(0.6),
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: controller.isLoading.value
            ? SizedBox(
                height: 24.r,
                width: 24.r,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                "Submit Support Request",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
      ),
    );
  }
}
