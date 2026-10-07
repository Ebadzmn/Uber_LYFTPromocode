/// Centralised place for all API-related URLs and endpoint paths.
class ApiUrls {
  ApiUrls._(); // Prevent instantiation

  /// The base URL for all API requests.
  ///
  /// Update this to point to your staging / production server.
  static const String baseUrl = 'https://api.zeroproofdrive.org/api/v1';

  // ─────────────── Endpoint paths ────────────────
  static const String signUp = '/user';
  static const String login = '/auth/login';
  static const String forgetPassword = '/auth/forget-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotOtpVerify = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/refresh-token';
  static const String helpRequest = '/help-request';
  static const String checkEmail = '/coupon-usage/check-email';
  static const String verifyEmail = '/coupon-usage/verify-email';
  static const String video = '/video';
  static const String generateCoupon = '/coupon/random';
  static const String couponClaimStatus = '/coupon/claim-status';
  static const String couponClaim = '/coupon/claim';
  // static const String profile     = '/user/profile';
  // static const String courses     = '/courses';

  static String userById(String id) => '/user/$id';
}
