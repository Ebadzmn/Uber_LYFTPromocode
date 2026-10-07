import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A Dio [Interceptor] that logs request, response, and error details
/// in debug mode only.
///
/// Features:
/// - Pretty-printed JSON bodies
/// - cURL command generation
/// - Request duration tracking
/// - Well-formatted, separator-wrapped console output
class LoggingInterceptor extends Interceptor {
  // ───────────────────────── Request ─────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      // Store the start time for duration tracking
      options.extra['_startTime'] = DateTime.now().millisecondsSinceEpoch;

      final buffer = StringBuffer();
      buffer.writeln('');
      buffer.writeln(
        '╔══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║  📤 REQUEST');
      buffer.writeln(
        '╠══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║  URL        : ${options.uri}');
      buffer.writeln('║  Method     : ${options.method}');
      buffer.writeln('║  Headers    :');
      options.headers.forEach((key, value) {
        buffer.writeln('║               $key: $value');
      });
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('║  Query Params:');
        options.queryParameters.forEach((key, value) {
          buffer.writeln('║               $key: $value');
        });
      }
      if (options.data != null) {
        buffer.writeln('║  Body       :');
        if (options.data is FormData) {
          buffer.writeln(
            _formatFormData(
              options.data as FormData,
            ).split('\n').map((l) => '║               $l').join('\n'),
          );
        } else {
          buffer.writeln(
            _prettyJson(
              options.data,
            ).split('\n').map((l) => '║               $l').join('\n'),
          );
        }
      }
      buffer.writeln(
        '╠──────────────────────────────────────────────────────────',
      );
      buffer.writeln('║  🔗 cURL');
      buffer.writeln('║  ${_generateCurl(options)}');
      buffer.writeln(
        '╚══════════════════════════════════════════════════════════',
      );

      debugPrint(buffer.toString());
    }

    super.onRequest(options, handler);
  }

  // ───────────────────────── Response ────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final duration = _getDuration(response.requestOptions);

      final buffer = StringBuffer();
      buffer.writeln('');
      buffer.writeln(
        '╔══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║  📥 RESPONSE');
      buffer.writeln(
        '╠══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║  URL         : ${response.requestOptions.uri}');
      buffer.writeln('║  Status Code : ${response.statusCode}');
      buffer.writeln('║  Duration    : ${duration}ms');
      buffer.writeln('║  Headers     :');
      response.headers.forEach((name, values) {
        buffer.writeln('║                $name: ${values.join(', ')}');
      });
      buffer.writeln('║  Data        :');
      buffer.writeln(
        _prettyJson(
          response.data,
        ).split('\n').map((l) => '║                $l').join('\n'),
      );
      buffer.writeln(
        '╚══════════════════════════════════════════════════════════',
      );

      debugPrint(buffer.toString());
    }

    super.onResponse(response, handler);
  }

  // ─────────────────────────── Error ─────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final duration = _getDuration(err.requestOptions);

      final buffer = StringBuffer();
      buffer.writeln('');
      buffer.writeln(
        '╔══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║  ❌ ERROR');
      buffer.writeln(
        '╠══════════════════════════════════════════════════════════',
      );
      buffer.writeln('║  URL         : ${err.requestOptions.uri}');
      buffer.writeln('║  Type        : ${err.type}');
      buffer.writeln('║  Status Code : ${err.response?.statusCode ?? 'N/A'}');
      buffer.writeln('║  Message     : ${err.message ?? 'No message'}');
      buffer.writeln('║  Duration    : ${duration}ms');
      if (err.response?.data != null) {
        buffer.writeln('║  Response    :');
        buffer.writeln(
          _prettyJson(
            err.response?.data,
          ).split('\n').map((l) => '║                $l').join('\n'),
        );
      }
      buffer.writeln(
        '╚══════════════════════════════════════════════════════════',
      );

      debugPrint(buffer.toString());
    }

    super.onError(err, handler);
  }

  // ───────────────────────── Helpers ─────────────────────────

  /// Returns a pretty-printed JSON string for maps/lists, or `.toString()` for
  /// other types.
  String _prettyJson(dynamic data) {
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  /// Returns a human-readable summary of [FormData] fields and files.
  String _formatFormData(FormData formData) {
    final buffer = StringBuffer();
    buffer.writeln('[multipart/form-data]');
    if (formData.fields.isNotEmpty) {
      buffer.writeln('  Fields:');
      for (final entry in formData.fields) {
        buffer.writeln('    ${entry.key}: ${entry.value}');
      }
    }
    if (formData.files.isNotEmpty) {
      buffer.writeln('  Files:');
      for (final entry in formData.files) {
        buffer.writeln(
          '    ${entry.key}: ${entry.value.filename} (${entry.value.length} bytes)',
        );
      }
    }
    return buffer.toString().trimRight();
  }

  /// Calculates the duration in ms since the request was sent.
  int _getDuration(RequestOptions options) {
    final startTime = options.extra['_startTime'] as int?;
    if (startTime == null) return 0;
    return DateTime.now().millisecondsSinceEpoch - startTime;
  }

  /// Generates a cURL command string from [RequestOptions].
  String _generateCurl(RequestOptions options) {
    final components = <String>['curl -i'];

    // Method
    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method.toUpperCase()}');
    }

    // Headers
    options.headers.forEach((key, value) {
      components.add('-H "$key: $value"');
    });

    // Body
    if (options.data != null) {
      if (options.data is FormData) {
        final formData = options.data as FormData;
        for (final field in formData.fields) {
          components.add('-F "${field.key}=${field.value}"');
        }
        for (final file in formData.files) {
          components.add('-F "${file.key}=@${file.value.filename}"');
        }
      } else {
        String body;
        if (options.data is Map || options.data is List) {
          body = jsonEncode(options.data);
        } else {
          body = options.data.toString();
        }
        components.add("-d '$body'");
      }
    }

    // URL (includes query params)
    components.add('"${options.uri}"');

    return components.join(' \\\n║       ');
  }
}
