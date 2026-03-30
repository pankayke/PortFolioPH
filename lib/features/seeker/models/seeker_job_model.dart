// lib/features/seeker/models/seeker_job_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job model from seeker's perspective with application status tracking.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:json_annotation/json_annotation.dart';

part 'seeker_job_model.g.dart';

@JsonSerializable()
class SeekerJob {
  final int id;
  final int recruiterId;
  final String recruiterName;
  final String recruiterLogo;
  final String title;
  final String description;
  final String category;
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final String employmentType;
  final String experienceLevel;
  final List<String> requiredSkills;
  final String? requiredQualifications;
  final DateTime deadline;
  final int totalApplications;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Application status from seeker perspective: none, applied, shortlisted, rejected, accepted
  @JsonKey(defaultValue: 'none')
  final String? applicationStatus;

  /// Whether job has been saved/bookmarked by this seeker
  @JsonKey(defaultValue: false)
  final bool? isSaved;

  SeekerJob({
    required this.id,
    required this.recruiterId,
    required this.recruiterName,
    required this.recruiterLogo,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    required this.employmentType,
    required this.experienceLevel,
    required this.requiredSkills,
    this.requiredQualifications,
    required this.deadline,
    required this.totalApplications,
    required this.createdAt,
    required this.updatedAt,
    this.applicationStatus,
    this.isSaved,
  });

  // Helper getters
  bool get isActive => DateTime.now().isBefore(deadline);
  bool get hasApplied =>
      applicationStatus != null && applicationStatus != 'none';
  bool get isShortlisted => applicationStatus == 'shortlisted';
  bool get isAccepted => applicationStatus == 'accepted';
  bool get isRejected => applicationStatus == 'rejected';

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Not specified';
    if (salaryMin != null && salaryMax != null) {
      return '\$${salaryMin!.toStringAsFixed(0)}-\$${salaryMax!.toStringAsFixed(0)}';
    }
    if (salaryMin != null) return '\$${salaryMin!.toStringAsFixed(0)}+';
    return '\$${salaryMax!.toStringAsFixed(0)}';
  }

  String get skillsDisplay => requiredSkills.join(', ');

  Duration get timeUntilDeadline => deadline.difference(DateTime.now());

  bool get deadlineExpired => DateTime.now().isAfter(deadline);

  SeekerJob copyWith({
    int? id,
    int? recruiterId,
    String? recruiterName,
    String? recruiterLogo,
    String? title,
    String? description,
    String? category,
    String? location,
    double? salaryMin,
    double? salaryMax,
    String? employmentType,
    String? experienceLevel,
    List<String>? requiredSkills,
    String? requiredQualifications,
    DateTime? deadline,
    int? totalApplications,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? applicationStatus,
    bool? isSaved,
  }) {
    return SeekerJob(
      id: id ?? this.id,
      recruiterId: recruiterId ?? this.recruiterId,
      recruiterName: recruiterName ?? this.recruiterName,
      recruiterLogo: recruiterLogo ?? this.recruiterLogo,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      employmentType: employmentType ?? this.employmentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      requiredQualifications:
          requiredQualifications ?? this.requiredQualifications,
      deadline: deadline ?? this.deadline,
      totalApplications: totalApplications ?? this.totalApplications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory SeekerJob.fromJson(Map<String, dynamic> json) =>
      _$SeekerJobFromJson(json);

  Map<String, dynamic> toJson() => _$SeekerJobToJson(this);

  @override
  String toString() =>
      'SeekerJob(id: $id, title: $title, status: $applicationStatus)';
}
