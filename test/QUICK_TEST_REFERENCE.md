// test/QUICK_TEST_REFERENCE.md

# Quick Test References & Snippets

## Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific file
flutter test test/domain/usecases/auth/register_usecase_test.dart

# Pattern matching
flutter test --name="RegisterUseCase"
flutter test --grep="should validate"

# Watch mode
flutter test --watch

# Stop at first failure
flutter test --fail-fast
```

## Basic Test Template

```dart
// test/domain/usecases/example/example_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockRepository extends Mock implements MyRepository {}

void main() {
  late MyUseCase myUseCase;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    myUseCase = MyUseCase(mockRepository);
  });

  group('MyUseCase', () {
    test('should do something', () async {
      // Arrange
      when(mockRepository.method())
          .thenAnswer((_) async => Right(data));

      // Act
      final result = await myUseCase.call();

      // Assert
      expect(result.isRight(), true);
      verify(mockRepository.method()).called(1);
    });

    test('should handle failure', () async {
      // Arrange
      when(mockRepository.method())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await myUseCase.call();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<MyFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
```

## Common Test Patterns

### Testing Valid Input
```dart
test('should succeed with valid input', () async {
  when(mockRepo.method(arg: 'valid'))
      .thenAnswer((_) async => Right(expectedResult));

  final result = await useCase.call(arg: 'valid');

  expect(result.isRight(), true);
  result.fold(
    (failure) => fail('Should succeed'),
    (success) => expect(success, expectedResult),
  );
});
```

### Testing Validation Failure
```dart
test('should return validation failure', () async {
  final result = await useCase.call(arg: '');

  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure, isA<ValidationFailure>()),
    (_) => fail('Should fail'),
  );
});
```

### Testing Network Error
```dart
test('should return network failure', () async {
  when(mockRepo.method())
      .thenAnswer((_) async => Left(NetworkFailure()));

  final result = await useCase.call();

  expect(result.isLeft(), true);
});
```

### Testing Repository Calls
```dart
test('should call repository with correct params', () async {
  when(mockRepo.method(param: 'value'))
      .thenAnswer((_) async => Right(data));

  await useCase.call(param: 'value');

  verify(mockRepo.method(param: 'value')).called(1);
});
```

## Entity Testing

### Create and Compare
```dart
test('entities should be equal', () {
  final entity1 = MyEntity(name: 'Test');
  final entity2 = MyEntity(name: 'Test');
  expect(entity1, entity2);
});
```

### Test Domain Rules
```dart
test('should determine correct state', () {
  final entity = MyEntity(status: 'open');
  expect(entity.isOpen, true);
});
```

### Test Formatting
```dart
test('should format data correctly', () {
  final entity = MyEntity(min: 100, max: 200);
  expect(entity.range, '\$100 - \$200');
});
```

## Integration Testing

### Multi-Step Workflow
```dart
test('complete workflow', () async {
  // Step 1
  final step1 = await useCase1.call();
  expect(step1.isRight(), true);

  // Step 2 - Use result from step 1
  final data = step1.getOrElse(() => throw Exception());
  final step2 = await useCase2.call(data);

  // Verify final state
  expect(step2.isRight(), true);
});
```

## Using Fixtures

```dart
import 'package:test/fixtures/mock_fixtures.dart';

// Predefined users
final user = MockFixtures.createTestUser();
final recruiter = MockFixtures.createTestRecruiter();

// Predefined jobs
final job = MockFixtures.createTestJob();
final jobs = MockFixtures.createTestJobs(count: 5);

// Custom instances
final customJob = MockFixtures.createTestJob(
  title: 'Custom Title',
  salary: 75000,
);
```

## Mockito Patterns

### Mock with Named Parameters
```dart
when(mockRepo.method(
  param1: anyNamed('param1'),
  param2: anyNamed('param2'),
)).thenAnswer((_) async => Right(data));

verify(mockRepo.method(
  param1: anyNamed('param1'),
  param2: anyNamed('param2'),
)).called(1);
```

### Mock with Any Type
```dart
// Match any argument
when(mockRepo.method(any)).thenAnswer((_) async => Right(data));

// Match any of specific type
when(mockRepo.method(
  list: anyNamed('list'),
)).thenAnswer((_) async => Right(data));
```

### Mock Sequential Calls
```dart
when(mockRepo.method())
    .thenAnswer((_) async => Right(data1))
    .thenAnswer((_) async => Right(data2));

await useCase.call(); // Returns data1
await useCase.call(); // Returns data2
```

### Verify Call Count
```dart
verify(mockRepo.method()).called(1);      // Exactly once
verify(mockRepo.method()).called(2);      // Exactly twice
verify(mockRepo.method()).called(greaterThan(0)); // At least once
verifyNever(mockRepo.method());            // Never called
```

## Dartz Either Patterns

### Extract Right Value
```dart
final result = await useCase.call();
result.fold(
  (failure) => print('Error: $failure'),
  (success) => print('Success: $success'),
);
```

### Get or Throw
```dart
final result = await useCase.call();
final value = result.getOrElse(() => throw Exception());
```

### Check Type
```dart
expect(result.isRight(), true);
expect(result.isLeft(), false);
```

## Debugging Tests

### Print Debug Info
```dart
test('debug test', () async {
  final result = await useCase.call();
  
  print('Result: $result');
  
  result.fold(
    (failure) => print('Failure: $failure'),
    (success) => print('Success: $success'),
  );
});
```

### Set Breakpoint in Test
```dart
test('test with breakpoint', () async {
  // Place cursor here and press Ctrl+Shift+D
  final result = await useCase.call();
  expect(result.isRight(), true);
});
```

### Verbose Test Output
```bash
flutter test --verbose
```

## Assertion Helpers

### Common Assertions
```dart
expect(value, equals(expected));
expect(value, isNotEmpty);
expect(value, isEmpty);
expect(list, contains(item));
expect(value, containsAll([a, b, c]));
expect(error, throwsException);
```

### Custom Matchers
```dart
expect(value, isA<MyType>());
expect(value, isA<ValidationFailure>());
expect(list, allOf([
  isEmpty,
  isNotNull,
]));
```

### Async Matchers
```dart
expect(
  futureValue,
  completes, // Future completes successfully
);

expect(
  futureValue,
  throwsException, // Future throws exception
);
```

## Test Organization

### Group-Based Organization
```dart
group('Feature', () {
  group('Subfeature', () {
    test('should work', () {
      // Test here
    });
  });
});
```

### Setup and Teardown
```dart
setUpAll(() {
  // Runs once before all tests in this group
});

setUp(() {
  // Runs before each test
});

tearDown(() {
  // Runs after each test
});

tearDownAll(() {
  // Runs once after all tests
});
```

## Performance Tips

1. **Use setUp, not test initialization** - Faster execution
2. **Mock external dependencies** - Avoid network/database calls
3. **Reuse fixtures** - Create common data once
4. **Minimize assertions** - Test one thing per test
5. **Use patterns** - Copy working test templates

## Common Issues

### Mock not called
```dart
// ❌ Wrong - missed named parameter wrapping
when(mockRepo.method(param: 'value')).thenAnswer(...);

// ✅ Correct - use anyNamed for named params
when(mockRepo.method(param: anyNamed('param'))).thenAnswer(...);
```

### Future timeout
```dart
// ✅ Add timeout to test
test('async test', () async {
  // ...
}, timeout: Timeout(Duration(seconds: 10)));
```

### Type mismatch
```dart
// ✅ Use explicit type in fold
result.fold<String>(
  (failure) => failure.message,
  (success) => success.toString(),
);
```

### State leaking
```dart
// Always reset in setUp
setUp(() {
  mock = MockClass();
  useCase = UseCase(mock);
});
```

## Resources

- [Flutter Testing Docs](https://flutter.dev/docs/testing)
- [Mockito Docs](https://pub.dev/packages/mockito)
- [Dartz Docs](https://pub.dev/packages/dartz)
- [Test Best Practices](https://flutter.dev/docs/testing/best-practices)

---

**Last Updated**: March 30, 2026  
**Version**: 1.0.0
