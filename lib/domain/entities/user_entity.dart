// lib/domain/entities/user_entity.dart
// ─────────────────────────────────────────────────────────────────────────────
// User domain entity - Business logic free, immutable representation
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

enum UserRole {
  jobSeeker('job_seeker'),
  recruiter('recruiter'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  /// Parse string to UserRole enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.jobSeeker,
    );
  }
}

class UserEntity extends Equatable {
  // ── Core identity ──────────────────────────────────────────────────────────
  final int? id;
  final String email;
  final String name;
  final UserRole role;

  // ── Profile info ───────────────────────────────────────────────────────────
  final String? bio;
  final String? avatarUrl;
  final String? location;
  final String? websiteUrl;

  // ── Metadata ───────────────────────────────────────────────────────────────
  final DateTime createdAt;
  final DateTime updatedAt;

  /// DOMAIN RULE: Only recruiters can post jobs
  bool get canPostJobs => role == UserRole.recruiter;

  /// DOMAIN RULE: Only seekers can apply to jobs
  bool get canApplyToJobs => role == UserRole.jobSeeker;

  /// DOMAIN RULE: Only admins can moderate
  bool get canModerate => role == UserRole.admin;

  const UserEntity({
    this.id,
    required this.email,
    required this.name,
    required this.role,
    this.bio,
    this.avatarUrl,
    this.location,
    this.websiteUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    bio,
    avatarUrl,
    location,
    websiteUrl,
    createdAt,
    updatedAt,
  ];
}
