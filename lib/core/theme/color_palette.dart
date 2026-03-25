import 'package:flutter/material.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color gradientStart;
  final Color gradientEnd;
  final Color glassFill;
  final Color glassBorder;
  final Color success;
  final Color warning;
  final Color danger;

  const AppPalette({
    required this.gradientStart,
    required this.gradientEnd,
    required this.glassFill,
    required this.glassBorder,
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const AppPalette light = AppPalette(
    gradientStart: DesignTokens.accentBlueBright,
    gradientEnd: DesignTokens.accentPurple,
    glassFill: Color(0xD9FFFFFF),
    glassBorder: Color(0xA6FFFFFF),
    success: DesignTokens.accentTeal,
    warning: Color(0xFFF59E0B),
    danger: DesignTokens.accentPhilippineRed,
  );

  static const AppPalette dark = AppPalette(
    gradientStart: DesignTokens.darkBaseA,
    gradientEnd: DesignTokens.accentPurple,
    glassFill: Color(0x663B4A63),
    glassBorder: Color(0x38FFFFFF),
    success: DesignTokens.accentTeal,
    warning: Color(0xFFFBBF24),
    danger: DesignTokens.accentPhilippineRed,
  );

  @override
  AppPalette copyWith({
    Color? gradientStart,
    Color? gradientEnd,
    Color? glassFill,
    Color? glassBorder,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppPalette(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
