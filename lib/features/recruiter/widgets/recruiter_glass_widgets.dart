import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:portfolioph/core/theme/color_palette.dart';
import 'package:portfolioph/core/styling/glass_constants.dart';

class GlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class RecruiterGlassScaffold extends GlassScaffold {
  const RecruiterGlassScaffold({
    super.key,
    super.appBar,
    required super.body,
    super.floatingActionButton,
    super.bottomNavigationBar,
  });
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final double blurSigma;
  final bool solid;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.onTap,
    this.blurSigma = 20,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<AppPalette>();
    final fillColor =
        palette?.glassFill ?? colorScheme.surface.withValues(alpha: 0.15);
    final borderColor =
        palette?.glassBorder ?? colorScheme.onSurface.withValues(alpha: 0.12);

    if (solid) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? Colors.white : null,
              borderRadius: borderRadius,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient == null
                    ? fillColor.withValues(alpha: 0.15)
                    : null,
                borderRadius: borderRadius,
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.50),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.10),
                    blurRadius: GlassConstants.shadowBlurMd.toDouble(),
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class RecruiterGlassCard extends GlassCard {
  const RecruiterGlassCard({
    super.key,
    required super.child,
    super.padding,
    super.gradient,
    super.borderRadius,
    super.onTap,
    super.blurSigma,
    super.solid = true,
  });
}

class GlassGlowChip extends StatelessWidget {
  final String label;
  final Color? glowColor;

  const GlassGlowChip({super.key, required this.label, this.glowColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = glowColor ?? colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class RecruiterGlowChip extends GlassGlowChip {
  const RecruiterGlowChip({super.key, required super.label, super.glowColor});
}
