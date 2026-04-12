class JobModel {
  final int id;
  final int recruiterId;
  final String title;
  final String description;
  final String requirements;
  final String jobType;
  final double? salaryMin;
  final double? salaryMax;
  final String currency;
  final String location;
  final bool remoteWork;
  final String status;
  final String? rejectionReason;
  final String deadlineAt;
  final String? approvedAt;
  final int? approvedBy;
  final int viewsCount;
  final int applicationsCount;
  final String createdAt;
  final Map<String, dynamic>? recruiter;

  JobModel({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.description,
    required this.requirements,
    required this.jobType,
    this.salaryMin,
    this.salaryMax,
    this.currency = 'USD',
    required this.location,
    this.remoteWork = false,
    this.status = 'pending',
    this.rejectionReason,
    required this.deadlineAt,
    this.approvedAt,
    this.approvedBy,
    this.viewsCount = 0,
    this.applicationsCount = 0,
    required this.createdAt,
    this.recruiter,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      recruiterId: json['recruiter_id'],
      title: json['title'],
      description: json['description'],
      requirements: json['requirements'],
      jobType: json['job_type'],
      salaryMin: json['salary_min'] != null
          ? double.parse(json['salary_min'].toString())
          : null,
      salaryMax: json['salary_max'] != null
          ? double.parse(json['salary_max'].toString())
          : null,
      currency: json['currency'] ?? 'USD',
      location: json['location'],
      remoteWork: json['remote_work'] ?? false,
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      deadlineAt: json['deadline_at'],
      approvedAt: json['approved_at'],
      approvedBy: json['approved_by'],
      viewsCount: json['views_count'] ?? 0,
      applicationsCount: json['applications_count'] ?? 0,
      createdAt: json['created_at'],
      recruiter: json['recruiter'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recruiter_id': recruiterId,
        'title': title,
        'description': description,
        'requirements': requirements,
        'job_type': jobType,
        'salary_min': salaryMin,
        'salary_max': salaryMax,
        'currency': currency,
        'location': location,
        'remote_work': remoteWork,
        'status': status,
        'rejection_reason': rejectionReason,
        'deadline_at': deadlineAt,
        'approved_at': approvedAt,
        'approved_by': approvedBy,
        'views_count': viewsCount,
        'applications_count': applicationsCount,
        'created_at': createdAt,
      };

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isClosed => status == 'closed';

  String get salaryRange {
    if (salaryMin == null || salaryMax == null) return 'Not specified';
    return '$currency $salaryMin - $salaryMax';
  }
}
