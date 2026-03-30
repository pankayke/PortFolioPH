// test/domain/usecases/application/apply_to_job_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/entities/index.dart';
import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/application/index.dart';

class MockApplicationRepository extends Mock implements ApplicationRepository {}

void main() {
  late ApplyToJobUseCase applyToJobUseCase;
  late MockApplicationRepository mockApplicationRepository;

  setUp(() {
    mockApplicationRepository = MockApplicationRepository();
    applyToJobUseCase = ApplyToJobUseCase(mockApplicationRepository);
  });

  final now = DateTime.now();

  final testApplication = ApplicationEntity(
    id: 1,
    jobId: 1,
    jobSeekerId: 1,
    status: ApplicationStatus.pending,
    coverLetter: 'I am interested in this role',
    createdAt: now,
    updatedAt: now,
  );

  group('ApplyToJobUseCase', () {
    test('should apply to job successfully without cover letter', () async {
      // Arrange
      when(
        mockApplicationRepository.applyToJob(jobId: 1, coverLetter: null),
      ).thenAnswer((_) async => Right(testApplication));

      // Act
      final result = await applyToJobUseCase.call(jobId: 1);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should return application'), (
        application,
      ) {
        expect(application.jobId, 1);
        expect(application.status, ApplicationStatus.pending);
      });
      verify(
        mockApplicationRepository.applyToJob(jobId: 1, coverLetter: null),
      ).called(1);
    });

    test('should apply to job successfully with cover letter', () async {
      // Arrange
      const coverLetter = 'I have 5+ years of experience';
      when(
        mockApplicationRepository.applyToJob(
          jobId: 1,
          coverLetter: coverLetter,
        ),
      ).thenAnswer((_) async => Right(testApplication));

      // Act
      final result = await applyToJobUseCase.call(
        jobId: 1,
        coverLetter: coverLetter,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        mockApplicationRepository.applyToJob(
          jobId: 1,
          coverLetter: coverLetter,
        ),
      ).called(1);
    });

    test('should return ValidationFailure for invalid job ID (zero)', () async {
      // Act
      final result = await applyToJobUseCase.call(jobId: 0);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ValidationFailure for negative job ID', () async {
      // Act
      final result = await applyToJobUseCase.call(jobId: -1);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return ValidationFailure for empty cover letter', () async {
      // Act
      final result = await applyToJobUseCase.call(jobId: 1, coverLetter: '');

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        final validationFailure = failure as ValidationFailure;
        expect(validationFailure.fieldErrors?['cover_letter'], isNotNull);
      }, (_) => fail('Should return failure'));
    });

    test('should handle duplicate application attempt', () async {
      // Arrange
      when(
        mockApplicationRepository.applyToJob(jobId: 1, coverLetter: null),
      ).thenAnswer(
        (_) async => Left(
          ValidationFailure(
            message: 'Already applied to this job',
            fieldErrors: {
              'job_id': ['already applied'],
            },
          ),
        ),
      );

      // Act
      final result = await applyToJobUseCase.call(jobId: 1);

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('Already applied'));
      }, (_) => fail('Should return failure'));
    });

    test('should return UnAuthorizedFailure when not logged in', () async {
      // Arrange
      when(
        mockApplicationRepository.applyToJob(jobId: 1, coverLetter: null),
      ).thenAnswer((_) async => Left(UnAuthenticatedFailure()));

      // Act
      final result = await applyToJobUseCase.call(jobId: 1);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnAuthenticatedFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return NetworkFailure on connectivity issue', () async {
      // Arrange
      when(
        mockApplicationRepository.applyToJob(jobId: 1, coverLetter: null),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await applyToJobUseCase.call(jobId: 1);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should handle very long cover letter gracefully', () async {
      // Arrange
      final longCoverLetter = 'A' * 5000;
      when(
        mockApplicationRepository.applyToJob(
          jobId: 1,
          coverLetter: longCoverLetter,
        ),
      ).thenAnswer((_) async => Right(testApplication));

      // Act
      final result = await applyToJobUseCase.call(
        jobId: 1,
        coverLetter: longCoverLetter,
      );

      // Assert
      expect(result.isRight(), true);
    });

    test('should handle special characters in cover letter', () async {
      // Arrange
      final specialCoverLetter = 'I am 100% interested! @mention #hashtag';
      when(
        mockApplicationRepository.applyToJob(
          jobId: 1,
          coverLetter: specialCoverLetter,
        ),
      ).thenAnswer((_) async => Right(testApplication));

      // Act
      final result = await applyToJobUseCase.call(
        jobId: 1,
        coverLetter: specialCoverLetter,
      );

      // Assert
      expect(result.isRight(), true);
    });
  });
}
