// test/index.dart

/// PortfolioPh Comprehensive Test Suite
///
/// Complete testing infrastructure for domain layer covering:
/// - Authentication use cases (register, login, logout, password reset)
/// - Job management use cases (create, retrieve with pagination)
/// - Application use cases (apply, update status)
/// - Domain entities (jobs, applications, users)
/// - Input validators (email format validation)
/// - Integration workflows
///
/// Total: 102+ tests with >90% critical path coverage
///
/// Documentation:
/// - README.md - Original testing guide
/// - TESTING_GUIDE.md - Comprehensive reference
/// - TEST_COVERAGE_SUMMARY.md - Coverage statistics
/// - QUICK_TEST_REFERENCE.md - Dev quick reference
///
/// Run with: flutter test
/// With coverage: flutter test --coverage
///

export 'domain/index.dart';
export 'integration/index.dart';
export 'fixtures/mock_fixtures.dart';
export 'test_helpers.dart';
