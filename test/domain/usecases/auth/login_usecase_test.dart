// test/domain/usecases/auth/login_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/entities/index.dart';
import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/auth/index.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });

  const testEmail = 'test@example.com';
  const testPassword = 'Test@123456';

  final testUser = UserEntity(
    id: 1,
    email: testEmail,
    name: 'John Doe',
    role: UserRole.jobSeeker,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('LoginUseCase', () {
    test('should login user with valid credentials', () async {
      // Arrange
      when(
        mockAuthRepository.login(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await loginUseCase.call(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, Right(testUser));
      verify(
        mockAuthRepository.login(email: testEmail, password: testPassword),
      ).called(1);
    });

    test('should return ValidationFailure for invalid email', () async {
      // Act
      final result = await loginUseCase.call(
        email: 'invalidemail',
        password: testPassword,
      );

      // Assert
      expect(result.isLeft(), true);
    });

    test(
      'should return InvalidCredentialsFailure for wrong password',
      () async {
        // Arrange
        when(
          mockAuthRepository.login(email: testEmail, password: 'wrongpassword'),
        ).thenAnswer((_) async => Left(InvalidCredentialsFailure()));

        // Act
        final result = await loginUseCase.call(
          email: testEmail,
          password: 'wrongpassword',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<InvalidCredentialsFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    test(
      'should return UserNotFoundFailure when user does not exist',
      () async {
        // Arrange
        when(
          mockAuthRepository.login(
            email: 'nonexistent@example.com',
            password: testPassword,
          ),
        ).thenAnswer((_) async => Left(UserNotFoundFailure()));

        // Act
        final result = await loginUseCase.call(
          email: 'nonexistent@example.com',
          password: testPassword,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<UserNotFoundFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    test('should return NetworkFailure on connectivity issue', () async {
      // Arrange
      when(
        mockAuthRepository.login(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await loginUseCase.call(
        email: testEmail,
        password: testPassword,
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
