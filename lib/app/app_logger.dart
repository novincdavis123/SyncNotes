import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      print('🟣 LOG: $message');
    }
  }

  static void error(String message, [Object? e]) {
    if (kDebugMode) {
      print('🔴 ERROR: $message');
      if (e != null) print(e);
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('🟢 SUCCESS: $message');
    }
  }

  static void sync(String message) {
    if (kDebugMode) {
      print('🔵 SYNC: $message');
    }
  }
}
