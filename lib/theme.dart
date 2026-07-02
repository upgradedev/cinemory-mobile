import 'package:flutter/material.dart';

/// Cinemory brand theme — cinematic dark, gold accent.
class CinemoryTheme {
  const CinemoryTheme._();

  static const Color gold = Color(0xFFE8C77A);
  static const Color ink = Color(0xFF0E0E12);
  static const Color surface = Color(0xFF17171F);

  static ThemeData get dark {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
    ).copyWith(surface: surface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ink,
      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
