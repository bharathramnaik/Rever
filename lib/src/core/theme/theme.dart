import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReverTheme {

  const ReverTheme();

  ThemeData get lightTheme => _buildTheme(_lightColors);
  ThemeData get darkTheme => _buildTheme(_darkColors);

  static const _lightColors = ColorScheme.light(
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFF00D9A6),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFFF6B6B),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1A2E),
    outline: Color(0xFFE0E0F0),
  );

  static const _darkColors = ColorScheme.dark(
    primary: Color(0xFF8B83FF),
    secondary: Color(0xFF00E6B3),
    surface: Color(0xFF1A1A2E),
    error: Color(0xFFFF6B6B),
    onPrimary: Color(0xFF1A1A2E),
    onSecondary: Color(0xFF1A1A2E),
    onSurface: Color(0xFFE8E8F0),
    outline: Color(0xFF2E2E42),
  );

  ThemeData _buildTheme(ColorScheme colors) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outline),
        ),
        color: colors.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withOpacity(0.15),
      ),
    );
  }
}

final themeProvider = Provider<ReverTheme>((ref) {
  return const ReverTheme();
});
