// test/test_helpers.dart

import 'package:mockito/mockito.dart';

/// Base mock class for common mock setup
class BaseMock extends Mock {}

/// Helper to verify that a method was never called
void verifyNeverCalled(Function method) {
  verifyNever(method as dynamic);
}

/// Helper for async test timeout management
Future<T> withTimeout<T>(
  Future<T> function, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  return function.timeout(timeout);
}

/// Helper to create a map of arguments for verification
Map<String, dynamic> createArgumentMap(Map<String, dynamic> args) => args;

/// Matcher for Any of a specific type
Any anyOfType<T>() => any;
