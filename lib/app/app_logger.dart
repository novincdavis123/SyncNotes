import 'package:flutter/foundation.dart';

// ============================================================
// LOGGER (DEBUGGING)
// ============================================================
class AppLogger {
  static String _time() => DateTime.now().toIso8601String().substring(11, 19);

  static void log(String message) {
    if (kDebugMode) {
      print('🟣 LOG [${_time()}]: $message');
    }
  }

  static void error(String message, [Object? e]) {
    if (kDebugMode) {
      print('🔴 ERROR [${_time()}]: $message');
      if (e != null) print('❌ $e');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('🟢 SUCCESS [${_time()}]: $message');
    }
  }

  static void sync(String message) {
    if (kDebugMode) {
      print('🔵 SYNC [${_time()}]: $message');
    }
  }

  static void conflict(String message) {
    if (kDebugMode) {
      print('🟠 CONFLICT [${_time()}]: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('🟡 WARN [${_time()}]: $message');
    }
  }
}
