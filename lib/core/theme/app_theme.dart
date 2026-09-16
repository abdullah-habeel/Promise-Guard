import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand colors ────────────────────────────────────────────────────────────
  static const Color navy        = Color(0xFF1B4F72);
  static const Color teal        = Color(0xFF0E9E8E);
  static const Color surface     = Color(0xFFF4F6F9);
  static const Color error       = Color(0xFFD32F2F);

  // ── Semantic colors ─────────────────────────────────────────────────────────
  static const Color confirmed    = Color(0xFF16A34A);
  static const Color notConfirmed = Color(0xFFDC2626);
  static const Color pending      = Color(0xFF6B7280);
  static const Color tentative    = Color(0xFFF59E0B);
  static const Color committed    = Color(0xFFDC2626);
  static const Color warning      = Color(0xFFE65100);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        brightness: Brightness.light,
        primary: navy,
        secondary: teal,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}