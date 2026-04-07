// test/domain/entities/job_entity_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/domain/entities/index.dart';

void main() {
  group('JobEntity', () {
    final now = DateTime.now();
    final deadline = now.add(const Duration(days: 30));

    final testJob = JobEntity(
      id: 1,
      recruiterId: 1,
      title: 'Flutter Developer',
      description: 'Experienced Flutter developer needed',
      location: 'Remote',
      salaryMin: 50000,
      salaryMax: 80000,
      jobType: JobType.fullTime,
      status: JobStatus.open,
      requiredSkills: const ['Flutter', 'Dart'],
      deadline: deadline,
      applicationCount: 5,
      createdAt: now,
      updatedAt: now,
    );

    test('should create job entity with required fields', () {
      expect(testJob.id, 1);
      expect(testJob.recruiterId, 1);
      expect(testJob.title, 'Flutter Developer');
      expect(testJob.status, JobStatus.open);
    });

    test('should have equality based on all properties', () {
      final job1 = testJob;
      final job2 = testJob;
      expect(job1, job2);
    });

    test('should differ when properties change', () {
      final job1 = testJob;
      final job2 = testJob.copyWith(id: 2);
      expect(job1 == job2, false);
    });

    test('should determine if job is open', () {
      // Open job with future deadline
      expect(testJob.isOpen, true);

      // Closed job
      final closedJob = testJob.copyWith(status: JobStatus.closed);
      expect(closedJob.isOpen, false);

      // Open job with past deadline
      final expiredJob = testJob.copyWith(
        deadline: now.subtract(const Duration(days: 1)),
      );
      expect(expiredJob.isOpen, false);

      // Open job with no deadline
      final noDeadlineJob = testJob.copyWith(deadline: null);
      expect(noDeadlineJob.isOpen, true);
    });

    test('should determine if job is accepting applications', () {
      expect(testJob.acceptingApplications, true);

      final closedJob = testJob.copyWith(status: JobStatus.closed);
      expect(closedJob.acceptingApplications, false);
    });

    test('should format salary range correctly', () {
      expect(testJob.salaryRange, '\$50000 - \$80000');
    });

    test('should show negotiable for missing salary', () {
      final noSalaryJob = JobEntity(
        id: testJob.id,
        recruiterId: testJob.recruiterId,
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salaryMin: null,
        salaryMax: null,
        jobType: testJob.jobType,
        status: testJob.status,
        requiredSkills: testJob.requiredSkills,
        deadline: testJob.deadline,
        applicationCount: testJob.applicationCount,
        createdAt: testJob.createdAt,
        updatedAt: testJob.updatedAt,
        recruiter: testJob.recruiter,
      );
      expect(noSalaryJob.salaryRange, 'Negotiable');
    });

    test('should handle partial salary data', () {
      final minOnlyJob = JobEntity(
        id: testJob.id,
        recruiterId: testJob.recruiterId,
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salaryMin: testJob.salaryMin,
        salaryMax: null,
        jobType: testJob.jobType,
        status: testJob.status,
        requiredSkills: testJob.requiredSkills,
        deadline: testJob.deadline,
        applicationCount: testJob.applicationCount,
        createdAt: testJob.createdAt,
        updatedAt: testJob.updatedAt,
        recruiter: testJob.recruiter,
      );
      expect(minOnlyJob.salaryRange, 'Negotiable');

      final maxOnlyJob = JobEntity(
        id: testJob.id,
        recruiterId: testJob.recruiterId,
        title: testJob.title,
        description: testJob.description,
        location: testJob.location,
        salaryMin: null,
        salaryMax: testJob.salaryMax,
        jobType: testJob.jobType,
        status: testJob.status,
        requiredSkills: testJob.requiredSkills,
        deadline: testJob.deadline,
        applicationCount: testJob.applicationCount,
        createdAt: testJob.createdAt,
        updatedAt: testJob.updatedAt,
        recruiter: testJob.recruiter,
      );
      expect(maxOnlyJob.salaryRange, 'Negotiable');
    });

    test('should support different job types', () {
      expect(
        testJob.copyWith(jobType: JobType.fullTime).jobType,
        JobType.fullTime,
      );
      expect(
        testJob.copyWith(jobType: JobType.partTime).jobType,
        JobType.partTime,
      );
      expect(
        testJob.copyWith(jobType: JobType.contract).jobType,
        JobType.contract,
      );
      expect(
        testJob.copyWith(jobType: JobType.freelance).jobType,
        JobType.freelance,
      );
    });

    test('should parse JobType from string', () {
      expect(JobType.fromString('full_time'), JobType.fullTime);
      expect(JobType.fromString('part_time'), JobType.partTime);
      expect(JobType.fromString('contract'), JobType.contract);
      expect(JobType.fromString('freelance'), JobType.freelance);
      expect(JobType.fromString('invalid'), JobType.fullTime); // default
    });

    test('should support different job statuses', () {
      expect(testJob.copyWith(status: JobStatus.open).status, JobStatus.open);
      expect(
        testJob.copyWith(status: JobStatus.closed).status,
        JobStatus.closed,
      );
    });

    test('should parse JobStatus from string', () {
      expect(JobStatus.fromString('open'), JobStatus.open);
      expect(JobStatus.fromString('closed'), JobStatus.closed);
      expect(JobStatus.fromString('invalid'), JobStatus.open); // default
    });

    test('should track application count', () {
      expect(testJob.applicationCount, 5);
      expect(testJob.copyWith(applicationCount: 10).applicationCount, 10);
    });

    test('should include recruiter information', () {
      final recruiter = UserEntity(
        id: 1,
        email: 'recruiter@example.com',
        name: 'John Recruiter',
        role: UserRole.recruiter,
        createdAt: now,
        updatedAt: now,
      );
      final jobWithRecruiter = testJob.copyWith(recruiter: recruiter);
      expect(jobWithRecruiter.recruiter, recruiter);
      expect(jobWithRecruiter.recruiter!.email, 'recruiter@example.com');
    });

    test('should include required skills list', () {
      expect(testJob.requiredSkills.length, 2);
      expect(testJob.requiredSkills.contains('Flutter'), true);
      expect(testJob.requiredSkills.contains('Dart'), true);
    });

    test('should handle empty skills list', () {
      final noSkillsJob = testJob.copyWith(requiredSkills: const []);
      expect(noSkillsJob.requiredSkills.isEmpty, true);
    });

    test('should track timestamps', () {
      expect(testJob.createdAt, testJob.updatedAt);
    });
  });
}

extension _JobEntityCopyWith on JobEntity {
  JobEntity copyWith({
    int? id,
    int? recruiterId,
    String? title,
    String? description,
    String? location,
    int? salaryMin,
    int? salaryMax,
    JobType? jobType,
    JobStatus? status,
    List<String>? requiredSkills,
    DateTime? deadline,
    int? applicationCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserEntity? recruiter,
  }) => JobEntity(
    id: id ?? this.id,
    recruiterId: recruiterId ?? this.recruiterId,
    title: title ?? this.title,
    description: description ?? this.description,
    location: location ?? this.location,
    salaryMin: salaryMin ?? this.salaryMin,
    salaryMax: salaryMax ?? this.salaryMax,
    jobType: jobType ?? this.jobType,
    status: status ?? this.status,
    requiredSkills: requiredSkills ?? this.requiredSkills,
    deadline: deadline ?? this.deadline,
    applicationCount: applicationCount ?? this.applicationCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    recruiter: recruiter ?? this.recruiter,
  );
}
