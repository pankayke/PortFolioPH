// lib/features/recruiter/models/job_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job posting model with serialization.
// ─────────────────────────────────────────────────────────────────────────────

class Job {
  final int id;
  final String title;
  final String description;
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final String jobType;
  final List<String> requiredSkills;
  final String status;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int applicationCount;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    required this.jobType,
    required this.requiredSkills,
    required this.status,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.applicationCount = 0,
  });

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';
  bool get isArchived => status == 'archived';

  bool get isDeadlinePassed =>
      deadline != null && DateTime.now().isAfter(deadline!);

  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Competitive';
    if (salaryMin == null) return '\$${salaryMax?.toStringAsFixed(0)}';
    if (salaryMax == null) return '\$${salaryMin?.toStringAsFixed(0)}+';
    return '\$${salaryMin?.toStringAsFixed(0)} - \$${salaryMax?.toStringAsFixed(0)}';
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return double.tryParse(value.toString());
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

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: _asInt(json['id']),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      salaryMin: _asDouble(json['salary_min']),
      salaryMax: _asDouble(json['salary_max']),
        jobType: (json['job_type'] as String?) ?? 'full_time',
      requiredSkills:
          (json['required_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
        status: (json['status'] as String?) ?? 'open',
        deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
        applicationCount:
            _asInt(json['applications_count'], fallback: -1) >= 0
                ? _asInt(json['applications_count'])
                : _asInt(json['application_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'job_type': jobType,
    'required_skills': requiredSkills,
    'status': status,
    'deadline': deadline?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Job copyWith({
    int? id,
    String? title,
    String? description,
    String? location,
    double? salaryMin,
    double? salaryMax,
    String? jobType,
    List<String>? requiredSkills,
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
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
        jobType: jobType ?? this.jobType,
      requiredSkills: requiredSkills ?? this.requiredSkills,
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
