/// Glassmorphism Design System Constants
/// Defines standardized blur, opacity, and animation values for premium glass UI
class GlassConstants {
  // Prevent instantiation
  GlassConstants._();

  // ============================================================================
  // BLUR STRENGTHS (px)
  // ============================================================================
  /// Subtle blur for text overlays, light glass effects
  static const double blurXs = 6;

  /// Standard blur for card containers, inputs
  static const double blurSm = 12;

  /// Medium blur for elevated surfaces, modals
  static const double blurMd = 16;

  /// Premium blur for hero sections, backgrounds
  static const double blurLg = 24;

  /// Ultra-premium blur for deep layered effects
  static const double blurXl = 32;

  // ============================================================================
  // OPACITY LAYERS (0.0–1.0)
  // ============================================================================
  /// Glass layer opacity - light glass (light mode fallback)
  static const double opacityLightGlass = 0.80;

  /// Glass layer opacity - standard glass
  static const double opacityGlassMd = 0.30;

  /// Glass layer opacity - strong glass
  static const double opacityGlassStrong = 0.50;

  /// Border/trim opacity - subtle
  static const double opacityBorderSoft = 0.10;

  /// Border/trim opacity - visible
  static const double opacityBorderMd = 0.20;

  /// Border/trim opacity - prominent
  static const double opacityBorderStrong = 0.30;

  /// Inner glow opacity
  static const double opacityGlow = 0.15;

  /// Overlay/shadow base opacity
  static const double opacityShadow = 0.08;

  // ============================================================================
  // ANIMATION TIMINGS (milliseconds)
  // ============================================================================
  /// Quick micro-interaction (tap, hover)
  static const Duration durationQuick = Duration(milliseconds: 150);

  /// Standard interaction (card entrance, fade)
  static const Duration durationMd = Duration(milliseconds: 300);

  /// Smooth transition (modal, sheet)
  static const Duration durationSlow = Duration(milliseconds: 400);

  /// Gentle motion (floating, breathing effects)
  static const Duration durationGentle = Duration(milliseconds: 600);

  // ============================================================================
  // SCALE FACTORS (for interactive feedback)
  // ============================================================================
  /// Subtle scale on press
  static const double scalePress = 0.98;

  /// Standard scale on press
  static const double scaleHoverSmall = 1.02;

  /// Elevated scale on hover
  static const double scaleHoverMedium = 1.03;

  // ============================================================================
  // SHADOW LAYER PRESETS
  // ============================================================================
  /// Soft shadow blur radius
  static const double shadowBlurSoft = 8;

  /// Medium shadow blur radius
  static const double shadowBlurMd = 12;

  /// Strong shadow blur radius
  static const double shadowBlurStrong = 24;

  /// Standard shadow spread
  static const double shadowSpread = 4;
}
