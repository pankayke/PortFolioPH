// lib/core/theme/app_theme.dart
// ─────────────────────────────────────────────────────────────────────────────
// Material 3 theme definitions for PortFolioPH.
// All colour values sourced from AppConstants – no magic literals here.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';
import 'package:portfolioph/core/theme/color_palette.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: brightness,
    );

    final colorScheme = baseScheme.copyWith(
      primary: isDark ? DesignTokens.accentBlueBright : DesignTokens.accentBlue,
      secondary: isDark ? DesignTokens.accentPurple : AppConstants.accentColor,
      error: AppConstants.errorColor,
      surface: isDark ? DesignTokens.darkBaseB : DesignTokens.lightBase,
      surfaceContainerHighest: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFEAF0FF),
      outlineVariant: isDark
          ? const Color(0xFF334155)
          : const Color(0xFFD2DBF3),
    );

    final textTheme = _buildTextTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [isDark ? AppPalette.dark : AppPalette.light],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? const Color(0x66304159)
            : Colors.white.withValues(alpha: 0.76),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.72),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingSm),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0x66304159)
            : Colors.white.withValues(alpha: 0.75),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.72),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.72),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: DesignTokens.accentBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: DesignTokens.accentBlue,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
            vertical: AppConstants.spacingSm,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: colorScheme.outlineVariant),
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: AppConstants.spacingMd,
        color: colorScheme.outlineVariant,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Shared text theme builder ─────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color baseColor = brightness == Brightness.light
        ? Colors.black87
        : Colors.white;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: AppConstants.fontSizeDisplay,
        fontWeight: FontWeight.w800,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: AppConstants.fontSizeXxl,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: AppConstants.fontSizeXxl,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: AppConstants.fontSizeXl,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: AppConstants.fontSizeLg,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: TextStyle(fontSize: AppConstants.fontSizeLg, color: baseColor),
      bodyMedium: TextStyle(
        fontSize: AppConstants.fontSizeMd,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        color: baseColor.withValues(alpha: 0.72),
      ),
      labelLarge: TextStyle(
        fontSize: AppConstants.fontSizeLg,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: AppConstants.fontSizeMd,
        fontWeight: FontWeight.w500,
        color: baseColor.withValues(alpha: 0.85),
      ),
      labelSmall: TextStyle(
        fontSize: AppConstants.fontSizeSm,
        color: baseColor.withValues(alpha: 0.75),
      ),
    );
  }
}
