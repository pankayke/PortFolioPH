class ApplicationModel {
  final int id;
  final int jobId;
  final int userId;
  final String? coverLetter;
  final String? resumeUrl;
  final String status;
  final String? reviewedAt;
  final int? reviewedBy;
  final String? rejectionReason;
  final String createdAt;
  final Map<String, dynamic>? job;
  final Map<String, dynamic>? applicant;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.userId,
    this.coverLetter,
    this.resumeUrl,
    this.status = 'pending',
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    required this.createdAt,
    this.job,
    this.applicant,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      jobId: json['job_id'],
      userId: json['user_id'],
      coverLetter: json['cover_letter'],
      resumeUrl: json['resume_url'],
      status: json['status'] ?? 'pending',
      reviewedAt: json['reviewed_at'],
      reviewedBy: json['reviewed_by'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      job: json['job'],
      applicant: json['applicant'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'job_id': jobId,
    'user_id': userId,
    'cover_letter': coverLetter,
    'resume_url': resumeUrl,
    'status': status,
    'reviewed_at': reviewedAt,
    'reviewed_by': reviewedBy,
    'rejection_reason': rejectionReason,
    'created_at': createdAt,
  };

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isWithdrawn => status == 'withdrawn';
}
