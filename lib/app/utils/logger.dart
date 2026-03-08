import 'dart:developer' as developer;

class AppLogger {
  const AppLogger._();

  static void d(String message, {String tag = 'DEBUG'}) {
    developer.log(message, name: tag);
  }

  static void e(String message, {String tag = 'ERROR', Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: tag, error: error, stackTrace: stackTrace);
  }
}

