// lib/core/services/polling_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Real-time polling service for periodic data refresh.
// Enables live API pulls at configurable intervals (e.g., 30s for job feed).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/foundation.dart';

typedef PollingCallback = Future<void> Function();

/// Manages a single polling task with auto-stop and error handling.
class PollingTask {
  final String id;
  final PollingCallback callback;
  final Duration interval;

  late Timer _timer;
  bool _isRunning = false;
  bool _isExecuting = false;
  int _failureCount = 0;
  static const int _maxFailures = 3;

  PollingTask({
    required this.id,
    required this.callback,
    required this.interval,
  });

  bool get isRunning => _isRunning;
  int get failureCount => _failureCount;

  /// Start polling.
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _failureCount = 0;
    debugPrint(
      '[PollingService] Started polling: $id (${interval.inSeconds}s)',
    );

    // Execute immediately
    _execute();

    // Then schedule recurring
    _timer = Timer.periodic(interval, (_) => _execute());
  }

  /// Stop polling.
  void stop() {
    if (!_isRunning) return;

    _isRunning = false;
    _timer.cancel();
    _failureCount = 0;
    debugPrint('[PollingService] Stopped polling: $id');
  }

  /// Reset failure counter (on success).
  void _resetFailures() {
    _failureCount = 0;
  }

  /// Execute callback with error handling.
  Future<void> _execute() async {
    if (!_isRunning || _isExecuting) return;

    _isExecuting = true;
    try {
      await callback();
      _resetFailures();
    } catch (e) {
      _failureCount++;
      debugPrint('[PollingService] Poll failed ($failureCount): $id | $e');

      // Stop polling after max failures
      if (_failureCount >= _maxFailures) {
        debugPrint('[PollingService] Max failures reached. Stopping: $id');
        stop();
      }
    } finally {
      _isExecuting = false;
    }
  }
}

/// Central polling coordinator for the app.
class PollingService {
  static final PollingService _instance = PollingService._internal();
  factory PollingService() => _instance;
  PollingService._internal();

  final Map<String, PollingTask> _tasks = {};

  /// Start a new polling task or restart existing one.
  void startPolling({
    required String id,
    required PollingCallback callback,
    Duration interval = const Duration(seconds: 30),
  }) {
    // Stop existing task with same ID
    _tasks[id]?.stop();

    // Create and start new task
    final task = PollingTask(id: id, callback: callback, interval: interval);
    _tasks[id] = task;
    task.start();
  }

  /// Stop a polling task.
  void stopPolling(String id) {
    _tasks[id]?.stop();
    _tasks.remove(id);
  }

  /// Stop all polling tasks.
  void stopAll() {
    for (final task in _tasks.values) {
      task.stop();
    }
    _tasks.clear();
    debugPrint('[PollingService] Stopped all polling tasks');
  }

  /// Check if a task is running.
  bool isPolling(String id) {
    return _tasks[id]?.isRunning ?? false;
  }

  /// Get active polling task count.
  int get activeTaskCount => _tasks.values.where((t) => t.isRunning).length;
}
