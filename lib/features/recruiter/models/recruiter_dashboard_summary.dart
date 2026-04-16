import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';

class RecruiterDashboardDayStat {
  final DateTime date;
  final String label;
  final int count;

  const RecruiterDashboardDayStat({
    required this.date,
    required this.label,
    required this.count,
  });

  factory RecruiterDashboardDayStat.fromJson(Map<String, dynamic> json) {
    return RecruiterDashboardDayStat(
      date: DateTime.parse(json['date'] as String),
      label: (json['label'] as String?) ?? '',
      count: _asInt(json['count']),
    );
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsedInt = int.tryParse(value.trim());
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value.trim());
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return fallback;
  }
}

class RecruiterDashboardSummary {
  final int totalJobs;
  final int activeJobs;
  final int totalApplications;
  final int newApplicationsCount;
  final int jobsWithApplicationCount;
  final Map<String, int> atsSummary;
  final List<RecruiterDashboardDayStat> applicationStatsByDay;
  final List<Job> topJobs;
  final List<Job> recentJobs;
  final List<RecruiterApplication> recentApplications;

  const RecruiterDashboardSummary({
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplications,
    required this.newApplicationsCount,
    required this.jobsWithApplicationCount,
    required this.atsSummary,
    required this.applicationStatsByDay,
    required this.topJobs,
    required this.recentJobs,
    required this.recentApplications,
  });

  factory RecruiterDashboardSummary.fromJson(Map<String, dynamic> json) {
    return RecruiterDashboardSummary(
      totalJobs: _asInt(json['total_jobs']),
      activeJobs: _asInt(json['active_jobs']),
      totalApplications: _asInt(json['total_applications']),
      newApplicationsCount: _asInt(json['new_applications_count']),
      jobsWithApplicationCount: _asInt(json['jobs_with_application_count']),
      atsSummary: {
        'pending': _asInt(json['ats_summary']?['pending']),
        'reviewed': _asInt(json['ats_summary']?['reviewed']),
        'shortlisted': _asInt(json['ats_summary']?['shortlisted']),
        'rejected': _asInt(json['ats_summary']?['rejected']),
      },
      applicationStatsByDay:
          (json['application_stats_by_day'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(RecruiterDashboardDayStat.fromJson)
              .toList(),
      topJobs:
          (json['top_jobs'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((job) => Job.fromJson(job))
              .toList(),
      recentJobs:
          (json['recent_jobs'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((job) => Job.fromJson(job))
              .toList(),
      recentApplications:
          (json['recent_applications'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((application) => RecruiterApplication.fromJson(application))
              .toList(),
    );
  }

  bool get hasJobs => totalJobs > 0;
  bool get hasApplications => totalApplications > 0;

  int get pendingApplications => atsSummary['pending'] ?? 0;
  int get reviewedApplications => atsSummary['reviewed'] ?? 0;
  int get shortlistedApplications => atsSummary['shortlisted'] ?? 0;
  int get rejectedApplications => atsSummary['rejected'] ?? 0;

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsedInt = int.tryParse(value.trim());
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value.trim());
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return fallback;
  }
}