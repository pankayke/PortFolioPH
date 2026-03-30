// test/domain/usecases/job_posting/create_job_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/entities/index.dart';
import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/job/index.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late CreateJobUseCase createJobUseCase;
  late MockJobRepository mockJobRepository;

  setUp(() {
    mockJobRepository = MockJobRepository();
    createJobUseCase = CreateJobUseCase(mockJobRepository);
  });

  final testJob = JobPostEntity(
    id: 1,
    title: 'Flutter Developer',
    description: 'Experienced Flutter developer needed',
    location: 'Remote',
    salary: 50000,
    salaryDuration: SalaryDuration.annual,
    employmentType: EmploymentType.fullTime,
    experience: 2,
    skills: const ['Flutter', 'Dart'],
    recruiterId: 1,
    status: JobStatus.open,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CreateJobUseCase', () {
    test('should create job posting successfully', () async {
      // Arrange
      when(
        mockJobRepository.createJob(any),
      ).thenAnswer((_) async => Right(testJob));

      // Act
      final result = await createJobUseCase.call(
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salary: testJob.salary,
        salaryDuration: testJob.salaryDuration,
        employmentType: testJob.employmentType,
        experience: testJob.experience,
        skills: testJob.skills,
      );

      // Assert
      expect(result, Right(testJob));
      verify(mockJobRepository.createJob(any)).called(1);
    });

    test('should return ValidationFailure for empty title', () async {
      // Act
      final result = await createJobUseCase.call(
        title: '',
        description: testJob.description,
        location: testJob.location,
        salary: testJob.salary,
        salaryDuration: testJob.salaryDuration,
        employmentType: testJob.employmentType,
        experience: testJob.experience,
        skills: testJob.skills,
      );

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return ValidationFailure for invalid salary', () async {
      // Act
      final result = await createJobUseCase.call(
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salary: -1000,
        salaryDuration: testJob.salaryDuration,
        employmentType: testJob.employmentType,
        experience: testJob.experience,
        skills: testJob.skills,
      );

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return ValidationFailure for negative experience', () async {
      // Act
      final result = await createJobUseCase.call(
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salary: testJob.salary,
        salaryDuration: testJob.salaryDuration,
        employmentType: testJob.employmentType,
        experience: -1,
        skills: testJob.skills,
      );

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return AuthorizationFailure for non-recruiter user', () async {
      // Arrange
      when(
        mockJobRepository.createJob(any),
      ).thenAnswer((_) async => Left(AuthorizationFailure()));

      // Act
      final result = await createJobUseCase.call(
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salary: testJob.salary,
        salaryDuration: testJob.salaryDuration,
        employmentType: testJob.employmentType,
        experience: testJob.experience,
        skills: testJob.skills,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthorizationFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return NetworkFailure on connectivity issue', () async {
      // Arrange
      when(
        mockJobRepository.createJob(any),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await createJobUseCase.call(
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salary: testJob.salary,
        salaryDuration: testJob.salaryDuration,
        employmentType: testJob.employmentType,
        experience: testJob.experience,
        skills: testJob.skills,
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
