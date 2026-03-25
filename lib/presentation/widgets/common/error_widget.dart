import 'package:flutter/material.dart';

/// Error Widget
///
/// Displays error messages
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement error widget
    return const SizedBox.shrink();
  }
}
