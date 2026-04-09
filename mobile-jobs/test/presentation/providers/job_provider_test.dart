import 'package:flutter_test/flutter_test.dart';
import 'package:job_platform/data/models/application_model.dart';
import 'package:job_platform/data/models/job_model.dart';
import 'package:job_platform/data/repositories/job_repository.dart';
import 'package:job_platform/presentation/providers/job_provider.dart';

class FakeJobRepository implements JobRepository {
  FakeJobRepository({
    required this.jobs,
    this.shouldThrowOnFetch = false,
  });

  final List<JobModel> jobs;
  final bool shouldThrowOnFetch;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<(List<JobModel> jobs, Map<String, dynamic> pagination)> getJobs({
    int page = 1,
    int perPage = 15,
    String? search,
    String? jobType,
    bool? remote,
  }) async {
    if (shouldThrowOnFetch) {
      throw Exception('Fetch failed');
    }
    return (jobs, {'page': page, 'total': jobs.length});
  }

  @override
  Future<JobModel> getJobDetail(int jobId) async => jobs.first;

  @override
  Future<JobModel> createJob({
    required String title,
    required String description,
    required String requirements,
    required String jobType,
    required String location,
    required String deadlineAt,
    double? salaryMin,
    double? salaryMax,
    bool remote = false,
  }) async {
    return jobs.first;
  }

  @override
  Future<JobModel> updateJob(
    int jobId, {
    String? title,
    String? description,
    String? requirements,
    String? jobType,
    String? location,
    String? deadlineAt,
    double? salaryMin,
    double? salaryMax,
    bool? remote,
  }) async {
    return jobs.first;
  }

  @override
  Future<void> deleteJob(int jobId) async {}

  @override
  Future<ApplicationModel> applyJob({
    required int jobId,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    return ApplicationModel(
      id: 1,
      jobId: jobId,
      userId: 2,
      createdAt: '2026-04-09T00:00:00Z',
    );
  }

  @override
  Future<(List<ApplicationModel> applications, Map<String, dynamic> pagination)>
      getMyApplications({int page = 1, int perPage = 15}) async {
    return (
      <ApplicationModel>[
        ApplicationModel(
          id: 1,
          jobId: 9,
          userId: 2,
          createdAt: '2026-04-09T00:00:00Z',
        ),
      ],
      {'page': 1},
    );
  }

  @override
  Future<void> withdrawApplication(int applicationId) async {}
}

void main() {
  group('JobProvider baseline', () {
    test('fetchJobs loads data and clears error', () async {
      final repo = FakeJobRepository(
        jobs: [
          JobModel(
            id: 10,
            recruiterId: 20,
            title: 'Flutter Dev',
            description: 'Build apps',
            requirements: 'Dart',
            jobType: 'full_time',
            location: 'Remote',
            deadlineAt: '2026-08-01T00:00:00Z',
            createdAt: '2026-04-09T00:00:00Z',
          ),
        ],
      );
      final provider = JobProvider(repo);

      await provider.fetchJobs(page: 1);

      expect(provider.jobs, hasLength(1));
      expect(provider.error, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('fetchJobs sets error on failure', () async {
      final repo = FakeJobRepository(jobs: const [], shouldThrowOnFetch: true);
      final provider = JobProvider(repo);

      await provider.fetchJobs(page: 1);

      expect(provider.jobs, isEmpty);
      expect(provider.error, isNotNull);
      expect(provider.isLoading, isFalse);
    });
  });
}
