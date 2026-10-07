import 'package:get/get.dart';
import 'package:uber_lyft_coupon/onbording/controller/onbording_controller.dart';
import 'package:uber_lyft_coupon/auth/controller/login_controller.dart';
import 'package:uber_lyft_coupon/profile/presentation/change_name_screen.dart';
import 'package:uber_lyft_coupon/auth/controller/signup_controller.dart';
import 'auth/controller/otp_controller.dart';
import 'auth/controller/forget_password_controller.dart';
import 'auth/controller/forgot_otp_controller.dart';
import 'auth/controller/reset_password_controller.dart';
import 'auth/presentation/login_screen.dart';
import 'auth/presentation/otpscreenforsignup.dart';
import 'splash/presentation/splash_screen.dart';
import 'onbording/presentation/onbording_screen.dart';
import 'auth/presentation/forgetpasswordemailscreen.dart';
import 'auth/presentation/otpforforgetpassword.dart';
import 'auth/presentation/creatnewpassword.dart';
import 'auth/presentation/signup.dart';
import 'homescreen/controller/homescreen_controller.dart';
import 'homescreen/controller/watchvideoscreencontroller.dart';
import 'homescreen/presentation/homescreen.dart';
import 'homescreen/presentation/watchvideoscreen.dart';
import 'homescreen/presentation/promo_code_screen.dart';
import 'notification/presentation/notification_screen.dart';
import 'finacialhelp/presentation/financial_help_screen.dart';
import 'profile/presentation/profile_screen.dart';
import 'profile/presentation/change_password_screen.dart';

class AppRoute {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String otpForgetPassword = '/otpForgetPassword';
  static const String createNewPassword = '/createNewPassword';
  static const String signup = '/signup';
  static const String signupOtp = '/signupOtp';
  static const String home = '/home';
  static const String watchVideo = '/watchVideo';
  static const String promoCode = '/promoCode';
  static const String notifications = '/notifications';
  static const String financialHelp = '/financialHelp';
  static const String profile = '/profile';
  static const String changeName = '/changeName';
  static const String changePassword = '/changePassword';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(
      name: onboarding,
      page: () => const OnbordingScreen(),
      binding: BindingsBuilder(() {
        Get.put(OnbordingController());
      }),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController(), fenix: true);
      }),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const Forgetpasswordemailscreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ForgetPasswordController(), fenix: true);
      }),
    ),
    GetPage(
      name: otpForgetPassword,
      page: () => const Otpforforgetpassword(),
      binding: BindingsBuilder(() {
        Get.put(ForgotOtpController());
      }),
    ),
    GetPage(
      name: createNewPassword,
      page: () => const Creatnewpassword(),
      binding: BindingsBuilder(() {
        Get.put(ResetPasswordController());
      }),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      binding: BindingsBuilder(() {
        Get.put(SignupController());
      }),
    ),
    GetPage(
      name: signupOtp,
      page: () => const Otpscreenforsignup(),
      binding: BindingsBuilder(() {
        Get.put(OtpController());
      }),
    ),
    GetPage(
      name: home,
      page: () => const Homescreen(),
      binding: BindingsBuilder(() {
        Get.put(HomescreenController());
      }),
    ),
    GetPage(
      name: watchVideo,
      page: () => const WatchVideoScreen(),
      binding: BindingsBuilder(() {
        Get.put(WatchVideoController());
      }),
    ),
    GetPage(name: promoCode, page: () => const PromoCodeScreen()),
    GetPage(name: notifications, page: () => const NotificationScreen()),
    GetPage(name: financialHelp, page: () => const FinancialHelpScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: changeName, page: () => const ChangeNameScreen()),
    GetPage(name: changePassword, page: () => const ChangePasswordScreen()),
  ];
}
