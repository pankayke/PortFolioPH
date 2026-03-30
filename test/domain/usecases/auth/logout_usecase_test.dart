// test/domain/usecases/auth/logout_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/auth/index.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase logoutUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUseCase = LogoutUseCase(mockAuthRepository);
  });

  group('LogoutUseCase', () {
    test('should logout user successfully', () async {
      // Arrange
      when(
        mockAuthRepository.logout(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await logoutUseCase.call();

      // Assert
      expect(result, const Right(null));
      verify(mockAuthRepository.logout()).called(1);
    });

    test('should return SessionFailure on logout error', () async {
      // Arrange
      when(mockAuthRepository.logout()).thenAnswer(
        (_) async => Left(SessionFailure(message: 'Failed to logout')),
      );

      // Act
      final result = await logoutUseCase.call();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<SessionFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return NetworkFailure on connectivity issue', () async {
      // Arrange
      when(
        mockAuthRepository.logout(),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await logoutUseCase.call();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
