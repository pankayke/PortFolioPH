// lib/presentation/widgets/theme_toggle_button.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reusable theme toggle button widget.
// Centralizes theme toggle logic to eliminate duplication across screens.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/presentation/providers/theme_provider.dart';

/// Reusable theme toggle button with consistent behavior across the app.
///
/// Shows the appropriate icon based on current theme mode and toggles between
/// light and dark modes on press.
///
/// Usage:
/// ```dart
/// AppBar(
///   actions: [ThemeToggleButton()],
/// )
/// ```
class ThemeToggleButton extends StatelessWidget {
  /// Optional custom tooltip text.
  final String? tooltip;

  /// Optional custom icon size.
  final double? iconSize;

  const ThemeToggleButton({super.key, this.tooltip, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.themeMode == ThemeMode.dark;

        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          iconSize: iconSize,
          tooltip: tooltip ?? 'Toggle theme',
          onPressed: () => themeProvider.toggleDarkMode(),
        );
      },
    );
  }
}
