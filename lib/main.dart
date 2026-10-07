import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'approut.dart';
import 'core/networkCaller/networkCaller.dart';
import 'core/services/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register services (order matters — SessionManager first for auth tokens).
  await Get.putAsync<SessionManager>(() => SessionManager().init());
  await Get.putAsync<NetworkCaller>(() => NetworkCaller().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zero Proof Drive',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(),
          ),
          initialRoute: AppRoute.splash,
          getPages: AppRoute.routes,
        );
      },
    );
  }
}
