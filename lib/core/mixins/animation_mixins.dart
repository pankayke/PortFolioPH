/// Animation mixins for common animation patterns
library;

import 'package:flutter/material.dart';

/// Provides a managed AnimationController for bokeh background animations
/// Use with TickerProviderStateMixin
///
/// Example:
/// ```dart
/// class MyScreen extends State<MyScreen> with TickerProviderStateMixin, BokehAnimationMixin {
///   @override
///   void initState() {
///     super.initState();
///     initializeBokehAnimation();
///   }
/// }
/// ```
mixin BokehAnimationMixin {
  late AnimationController _bokehController;

  AnimationController get bokehController => _bokehController;

  /// Initialize the bokeh animation controller
  /// Must be called in initState()
  /// Requires this state to mix with TickerProviderStateMixin
  void initializeBokehAnimation({
    Duration duration = const Duration(seconds: 8),
  }) {
    if (this is! TickerProvider) {
      throw Error.safeToString(
        'BokehAnimationMixin requires TickerProviderStateMixin on the State class',
      );
    }

    _bokehController = AnimationController(
      duration: duration,
      vsync: this as TickerProvider,
    )..repeat();
  }

  /// Dispose the animation controller
  /// Must be called in dispose()
  void disposeBokehAnimation() {
    _bokehController.dispose();
  }
}
