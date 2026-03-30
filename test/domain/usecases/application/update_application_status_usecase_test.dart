// test/domain/usecases/application/update_application_status_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/entities/index.dart';
import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/application/index.dart';

class MockApplicationRepository extends Mock implements ApplicationRepository {}

void main() {
  late UpdateApplicationStatusUseCase updateApplicationStatusUseCase;
  late MockApplicationRepository mockApplicationRepository;

  setUp(() {
    mockApplicationRepository = MockApplicationRepository();
    updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(
      mockApplicationRepository,
    );
  });

  final now = DateTime.now();

  final testApplication = ApplicationEntity(
    id: 1,
    jobId: 1,
    jobSeekerId: 1,
    status: ApplicationStatus.rejected,
    coverLetter: 'I am interested in this role',
    createdAt: now,
    updatedAt: now,
  );

  group('UpdateApplicationStatusUseCase', () {
    test('should update application status to rejected', () async {
      // Arrange
      when(
        mockApplicationRepository.updateStatus(
          applicationId: 1,
          status: ApplicationStatus.rejected,
        ),
      ).thenAnswer((_) async => Right(testApplication));

      // Act
      final result = await updateApplicationStatusUseCase.call(
        applicationId: 1,
        status: ApplicationStatus.rejected,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should return application'), (
        application,
      ) {
        expect(application.status, ApplicationStatus.rejected);
      });
      verify(
        mockApplicationRepository.updateStatus(
          applicationId: 1,
          status: ApplicationStatus.rejected,
        ),
      ).called(1);
    });

    test('should update application status to accepted', () async {
      // Arrange
      final acceptedApplication = testApplication.copyWith(
        status: ApplicationStatus.accepted,
      );
      when(
        mockApplicationRepository.updateStatus(
          applicationId: 1,
          status: ApplicationStatus.accepted,
        ),
      ).thenAnswer((_) async => Right(acceptedApplication));

      // Act
      final result = await updateApplicationStatusUseCase.call(
        applicationId: 1,
        status: ApplicationStatus.accepted,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should return application'), (
        application,
      ) {
        expect(application.status, ApplicationStatus.accepted);
      });
    });

    test('should update application status to reviewed', () async {
      // Arrange
      final reviewedApplication = testApplication.copyWith(
        status: ApplicationStatus.reviewed,
      );
      when(
        mockApplicationRepository.updateStatus(
          applicationId: 1,
          status: ApplicationStatus.reviewed,
        ),
      ).thenAnswer((_) async => Right(reviewedApplication));

      // Act
      final result = await updateApplicationStatusUseCase.call(
        applicationId: 1,
        status: ApplicationStatus.reviewed,
      );

      // Assert
      expect(result.isRight(), true);
    });

    test(
      'should return ValidationFailure for invalid application ID',
      () async {
        // Act
        final result = await updateApplicationStatusUseCase.call(
          applicationId: 0,
          status: ApplicationStatus.rejected,
        );

        // Assert
        expect(result.isLeft(), true);
      },
    );

    test(
      'should return ValidationFailure for negative application ID',
      () async {
        // Act
        final result = await updateApplicationStatusUseCase.call(
          applicationId: -1,
          status: ApplicationStatus.rejected,
        );

        // Assert
        expect(result.isLeft(), true);
      },
    );

    test(
      'should return NotFoundFailure when application does not exist',
      () async {
        // Arrange
        when(
          mockApplicationRepository.updateStatus(
            applicationId: 9999,
            status: ApplicationStatus.rejected,
          ),
        ).thenAnswer((_) async => Left(NotFoundFailure()));

        // Act
        final result = await updateApplicationStatusUseCase.call(
          applicationId: 9999,
          status: ApplicationStatus.rejected,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<NotFoundFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    test(
      'should return UnAuthorizedFailure when user cannot update status',
      () async {
        // Arrange
        when(
          mockApplicationRepository.updateStatus(
            applicationId: 1,
            status: ApplicationStatus.rejected,
          ),
        ).thenAnswer((_) async => Left(UnAuthenticatedFailure()));

        // Act
        final result = await updateApplicationStatusUseCase.call(
          applicationId: 1,
          status: ApplicationStatus.rejected,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<UnAuthenticatedFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    test('should return NetworkFailure on connectivity issue', () async {
      // Arrange
      when(
        mockApplicationRepository.updateStatus(
          applicationId: 1,
          status: ApplicationStatus.rejected,
        ),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await updateApplicationStatusUseCase.call(
        applicationId: 1,
        status: ApplicationStatus.rejected,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should handle status update for multiple applications', () async {
      // Arrange
      when(
        mockApplicationRepository.updateStatus(
          applicationId: 1,
          status: ApplicationStatus.accepted,
        ),
      ).thenAnswer(
        (_) async =>
            Right(testApplication.copyWith(status: ApplicationStatus.accepted)),
      );

      when(
        mockApplicationRepository.updateStatus(
          applicationId: 2,
          status: ApplicationStatus.rejected,
        ),
      ).thenAnswer(
        (_) async => Right(
          testApplication.copyWith(id: 2, status: ApplicationStatus.rejected),
        ),
      );

      // Act
      final result1 = await updateApplicationStatusUseCase.call(
        applicationId: 1,
        status: ApplicationStatus.accepted,
      );
      final result2 = await updateApplicationStatusUseCase.call(
        applicationId: 2,
        status: ApplicationStatus.rejected,
      );

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
      verify(
        mockApplicationRepository.updateStatus(
          applicationId: 1,
          status: ApplicationStatus.accepted,
        ),
      ).called(1);
      verify(
        mockApplicationRepository.updateStatus(
          applicationId: 2,
          status: ApplicationStatus.rejected,
        ),
      ).called(1);
    });
  });
}

extension _ApplicationEntityCopyWith on ApplicationEntity {
  ApplicationEntity copyWith({
    int? id,
    int? jobId,
    int? jobSeekerId,
    ApplicationStatus? status,
    String? coverLetter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ApplicationEntity(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    jobSeekerId: jobSeekerId ?? this.jobSeekerId,
    status: status ?? this.status,
    coverLetter: coverLetter ?? this.coverLetter,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
