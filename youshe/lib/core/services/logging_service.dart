import 'package:flutter/foundation.dart';

enum LogLevel { error, warn, info, debug }

class LoggingService {
  static final LoggingService _instance = LoggingService._();
  factory LoggingService() => _instance;
  LoggingService._();

  void log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final prefix = '[${level.name.toUpperCase()}]${tag != null ? '[$tag]' : ''}';
    final ts = DateTime.now().toIso8601String();

    if (level == LogLevel.error || level == LogLevel.warn) {
      debugPrint('$ts $prefix $message${error != null ? ' | $error' : ''}');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    } else {
      debugPrint('$ts $prefix $message');
    }
  }

  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void warn(String message, {String? tag, Object? error}) {
    log(LogLevel.warn, message, tag: tag, error: error);
  }

  void info(String message, {String? tag}) {
    log(LogLevel.info, message, tag: tag);
  }

  void debug(String message, {String? tag}) {
    log(LogLevel.debug, message, tag: tag);
  }
}
