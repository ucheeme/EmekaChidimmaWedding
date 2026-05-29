import 'package:flutter/foundation.dart';

/// Centralized logging — never log tokens, PII, or media content.
class AppLogger {
  const AppLogger._();

  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint(_format('DEBUG', message, tag));
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint(_format('INFO', message, tag));
    }
  }

  static void warning(String message, {String? tag}) {
    debugPrint(_format('WARN', message, tag));
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    debugPrint(_format('ERROR', message, tag));
    if (kDebugMode && error != null) {
      debugPrint('$error');
      if (stackTrace != null) {
        debugPrint('$stackTrace');
      }
    }
  }

  static String _format(String level, String message, String? tag) {
    final prefix = tag != null ? '[$tag]' : '[ForeverMoments]';
    return '$prefix $level: $message';
  }
}
