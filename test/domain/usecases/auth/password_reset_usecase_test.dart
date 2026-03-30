// test/domain/usecases/auth/password_reset_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/auth/index.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late PasswordResetUseCase passwordResetUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    passwordResetUseCase = PasswordResetUseCase(mockAuthRepository);
  });

  const testEmail = 'test@example.com';
  const testToken = 'reset_token_123';
  const testNewPassword = 'NewTest@123456';

  group('PasswordResetUseCase - Request Reset', () {
    test('should request password reset successfully', () async {
      // Arrange
      when(
        mockAuthRepository.requestPasswordReset(email: testEmail),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await passwordResetUseCase.call(email: testEmail);

      // Assert
      expect(result, const Right(null));
      verify(
        mockAuthRepository.requestPasswordReset(email: testEmail),
      ).called(1);
    });

    test('should return ValidationFailure for invalid email', () async {
      // Act
      final result = await passwordResetUseCase.call(email: 'invalidemail');

      // Assert
      expect(result.isLeft(), true);
    });

    test(
      'should return UserNotFoundFailure when user does not exist',
      () async {
        // Arrange
        when(
          mockAuthRepository.requestPasswordReset(email: testEmail),
        ).thenAnswer((_) async => Left(UserNotFoundFailure()));

        // Act
        final result = await passwordResetUseCase.call(email: testEmail);

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
        mockAuthRepository.requestPasswordReset(email: testEmail),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await passwordResetUseCase.call(email: testEmail);

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('PasswordResetUseCase - Confirm Reset', () {
    test('should confirm password reset successfully', () async {
      // Arrange
      when(
        mockAuthRepository.confirmPasswordReset(
          token: testToken,
          newPassword: testNewPassword,
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await passwordResetUseCase.confirmReset(
        token: testToken,
        newPassword: testNewPassword,
      );

      // Assert
      expect(result, const Right(null));
      verify(
        mockAuthRepository.confirmPasswordReset(
          token: testToken,
          newPassword: testNewPassword,
        ),
      ).called(1);
    });

    test('should return ValidationFailure for weak password', () async {
      // Act
      final result = await passwordResetUseCase.confirmReset(
        token: testToken,
        newPassword: 'weak',
      );

      // Assert
      expect(result.isLeft(), true);
    });

    test(
      'should return InvalidTokenFailure for expired/invalid token',
      () async {
        // Arrange
        when(
          mockAuthRepository.confirmPasswordReset(
            token: 'invalid_token',
            newPassword: testNewPassword,
          ),
        ).thenAnswer((_) async => Left(InvalidTokenFailure()));

        // Act
        final result = await passwordResetUseCase.confirmReset(
          token: 'invalid_token',
          newPassword: testNewPassword,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<InvalidTokenFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );
  });
}
