/// Screen state mixins for common patterns
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

/// Provides automatic user-aware data loading on screen initialization
/// Handles:
/// - User ID caching to prevent redundant loads
/// - Safe post-frame callback for data loading
///
/// Example:
/// ```dart
/// class MyScreen extends State<MyScreen> with UserAwareScreenMixin {
///   @override
///   void didChangeDependencies() {
///     loadDataForUser(
///       onLoad: (userId) {
///         context.read<MyProvider>().loadForUser(userId);
///       },
///     );
///   }
/// }
/// ```
mixin UserAwareScreenMixin {
  /// Tracks the last loaded user ID to prevent redundant loads
  int? _loadedForUserId;

  /// Get the current loaded user ID
  int? get loadedForUserId => _loadedForUserId;

  /// Reset the loaded user ID (useful on logout)
  void resetLoadedUserId() {
    _loadedForUserId = null;
  }

  /// Call this in didChangeDependencies() to handle user-aware loading
  /// Only triggers onLoad() if user ID has changed
  void loadDataForUser(VoidCallback onLoad) {
    final state = this as State;
    final userId = state.context.read<AuthProvider>().currentUser?.id;

    if (userId == null || _loadedForUserId == userId) return;

    _loadedForUserId = userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.mounted) return;
      onLoad();
    });
  }

  /// Variant that passes the user ID to the callback
  void loadDataForUserWithId(Function(int userId) onLoad) {
    final state = this as State;
    final userId = state.context.read<AuthProvider>().currentUser?.id;

    if (userId == null || _loadedForUserId == userId) return;

    _loadedForUserId = userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.mounted) return;
      onLoad(userId);
    });
  }
}
