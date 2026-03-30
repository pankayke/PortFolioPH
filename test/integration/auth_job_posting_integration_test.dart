// test/integration/auth_job_posting_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:portfolioph/domain/entities/index.dart';
import 'package:portfolioph/domain/failures/failures.dart';
import 'package:portfolioph/domain/repositories/index.dart';
import 'package:portfolioph/domain/usecases/auth/index.dart';
import 'package:portfolioph/domain/usecases/job_posting/index.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockJobPostingRepository extends Mock implements JobPostingRepository {}

void main() {
  group('Authentication and Job Posting Integration Tests', () {
    late LoginUseCase loginUseCase;
    late CreateJobUseCase createJobUseCase;
    late GetJobsUseCase getJobsUseCase;
    late MockAuthRepository mockAuthRepository;
    late MockJobPostingRepository mockJobPostingRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockJobPostingRepository = MockJobPostingRepository();

      loginUseCase = LoginUseCase(mockAuthRepository);
      createJobUseCase = CreateJobUseCase(mockJobPostingRepository);
      getJobsUseCase = GetJobsUseCase(mockJobPostingRepository);
    });

    test(
      'Complete recruitment workflow: Login -> Create Job -> Get Jobs',
      () async {
        // Setup test data
        const testEmail = 'recruiter@example.com';
        const testPassword = 'Test@123456';

        final recruiter = UserEntity(
          id: 1,
          email: testEmail,
          name: 'John Recruiter',
          role: UserRole.recruiter,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final jobPost = JobPostEntity(
          id: 1,
          title: 'Flutter Developer',
          description: 'Experienced Flutter developer needed',
          location: 'Remote',
          salary: 50000,
          salaryDuration: SalaryDuration.annual,
          employmentType: EmploymentType.fullTime,
          experience: 2,
          skills: const ['Flutter', 'Dart'],
          recruiterId: recruiter.id,
          status: JobStatus.open,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Step 1: Login as recruiter
        when(
          mockAuthRepository.login(email: testEmail, password: testPassword),
        ).thenAnswer((_) async => Right(recruiter));

        final loginResult = await loginUseCase.call(
          email: testEmail,
          password: testPassword,
        );

        expect(loginResult.isRight(), true);
        expect(
          loginResult.getOrElse(() => throw Exception()).role,
          UserRole.recruiter,
        );

        // Step 2: Create job posting
        when(
          mockJobPostingRepository.createJob(any),
        ).thenAnswer((_) async => Right(jobPost));

        final createResult = await createJobUseCase.call(
          title: jobPost.title,
          description: jobPost.description,
          location: jobPost.location,
          salary: jobPost.salary,
          salaryDuration: jobPost.salaryDuration,
          employmentType: jobPost.employmentType,
          experience: jobPost.experience,
          skills: jobPost.skills,
        );

        expect(createResult.isRight(), true);
        expect(
          createResult.getOrElse(() => throw Exception()).title,
          'Flutter Developer',
        );

        // Step 3: Get all job postings
        when(
          mockJobPostingRepository.getJobs(
            page: anyNamed('page'),
            limit: anyNamed('limit'),
            filters: anyNamed('filters'),
          ),
        ).thenAnswer((_) async => Right(([jobPost], 1)));

        final getResult = await getJobsUseCase.call(page: 1, limit: 10);

        expect(getResult.isRight(), true);
        final (jobs, total) = getResult.getOrElse(() => throw Exception());
        expect(jobs.length, 1);
        expect(total, 1);
        expect(jobs[0].title, 'Flutter Developer');
      },
    );

    test('Job seeker workflow: Login -> Get Jobs', () async {
      // Setup test data
      const testEmail = 'seeker@example.com';
      const testPassword = 'Seeker@123456';

      final jobSeeker = UserEntity(
        id: 2,
        email: testEmail,
        name: 'Jane Seeker',
        role: UserRole.jobSeeker,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final jobs = [
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
      ];

      // Step 1: Login as job seeker
      when(
        mockAuthRepository.login(email: testEmail, password: testPassword),
      ).thenAnswer((_) async => Right(jobSeeker));

      final loginResult = await loginUseCase.call(
        email: testEmail,
        password: testPassword,
      );

      expect(loginResult.isRight(), true);
      expect(
        loginResult.getOrElse(() => throw Exception()).role,
        UserRole.jobSeeker,
      );

      // Step 2: Get available jobs
      when(
        mockJobPostingRepository.getJobs(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          filters: anyNamed('filters'),
        ),
      ).thenAnswer((_) async => Right((jobs, 1)));

      final getResult = await getJobsUseCase.call(page: 1, limit: 10);

      expect(getResult.isRight(), true);
      final (retrievedJobs, _) = getResult.getOrElse(() => throw Exception());
      expect(retrievedJobs.isNotEmpty, true);
      expect(retrievedJobs[0].title, 'Flutter Developer');
    });

    test('Authorization failure: Job seeker cannot create jobs', () async {
      // Setup
      when(
        mockJobPostingRepository.createJob(any),
      ).thenAnswer((_) async => Left(AuthorizationFailure()));

      // Attempt to create job
      final result = await createJobUseCase.call(
        title: 'Any Job',
        description: 'Any description',
        location: 'Remote',
        salary: 50000,
        salaryDuration: SalaryDuration.annual,
        employmentType: EmploymentType.fullTime,
        experience: 2,
        skills: const ['Skill1'],
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<AuthorizationFailure>()),
        (_) => fail('Should return authorization failure'),
      );
    });

    test('Network failure handling across use cases', () async {
      // Both repositories return network failure
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      when(
        mockJobPostingRepository.getJobs(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
          filters: anyNamed('filters'),
        ),
      ).thenAnswer((_) async => Left(NetworkFailure()));

      // Test login failure
      final loginResult = await loginUseCase.call(
        email: 'test@example.com',
        password: 'pwd',
      );
      expect(loginResult.isLeft(), true);

      // Test get jobs failure
      final jobsResult = await getJobsUseCase.call(page: 1, limit: 10);
      expect(jobsResult.isLeft(), true);
    });
  });
}
