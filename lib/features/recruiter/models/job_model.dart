// lib/features/recruiter/models/job_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job posting model with serialization.
// ─────────────────────────────────────────────────────────────────────────────

class Job {
  final int id;
  final String title;
  final String description;
  final String category;
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final String employmentType;
  final String experienceLevel;
  final String companyName;
  final List<String> requiredSkills;
  final String? requiredQualifications;
  final String status;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int applicationCount;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    required this.employmentType,
    required this.experienceLevel,
    required this.companyName,
    required this.requiredSkills,
    this.requiredQualifications,
    required this.status,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.applicationCount = 0,
  });

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';
  bool get isArchived => status == 'archived';

  bool get isDeadlinePassed => DateTime.now().isAfter(deadline);

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Competitive';
    if (salaryMin == null) return '\$${salaryMax?.toStringAsFixed(0)}';
    if (salaryMax == null) return '\$${salaryMin?.toStringAsFixed(0)}+';
    return '\$${salaryMin?.toStringAsFixed(0)} - \$${salaryMax?.toStringAsFixed(0)}';
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      salaryMin: (json['salary_min'] as num?)?.toDouble(),
      salaryMax: (json['salary_max'] as num?)?.toDouble(),
      employmentType: json['employment_type'] as String,
      experienceLevel: json['experience_level'] as String,
      companyName: json['company_name'] as String,
      requiredSkills:
          (json['required_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      requiredQualifications: json['required_qualifications'] as String?,
      status: json['status'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      applicationCount: json['application_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'employment_type': employmentType,
    'experience_level': experienceLevel,
    'company_name': companyName,
    'required_skills': requiredSkills,
    'required_qualifications': requiredQualifications,
    'status': status,
    'deadline': deadline.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Job copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? location,
    double? salaryMin,
    double? salaryMax,
    String? employmentType,
    String? experienceLevel,
    String? companyName,
    List<String>? requiredSkills,
    String? requiredQualifications,
    String? status,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? applicationCount,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      employmentType: employmentType ?? this.employmentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      companyName: companyName ?? this.companyName,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      requiredQualifications:
          requiredQualifications ?? this.requiredQualifications,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicationCount: applicationCount ?? this.applicationCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Job && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
