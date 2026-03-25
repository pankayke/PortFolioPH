import 'package:flutter/material.dart';

/// Global 2026 design tokens for PortFolioPH.
abstract final class DesignTokens {
  static const Color darkBaseA = Color(0xFF0F172A);
  static const Color darkBaseB = Color(0xFF0A0F1A);
  static const Color darkBaseC = Color(0xFF111827);
  static const Color lightBase = Color(0xFFF8FAFC);

  static const Color accentBlue = Color(0xFF0A66C2);
  static const Color accentBlueBright = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPhilippineRed = Color(0xFFEF4444);
  static const Color accentPhilippineRedDeep = Color(0xFFDC2626);
  static const Color accentTeal = Color(0xFF14B8A6);

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

