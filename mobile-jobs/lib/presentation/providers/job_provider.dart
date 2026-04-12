import 'package:flutter/foundation.dart';
import '../../data/models/job_model.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/job_repository.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _repository;

  List<JobModel> _jobs = [];
  Map<String, dynamic> _jobsPagination = {};
  JobModel? _selectedJob;
  final Map<int, JobModel> _jobDetailCache = {};
  List<ApplicationModel> _myApplications = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;

  JobProvider(this._repository);

  // Getters
  List<JobModel> get jobs => _jobs;
  Map<String, dynamic> get jobsPagination => _jobsPagination;
  JobModel? get selectedJob => _selectedJob;
  List<ApplicationModel> get myApplications => _myApplications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;

  Future<T?> _runWithLoading<T>(Future<T> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await action();
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch jobs
  Future<void> fetchJobs({
    int page = 1,
    String? search,
    String? jobType,
    bool? remote,
    bool forceRefresh = false,
  }) async {
    final isDefaultQuery = search == null && jobType == null && remote == null;
    if (!forceRefresh && page == 1 && isDefaultQuery && _jobs.isNotEmpty) {
      return;
    }

    _currentPage = page;
    final result = await _runWithLoading(
      () => _repository.getJobs(
        page: page,
        search: search,
        jobType: jobType,
        remote: remote,
      ),
    );

    if (result == null) {
      return;
    }

    final (jobs, pagination) = result;
    if (page == 1) {
      _jobs = jobs;
    } else {
      _jobs.addAll(jobs);
    }
    _jobsPagination = pagination;
  }

  // Get job detail
  Future<void> getJobDetail(int jobId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _jobDetailCache.containsKey(jobId)) {
      _selectedJob = _jobDetailCache[jobId];
      notifyListeners();
      return;
    }

    final job = await _runWithLoading(() => _repository.getJobDetail(jobId));
    if (job != null) {
      _selectedJob = job;
      _jobDetailCache[jobId] = job;
    }
  }

  // Create job
  Future<bool> createJob({
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
    final job = await _runWithLoading(
      () => _repository.createJob(
        title: title,
        description: description,
        requirements: requirements,
        jobType: jobType,
        location: location,
        deadlineAt: deadlineAt,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        remote: remote,
      ),
    );

    if (job == null) {
      return false;
    }

    _jobs.insert(0, job);
    _jobDetailCache[job.id] = job;
    notifyListeners();
    return true;
  }

  // Apply for job
  Future<bool> applyJob({
    required int jobId,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    final application = await _runWithLoading(
      () => _repository.applyJob(
        jobId: jobId,
        coverLetter: coverLetter,
        resumeUrl: resumeUrl,
      ),
    );

    if (application == null) {
      return false;
    }

    _myApplications.insert(0, application);
    notifyListeners();
    return true;
  }

  // Get my applications
  Future<void> getMyApplications({int page = 1}) async {
    final result = await _runWithLoading(
      () => _repository.getMyApplications(page: page),
    );

    if (result == null) {
      return;
    }

    final (applications, _) = result;
    if (page == 1) {
      _myApplications = applications;
    } else {
      _myApplications.addAll(applications);
    }
  }

  // Withdraw application
  Future<bool> withdrawApplication(int applicationId) async {
    final success =
        await _runWithLoading(() async {
          await _repository.withdrawApplication(applicationId);
          return true;
        }) ??
        false;

    if (!success) {
      return false;
    }

    _myApplications.removeWhere((app) => app.id == applicationId);
    notifyListeners();
    return true;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedJob = null;
    notifyListeners();
  }

  void clearJobCache() {
    _jobDetailCache.clear();
    notifyListeners();
  }
}
