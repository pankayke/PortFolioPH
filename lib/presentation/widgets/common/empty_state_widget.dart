import 'package:flutter/material.dart';

/// Empty State Widget
///
/// Displays empty state UI
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement empty state widget
    return const SizedBox.shrink();
  }
}
