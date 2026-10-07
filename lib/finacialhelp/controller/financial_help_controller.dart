import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/api/api_urls.dart';
import '../../core/networkCaller/networkCaller.dart';
import '../../core/networkCaller/http_method.dart';

class FinancialHelpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  /// Selected files (supports multiple).
  final RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;

  /// Loading state for the submit button.
  final RxBool isLoading = false.obs;

  // ────────────── File Picker ──────────────

  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        selectedFiles.addAll(result.files);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick file: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  /// Remove a file from the selected list by index.
  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }

  // ────────────── Validation ──────────────

  bool _validate() {
    if (nameController.text.trim().isEmpty) {
      _showError("Full Name is required.");
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _showError("Email Address is required.");
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError("Please enter a valid email address.");
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      _showError("Phone Number is required.");
      return false;
    }

    if (addressController.text.trim().isEmpty) {
      _showError("Home Address is required.");
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      _showError("Description is required.");
      return false;
    }

    if (amountController.text.trim().isEmpty) {
      _showError("Help Amount is required.");
      return false;
    }

    if (double.tryParse(amountController.text.trim()) == null) {
      _showError("Help Amount must be a valid number.");
      return false;
    }

    if (selectedFiles.isEmpty) {
      _showError("Please attach at least one supporting document.");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      "Validation Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  // ────────────── Submit ──────────────

  Future<void> submitRequest() async {
    if (!_validate()) return;
    if (isLoading.value) return; // prevent double-tap

    isLoading.value = true;

    try {
      final networkCaller = Get.find<NetworkCaller>();

      // Collect file paths
      final List<String> filePaths = selectedFiles
          .where((f) => f.path != null)
          .map((f) => f.path!)
          .toList();

      final response = await networkCaller.uploadRequest(
        url: ApiUrls.helpRequest,
        method: HttpMethod.post,
        fields: {
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'description': descriptionController.text.trim(),
          'helpAmount': amountController.text.trim(),
        },
        multiFiles: {'doc': filePaths},
      );

      if (response.success) {
        Get.snackbar(
          "Success",
          response.message ?? "Support request submitted successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        // Clear form
        _clearForm();
      } else {
        _showError(
          response.message ?? "Something went wrong. Please try again.",
        );
      }
    } catch (e) {
      _showError("An unexpected error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    descriptionController.clear();
    amountController.clear();
    selectedFiles.clear();
  }

  // ────────────── Lifecycle ──────────────

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
