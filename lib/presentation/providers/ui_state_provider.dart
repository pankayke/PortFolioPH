// lib/presentation/providers/ui_state_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Provider helpers for managing common UI states: loading, error, success
// Used by screens to track async operations with automatic error handling
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../../core/services/api_error_interceptor.dart';

/// Enum for UI state lifecycle
enum UiStateType { initial, loading, success, error }

/// Immutable UI state container
/// Simplifies state management: all screens can use this pattern
class UiState {
  final UiStateType type;
  final dynamic data;
  final ApiException? error;
  final int? statusCode;

  const UiState({
    required this.type,
    this.data,
    this.error,
    this.statusCode,
  });

  // Factory constructors for convenience
  factory UiState.initial() => const UiState(type: UiStateType.initial);

  factory UiState.loading() => const UiState(type: UiStateType.loading);

  factory UiState.success(dynamic data, {int? statusCode}) => UiState(
    type: UiStateType.success,
    data: data,
    statusCode: statusCode,
  );

  factory UiState.error(ApiException error) => UiState(
    type: UiStateType.error,
    error: error,
  );

  // Convenience getters
  bool get isLoading => type == UiStateType.loading;
  bool get isSuccess => type == UiStateType.success;
  bool get isError => type == UiStateType.error;
  bool get isInitial => type == UiStateType.initial;

  @override
  String toString() => 'UiState($type)';
}

/// ChangeNotifier mixin for easy async operation handling
/// Usage:
/// ```dart
/// class MyScreenProvider extends ChangeNotifier with AsyncOperationMixin {
///   loadData() async {
///     await executeAsync(
///       operation: () => apiService.getData(),
///       onSuccess: (data) => _data = data,
///     );
///   }
/// }
/// ```
mixin AsyncOperationMixin on ChangeNotifier {
  UiState _state = UiState.initial();

  UiState get state => _state;

  /// Execute async operation with automatic state management
  Future<T?> executeAsync<T>({
    required Future<T> Function() operation,
    void Function(T data)? onSuccess,
    void Function(ApiException error)? onError,
  }) async {
    try {
      _state = UiState.loading();
      notifyListeners();

      final result = await operation();

      _state = UiState.success(result);
      onSuccess?.call(result);
      notifyListeners();

      return result;
    } on ApiException catch (e) {
      _state = UiState.error(e);
      onError?.call(e);
      notifyListeners();
      return null;
    } catch (e) {
      final error = ApiException(
        e.toString(),
        code: 'UNKNOWN',
        originalError: e,
      );
      _state = UiState.error(error);
      onError?.call(error);
      notifyListeners();
      return null;
    }
  }

  /// Reset state to initial
  void resetState() {
    _state = UiState.initial();
    notifyListeners();
  }

  /// Set state directly (for manual control)
  void setState(UiState newState) {
    _state = newState;
    notifyListeners();
  }
}

/// Example provider implementation
/// Shows how to use AsyncOperationMixin for common use cases
class ExampleAsyncProvider extends ChangeNotifier with AsyncOperationMixin {
  // Example: List state
  List<dynamic> _items = [];
  List<dynamic> get items => _items;

  // Example usage:
  // Future<void> loadItems() async {
  //   await executeAsync(
  //     operation: () => apiService.getItems(),
  //     onSuccess: (items) {
  //       _items = items;
  //     },
  //     onError: (error) {
  //       // Handle error if needed (already in state)
  //     },
  //   );
  // }

  // Future<void> retryLoadItems() async {
  //   resetState(); // Reset to initial before retry
  //   await loadItems();
  // }
}

/// Pagination mixin for paginated list screens
mixin PaginationMixin on ChangeNotifier with AsyncOperationMixin {
  int _currentPage = 1;
  int _perPage = 15;
  List<dynamic> _items = [];
  bool _hasMore = true;

  int get currentPage => _currentPage;
  int get perPage => _perPage;
  List<dynamic> get items => _items;
  bool get hasMore => _hasMore;

  /// Load first page
  Future<void> loadFirstPage({
    required Future<List<dynamic>> Function(int page, int perPage) operation,
  }) async {
    _currentPage = 1;
    await executeAsync(
      operation: () => operation(_currentPage, _perPage),
      onSuccess: (data) {
        _items = data;
        _hasMore = data.length >= _perPage;
      },
    );
  }

  /// Load next page and append
  Future<void> loadNextPage({
    required Future<List<dynamic>> Function(int page, int perPage) operation,
  }) async {
    if (!_hasMore || state.isLoading) return;

    _currentPage++;
    await executeAsync(
      operation: () => operation(_currentPage, _perPage),
      onSuccess: (data) {
        _items.addAll(data);
        _hasMore = data.length >= _perPage;
      },
      onError: (error) {
        _currentPage--; // Decrement if failed
      },
    );
  }

  /// Reset pagination
  void resetPagination() {
    _currentPage = 1;
    _items = [];
    _hasMore = true;
    resetState();
  }
}
