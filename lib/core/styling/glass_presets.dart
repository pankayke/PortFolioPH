/// Glassmorphism Presets
/// Pre-configured glass styling combinations for different use cases
import 'package:flutter/material.dart';
import 'glass_constants.dart';

/// Preset configurations for glass containers (blur + opacity combinations)
class GlassPresets {
  // Prevent instantiation
  GlassPresets._();

  // ============================================================================
  // CONTAINER PRESETS (blur, opacity for bg)
  // ============================================================================

  /// Subtle background — light glass for secondary content
  static const GlassPreset subtle = GlassPreset(
    blurStrength: GlassConstants.blurXs,
    bgOpacity: GlassConstants.opacityGlassMd,
    borderOpacity: GlassConstants.opacityBorderSoft,
  );

  /// Standard card preset — primary UI containers
  static const GlassPreset card = GlassPreset(
    blurStrength: GlassConstants.blurSm,
    bgOpacity: GlassConstants.opacityGlassMd,
    borderOpacity: GlassConstants.opacityBorderMd,
  );

  /// Elevated surface — modals, bottom sheets, dropdowns
  static const GlassPreset elevated = GlassPreset(
    blurStrength: GlassConstants.blurMd,
    bgOpacity: GlassConstants.opacityGlassStrong,
    borderOpacity: GlassConstants.opacityBorderMd,
  );

  /// Premium hero section — splash screens, headers
  static const GlassPreset hero = GlassPreset(
    blurStrength: GlassConstants.blurLg,
    bgOpacity: GlassConstants.opacityGlassStrong,
    borderOpacity: GlassConstants.opacityBorderStrong,
  );

  /// Ultra-premium background layer — deep depth effects
  static const GlassPreset ultra = GlassPreset(
    blurStrength: GlassConstants.blurXl,
    bgOpacity: GlassConstants.opacityGlassStrong,
    borderOpacity: GlassConstants.opacityBorderMd,
  );

  /// Form input preset — fields, search, text areas
  static const GlassPreset input = GlassPreset(
    blurStrength: GlassConstants.blurSm,
    bgOpacity: GlassConstants.opacityGlassMd,
    borderOpacity: GlassConstants.opacityBorderMd,
  );

  /// Button preset — CTAs, actions
  static const GlassPreset button = GlassPreset(
    blurStrength: GlassConstants.blurXs,
    bgOpacity: GlassConstants.opacityGlassMd,
    borderOpacity: GlassConstants.opacityBorderSoft,
  );

  // ============================================================================
  // BORDER/GLOW PRESETS
  // ============================================================================

  /// Soft border for subtle separation
  static const BorderPreset borderSoft = BorderPreset(
    width: 1.0,
    opacity: GlassConstants.opacityBorderSoft,
  );

  /// Standard border for definition
  static const BorderPreset borderMd = BorderPreset(
    width: 1.5,
    opacity: GlassConstants.opacityBorderMd,
  );

  /// Prominent border for focus/active states
  static const BorderPreset borderStrong = BorderPreset(
    width: 2.0,
    opacity: GlassConstants.opacityBorderStrong,
  );

  /// Glow effect for interactive elements
  static const GlowPreset glowSoft = GlowPreset(
    blurRadius: GlassConstants.shadowBlurSoft,
    opacity: GlassConstants.opacityGlow,
    spreadRadius: 2,
  );

  static const GlowPreset glowMd = GlowPreset(
    blurRadius: GlassConstants.shadowBlurMd,
    opacity: GlassConstants.opacityGlow,
    spreadRadius: 4,
  );

  static const GlowPreset glowStrong = GlowPreset(
    blurRadius: GlassConstants.shadowBlurStrong,
    opacity: GlassConstants.opacityGlow,
    spreadRadius: 6,
  );
}

/// Glass container configuration
class GlassPreset {
  final double blurStrength;
  final double bgOpacity;
  final double borderOpacity;

  const GlassPreset({
    required this.blurStrength,
    required this.bgOpacity,
    required this.borderOpacity,
  });
}

/// Border styling preset
class BorderPreset {
  final double width;
  final double opacity;

  const BorderPreset({required this.width, required this.opacity});
}

/// Glow/shadow styling preset
class GlowPreset {
  final double blurRadius;
  final double opacity;
  final double spreadRadius;

  const GlowPreset({
    required this.blurRadius,
    required this.opacity,
    required this.spreadRadius,
  });
}
