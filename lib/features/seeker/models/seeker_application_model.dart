// lib/features/seeker/models/seeker_application_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Application model from seeker's perspective.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:json_annotation/json_annotation.dart';

part 'seeker_application_model.g.dart';

@JsonSerializable()
class SeekerApplication {
  final int id;
  final int jobId;
  final String jobTitle;
  final String recruiterName;
  final String recruiterLogo;
  final String? jobLocation;
  final double? salaryMin;
  final double? salaryMax;
  final String
  status; // applied, reviewing, shortlisted, rejected, accepted, withdrawn
  final String? notes;
  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? videoInterviewLink;
  final DateTime appliedAt;
  final DateTime? updatedAt;

  SeekerApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.recruiterName,
    required this.recruiterLogo,
    this.jobLocation,
    this.salaryMin,
    this.salaryMax,
    required this.status,
    this.notes,
    this.interviewDate,
    this.interviewLocation,
    this.videoInterviewLink,
    required this.appliedAt,
    this.updatedAt,
  });

  // Helper getters
  bool get isApplied => status == 'applied';
  bool get isReviewing => status == 'reviewing';
  bool get isShortlisted => status == 'shortlisted';
  bool get isRejected => status == 'rejected';
  bool get isAccepted => status == 'accepted';
  bool get isWithdrawn => status == 'withdrawn';

  bool get hasInterview => interviewDate != null;
  bool get isUpcomingInterview =>
      interviewDate != null && DateTime.now().isBefore(interviewDate!);

  String get statusDisplay => _getStatusDisplay(status);

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'applied':
        return 'Applied';
      case 'reviewing':
        return 'Under Review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'rejected':
        return 'Rejected';
      case 'accepted':
        return 'Accepted';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return 'Unknown';
    }
  }

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Not specified';
    if (salaryMin != null && salaryMax != null) {
      return '\$${salaryMin!.toStringAsFixed(0)}-\$${salaryMax!.toStringAsFixed(0)}';
    }
    if (salaryMin != null) return '\$${salaryMin!.toStringAsFixed(0)}+';
    return '\$${salaryMax!.toStringAsFixed(0)}';
  }

  Duration get applicationAge => DateTime.now().difference(appliedAt);

  String get applicationAgeDisplay {
    final days = applicationAge.inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    final weeks = (days / 7).floor();
    if (weeks == 1) return '1 week ago';
    if (weeks < 4) return '$weeks weeks ago';
    final months = (days / 30).floor();
    if (months == 1) return '1 month ago';
    return '$months months ago';
  }

  SeekerApplication copyWith({
    int? id,
    int? jobId,
    String? jobTitle,
    String? recruiterName,
    String? recruiterLogo,
    String? jobLocation,
    double? salaryMin,
    double? salaryMax,
    String? status,
    String? notes,
    DateTime? interviewDate,
    String? interviewLocation,
    String? videoInterviewLink,
    DateTime? appliedAt,
    DateTime? updatedAt,
  }) {
    return SeekerApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      recruiterName: recruiterName ?? this.recruiterName,
      recruiterLogo: recruiterLogo ?? this.recruiterLogo,
      jobLocation: jobLocation ?? this.jobLocation,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewLocation: interviewLocation ?? this.interviewLocation,
      videoInterviewLink: videoInterviewLink ?? this.videoInterviewLink,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SeekerApplication.fromJson(Map<String, dynamic> json) =>
      _$SeekerApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$SeekerApplicationToJson(this);

  @override
  String toString() =>
      'SeekerApplication(id: $id, jobId: $jobId, jobTitle: $jobTitle, status: $status)';
}
