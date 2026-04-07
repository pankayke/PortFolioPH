// lib/presentation/widgets/error_widget.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reusable error display widget with optional retry button
// Shows user-friendly error messages + action button for retrying
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../core/exceptions/custom_exceptions.dart';

/// Displays error message with optional retry button
/// 
/// Features:
/// - Shows error icon + message + action button
/// - Detects if error is retryable (network/server errors)
/// - Customizable retry callback
/// - Adaptive UI for different screen sizes
class ApiErrorWidget extends StatelessWidget {
  final ApiException error;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const ApiErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRetryable = error.isRetryable && showRetryButton;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon with color based on error type
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getErrorColor(context).withValues(alpha: 0.1),
                ),
                padding: const EdgeInsets.all(20),
                child: Icon(
                  _getErrorIcon(),
                  size: 48,
                  color: _getErrorColor(context),
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              Text(
                'Oops!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                error.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Retry button (if error is retryable and callback provided)
              if (isRetryable && onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getErrorColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                )
              else if (onRetry != null)
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Dismiss'),
                )
              else
                SizedBox(
                  width: 200,
                  child: Text(
                    'Error code: ${error.code ?? "UNKNOWN"}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get appropriate icon for error type
  IconData _getErrorIcon() {
    if (error.isNetworkError) {
      return Icons.cloud_off;
    } else if (error.isServerError) {
      return Icons.storage;
    }
    return Icons.error_outline;
  }

  /// Get color for error type
  Color _getErrorColor(BuildContext context) {
    if (error.isNetworkError) {
      return Colors.orange;
    } else if (error.isServerError) {
      return Colors.red;
    }
    return Colors.red;
  }
}

/// Compact error display (for inline use in forms, lists, etc)
class CompactErrorWidget extends StatelessWidget {
  final ApiException error;
  final VoidCallback? onRetry;

  const CompactErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRetryable = error.isRetryable;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isRetryable && onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                color: Colors.blue,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error snackbar for transient errors
void showErrorSnackbar(
  BuildContext context,
  ApiException error, {
  VoidCallback? onRetry,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  
  messenger.showSnackBar(
    SnackBar(
      content: Text(error.message),
      backgroundColor: error.isNetworkError ? Colors.orange : Colors.red,
      duration: duration,
      action: error.isRetryable && onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    ),
  );
}
