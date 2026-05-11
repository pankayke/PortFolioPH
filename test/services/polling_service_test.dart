// test/services/polling_service_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Unit tests for PollingService and real-time data refresh.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/core/services/polling_service.dart';

void main() {
  group('PollingService', () {
    late PollingService pollingService;
    int callCount = 0;

    setUp(() {
      pollingService = PollingService();
      callCount = 0;
    });

    tearDown(() {
      pollingService.stopAll();
    });

    test('startPolling calls callback immediately', () async {
      pollingService.startPolling(
        id: 'test_poll',
        callback: () async => callCount++,
        interval: const Duration(milliseconds: 100),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(
        callCount,
        greaterThanOrEqualTo(1),
        reason: 'Should execute at least once immediately',
      );
    });

    test('startPolling calls callback periodically', () async {
      pollingService.startPolling(
        id: 'test_poll',
        callback: () async => callCount++,
        interval: const Duration(milliseconds: 50),
      );

      await Future.delayed(const Duration(milliseconds: 150));
      expect(
        callCount,
        greaterThanOrEqualTo(2),
        reason: 'Should call multiple times in 150ms with 50ms interval',
      );
    });

    test('stopPolling stops the task', () async {
      pollingService.startPolling(
        id: 'test_poll',
        callback: () async => callCount++,
        interval: const Duration(milliseconds: 50),
      );

      await Future.delayed(const Duration(milliseconds: 80));
      final callsBefore = callCount;

      pollingService.stopPolling('test_poll');
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        callCount,
        equals(callsBefore),
        reason: 'Should not call after stopping',
      );
    });

    test('isPolling returns correct state', () {
      expect(pollingService.isPolling('test_poll'), false);

      pollingService.startPolling(
        id: 'test_poll',
        callback: () async => callCount++,
        interval: const Duration(seconds: 1),
      );

      expect(pollingService.isPolling('test_poll'), true);

      pollingService.stopPolling('test_poll');
      expect(pollingService.isPolling('test_poll'), false);
    });

    test('stopAll stops all tasks', () async {
      pollingService.startPolling(
        id: 'poll_1',
        callback: () async => callCount++,
        interval: const Duration(milliseconds: 50),
      );

      pollingService.startPolling(
        id: 'poll_2',
        callback: () async => callCount++,
        interval: const Duration(milliseconds: 50),
      );

      await Future.delayed(const Duration(milliseconds: 80));
      final callsBefore = callCount;

      pollingService.stopAll();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        callCount,
        equals(callsBefore),
        reason: 'No new calls after stopAll()',
      );
      expect(pollingService.activeTaskCount, 0);
    });

    test('handles failed callbacks gracefully', () async {
      int failCount = 0;
      pollingService.startPolling(
        id: 'failing_poll',
        callback: () async {
          failCount++;
          throw Exception('Test error');
        },
        interval: const Duration(milliseconds: 50),
      );

      // Wait for 3 max failures (50ms interval * 3 + buffer)
      await Future.delayed(const Duration(milliseconds: 300));

      // Should have failed 3 times max, then stopped
      expect(failCount, lessThanOrEqualTo(3));
      expect(pollingService.isPolling('failing_poll'), false);
    });

    test('activeTaskCount reflects running tasks', () {
      expect(pollingService.activeTaskCount, 0);

      pollingService.startPolling(
        id: 'poll_1',
        callback: () async => {},
        interval: const Duration(seconds: 1),
      );
      expect(pollingService.activeTaskCount, 1);

      pollingService.startPolling(
        id: 'poll_2',
        callback: () async => {},
        interval: const Duration(seconds: 1),
      );
      expect(pollingService.activeTaskCount, 2);

      pollingService.stopPolling('poll_1');
      expect(pollingService.activeTaskCount, 1);
    });

    test('does not overlap executions when callback is slow', () async {
      int maxConcurrent = 0;
      int active = 0;
      int callTotal = 0;

      pollingService.startPolling(
        id: 'slow_poll',
        callback: () async {
          active++;
          if (active > maxConcurrent) {
            maxConcurrent = active;
          }
          callTotal++;
          await Future.delayed(const Duration(milliseconds: 120));
          active--;
        },
        interval: const Duration(milliseconds: 30),
      );

      await Future.delayed(const Duration(milliseconds: 260));
      pollingService.stopPolling('slow_poll');

      expect(
        maxConcurrent,
        equals(1),
        reason: 'Polling callback should never run in parallel for same task',
      );
      expect(callTotal, greaterThanOrEqualTo(2));
    });
  });
}
