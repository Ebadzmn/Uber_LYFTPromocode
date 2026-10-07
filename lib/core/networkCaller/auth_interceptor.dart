import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../approut.dart';
import '../api/api_urls.dart';
import '../services/session_manager.dart';

/// A [QueuedInterceptor] that handles automatic token refresh on 401 responses.
///
/// How it works:
/// 1. **onRequest** – Injects the latest `accessToken` into every request.
/// 2. **onError**   – On a 401, calls `/refresh-token` to get a new
///    `accessToken`, stores it, and retries the original request.
///    If the refresh itself fails, clears all session data and navigates
///    to the Login screen.
///
/// Uses [QueuedInterceptor] so that concurrent 401 errors are serialised
/// (only one refresh call at a time).
class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;

  /// A **separate** Dio instance used exclusively for the refresh call
  /// so it doesn't trigger interceptors (which would cause an infinite loop).
  late final Dio _refreshDio;

  AuthInterceptor(this._dio) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiUrls.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {'Accept': 'application/json'},
        contentType: 'application/json',
      ),
    );
  }

  // ───────────────── Inject Token ─────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final session = Get.find<SessionManager>();
      final token = session.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // SessionManager not registered yet — skip.
    }
    super.onRequest(options, handler);
  }

  // ───────────────── Handle 401 ──────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    if (kDebugMode) {
      debugPrint('🔄 AuthInterceptor: 401 received — attempting token refresh');
    }

    try {
      final session = Get.find<SessionManager>();
      final storedRefreshToken = session.refreshToken;

      // No refresh token available → force logout
      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        await _forceLogout(session);
        return super.onError(err, handler);
      }

      // Call the refresh endpoint with a separate Dio instance
      final refreshResponse = await _refreshDio.post(
        ApiUrls.refreshToken,
        data: {'refreshToken': storedRefreshToken},
      );

      final responseData = refreshResponse.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        // Extract the new accessToken
        final data = responseData['data'] as Map<String, dynamic>?;
        final newAccessToken = data?['accessToken']?.toString() ?? '';

        if (newAccessToken.isNotEmpty) {
          // Save the new accessToken (refreshToken stays the same)
          await session.setAccessToken(newAccessToken);

          if (kDebugMode) {
            debugPrint('✅ AuthInterceptor: Token refreshed successfully');
          }

          // Retry the original request with the new token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await _dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        }
      }

      // Refresh response didn't contain a valid token
      await _forceLogout(session);
      return super.onError(err, handler);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthInterceptor: Refresh failed — $e');
      }

      try {
        final session = Get.find<SessionManager>();
        await _forceLogout(session);
      } catch (_) {}

      return super.onError(err, handler);
    }
  }

  // ───────────────── Force Logout ────────────────

  Future<void> _forceLogout(SessionManager session) async {
    await session.clearSession();

    if (kDebugMode) {
      debugPrint('🚪 AuthInterceptor: Session cleared — navigating to Login');
    }

    Get.offAllNamed(AppRoute.login);
  }
}
