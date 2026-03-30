import 'package:flutter/foundation.dart';

import 'package:portfolioph/core/services/polling_service.dart';
import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/data/models/skill_model.dart';
import 'package:portfolioph/data/repositories/job_feed_repository.dart';
import 'package:portfolioph/data/services/job_matching_service.dart';

/// JobFeedProvider - Online-only with real-time polling.
/// Fetches jobs from API on every load/refresh. No local caching for jobs.
/// Supports:
/// - Manual refresh via pull-to-refresh
/// - Automatic polling (30s interval recommended)
/// - Job alignment scoring based on user profile
/// - Graceful error  handling with retry UI
class JobFeedProvider extends ChangeNotifier {
  final JobFeedRepository _repository;
  final JobMatchingService _matchingService;
  final PollingService _pollingService = PollingService();

  List<JobListingModel> _jobs = [];
  final Set<int> _savedJobIds = <int>{};
  bool _isLoading = false;
  String? _errorMessage;
  Map<int, double> _jobScores = {}; // Store alignment scores

  // Polling state
  bool _isPollingActive = false;
  static const String _pollingTaskId = 'job_feed_polling';
  static const Duration _pollingInterval = Duration(seconds: 30);

  JobFeedProvider({
    JobFeedRepository? repository,
    JobMatchingService? matchingService,
  }) : _repository = repository ?? JobFeedRepository(),
       _matchingService = matchingService ?? JobMatchingService();

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<JobListingModel> get jobs => List.unmodifiable(_jobs);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<int> get savedJobIds => Set.unmodifiable(_savedJobIds);
  bool get isPollingActive => _isPollingActive;

  /// Get alignment score for a specific job (null if not scored)
  double? getJobScore(int jobId) => _jobScores[jobId];

  // ─── Loading & Refresh ────────────────────────────────────────────────────

  /// Load jobs from API (no caching).
  /// Clears previous jobs and scores.
  Future<void> loadJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jobs = await _repository.findAll();
      _jobScores.clear();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[JobFeedProvider] Load failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh wrapper.
  /// Call from RefreshIndicator.
  Future<void> refresh() => loadJobs();

  /// Load jobs with alignment scoring based on user profile.
  ///
  /// If user profile is empty: shows ALL jobs (new users can apply to anything).
  /// If user profile has data: ranks jobs by alignment score.
  Future<void> loadJobsWithAlignment({
    required List<dynamic> userSkills,
    required List<ExperienceModel> userExperience,
    required List<EducationModel> userEducation,
    required List<CertificationModel> userCertifications,
    required List<ProjectModel> userProjects,
    required String? userLocation,
    double minimumScore = 0.15,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allJobs = await _repository.findAll();

      // Check if user profile is empty
      final profileIsEmpty =
          userSkills.isEmpty &&
          userExperience.isEmpty &&
          userEducation.isEmpty &&
          userCertifications.isEmpty &&
          userProjects.isEmpty &&
          (userLocation == null || userLocation.isEmpty);

      if (profileIsEmpty) {
        // User is new with empty profile - show all jobs
        _jobs = allJobs;
        _jobScores.clear();
      } else {
        // User has profile data - try alignment scoring
        try {
          final scoredJobs = _matchingService.scoreJobs(
            jobs: allJobs,
            userSkills: userSkills.cast<SkillModel>(),
            userExperience: userExperience,
            userEducation: userEducation,
            userCertifications: userCertifications,
            userProjects: userProjects,
            userLocation: userLocation ?? '',
          );

          // Store scores and filter
          _jobScores = {};
          final filtered = <JobListingModel>[];
          for (final scoredJob in scoredJobs) {
            if (scoredJob.score >= minimumScore) {
              filtered.add(scoredJob.job);
              _jobScores[scoredJob.job.id ?? 0] = scoredJob.score;
            }
          }
          _jobs = filtered.isNotEmpty ? filtered : allJobs;
        } catch (e) {
          // Fallback to all jobs if scoring fails
          _jobs = allJobs;
          _jobScores.clear();
          debugPrint(
            '[JobFeedProvider] Alignment scoring failed: $e, showing all jobs',
          );
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[JobFeedProvider] Alignment load failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Polling ──────────────────────────────────────────────────────────────

  /// Start automatic polling of jobs.
  /// Useful for dashboard to get real-time job updates.
  /// Polls every 30 seconds by default.
  void startPolling() {
    if (_isPollingActive) return;

    _isPollingActive = true;
    _pollingService.startPolling(
      id: _pollingTaskId,
      callback: loadJobs,
      interval: _pollingInterval,
    );
    debugPrint('[JobFeedProvider] Started polling');
  }

  /// Stop automatic polling.
  void stopPolling() {
    if (!_isPollingActive) return;

    _isPollingActive = false;
    _pollingService.stopPolling(_pollingTaskId);
    debugPrint('[JobFeedProvider] Stopped polling');
  }

  // ─── Save/Bookmark Management ─────────────────────────────────────────────

  void toggleSave(int jobId) {
    if (_savedJobIds.contains(jobId)) {
      _savedJobIds.remove(jobId);
    } else {
      _savedJobIds.add(jobId);
    }
    notifyListeners();
  }

  bool isSaved(int jobId) => _savedJobIds.contains(jobId);

  // ─── Cleanup ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
