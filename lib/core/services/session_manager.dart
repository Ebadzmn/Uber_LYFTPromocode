import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages session tokens and user persistence using [SharedPreferences].
///
/// Register once in `main.dart`:
/// ```dart
/// await Get.putAsync<SessionManager>(() => SessionManager().init());
/// ```
class SessionManager extends GetxService {
  late final SharedPreferences _prefs;

  // ─────────────── Keys ───────────────
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  /// Initialise SharedPreferences instance.
  Future<SessionManager> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ─────────────── Access Token ───────────────
  String? get accessToken => _prefs.getString(_accessTokenKey);

  Future<void> setAccessToken(String token) async {
    await _prefs.setString(_accessTokenKey, token);
  }

  // ─────────────── Refresh Token ──────────────
  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  // ─────────────── User Data ──────────────────
  String? get userData => _prefs.getString(_userDataKey);

  Future<void> setUserData(String jsonString) async {
    await _prefs.setString(_userDataKey, jsonString);
  }

  // ─────────────── User Profile ────────────────
  static const String _userNameKey = 'user_name';
  static const String _profilePhotoKey = 'profile_photo';
  static const String _createdAtKey = 'created_at';
  static const String _userEmailKey = 'user_email';

  String? get userName => _prefs.getString(_userNameKey);

  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  String? get profilePhoto => _prefs.getString(_profilePhotoKey);

  Future<void> setProfilePhoto(String url) async {
    await _prefs.setString(_profilePhotoKey, url);
  }

  String? get createdAt => _prefs.getString(_createdAtKey);

  Future<void> setCreatedAt(String date) async {
    await _prefs.setString(_createdAtKey, date);
  }

  String? get userEmail => _prefs.getString(_userEmailKey);

  Future<void> setUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  // ─────────────── Registered Email (Watch Video flow) ────────────────
  static const String _registeredEmailKey = 'registered_email';

  String? get registeredEmail => _prefs.getString(_registeredEmailKey);

  Future<void> setRegisteredEmail(String email) async {
    await _prefs.setString(_registeredEmailKey, email);
  }

  // ─────────────── Coupon Data ────────────────
  static const String _couponDataKey = 'coupon_data';

  Map<String, dynamic>? get couponData {
    final json = _prefs.getString(_couponDataKey);
    if (json == null || json.isEmpty) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setCouponData(Map<String, dynamic> data) async {
    await _prefs.setString(_couponDataKey, jsonEncode(data));
  }

  Future<void> clearCouponData() async {
    await _prefs.remove(_couponDataKey);
  }

  // ─────────────── Session Helpers ────────────
  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  /// Saves both tokens in one call.
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    String? userData,
    String? userName,
    String? profilePhoto,
    String? createdAt,
    String? userEmail,
  }) async {
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
    if (userData != null) {
      await setUserData(userData);
    }
    if (userName != null) {
      await setUserName(userName);
    }
    if (profilePhoto != null) {
      await setProfilePhoto(profilePhoto);
    }
    if (createdAt != null) {
      await setCreatedAt(createdAt);
    }
    if (userEmail != null) {
      await setUserEmail(userEmail);
    }
  }

  /// Clears all session data (logout).
  Future<void> clearSession() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userDataKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_profilePhotoKey);
    await _prefs.remove(_createdAtKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_registeredEmailKey);
    await _prefs.remove(_couponDataKey);
  }

  // ─────────────── Onboarding ─────────────────
  static const String _onboardingKey = 'onboarding_completed';

  bool get isOnboardingCompleted => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_onboardingKey, true);
  }
}
