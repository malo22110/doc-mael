import 'package:flutter/material.dart';

class DocMaelTheme {
  static const Color primaryTeal = Color(0xFF1D829B);
  static const Color accentOrange = Color(0xFFD4542E);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color darkSlate = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: accentOrange,
        surface: lightBg,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
      ),
    );
  }
}
