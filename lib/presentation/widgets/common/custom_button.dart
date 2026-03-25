import 'package:flutter/material.dart';

/// Custom Button Widget
///
/// Reusable button widget with customization options
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement custom button
    return const SizedBox.shrink();
  }
}
