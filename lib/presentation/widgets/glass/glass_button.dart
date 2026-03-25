// lib/presentation/widgets/glass/glass_button.dart
// ─────────────────────────────────────────────────────────────────────────────
// Premium glassmorphic buttons with gradient, glow, and hover effects
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:portfolioph/core/constants/app_constants.dart';

enum GlassButtonStyle { primary, secondary, tertiary }

class GlassButton extends StatefulWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button style variant
  final GlassButtonStyle style;

  /// Icon to display (optional)
  final IconData? icon;

  /// Icon position (left or right of text)
  final bool iconRight;

  /// Full width button
  final bool fullWidth;

  /// Is loading state
  final bool isLoading;

  /// Button disabled state
  final bool? enabled;

  /// Custom gradient (for primary buttons)
  final Gradient? gradient;

  /// Glassmorphism blur strength
  final double glassBlur;

  /// Glass opacity
  final double glassOpacity;

  /// Shadow intensity
  final double shadowIntensity;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = GlassButtonStyle.primary,
    this.icon,
    this.iconRight = false,
    this.fullWidth = true,
    this.isLoading = false,
    this.enabled,
    this.gradient,
    this.glassBlur = 12.0,
    this.glassOpacity = 0.15,
    this.shadowIntensity = 1.0,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        widget.enabled ?? widget.onPressed != null && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: isEnabled ? _onTapDown : null,
        onTapUp: isEnabled ? _onTapUp : null,
        onTapCancel: isEnabled ? _onTapCancel : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: _buildButton(isEnabled),
      ),
    );
  }

  Widget _buildButton(bool isEnabled) {
    switch (widget.style) {
      case GlassButtonStyle.primary:
        return _buildPrimaryButton(isEnabled);
      case GlassButtonStyle.secondary:
        return _buildSecondaryButton(isEnabled);
      case GlassButtonStyle.tertiary:
        return _buildTertiaryButton(isEnabled);
    }
  }

  Widget _buildPrimaryButton(bool isEnabled) {
    return Container(
      width: widget.fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient:
            widget.gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                Color.lerp(AppConstants.primaryColor, Colors.white, 0.22)!,
              ],
            ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16 * widget.shadowIntensity,
            offset: const Offset(0, 8),
            color: AppConstants.primaryColor.withAlpha(
              ((0.3 * widget.shadowIntensity) * 255).toInt(),
            ),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: _buildButtonContent(isEnabled),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(bool isEnabled) {
    return Container(
      width: widget.fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(77), width: 1.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 8 * widget.shadowIntensity,
            offset: const Offset(0, 4),
            color: Colors.black.withAlpha(
              ((0.1 * widget.shadowIntensity) * 255).toInt(),
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: widget.glassBlur,
            sigmaY: widget.glassBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(
                (widget.glassOpacity * 255).toInt(),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: _buildButtonContent(isEnabled, isSecondary: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTertiaryButton(bool isEnabled) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? widget.onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: _buildButtonContent(isEnabled, isText: true),
        ),
      ),
    );
  }

  Widget _buildButtonContent(
    bool isEnabled, {
    bool isSecondary = false,
    bool isText = false,
  }) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isText
                ? AppConstants.primaryColor
                : isSecondary
                ? AppConstants.primaryColor
                : Colors.white,
          ),
        ),
      );
    }

    final textColor = isText
        ? AppConstants.primaryColor
        : isSecondary
        ? AppConstants.primaryColor
        : Colors.white;

    final children = [
      if (widget.icon != null && !widget.iconRight)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(widget.icon, size: 16, color: textColor),
        ),
      Text(
        widget.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: isText ? 13 : 14,
        ),
      ),
      if (widget.icon != null && widget.iconRight)
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(widget.icon, size: 16, color: textColor),
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
