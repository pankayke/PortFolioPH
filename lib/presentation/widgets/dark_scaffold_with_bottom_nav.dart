import 'package:flutter/material.dart';

import 'package:portfolioph/core/styling/design_tokens.dart';

/// Shared dark scaffold wrapper for tab screens with persistent bottom nav.
///
/// Keeps a stable dark background and prevents web color bleed by ensuring
/// the body sits on an opaque surface.
class DarkScaffoldWithBottomNav extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Extra clearance added to the scrollable bottom inset (e.g. FAB height).
  final double extraBottomClearance;

  const DarkScaffoldWithBottomNav({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extraBottomClearance = 0,
  });

  /// Recommended bottom inset for scrollables inside tabs with persistent nav.
  ///
  /// Includes nav bar height + safe area inset + optional extra clearance.
  static double scrollBottomInset(
    BuildContext context, {
    double extraClearance = 0,
  }) {
    return kBottomNavigationBarHeight +
        MediaQuery.viewPaddingOf(context).bottom +
        extraClearance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? DesignTokens.darkBaseC
          : Theme.of(context).colorScheme.surface,
      appBar: appBar,
      body: SafeArea(
        top: false,
        bottom: false,
        child: ColoredBox(
          color: Theme.of(context).brightness == Brightness.dark
              ? DesignTokens.darkBaseC
              : Theme.of(context).colorScheme.surface,
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
