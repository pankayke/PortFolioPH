// test/domain/usecases/job_posting/get_jobs_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/entities/index.dart';
import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/job/index.dart';

class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late GetJobsUseCase getJobsUseCase;
  late MockJobRepository mockJobRepository;

  setUp(() {
    mockJobRepository = MockJobRepository();
    getJobsUseCase = GetJobsUseCase(mockJobRepository);
  });

  final testJobs = [
    JobPostEntity(
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
    ),
    JobPostEntity(
      id: 2,
      title: 'Senior Developer',
      description: 'Senior developer with 5+ years experience',
      location: 'San Francisco',
      salary: 120000,
      salaryDuration: SalaryDuration.annual,
      employmentType: EmploymentType.fullTime,
      experience: 5,
      skills: const ['Flutter', 'React', 'Node.js'],
      recruiterId: 2,
      status: JobStatus.open,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  group('GetJobsUseCase', () {
    test('should get all open jobs', () async {
      // Arrange
      when(
        mockJobRepository.getJobs(
          page: 1,
          limit: 10,
          filters: anyNamed('filters'),
        ),
      ).thenAnswer((_) async => Right((testJobs, 2)));

      // Act
      final result = await getJobsUseCase.call(page: 1, limit: 10);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should return jobs'), (data) {
        expect(data.$1.length, 2);
        expect(data.$2, 2);
      });
    });

    test('should get jobs with filters', () async {
      // Arrange
      final filters = JobFilters(
        location: 'Remote',
        employmentType: EmploymentType.fullTime,
      );

      when(
        mockJobRepository.getJobs(page: 1, limit: 10, filters: filters),
      ).thenAnswer((_) async => Right(([testJobs[0]], 1]));

      // Act
      final result = await getJobsUseCase.call(
        page: 1,
        limit: 10,
        filters: filters,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return jobs'),
        (data) => expect(data.$1.length, 1),
      );
    });

    test('should return empty list when no jobs found', () async {
      // Arrange
      when(
        mockJobRepository.getJobs(
          page: 1,
          limit: 10,
          filters: anyNamed('filters'),
        ),
      ).thenAnswer((_) async => Right(([], 0)));

      // Act
      final result = await getJobsUseCase.call(page: 1, limit: 10);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return empty list'),
        (data) => expect(data.$1.isEmpty, true),
      );
    });

    test('should return ValidationFailure for invalid page number', () async {
      // Act
      final result = await getJobsUseCase.call(page: 0, limit: 10);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return ValidationFailure for invalid limit', () async {
      // Act
      final result = await getJobsUseCase.call(page: 1, limit: 0);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should return NetworkFailure on connectivity issue', () async {
      // Arrange
      when(
        mockJobRepository.getJobs(
          page: 1,
          limit: 10,
          filters: anyNamed('filters'),
        ),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await getJobsUseCase.call(page: 1, limit: 10);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}
