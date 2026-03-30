// lib/domain/entities/job_entity.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job posting domain entity - Recruiter-only creation
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'user_entity.dart';

enum JobType {
  fullTime('full_time'),
  partTime('part_time'),
  contract('contract'),
  freelance('freelance');

  final String value;
  const JobType(this.value);

  static JobType fromString(String value) {
    return JobType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => JobType.fullTime,
    );
  }
}

enum JobStatus {
  open('open'),
  closed('closed');

  final String value;
  const JobStatus(this.value);

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => JobStatus.open,
    );
  }
}

class JobEntity extends Equatable {
  // ── Core fields ────────────────────────────────────────────────────────────
  final int? id;
  final int recruiterId;
  final String title;
  final String description;

  // ── Job details ────────────────────────────────────────────────────────────
  final String location;
  final int? salaryMin;
  final int? salaryMax;
  final JobType jobType;
  final JobStatus status;

  // ── Skills and deadline ────────────────────────────────────────────────────
  final List<String> requiredSkills;
  final DateTime? deadline;

  // ── Metadata ───────────────────────────────────────────────────────────────
  final int applicationCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Recruiter info (denormalized for convenience) ──────────────────────────
  final UserEntity? recruiter;

  /// DOMAIN RULE: Job is open if status=open AND (no deadline OR deadline > now)
  bool get isOpen =>
      status == JobStatus.open &&
      (deadline == null || deadline!.isAfter(DateTime.now()));

  /// DOMAIN RULE: Job is accepting applications if open
  bool get acceptingApplications => isOpen;

  /// DOMAIN RULE: Calculate salary range display
  String get salaryRange {
    if (salaryMin == null || salaryMax == null) return 'Negotiable';
    return '\$$salaryMin - \$$salaryMax';
  }

  const JobEntity({
    this.id,
    required this.recruiterId,
    required this.title,
    required this.description,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    this.jobType = JobType.fullTime,
    this.status = JobStatus.open,
    this.requiredSkills = const [],
    this.deadline,
    this.applicationCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.recruiter,
  });

  @override
  List<Object?> get props => [
    id,
    recruiterId,
    title,
    description,
    location,
    salaryMin,
    salaryMax,
    jobType,
    status,
    requiredSkills,
    deadline,
    applicationCount,
    createdAt,
    updatedAt,
    recruiter,
  ];
}
