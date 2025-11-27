import 'package:flutter/material.dart';

class AppTheme {
  static const Color baseColor = Color(0xFFE0E5EC);
  static const Color lightShadow = Color(0xFFFFFFFF);
  static const Color darkShadow = Color(0xFFA3B1C6);
  static const Color accentColor = Color(0xFF6C63FF);
  static const Color textColor = Color(0xFF4A4A4A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: baseColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        background: baseColor,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textColor),
      ),
    );
  }
}
