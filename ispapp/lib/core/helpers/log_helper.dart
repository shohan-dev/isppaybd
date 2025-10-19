import 'dart:convert';

class AppLoggerHelper {
  /// Simple debug logging using Flutter's built-in print
  static void debug(String message) {
    print('🐛 DEBUG $message');
  }

  /// Simple info logging using Flutter's built-in print
  static void info(String message) {
    print('💡 INFO $message');
  }

  /// Simple warning logging using Flutter's built-in print
  static void warning(String message) {
    print('⚠️  WARN $message');
  }

  /// Simple error logging using Flutter's built-in print
  static void error(String message, [dynamic error]) {
    print('❌ ERROR  $message');
    if (error != null) {
      print('   └─ Error details: $error');
    }
  }

  /// Pretty print JSON data for better readability
  static String prettyJson(dynamic json) {
    try {
      if (json is String) {
        // Try to parse if it's a JSON string
        final parsed = jsonDecode(json);
        return JsonEncoder.withIndent('  ').convert(parsed);
      } else {
        return JsonEncoder.withIndent('  ').convert(json);
      }
    } catch (e) {
      return json.toString();
    }
  }

  /// Log HTTP request with enhanced UI/UX
  static void logHttpRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    // Header with method prominently displayed
    info('');
    info('🚀 ═══════════════════════════════════════════════════════════════');
    info('📤 HTTP REQUEST');
    info('   METHOD: ⚡ $method');
    info('   URL: 🌍 $url');

    if (queryParams?.isNotEmpty == true) {
      info('   QUERY PARAMS: 🔍 ${queryParams?.length ?? 0} parameters');
      debug('   └─ Query Details: ${prettyJson(queryParams)}');
    }

    if (headers?.isNotEmpty == true) {
      info('   HEADERS: 📋 ${headers?.length ?? 0} items');
    }

    if (body != null) {
      final bodySize = body.toString().length;
      info('   BODY: 📄 $bodySize characters');
      if (bodySize > 0) {
        try {
          debug('   └─ Request Body:\n${prettyJson(body)}');
        } catch (e) {
          debug('   └─ Request Body: $body');
        }
      }
    }

    info('═══════════════════════════════════════════════════════════════');
  }

  /// Log HTTP response with enhanced UI/UX
  static void logHttpResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, dynamic>? headers,
    dynamic body,
    int? duration,
  }) {
    // Status code color and emoji based on HTTP status
    String statusEmoji = '✅';
    String statusDescription = 'SUCCESS';

    if (statusCode >= 400 && statusCode < 500) {
      statusEmoji = '⚠️';
      statusDescription = 'CLIENT ERROR';
    } else if (statusCode >= 500) {
      statusEmoji = '❌';
      statusDescription = 'SERVER ERROR';
    } else if (statusCode >= 300) {
      statusEmoji = '�';
      statusDescription = 'REDIRECT';
    }

    // Enhanced response header
    info('');
    info('📡 ═══════════════════════════════════════════════════════════════');
    info('📥 HTTP RESPONSE');
    info('   METHOD: ⚡ $method');
    info('   URL: 🌍 $url');
    info('   STATUS: $statusEmoji $statusCode ($statusDescription)');

    if (duration != null) {
      String durationEmoji = '⚡';
      if (duration > 3000) {
        durationEmoji = '🐌';
      } else if (duration > 1000)
        durationEmoji = '⏱️';

      info('   DURATION: $durationEmoji ${duration}ms');
    }

    if (headers?.isNotEmpty == true) {
      info('   HEADERS: 📋 ${headers?.length ?? 0} items');
    }

    if (body != null) {
      final bodySize = body.toString().length;
      String sizeEmoji = '📄';
      if (bodySize > 10000) {
        sizeEmoji = '📚';
      } else if (bodySize > 1000) {
        sizeEmoji = '📃';
      }

      info('   RESPONSE SIZE: $sizeEmoji $bodySize characters');
      info('');
      info('📋 RESPONSE BODY:');
      info('┌─────────────────────────────────────────────────────────────');

      try {
        // Format as pretty JSON with proper indentation
        final prettyBody = prettyJson(body);
        final lines = prettyBody.split('\n');
        for (final line in lines) {
          debug('│ $line');
        }
      } catch (e) {
        // If JSON formatting fails, show raw response with proper formatting
        final lines = body.toString().split('\n');
        for (final line in lines) {
          debug('│ $line');
        }
      }

      info('└─────────────────────────────────────────────────────────────');
    }

    info('═══════════════════════════════════════════════════════════════');
    info('');
  }

  /// Log HTTP error in a clean, compact format
  static void logHttpError({
    required String method,
    required String url,
    required String errorType,
    String? errorMessage,
    int? statusCode,
  }) {
    final buffer = StringBuffer();
    buffer.write('💥 ERROR $method $url');

    if (statusCode != null) {
      buffer.write(' • Status: $statusCode');
    }

    buffer.write(' • Type: $errorType');

    if (errorMessage != null) {
      buffer.write(' • Message: $errorMessage');
    }

    error(buffer.toString());
  }
}
