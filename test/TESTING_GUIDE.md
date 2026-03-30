// test/TESTING_GUIDE.md

# PortfolioPh Comprehensive Testing Guide

## Overview

This document provides a complete testing strategy covering domain entities, use cases, and integration scenarios for the PortfolioPh job platform.

## Test Structure

```
test/
├── domain/
│   ├── entities/
│   │   ├── job_entity_test.dart
│   │   ├── application_entity_test.dart
│   │   └── index.dart
│   ├── usecases/
│   │   ├── auth/
│   │   │   ├── register_usecase_test.dart
│   │   │   ├── login_usecase_test.dart
│   │   │   ├── logout_usecase_test.dart
│   │   │   ├── password_reset_usecase_test.dart
│   │   │   └── index.dart
│   │   ├── job/
│   │   │   ├── create_job_usecase_test.dart
│   │   │   ├── get_jobs_usecase_test.dart
│   │   │   └── index.dart
│   │   ├── application/
│   │   │   ├── apply_to_job_usecase_test.dart
│   │   │   ├── update_application_status_usecase_test.dart
│   │   │   └── index.dart
│   │   └── index.dart
│   └── validators/
│       ├── email_validator_test.dart
│       └── index.dart
├── integration/
│   ├── auth_job_posting_integration_test.dart
│   └── index.dart
├── fixtures/
│   └── mock_fixtures.dart
├── test_helpers.dart
├── README.md
└── TESTING_GUIDE.md (this file)
```

## Entity Tests

### JobEntity Tests
Tests the business domain rules and properties:
- ✅ Entity creation with required fields
- ✅ Equality comparisons
- ✅ Job status determination (`isOpen`, `acceptingApplications`)
- ✅ Salary range formatting
- ✅ Job type and status parsing
- ✅ Deadline handling
- ✅ Skills management
- ✅ Recruiter information

**Key Assertions:**
- Job is open: `status == open AND (no deadline OR deadline > now)`
- Salary range formatting: `$min - $max` or 'Negotiable'

### ApplicationEntity Tests
Tests application state management:
- ✅ Entity creation with required fields
- ✅ Status transitions (pending → reviewed → accepted/rejected)
- ✅ Cover letter handling (optional)
- ✅ Timestamps tracking
- ✅ Job and job seeker linking

**Key Assertions:**
- Valid status flow: pending → reviewed → (accepted | rejected)
- Cover letter can be null or long strings

## Use Case Tests

### Authentication Use Cases

#### RegisterUseCase
- ✅ Successful registration with valid data
- ✅ Validation failures: invalid email, weak password, empty name
- ✅ Duplicate email detection
- ✅ Network failure handling

#### LoginUseCase
- ✅ Successful login with valid credentials
- ✅ Invalid credentials handling
- ✅ User not found scenarios
- ✅ Network error handling

#### LogoutUseCase
- ✅ Successful logout
- ✅ Session error handling
- ✅ Network failure handling

#### PasswordResetUseCase
- ✅ Request password reset
- ✅ Confirm password reset with new password
- ✅ Validation for weak passwords
- ✅ Invalid/expired token handling
- ✅ User not found scenarios

### Job Use Cases

#### CreateJobUseCase
- ✅ Successful job creation with all fields
- ✅ Validation: title (empty, too short)
- ✅ Validation: description (empty)
- ✅ Validation: location (empty)
- ✅ Validation: salary range (invalid, negative, min > max)
- ✅ Validation: deadline (past date)
- ✅ Partial salary data (min only)
- ✅ Network failure handling

#### GetJobsUseCase
- ✅ Get all jobs with pagination
- ✅ Empty results handling
- ✅ Validation: page number (0, negative)
- ✅ Validation: limit (0, exceeds maximum)
- ✅ Pagination correctness
- ✅ Large page number handling
- ✅ Network failure handling

### Application Use Cases

#### ApplyToJobUseCase
- ✅ Successful application without cover letter
- ✅ Successful application with cover letter
- ✅ Validation: invalid job ID (zero, negative)
- ✅ Validation: empty cover letter if provided
- ✅ Duplicate application detection
- ✅ Unauthenticated user handling
- ✅ Long cover letter handling
- ✅ Special characters in cover letter
- ✅ Network failure handling

#### UpdateApplicationStatusUseCase
- ✅ Update to rejected status
- ✅ Update to accepted status
- ✅ Update to reviewed status
- ✅ Validation: invalid application ID
- ✅ Not found handling
- ✅ Unauthorized user handling
- ✅ Multiple status updates
- ✅ Network failure handling

## Validator Tests

### EmailValidator
- ✅ Valid email formats
- ✅ Invalid email formats
- ✅ Edge cases (subdomains, special chars)

## Integration Tests

### Auth → Job Posting Workflow
- **Scenario 1: Recruiter Workflow**
  1. Login as recruiter
  2. Verify recruiter role
  3. Create job posting
  4. Verify job is created
  5. Get all jobs
  6. Verify job appears in list

- **Scenario 2: Job Seeker Workflow**
  1. Login as job seeker
  2. Verify job seeker role
  3. Get available jobs
  4. Verify job list is not empty

- **Scenario 3: Authorization Failures**
  - Job seeker cannot create jobs
  - System returns authorization failure

- **Scenario 4: Network Resilience**
  - Network failures handled gracefully
  - Consistent error messages

## Mock Fixtures

Common test data provided via `MockFixtures`:

```dart
// Users
final user = MockFixtures.createTestUser();
final recruiter = MockFixtures.createTestRecruiter();
final admin = MockFixtures.createTestAdmin();

// Jobs
final job = MockFixtures.createTestJob();
final jobs = MockFixtures.createTestJobs(count: 5);

// Applications
final app = MockFixtures.createTestApplication();
final apps = MockFixtures.createTestApplications(count: 3);

// Notifications
final notification = MockFixtures.createTestNotification();

// Validators
const validEmail = MockFixtures.validEmail;
const weakPassword = MockFixtures.weakPassword;
```

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/domain/usecases/auth/register_usecase_test.dart
```

### Tests Matching Pattern
```bash
flutter test --name="RegisterUseCase"
flutter test --grep="should validate"
```

### With Coverage
```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

### Watch Mode
```bash
flutter test --watch
```

### Performance Analysis
```bash
flutter test --reporter expanded
```

## Test Patterns & Best Practices

### AAA Pattern (Arrange-Act-Assert)
```dart
test('should do something', () async {
  // Arrange: Setup test data and mocks
  when(mockRepo.method()).thenAnswer((_) async => Right(data));

  // Act: Execute the code being tested
  final result = await useCase.call();

  // Assert: Verify the results
  expect(result.isRight(), true);
  verify(mockRepo.method()).called(1);
});
```

### Failure Testing
```dart
test('should return failure', () async {
  when(mockRepo.method()).thenAnswer((_) async => Left(failure));

  final result = await useCase.call();

  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure, isA<MyFailure>()),
    (_) => fail('Should return failure'),
  );
});
```

### Entity Equality
```dart
test('entities should be equal', () {
  final entity1 = SomeEntity(...);
  final entity2 = SomeEntity(...);
  expect(entity1, entity2);
});
```

### Mocking Named Parameters
```dart
when(mockRepo.method(
  param1: anyNamed('param1'),
  param2: anyNamed('param2'),
)).thenAnswer((_) async => Right(data));
```

## Validation Rules Tested

### Email
- Format must be valid (e.g., test@example.com)
- Cannot be empty
- Rejects invalid formats

### Password
- Minimum 8 characters
- Must contain uppercase letter
- Must contain number
- Must contain special character or lowercase

### Job Creation
- Title: Required, minimum 3 characters
- Description: Required, minimum 10 characters
- Location: Required, non-empty
- Salary: Must be positive, min ≤ max
- Deadline: Must be in future (if provided)

### Job Retrieval
- Page: Must be ≥ 1
- Limit: Must be > 0 and ≤ 100

### Application
- Job ID: Must be positive
- Cover Letter: Cannot be empty if provided

### Application Status Update
- Application ID: Must be positive
- Valid status transitions

## Error Scenarios Covered

### Validation Errors
- Invalid input formats
- Missing required fields
- Out-of-range values
- Business rule violations

### Authentication Errors
- Invalid credentials
- Duplicate emails
- Expired tokens
- Unauthorized access

### Not Found Errors
- User not found
- Job not found
- Application not found

### Network Errors
- Connection failures
- Timeout scenarios
- Server errors

### Authorization Errors
- Insufficient permissions
- Role-based restrictions

## Metrics & Standards

### Coverage Targets
- Critical paths: 100%
- Use cases: 95%+
- Entities: 95%+
- Validators: 100%
- Overall: 80%+

### Performance Targets
- Test execution: < 2 seconds per test
- Total suite: < 30 seconds
- No flaky tests (100% deterministic)

### Code Quality
- Meaningful test names
- Clear arrange-act-assert structure
- DRY principle (use fixtures)
- Isolated tests (no interdependencies)

## Common Issues & Solutions

### Issue: Mock not called
```dart
// Solution: Use anyNamed for named parameters
verify(mockRepo.method(param: anyNamed('param'))).called(1);
```

### Issue: Type mismatch in exceptions
```dart
// Solution: Explicit type parameters
result.fold<String>(
  (failure) => failure.message,
  (success) => 'Success',
);
```

### Issue: Future timeout
```dart
// Solution: Set explicit timeout
test('async test', () async {
  // ...
}, timeout: Timeout(Duration(seconds: 10)));
```

### Issue: State leaking between tests
```dart
// Solution: Always use setUp for clean state
setUp(() {
  mockRepository = MockRepository();
  useCase = UseCase(mockRepository);
});
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run tests
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

## Future Enhancements

- [ ] Add BLoC/Cubit layer tests
- [ ] Add widget tests for UI components
- [ ] Add E2E tests with real backend
- [ ] Add performance benchmarks
- [ ] Add mutation testing
- [ ] Add golden file tests for widgets
- [ ] Add accessibility tests
- [ ] Add security/injection tests

## References

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Dartz Documentation](https://pub.dev/packages/dartz)
- [Test Best Practices](https://flutter.dev/docs/testing/best-practices)
