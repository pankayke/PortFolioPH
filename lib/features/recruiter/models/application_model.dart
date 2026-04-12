// lib/features/recruiter/models/application_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job application model for recruiter side.
// ─────────────────────────────────────────────────────────────────────────────

class RecruiterApplication {
  final int id;
  final int jobId;
  final int userId;
  final String applicantName;
  final String applicantEmail;
  final String applicantPhone;
  final String applicantLocation;
  final String status;
  final String? resumeUrl;
  final String? coverLetter;
  final DateTime? interviewDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecruiterApplication({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantPhone,
    required this.applicantLocation,
    required this.status,
    this.resumeUrl,
    this.coverLetter,
    this.interviewDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isApplied => status == 'applied';
  bool get isReviewing => status == 'reviewed' || status == 'pending';
  bool get isShortlisted => status == 'shortlisted';
  bool get isRejected => status == 'rejected';
  bool get isAccepted => status == 'accepted';
  bool get isWithdrawn => status == 'withdrawn';

  String get statusDisplay {
    switch (status) {
      case 'applied':
        return 'Applied';
      case 'pending':
        return 'Under Review';
      case 'reviewed':
        return 'Reviewed';
      case 'shortlisted':
        return 'Shortlisted';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return status;
    }
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

  factory RecruiterApplication.fromJson(Map<String, dynamic> json) {
    return RecruiterApplication(
      id: _asInt(json['id']),
      jobId: _asInt(json['job_id']),
      userId: _asInt(json['user_id']),
      applicantName: json['user']?['name'] ?? json['applicant_name'] ?? 'N/A',
      applicantEmail:
          json['user']?['email'] ?? json['applicant_email'] ?? 'N/A',
      applicantPhone:
          json['user']?['phone_number'] ?? json['applicant_phone'] ?? '',
      applicantLocation:
          json['user']?['location'] ?? json['applicant_location'] ?? '',
      status: json['status'] as String,
      resumeUrl: json['resume_url'] as String?,
      coverLetter: json['cover_letter'] as String?,
      interviewDate: json['interview_date'] != null
          ? DateTime.parse(json['interview_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'job_id': jobId,
    'user_id': userId,
    'applicant_name': applicantName,
    'applicant_email': applicantEmail,
    'applicant_phone': applicantPhone,
    'applicant_location': applicantLocation,
    'status': status,
    'resume_url': resumeUrl,
    'cover_letter': coverLetter,
    'interview_date': interviewDate?.toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  RecruiterApplication copyWith({
    int? id,
    int? jobId,
    int? userId,
    String? applicantName,
    String? applicantEmail,
    String? applicantPhone,
    String? applicantLocation,
    String? status,
    String? resumeUrl,
    String? coverLetter,
    DateTime? interviewDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecruiterApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantLocation: applicantLocation ?? this.applicantLocation,
      status: status ?? this.status,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      coverLetter: coverLetter ?? this.coverLetter,
      interviewDate: interviewDate ?? this.interviewDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecruiterApplication &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
