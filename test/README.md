// test/README.md

# PortfolioPh Testing Strategy

This document outlines the comprehensive testing approach for the PortfolioPh application, covering unit tests, integration tests, and best practices.

## Testing Structure

```
test/
├── domain/
│   └── usecases/
│       ├── auth/
│       │   ├── register_usecase_test.dart
│       │   ├── login_usecase_test.dart
│       │   ├── logout_usecase_test.dart
│       │   ├── password_reset_usecase_test.dart
│       │   └── index.dart
│       └── job_posting/
│           ├── create_job_usecase_test.dart
│           ├── get_jobs_usecase_test.dart
│           └── index.dart
├── integration/
│   ├── auth_job_posting_integration_test.dart
│   └── index.dart
├── fixtures/
│   └── mock_fixtures.dart
├── test_helpers.dart
└── README.md
```

## Test Coverage

### Domain Layer Tests

#### Authentication Use Cases
- **RegisterUseCase**: Tests user registration with validation, duplicate email handling, and network errors
- **LoginUseCase**: Tests user login with credential validation and various failure scenarios
- **LogoutUseCase**: Tests session cleanup and logout failures
- **PasswordResetUseCase**: Tests password reset request and confirmation flows

#### Job Posting Use Cases
- **CreateJobUseCase**: Tests job creation with validation and authorization checks
- **GetJobsUseCase**: Tests job retrieval with pagination and filtering

### Integration Tests
- Complete authentication and job posting workflows
- Multi-step user journeys (login → create job → get jobs)
- Role-based authorization across use cases
- Network and error handling coordination

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/domain/usecases/auth/register_usecase_test.dart
```

### Run Tests with Pattern Matching
```bash
flutter test --name="RegisterUseCase"
flutter test --grep="should register user"
```

### Run with Coverage Report
```bash
flutter test --coverage
lcov --list coverage/lcov.info  # View coverage
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

## Test Organization

### Unit Tests (Domain Layer)
- **Focus**: Individual use case behavior
- **Mocking**: All repository dependencies are mocked
- **Assertions**: Specific failure types and successful results
- **Validation**: Input validation and business rule enforcement

### Integration Tests
- **Focus**: Multi-step workflows and coordinate behavior between use cases
- **Coverage**: Real-world user scenarios
- **Scope**: Auth → Job posting interactions

## Mock Fixtures

Common test data is provided via `MockFixtures` class:

```dart
// Create test user
final user = MockFixtures.createTestUser();

// Create test job
final job = MockFixtures.createTestJob();

// Create recruiter
final recruiter = MockFixtures.createTestRecruiter();

// Create with custom values
final customJob = MockFixtures.createTestJob(
  title: 'Custom Title',
  salary: 75000,
);
```

## Test Patterns

### Basic Unit Test
```dart
test('should perform action', () async {
  // Arrange
  when(mockRepository.method()).thenAnswer((_) async => Right(data));

  // Act
  final result = await useCase.call();

  // Assert
  expect(result, Right(data));
  verify(mockRepository.method()).called(1);
});
```

### Failure Handling Test
```dart
test('should return failure', () async {
  // Arrange
  when(mockRepository.method()).thenAnswer((_) async => Left(failure));

  // Act
  final result = await useCase.call();

  // Assert
  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure, isA<MyFailure>()),
    (_) => fail('Should return failure'),
  );
});
```

### Integration Test
```dart
test('multi-step workflow', () async {
  // Step 1: Setup and first action
  final step1Result = await useCase1.call();
  expect(step1Result.isRight(), true);

  // Step 2: Use result from step 1
  final data = step1Result.getOrElse(() => throw Exception());
  final step2Result = await useCase2.call(data);

  // Assert final state
  expect(step2Result.isRight(), true);
});
```

## Key Testing Principles

1. **Isolation**: Each test is independent and can run in any order
2. **Clarity**: Test names clearly describe what is being tested
3. **Completeness**: Both success and failure paths are tested
4. **Speed**: Tests run quickly (< 100ms per test)
5. **Maintainability**: Fixtures and helpers reduce duplication

## Validation Tests

All use cases include validation tests for:
- Empty/invalid inputs
- Boundary conditions
- Business rule violations

Examples:
- Email format validation
- Password strength requirements (8+ chars, numeric, uppercase)
- Salary and experience ranges
- Job filters and pagination

## Failure Scenario Tests

Comprehensive failure tests cover:
- **ValidationFailure**: Input validation errors
- **AuthorizationFailure**: Permission denials
- **NetworkFailure**: Connectivity issues
- **DuplicateEmailFailure**: Email already exists
- **UserNotFoundFailure**: User doesn't exist
- **InvalidCredentialsFailure**: Wrong password
- **InvalidTokenFailure**: Expired/invalid tokens
- **SessionFailure**: Session management errors

## Continuous Integration

Run tests in CI with:
```bash
flutter test --reporter json > test-results.json
```

## Test Metrics

Track:
- **Pass Rate**: Target > 95%
- **Coverage**: Target > 80% for critical paths
- **Execution Time**: Target < 30 seconds for all tests
- **Flakiness**: Zero flaky tests

## Common Issues and Solutions

### Issue: Mock not being called
```dart
// Solution: Use anyNamed() for named parameters
when(mockRepo.method(
  param: anyNamed('param'),
)).thenAnswer((_) async => Right(data));
```

### Issue: Future test timeout
```dart
// Solution: Ensure async operation completes
test('async operation', () async {
  final result = await useCase.call();
  expect(result.isRight(), true);
}, timeout: Timeout(Duration(seconds: 10)));
```

### Issue: Type mismatch in fold
```dart
// Solution: Use explicit type parameters
result.fold<String>(
  (failure) => failure.message,
  (success) => success.toString(),
);
```

## Next Steps

1. Add BLoC/Cubit layer tests after UI architecture is finalized
2. Add widget tests for presentation layer components
3. Add repository implementation tests with real HTTP clients
4. Set up code coverage monitoring in CI/CD

## References

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Dartz Documentation](https://pub.dev/packages/dartz)
