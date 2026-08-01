import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ReverTheme {
  const ReverTheme();

  ThemeData get lightTheme => _buildTheme(_lightColors, brightness: Brightness.light);
  ThemeData get darkTheme => _buildTheme(_darkColors, brightness: Brightness.dark);

  static const _lightColors = ColorScheme.light(
    primary: Color(0xFF6C4DF6),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEDE9FF),
    onPrimaryContainer: Color(0xFF2A1B6E),
    secondary: Color(0xFF00B894),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD8FFF4),
    onSecondaryContainer: Color(0xFF004D3E),
    surface: Color(0xFFFAFAFD),
    onSurface: Color(0xFF17171F),
    surfaceContainerHighest: Color(0xFFEFEFF6),
    surfaceContainer: Color(0xFFF4F4FA),
    onSurfaceVariant: Color(0xFF5D5D6E),
    error: Color(0xFFE5484D),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDADC),
    onErrorContainer: Color(0xFF5C0006),
    outline: Color(0xFFE2E2EE),
    outlineVariant: Color(0xFFEEEEF6),
    surfaceTint: Color(0xFF6C4DF6),
  );

  static const _darkColors = ColorScheme.dark(
    primary: Color(0xFF9B8CFF),
    onPrimary: Color(0xFF1A1030),
    primaryContainer: Color(0xFF3A2A7A),
    onPrimaryContainer: Color(0xFFE7E1FF),
    secondary: Color(0xFF00E5B8),
    onSecondary: Color(0xFF00332A),
    secondaryContainer: Color(0xFF005A48),
    onSecondaryContainer: Color(0xFFB6FFF0),
    surface: Color(0xFF0F0F16),
    onSurface: Color(0xFFEFEFF6),
    surfaceContainerHighest: Color(0xFF1E1E2A),
    surfaceContainer: Color(0xFF16161F),
    onSurfaceVariant: Color(0xFF9A9AAE),
    error: Color(0xFFFF6369),
    onError: Color(0xFF570008),
    errorContainer: Color(0xFF8C1D22),
    onErrorContainer: Color(0xFFFFDADB),
    outline: Color(0xFF2A2A3A),
    outlineVariant: Color(0xFF23232F),
    surfaceTint: Color(0xFF9B8CFF),
  );

  ThemeData _buildTheme(ColorScheme colors, {required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final displayFont = GoogleFonts.playfairDisplayTextTheme();
    final bodyFont = GoogleFonts.manropeTextTheme();

    final textTheme = TextTheme(
      displayLarge: displayFont.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: colors.onSurface,
      ),
      displayMedium: displayFont.displayMedium?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: colors.onSurface,
      ),
      headlineLarge: displayFont.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: colors.onSurface,
      ),
      headlineMedium: displayFont.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: colors.onSurface,
      ),
      headlineSmall: bodyFont.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleLarge: bodyFont.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleMedium: bodyFont.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleSmall: bodyFont.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        color: colors.onSurface,
      ),
      bodyMedium: bodyFont.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
        color: colors.onSurface,
      ),
      bodySmall: bodyFont.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.4,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: bodyFont.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: bodyFont.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: bodyFont.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      textTheme: textTheme,
      brightness: brightness,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? const Color(0xFF16161F)
            : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colors.outline.withValues(alpha: isDark ? 0.6 : 0.8),
          ),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall!.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.primary,
        unselectedLabelColor: colors.onSurfaceVariant,
        indicatorColor: colors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        dividerColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: colors.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: colors.outline),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        selectedColor: colors.primary.withValues(alpha: 0.15),
        checkmarkColor: colors.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDark ? const Color(0xFF23232F) : const Color(0xFF17171F),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        iconColor: colors.onSurfaceVariant,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primary.withValues(alpha: 0.12),
        circularTrackColor: colors.primary.withValues(alpha: 0.12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeSlideTransitions(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: _FadeSlideTransitions(),
          TargetPlatform.linux: _FadeSlideTransitions(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

class _FadeSlideTransitions extends PageTransitionsBuilder {
  const _FadeSlideTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

enum ReverThemeMode { system, light, dark }

class ThemeModeNotifier extends Notifier<ReverThemeMode> {
  @override
  ReverThemeMode build() => ReverThemeMode.system;

  void setMode(ReverThemeMode mode) => state = mode;

  void toggle() {
    state = state == ReverThemeMode.dark
        ? ReverThemeMode.light
        : state == ReverThemeMode.light
            ? ReverThemeMode.dark
            : ReverThemeMode.dark;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ReverThemeMode>(
  ThemeModeNotifier.new,
);

final themeProvider = Provider<ReverTheme>((ref) {
  return const ReverTheme();
});
