import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/appicon/app_icon.png',
          width: 250.w, // Adjusted width for icon
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
