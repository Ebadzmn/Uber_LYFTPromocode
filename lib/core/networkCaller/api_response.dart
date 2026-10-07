/// A generic API response wrapper used across the app.
///
/// [T] is the type of the parsed response data.
class ApiResponse<T> {
  /// Whether the request was successful (status 2xx).
  final bool success;

  /// The parsed response data (null on failure unless partially available).
  final T? data;

  /// A human-readable message (error detail or success note).
  final String? message;

  /// The HTTP status code returned by the server.
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  /// Convenience factory for a successful response.
  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Convenience factory for a failed response.
  factory ApiResponse.error({String? message, int? statusCode, T? data}) {
    return ApiResponse(
      success: false,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, statusCode: $statusCode, message: $message, data: $data)';
}
