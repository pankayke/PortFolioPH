// lib/domain/entities/application_entity.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job application domain entity - Seeker applies to Recruiter's job
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  pending('pending'),
  reviewed('reviewed'),
  shortlisted('shortlisted'),
  rejected('rejected'),
  accepted('accepted');

  final String value;
  const ApplicationStatus(this.value);

  static ApplicationStatus fromString(String value) => ApplicationStatus.values
      .firstWhere((s) => s.value == value, orElse: () => ApplicationStatus.pending);

  /// DOMAIN RULE: Application can be updated if in certain states
  bool get canUpdate => this == ApplicationStatus.pending ||
      this == ApplicationStatus.reviewed;

  /// DOMAIN RULE: Is final decision made?
  bool get isDecided => this == ApplicationStatus.accepted ||
      this == ApplicationStatus.rejected;
}

class ApplicationEntity extends Equatable {
  final int? id;
  final int jobId;
  final int userId;
  final String? coverLetter;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime updatedAt;

  /// DOMAIN RULE: Seeker can withdraw if not yet accepted/rejected
  bool get canWithdraw => !status.isDecided;

  /// DOMAIN RULE: Recruiter can revert rejection to pending
  bool get canRevert => status == ApplicationStatus.rejected;

  const ApplicationEntity({
    this.id,
    required this.jobId,
    required this.userId,
    this.coverLetter,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, jobId, userId, coverLetter, status, appliedAt, updatedAt,
  ];
}
