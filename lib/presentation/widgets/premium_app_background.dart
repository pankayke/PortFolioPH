// Premium app background with gradient and animated bokeh particles.
import 'package:flutter/material.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';

class PremiumAppBackground extends StatelessWidget {
  final Widget child;
  final AnimationController? animation;
  final bool lite;

  const PremiumAppBackground({
    super.key,
    required this.child,
    this.animation,
    this.lite = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        /// Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      DesignTokens.darkBaseA,
                      DesignTokens.darkSurface,
                      DesignTokens.darkBaseC,
                    ]
                  : [
                      DesignTokens.lightBase,
                      DesignTokens.lightSurfaceSoft,
                      DesignTokens.lightSurfaceTint,
                    ],
            ),
          ),
        ),
        // Sunrise hint glow for PH warmth, kept intentionally subtle.
        Positioned(
          left: -120,
          top: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (isDark
                          ? DesignTokens.accentPhilippineRed
                          : DesignTokens.accentPhilippineRedDeep)
                      .withAlpha(isDark ? 22 : 14),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Animated bokeh particles (optional - requires animation controller)
        if (!lite && animation != null)
          CustomPaint(
            painter: _BokehBackgroundPainter(
              animation: animation!,
              isDark: isDark,
            ),
            size: Size.infinite,
          ),

        /// Content
        child,
      ],
    );
  }
}

/// Custom painter for animated bokeh background
class _BokehBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  _BokehBackgroundPainter({required this.animation, required this.isDark})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = (isDark ? Colors.white : DesignTokens.accentBlue).withAlpha(
        isDark ? 8 : 12,
      );

    // Generate a small set of bokeh circles (lighter for performance)
    final circles = [
      (dx: 80.0, dy: 150.0, size: 140.0),
      (dx: 200.0, dy: 40.0, size: 120.0),
      (dx: 320.0, dy: 200.0, size: 90.0),
      (dx: 150.0, dy: 300.0, size: 140.0),
    ];

    for (var i = 0; i < circles.length; i++) {
      final circle = circles[i];
      final offset = animation.value * 6;
      final yOffset = (i % 2 == 0) ? offset : -offset;

      paint.color = isDark
          ? DesignTokens.accentBlue.withAlpha(18)
          : DesignTokens.accentBlue.withAlpha(10);

      canvas.drawCircle(
        Offset(circle.dx, circle.dy + yOffset),
        circle.size / 2,
        paint,
      );
    }

    // Very subtle talent-network lines to add brand texture behind glass layers.
    for (var i = 0; i < circles.length - 1; i++) {
      final c1 = circles[i];
      final c2 = circles[i + 1];
      final start = Offset(
        c1.dx,
        c1.dy + ((i % 2 == 0) ? animation.value * 8 : -animation.value * 8),
      );
      final end = Offset(
        c2.dx,
        c2.dy +
            (((i + 1) % 2 == 0) ? animation.value * 8 : -animation.value * 8),
      );
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(_BokehBackgroundPainter oldDelegate) => true;
}
