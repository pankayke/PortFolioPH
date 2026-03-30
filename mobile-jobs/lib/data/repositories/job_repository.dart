import '../models/job_model.dart';
import '../models/application_model.dart';
import '../../core/services/api_service.dart';

class JobRepository {
  final ApiService apiService;

  JobRepository(this.apiService);

  Future<(List<JobModel> jobs, Map<String, dynamic> pagination)> getJobs({
    int page = 1,
    int perPage = 15,
    String? search,
    String? jobType,
    bool? remote,
  }) async {
    try {
      final response = await apiService.getJobs(
        page: page,
        perPage: perPage,
        search: search,
        jobType: jobType,
        remote: remote,
      );

      final jobs = (response['data'] as List)
          .map((job) => JobModel.fromJson(job))
          .toList();

      return (jobs, response['pagination'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      rethrow;
    }
  }

  Future<JobModel> getJobDetail(int jobId) async {
    try {
      final response = await apiService.getJobDetail(jobId);
      return JobModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

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
    try {
      final response = await apiService.createJob(
        title: title,
        description: description,
        requirements: requirements,
        jobType: jobType,
        location: location,
        deadlineAt: deadlineAt,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        remote: remote,
      );

      return JobModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

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
    try {
      final response = await apiService.updateJob(
        jobId,
        title: title,
        description: description,
        requirements: requirements,
        jobType: jobType,
        location: location,
        deadlineAt: deadlineAt,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        remote: remote,
      );

      return JobModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      await apiService.deleteJob(jobId);
    } catch (e) {
      rethrow;
    }
  }

  // Applications
  Future<ApplicationModel> applyJob({
    required int jobId,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    try {
      final response = await apiService.applyJob(
        jobId: jobId,
        coverLetter: coverLetter,
        resumeUrl: resumeUrl,
      );

      return ApplicationModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<(List<ApplicationModel> applications, Map<String, dynamic> pagination)>
  getMyApplications({int page = 1, int perPage = 15}) async {
    try {
      final response = await apiService.getMyApplications(
        page: page,
        perPage: perPage,
      );

      final applications = (response['data'] as List)
          .map((app) => ApplicationModel.fromJson(app))
          .toList();

      return (applications, response['pagination'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> withdrawApplication(int applicationId) async {
    try {
      await apiService.withdrawApplication(applicationId);
    } catch (e) {
      rethrow;
    }
  }
}
