import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(centerTitle: true),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: const CardThemeData(
        elevation: 1,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
