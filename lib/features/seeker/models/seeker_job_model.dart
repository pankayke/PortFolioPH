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

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return double.tryParse(value.toString());
  }

  static DateTime _asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return DateTime.now();
  }

  static dynamic _pick(Map<String, dynamic> json, String camel, String snake) {
    return json.containsKey(camel) ? json[camel] : json[snake];
  }

  factory SeekerJob.fromJson(Map<String, dynamic> json) {
    final requiredSkillsRaw =
        _pick(json, 'requiredSkills', 'required_skills') as List<dynamic>?;

    final normalized = <String, dynamic>{
      ...json,
      'id': _asInt(_pick(json, 'id', 'id')),
      'recruiterId': _asInt(_pick(json, 'recruiterId', 'recruiter_id')),
      'recruiterName': (_pick(json, 'recruiterName', 'recruiter_name') ?? '')
          .toString(),
      'recruiterLogo': (_pick(json, 'recruiterLogo', 'recruiter_logo') ?? '')
          .toString(),
      'title': (_pick(json, 'title', 'title') ?? '').toString(),
      'description': (_pick(json, 'description', 'description') ?? '')
          .toString(),
      'category': (_pick(json, 'category', 'category') ?? 'General').toString(),
      'location': (_pick(json, 'location', 'location') ?? 'Remote').toString(),
      'salaryMin': _asDouble(_pick(json, 'salaryMin', 'salary_min')),
      'salaryMax': _asDouble(_pick(json, 'salaryMax', 'salary_max')),
      'employmentType':
          (_pick(json, 'employmentType', 'employment_type') ?? 'full_time')
              .toString(),
      'experienceLevel':
          (_pick(json, 'experienceLevel', 'experience_level') ?? 'entry')
              .toString(),
      'requiredSkills': (requiredSkillsRaw ?? const <dynamic>[])
          .map((e) => '$e')
          .toList(),
      'requiredQualifications': _pick(
        json,
        'requiredQualifications',
        'required_qualifications',
      ),
      'deadline': _asDateTime(
        _pick(json, 'deadline', 'deadline'),
      ).toIso8601String(),
      'totalApplications': _asInt(
        _pick(json, 'totalApplications', 'total_applications'),
      ),
      'createdAt': _asDateTime(
        _pick(json, 'createdAt', 'created_at'),
      ).toIso8601String(),
      'updatedAt': _asDateTime(
        _pick(json, 'updatedAt', 'updated_at'),
      ).toIso8601String(),
      'applicationStatus':
          (_pick(json, 'applicationStatus', 'application_status') ?? 'none')
              .toString(),
      'isSaved':
          (_pick(json, 'isSaved', 'is_saved') == true) ||
          (_pick(json, 'isSaved', 'is_saved')?.toString() == '1'),
    };

    return _$SeekerJobFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$SeekerJobToJson(this);

  @override
  String toString() =>
      'SeekerJob(id: $id, title: $title, status: $applicationStatus)';
}
