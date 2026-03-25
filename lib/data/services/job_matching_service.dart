// lib/data/services/job_matching_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job matching service — aligns jobs with user profile/resume/portfolio.
//
// Scores jobs based on:
//   • Skills match (40%) — extract keywords, compare against user skills
//   • Experience level (25%) — work history, recency, current status
//   • Location (15%) — exact match or remote-friendly
//   • Education (10%) — degree requirements in description
//   • Certifications (10%) — industry credentials
//
// Usage:
// ```dart
// final service = JobMatchingService();
// final alignedJobs = service.scoreJobs(
//   jobs: allJobs,
//   userSkills: userSkills,
//   userExperience: userExperience,
//   userEducation: userEducation,
//   userCertifications: userCerts,
//   userProjects: portfolioItems,
//   userLocation: userLocation,
// );
// final topMatches = alignedJobs.where((j) => j.score! >= 0.75).toList();
// ```
// ─────────────────────────────────────────────────────────────────────────────

import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/data/models/skill_model.dart';

/// Wrapper class for scored jobs (adds alignment score to JobListingModel)
class ScoredJob {
  final JobListingModel job;
  final double score;

  ScoredJob({required this.job, required this.score});
}

/// Service for calculating alignment scores between jobs and user profiles.
class JobMatchingService {
  /// Common tech stack keywords by category (for skill extraction)
  static const Map<String, List<String>> _techKeywords = {
    'Frontend': [
      'flutter',
      'react',
      'vue',
      'angular',
      'swift',
      'kotlin',
      'jetpack compose',
      'swiftui',
    ],
    'Backend': [
      'node',
      'python',
      'java',
      'go',
      'rust',
      'php',
      'c#',
      'scala',
      'django',
      'spring',
      'fastapi',
    ],
    'Mobile': ['flutter', 'react native', 'swift', 'kotlin', 'ionic'],
    'DevOps': [
      'docker',
      'kubernetes',
      'aws',
      'gcp',
      'azure',
      'terraform',
      'jenkins',
    ],
    'Data': ['sql', 'python', 'spark', 'hadoop', 'tableau', 'powerbi'],
    'Design': ['figma', 'sketch', 'adobe', 'photoshop', 'illustrator'],
  };

  /// Scores a list of jobs against user profile and returns sorted by alignment.
  /// Returns list of ScoredJob objects with alignment scores.
  List<ScoredJob> scoreJobs({
    required List<JobListingModel> jobs,
    required List<SkillModel> userSkills,
    required List<ExperienceModel> userExperience,
    required List<EducationModel> userEducation,
    required List<CertificationModel> userCertifications,
    required List<ProjectModel> userProjects,
    required String? userLocation,
  }) {
    final scoredJobs = jobs.map((job) {
      final skillsScore = _scoreSkillsMatch(job, userSkills, userProjects);
      final experienceScore = _scoreExperience(job, userExperience);
      final locationScore = _scoreLocation(job, userLocation);
      final educationScore = _scoreEducation(job, userEducation);
      final certScore = _scoreCertifications(job, userCertifications);

      // Weighted calculation
      final totalScore =
          (skillsScore * 0.40) +
          (experienceScore * 0.25) +
          (locationScore * 0.15) +
          (educationScore * 0.10) +
          (certScore * 0.10);

      return ScoredJob(job: job, score: totalScore);
    }).toList();

    // Sort by score (highest first)
    scoredJobs.sort((a, b) => b.score.compareTo(a.score));
    return scoredJobs;
  }

  /// Scores skills match (0.0 - 1.0).
  /// Checks user skills and project tech stack against job requirements.
  double _scoreSkillsMatch(
    JobListingModel job,
    List<SkillModel> userSkills,
    List<ProjectModel> userProjects,
  ) {
    final jobDescription = '${job.title} ${job.description} ${job.category}'
        .toLowerCase();

    // Extract user skill names
    final userSkillNames = userSkills.map((s) => s.name.toLowerCase()).toSet();

    // Extract tech stack from projects
    final projectTechs = userProjects
        .expand((p) => (p.techStack ?? '').split(','))
        .map((t) => t.trim().toLowerCase())
        .toSet();

    final allUserTechs = {...userSkillNames, ...projectTechs};

    if (allUserTechs.isEmpty) return 0.0;

    // Count matches
    int matchCount = 0;
    for (final tech in allUserTechs) {
      if (jobDescription.contains(tech)) {
        matchCount++;
      }
    }

    // Score: matches / total user skills (capped at 1.0)
    return (matchCount / allUserTechs.length).clamp(0.0, 1.0);
  }

  /// Scores experience level match (0.0 - 1.0).
  /// Checks work history relevance, recency, and current employment status.
  double _scoreExperience(
    JobListingModel job,
    List<ExperienceModel> userExperience,
  ) {
    if (userExperience.isEmpty) return 0.3; // Some benefit of doubt

    double score = 0.0;

    // Check if user is currently employed
    final isCurrent = userExperience.any((exp) => exp.isCurrent);
    if (isCurrent) score += 0.3;

    // Check if any experience matches job location or company type
    final jobCompanyLower = job.company.toLowerCase();
    final jobLocationLower = job.location.toLowerCase();

    for (final exp in userExperience) {
      final expCompanyLower = exp.company.toLowerCase();
      final expLocationLower = (exp.location ?? '').toLowerCase();

      // Company match
      if (expCompanyLower.contains(jobCompanyLower) ||
          jobCompanyLower.contains(expCompanyLower)) {
        score += 0.35;
      }

      // Location match
      if (expLocationLower.contains(jobLocationLower) ||
          jobLocationLower.contains(expLocationLower)) {
        score += 0.15;
      }

      // Job title relevance (simple heuristic)
      if (job.title.toLowerCase().contains('senior') &&
          exp.jobTitle.toLowerCase().contains('senior')) {
        score += 0.2;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  /// Scores location match (0.0 - 1.0).
  /// Full match = 1.0, partial match = 0.6, remote = 0.8, no match = 0.0.
  double _scoreLocation(JobListingModel job, String? userLocation) {
    if (userLocation == null || userLocation.isEmpty) return 0.5;

    final jobLocationLower = job.location.toLowerCase();
    final userLocationLower = userLocation.toLowerCase();

    // Exact match
    if (jobLocationLower == userLocationLower) return 1.0;

    // Remote means more flexible
    if (jobLocationLower.contains('remote')) return 0.8;

    // Partial match (e.g., "Cebu" in "Cebu, Philippines")
    if (jobLocationLower.contains(userLocationLower) ||
        userLocationLower.contains(jobLocationLower)) {
      return 0.6;
    }

    return 0.0;
  }

  /// Scores education match (0.0 - 1.0).
  /// Looks for degree keywords in job description.
  double _scoreEducation(
    JobListingModel job,
    List<EducationModel> userEducation,
  ) {
    if (userEducation.isEmpty) return 0.3;

    final jobDescription = '${job.title} ${job.description}'.toLowerCase();

    double score = 0.0;
    final degreeTypes = ['bachelor', 'master', 'diploma', 'degree'];

    for (final edu in userEducation) {
      // Check if degree is mentioned in job
      for (final degreeType in degreeTypes) {
        if (jobDescription.contains(degreeType)) {
          score += 0.5 / (userEducation.length > 1 ? userEducation.length : 1);
          break;
        }
      }

      // Field of study match
      if (edu.fieldOfStudy.isNotEmpty) {
        final fieldLower = edu.fieldOfStudy.toLowerCase();
        if (jobDescription.contains(fieldLower)) {
          score += 0.3 / (userEducation.length > 1 ? userEducation.length : 1);
        }
      }
    }

    return score.clamp(0.0, 1.0);
  }

  /// Scores certification match (0.0 - 1.0).
  /// Looks for certification keywords in job description.
  double _scoreCertifications(
    JobListingModel job,
    List<CertificationModel> userCertifications,
  ) {
    if (userCertifications.isEmpty) return 0.3;

    final jobDescription = '${job.title} ${job.description}'.toLowerCase();

    int matchCount = 0;
    for (final cert in userCertifications) {
      final certNameLower = cert.name.toLowerCase();
      if (jobDescription.contains(certNameLower)) {
        matchCount++;
      }
    }

    return (matchCount / userCertifications.length).clamp(0.0, 1.0);
  }

  /// Filter jobs by minimum alignment score threshold.
  List<ScoredJob> filterByScore(
    List<ScoredJob> scoredJobs, {
    double minimumScore = 0.5,
  }) {
    return scoredJobs.where((sj) => sj.score >= minimumScore).toList();
  }

  /// Get alignment badge text and color based on score.
  (String label, String color) getAlignmentBadge(double? score) {
    if (score == null) return ('Not Scored', '#999999');

    if (score >= 0.75) return ('Excellent Match', '#10B981');
    if (score >= 0.50) return ('Good Match', '#3B82F6');
    if (score >= 0.25) return ('Possible Fit', '#F59E0B');

    return ('Not Recommended', '#EF4444');
  }
}
