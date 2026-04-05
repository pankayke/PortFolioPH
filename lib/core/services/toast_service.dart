// lib/core/services/toast_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Global toast/snackbar service for user feedback
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

class ToastService {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show success toast
  static void showSuccess(String message) {
    _show(
      message: message,
      type: ToastType.success,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
    );
  }

  /// Show error toast
  static void showError(String message) {
    _show(
      message: message,
      type: ToastType.error,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  /// Show info toast
  static void showInfo(String message) {
    _show(
      message: message,
      type: ToastType.info,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline,
    );
  }

  /// Show warning toast
  static void showWarning(String message) {
    _show(
      message: message,
      type: ToastType.warning,
      backgroundColor: Colors.orange.shade600,
      icon: Icons.warning_amber,
    );
  }

  /// Internal implementation
  static void _show({
    required String message,
    required ToastType type,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
