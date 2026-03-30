import 'package:flutter/foundation.dart';
import '../../data/models/job_model.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/job_repository.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _repository;

  List<JobModel> _jobs = [];
  Map<String, dynamic> _jobsPagination = {};
  JobModel? _selectedJob;
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

  // Fetch jobs
  Future<void> fetchJobs({
    int page = 1,
    String? search,
    String? jobType,
    bool? remote,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _currentPage = page;
      notifyListeners();

      final (jobs, pagination) = await _repository.getJobs(
        page: page,
        search: search,
        jobType: jobType,
        remote: remote,
      );

      if (page == 1) {
        _jobs = jobs;
      } else {
        _jobs.addAll(jobs);
      }

      _jobsPagination = pagination;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get job detail
  Future<void> getJobDetail(int jobId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _selectedJob = await _repository.getJobDetail(jobId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final job = await _repository.createJob(
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

      _jobs.insert(0, job);
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Apply for job
  Future<bool> applyJob({
    required int jobId,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final application = await _repository.applyJob(
        jobId: jobId,
        coverLetter: coverLetter,
        resumeUrl: resumeUrl,
      );

      _myApplications.insert(0, application);
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get my applications
  Future<void> getMyApplications({int page = 1}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final (applications, pagination) = await _repository.getMyApplications(
        page: page,
      );

      if (page == 1) {
        _myApplications = applications;
      } else {
        _myApplications.addAll(applications);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Withdraw application
  Future<bool> withdrawApplication(int applicationId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.withdrawApplication(applicationId);

      _myApplications.removeWhere((app) => app.id == applicationId);
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
}
