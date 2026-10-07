import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:http_parser/http_parser.dart';

import '../api/api_urls.dart';
import 'api_response.dart';
import 'auth_interceptor.dart';
import 'http_method.dart';
import 'logging_interceptor.dart';

/// A production-ready, reusable network service built on top of [Dio].
///
/// Register once with `Get.put(NetworkCaller())` and retrieve anywhere
/// via `Get.find<NetworkCaller>()`.
///
/// Every HTTP call goes through the single [request] method which returns
/// a typed [ApiResponse<T>].
class NetworkCaller extends GetxService {
  late final Dio _dio;

  /// Default timeout durations (in milliseconds).
  static const int _connectTimeout = 30000;
  static const int _receiveTimeout = 30000;
  static const int _sendTimeout = 30000;

  /// Initialises the [Dio] instance with base options and interceptors.
  ///
  /// Call this after registration, e.g.:
  /// ```dart
  /// await Get.put(NetworkCaller()).init();
  /// ```
  Future<NetworkCaller> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiUrls.baseUrl,
        connectTimeout: const Duration(milliseconds: _connectTimeout),
        receiveTimeout: const Duration(milliseconds: _receiveTimeout),
        sendTimeout: const Duration(milliseconds: _sendTimeout),
        headers: _globalHeaders,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Attach the auth interceptor for automatic token injection & refresh.
    _dio.interceptors.add(AuthInterceptor(_dio));

    // Attach the logging interceptor (only active in debug mode).
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    return this;
  }

  /// Global headers sent with every request.
  ///
  /// Automatically includes the `Authorization` header when a session
  /// token is available.
  /// Global headers sent with every request.
  ///
  /// Note: The `Authorization` header is injected dynamically by
  /// [AuthInterceptor.onRequest] to always use the latest token.
  Map<String, dynamic> get _globalHeaders {
    return <String, dynamic>{'Accept': 'application/json'};
  }

  // ─────────────────────── Public API ───────────────────────

  /// The **single** entry-point for all HTTP calls.
  ///
  /// - [url]             – The endpoint path (appended to [ApiUrls.baseUrl]).
  /// - [method]          – The HTTP verb (see [HttpMethod]).
  /// - [queryParameters] – Optional query params.
  /// - [body]            – Optional request body (Map, FormData, etc.).
  /// - [headers]         – Optional per-request headers (merged with globals).
  ///
  /// Returns an [ApiResponse<T>] wrapping success/failure details.
  Future<ApiResponse<T>> request<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.request<T>(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(method: _resolveMethod(method), headers: headers),
      );

      return ApiResponse<T>.success(
        data: response.data,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      return _handleDioException<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(message: 'An unexpected error occurred: $e');
    }
  }

  /// Sends a **multipart/form-data** request — just like Postman's form-data.
  ///
  /// - [url]             – The endpoint path (appended to [ApiUrls.baseUrl]).
  /// - [method]          – The HTTP verb (typically POST or PUT).
  /// - [fields]          – Plain text key-value pairs (normal body fields).
  /// - [files]           – A map of `fieldName → filePath` for file uploads.
  ///                       Supports images, PDFs, videos, etc.
  /// - [queryParameters] – Optional query params.
  /// - [headers]         – Optional per-request headers.
  ///
  /// Example usage:
  /// ```dart
  /// final response = await networkCaller.uploadRequest(
  ///   url: '/user/update-profile',
  ///   method: HttpMethod.post,
  ///   fields: {'name': 'John', 'email': 'john@test.com'},
  ///   files: {'avatar': '/path/to/image.jpg'},
  /// );
  /// ```
  Future<ApiResponse<T>> uploadRequest<T>({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? fields,
    Map<String, String>? files,
    Map<String, List<String>>? multiFiles,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final formData = FormData();

      // ── Add plain text fields ──
      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      // ── Add single file fields ──
      if (files != null) {
        for (final entry in files.entries) {
          final filePath = entry.value;
          final fileName = filePath.split('/').last;

          formData.files.add(
            MapEntry(
              entry.key,
              await MultipartFile.fromFile(
                filePath,
                filename: fileName,
                contentType: _resolveContentType(fileName),
              ),
            ),
          );
        }
      }

      // ── Add multiple files under the same key ──
      if (multiFiles != null) {
        for (final entry in multiFiles.entries) {
          for (final filePath in entry.value) {
            final fileName = filePath.split('/').last;

            formData.files.add(
              MapEntry(
                entry.key,
                await MultipartFile.fromFile(
                  filePath,
                  filename: fileName,
                  contentType: _resolveContentType(fileName),
                ),
              ),
            );
          }
        }
      }

      final response = await _dio.request<T>(
        url,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          method: _resolveMethod(method),
          headers: {
            ...?headers,
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      return ApiResponse<T>.success(
        data: response.data,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } on DioException catch (e) {
      return _handleDioException<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(message: 'An unexpected error occurred: $e');
    }
  }

  // ──────────────────── Private Helpers ─────────────────────

  /// Maps the [HttpMethod] enum to the Dio method string.
  String _resolveMethod(HttpMethod method) {
    switch (method) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
    }
  }

  /// Converts a [DioException] into a user-friendly [ApiResponse].
  ApiResponse<T> _handleDioException<T>(DioException e) {
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message =
            'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request send timed out. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server took too long to respond. Please try again later.';
        break;
      case DioExceptionType.badResponse:
        message = _extractErrorMessage(e.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network settings.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Invalid SSL certificate. Connection is not secure.';
        break;
      case DioExceptionType.unknown:
        message = e.message ?? 'An unexpected network error occurred.';
        break;
    }

    return ApiResponse<T>.error(
      message: message,
      statusCode: e.response?.statusCode,
    );
  }

  /// Tries to extract a readable error message from the response body.
  String _extractErrorMessage(Response? response) {
    if (response == null) return 'Unknown server error.';

    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Common API error-message field names.
      return data['message'] ??
          data['error'] ??
          data['msg'] ??
          'Server error (${response.statusCode})';
    }

    return 'Server error (${response.statusCode})';
  }

  /// Resolves a MIME [MediaType] from the file extension.
  MediaType _resolveContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      // Images
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'svg':
        return MediaType('image', 'svg+xml');
      // Documents
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
      case 'docx':
        return MediaType('application', 'msword');
      // Video
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      // Default binary
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
