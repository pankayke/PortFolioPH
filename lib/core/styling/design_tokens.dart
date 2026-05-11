import 'package:flutter/material.dart';

/// Global 2026 design tokens for PortFolioPH.
abstract final class DesignTokens {
  static const Color darkBaseA = Color(0xFF0F172A);
  static const Color darkBaseB = Color(0xFF0A0F1A);
  static const Color darkBaseC = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color lightBase = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSoft = Color(0xFFF7F8FC);
  static const Color lightSurfaceTint = Color(0xFFE0F2FE);
  static const Color outlineDark = Color(0xFF334155);
  static const Color outlineLight = Color(0xFFE0E3EB);

  static const Color accentBlue = Color(0xFF8E75FF);
  static const Color accentBlueBright = Color(0xFF8E75FF);
  static const Color accentPurple = Color(0xFF8E75FF);
  static const Color accentPhilippineRed = Color(0xFFEF4444);
  static const Color accentPhilippineRedDeep = Color(0xFFDC2626);
  static const Color accentTeal = Color(0xFF32D796);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, accentPurple],
  );

  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(32));

  static const double blurCard = 24;
  static const double blurHero = 32;
  static const double blurHeavy = 36;

  static const double borderWidth = 1.5;
  static const double hoverScale = 1.04;
}
