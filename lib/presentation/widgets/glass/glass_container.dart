// lib/presentation/widgets/glass/glass_container.dart
// ─────────────────────────────────────────────────────────────────────────────
// Premium glassmorphism container widget
// Handles blur effects, translucent backgrounds, borders, and depth layers
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';

class GlassContainer extends StatelessWidget {
  /// Main content widget
  final Widget child;

  /// Container width (defaults to maxWidth constraint)
  final double? width;

  /// Container height
  final double? height;

  /// Padding around child
  final EdgeInsetsGeometry? padding;

  /// Glassmorphism blur strength (16–32px recommended)
  final double blurStrength;

  /// Backdrop saturation (120–180% typical for depth)
  final double saturation;

  /// Glass opacity (0.10–0.30 typical)
  final double opacity;

  /// Border color opacity (0.15–0.25 typical)
  final double borderOpacity;

  /// Border radius
  final double borderRadius;

  /// Shadow depth intensity
  final double shadowIntensity;

  /// Custom gradient background (bypasses default)
  final Gradient? backgroundGradient;

  /// Enable inner glow effect on focus/hover
  final bool enableGlow;

  /// Glow color (primary accent by default)
  final Color? glowColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.blurStrength = 14.0,
    this.saturation = 150.0,
    this.opacity = 0.18,
    this.borderOpacity = 0.2,
    this.borderRadius = 24.0,
    this.shadowIntensity = 0.10,
    this.backgroundGradient,
    this.enableGlow = true,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGlowColor =
        glowColor ?? AppConstants.primaryColor.withAlpha(50);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          // Glow layer (background)
          if (enableGlow)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    radius: 1.5,
                    colors: [
                      effectiveGlowColor.withAlpha(40),
                      effectiveGlowColor.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),

          // Glass layer
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withAlpha((borderOpacity * 255).toInt()),
                width: DesignTokens.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8 * shadowIntensity,
                  offset: const Offset(0, 8),
                  color: Colors.black.withAlpha(
                    ((shadowIntensity * 0.32) * 255).toInt(),
                  ),
                ),
                BoxShadow(
                  blurRadius: 20 * shadowIntensity,
                  offset: const Offset(0, 4),
                  color: Colors.black.withAlpha(
                    ((shadowIntensity * 0.24) * 255).toInt(),
                  ),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: blurStrength,
                  sigmaY: blurStrength,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        backgroundGradient ??
                        LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (isDark ? const Color(0xFF1E293B) : Colors.white)
                                .withAlpha((opacity * 255).toInt()),
                            Colors.white.withAlpha(
                              (opacity * 0.8 * 255).toInt(),
                            ),
                          ],
                        ),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: Padding(
                    padding:
                        padding ?? const EdgeInsets.all(AppConstants.spacingMd),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
