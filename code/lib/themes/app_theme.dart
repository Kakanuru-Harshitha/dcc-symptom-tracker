// lib/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build(bool dark) {
    final base   = dark ? ThemeData.dark() : ThemeData.light();
    final colors = dark
        ? const ColorScheme.dark(
            primary: Color(0xFF0091EA), // blue-accent
            secondary: Color(0xFFFFA726), // orange
          )
        : const ColorScheme.light(
            primary: Color(0xFF0066CC), // blue
            secondary: Color(0xFFF57C00), // orange
          );

    return base.copyWith(
      colorScheme: colors,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF121212) : const Color(0xFFF7F9FC),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark
            ? const Color(0xFF1D1D1D)
            : Colors.white,
        selectedItemColor: colors.primary,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
