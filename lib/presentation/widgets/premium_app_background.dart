// Premium app background with gradient and animated bokeh particles.
import 'package:flutter/material.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';

class PremiumAppBackground extends StatelessWidget {
  final Widget child;
  final AnimationController? animation;

  const PremiumAppBackground({super.key, required this.child, this.animation});

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
                      const Color(0xFF1E293B),
                      DesignTokens.darkBaseC,
                    ]
                  : [
                      DesignTokens.lightBase,
                      const Color(0xFFF1F5F9),
                      const Color(0xFFE0F2FE),
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

        /// Animated bokeh particles (optional - requires animation controller)
        if (animation != null)
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
      ..strokeWidth = 1.1
      ..color = (isDark ? Colors.white : const Color(0xFF0A66C2)).withAlpha(
        isDark ? 14 : 20,
      );

    // Generate 12 bokeh circles with subtle movement
    final circles = [
      (dx: 20.0, dy: 60.0, size: 120.0),
      (dx: 80.0, dy: 150.0, size: 200.0),
      (dx: 200.0, dy: 40.0, size: 150.0),
      (dx: 320.0, dy: 200.0, size: 100.0),
      (dx: 150.0, dy: 300.0, size: 180.0),
      (dx: 400.0, dy: 100.0, size: 130.0),
      (dx: 50.0, dy: 400.0, size: 160.0),
      (dx: 300.0, dy: 320.0, size: 110.0),
      (dx: 450.0, dy: 200.0, size: 140.0),
      (dx: 100.0, dy: 500.0, size: 120.0),
      (dx: 350.0, dy: 450.0, size: 100.0),
      (dx: 200.0, dy: 550.0, size: 150.0),
    ];

    for (var i = 0; i < circles.length; i++) {
      final circle = circles[i];
      final offset = animation.value * 8;
      final yOffset = (i % 2 == 0) ? offset : -offset;

      paint.color = isDark
          ? const Color(0xFF0A66C2).withAlpha(30)
          : const Color(0xFF0A66C2).withAlpha(15);

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
      final start = Offset(c1.dx, c1.dy + ((i % 2 == 0) ? animation.value * 8 : -animation.value * 8));
      final end = Offset(c2.dx, c2.dy + (((i + 1) % 2 == 0) ? animation.value * 8 : -animation.value * 8));
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(_BokehBackgroundPainter oldDelegate) => true;
}
