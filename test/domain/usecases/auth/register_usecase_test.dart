// test/domain/usecases/auth/register_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/entities/index.dart';
import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/auth/index.dart';

// Generate mocks: flutter pub run build_runner build
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase registerUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUseCase = RegisterUseCase(mockAuthRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'Test@123456';
  const testName = 'John Doe';
  const testRole = UserRole.jobSeeker;

  final testUser = UserEntity(
    id: 1,
    email: testEmail,
    name: testName,
    role: testRole,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('RegisterUseCase', () {
    test('should register user with valid data', () async {
      // Arrange
      when(
        mockAuthRepository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
        ),
      ).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await registerUseCase.call(
        email: testEmail,
        password: testPassword,
        name: testName,
        role: testRole,
      );

      // Assert
      expect(result, Right(testUser));
      verify(
        mockAuthRepository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
        ),
      ).called(1);
    });

    test('should return ValidationFailure for invalid email', () async {
      // Act
      final result = await registerUseCase.call(
        email: 'invalidemail',
        password: testPassword,
        name: testName,
        role: testRole,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('Invalid email'));
      }, (user) => fail('Should return failure'));
    });

    test('should return ValidationFailure for password < 8 chars', () async {
      // Act
      final result = await registerUseCase.call(
        email: testEmail,
        password: 'short',
        name: testName,
        role: testRole,
      );

      // Assert
      expect(result.isLeft(), true);
    });

    test(
      'should return ValidationFailure if password has no numeric',
      () async {
        // Act
        final result = await registerUseCase.call(
          email: testEmail,
          password: 'noNumbers!@',
          name: testName,
          role: testRole,
        );

        // Assert
        expect(result.isLeft(), true);
      },
    );

    test('should return ValidationFailure for empty name', () async {
      // Act
      final result = await registerUseCase.call(
        email: testEmail,
        password: testPassword,
        name: '',
        role: testRole,
      );

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return DuplicateEmailFailure when email exists', () async {
      // Arrange
      when(
        mockAuthRepository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
        ),
      ).thenAnswer((_) async => Left(DuplicateEmailFailure()));

      // Act
      final result = await registerUseCase.call(
        email: testEmail,
        password: testPassword,
        name: testName,
        role: testRole,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DuplicateEmailFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return NetworkFailure on connectivity issue', () async {
      // Arrange
      when(
        mockAuthRepository.register(
          email: testEmail,
          password: testPassword,
          name: testName,
          role: testRole,
        ),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await registerUseCase.call(
        email: testEmail,
        password: testPassword,
        name: testName,
        role: testRole,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
