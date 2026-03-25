import 'package:flutter/foundation.dart';

import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/data/models/skill_model.dart';
import 'package:portfolioph/data/repositories/job_feed_repository.dart';
import 'package:portfolioph/data/services/job_matching_service.dart';

class JobFeedProvider extends ChangeNotifier {
  final JobFeedRepository _repository;
  final JobMatchingService _matchingService;

  JobFeedProvider({
    JobFeedRepository? repository,
    JobMatchingService? matchingService,
  }) : _repository = repository ?? JobFeedRepository(),
       _matchingService = matchingService ?? JobMatchingService();

  List<JobListingModel> _jobs = [];
  final Set<int> _savedJobIds = <int>{};
  bool _isLoading = false;
  String? _errorMessage;
  Map<int, double> _jobScores = {}; // Store alignment scores

  List<JobListingModel> get jobs => List.unmodifiable(_jobs);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<int> get savedJobIds => Set.unmodifiable(_savedJobIds);

  /// Get alignment score for a specific job (null if not scored)
  double? getJobScore(int jobId) => _jobScores[jobId];

  Future<void> loadJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jobs = await _repository.findAll();
      _jobScores.clear();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        // User has profile data - rank jobs by alignment score
        final scoredJobs = _matchingService.scoreJobs(
          jobs: allJobs,
          userSkills: userSkills.cast<SkillModel>(),
          userExperience: userExperience,
          userEducation: userEducation,
          userCertifications: userCertifications,
          userProjects: userProjects,
          userLocation: userLocation,
        );
        _jobScores = {
          for (var sj in scoredJobs)
            if (sj.job.id != null) sj.job.id!: sj.score,
        };
        final filteredScored = _matchingService.filterByScore(
          scoredJobs,
          minimumScore: minimumScore,
        );
        _jobs = filteredScored.isNotEmpty
            ? filteredScored.map((sj) => sj.job).toList()
            : allJobs; // Fallback: show all jobs if none pass filter
      }
    } catch (e) {
      _errorMessage = e.toString();
      // Fallback: at least try to load jobs without alignment
      try {
        _jobs = await _repository.findAll();
      } catch (e2) {
        _errorMessage = 'Failed to load jobs: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadJobs();

  void toggleSave(int jobId) {
    if (_savedJobIds.contains(jobId)) {
      _savedJobIds.remove(jobId);
    } else {
      _savedJobIds.add(jobId);
    }
    notifyListeners();
  }

  bool isSaved(int jobId) => _savedJobIds.contains(jobId);
}
