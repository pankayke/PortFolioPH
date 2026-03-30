// lib/features/auth/models/auth_user.dart
// ─────────────────────────────────────────────────────────────────────────────
// Represents authenticated user with role and approval status.
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole { jobSeeker, recruiter, admin }

enum RecruiterApprovalStatus { pending, approved, rejected }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.jobSeeker:
        return 'job_seeker';
      case UserRole.recruiter:
        return 'recruiter';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'job_seeker':
        return UserRole.jobSeeker;
      case 'recruiter':
        return UserRole.recruiter;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.jobSeeker;
    }
  }
}

class AuthUser {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final bool isApproved;
  final RecruiterApprovalStatus? recruiterStatus;
  final String? companyName;
  final String? token;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isApproved,
    this.recruiterStatus,
    this.companyName,
    this.token,
  });

  /// Determines if recruiter can access full features
  bool get canAccessRecruiterDashboard =>
      role == UserRole.recruiter &&
      recruiterStatus == RecruiterApprovalStatus.approved;

  /// Determines approval status message
  String get approvalStatusMessage {
    switch (recruiterStatus) {
      case RecruiterApprovalStatus.pending:
        return 'Account pending admin approval';
      case RecruiterApprovalStatus.approved:
        return 'Account approved';
      case RecruiterApprovalStatus.rejected:
        return 'Account rejected';
      case null:
        return 'No status';
    }
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final roleString = json['role'] as String? ?? 'job_seeker';
    final role = UserRoleExtension.fromString(roleString);

    RecruiterApprovalStatus? recruiterStatus;
    if (role == UserRole.recruiter) {
      final isApproved = json['is_approved'] as bool? ?? false;
      if (isApproved) {
        recruiterStatus = RecruiterApprovalStatus.approved;
      } else {
        // Check if explicitly rejected (would need is_rejected field or similar)
        recruiterStatus = RecruiterApprovalStatus.pending;
      }
    }

    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: role,
      isApproved: json['is_approved'] as bool? ?? false,
      recruiterStatus: recruiterStatus,
      companyName: json['company_name'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.value,
    'is_approved': isApproved,
    'company_name': companyName,
    'token': token,
  };
}
