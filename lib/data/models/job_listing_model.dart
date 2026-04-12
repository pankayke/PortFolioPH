class JobListingModel {
  final int? id;
  final String title;
  final String company;
  final String salary;
  final String location;
  final String description;
  final String category;
  final bool isFeatured;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  const JobListingModel({
    this.id,
    required this.title,
    required this.company,
    required this.salary,
    required this.location,
    required this.description,
    required this.category,
    this.isFeatured = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobListingModel.fromMap(Map<String, dynamic> map) {
    final salaryMin = map['salary_min'];
    final salaryMax = map['salary_max'];
    final parsedSalary = _toSalary(
      map['salary']?.toString(),
      min: salaryMin,
      max: salaryMax,
    );

    return JobListingModel(
      id: map['id'] as int?,
      title: _asString(map['title'], fallback: 'Untitled Job'),
      company: _asString(
        map['company'] ?? map['company_name'],
        fallback: 'PortfolioPH',
      ),
      salary: parsedSalary,
      location: _asString(map['location'], fallback: 'Remote'),
      description: _asString(
        map['description'],
        fallback: 'No description provided.',
      ),
      category: _asString(
        map['category'] ?? map['job_type'],
        fallback: 'General',
      ),
      isFeatured: _asBool(map['is_featured']),
      sortOrder: _asInt(map['sort_order']),
      createdAt: _asString(map['created_at']),
      updatedAt: _asString(map['updated_at']),
    );
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == '1' || normalized == 'true' || normalized == 'yes';
    }
    return false;
  }

  static String _toSalary(String? existing, {dynamic min, dynamic max}) {
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final minValue = _toDouble(min);
    final maxValue = _toDouble(max);
    if (minValue == null && maxValue == null) return 'Not specified';
    if (minValue != null && maxValue != null) {
      return 'PHP ${minValue.toStringAsFixed(0)} - ${maxValue.toStringAsFixed(0)}';
    }
    final value = minValue ?? maxValue!;
    return 'PHP ${value.toStringAsFixed(0)}';
  }

  static double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'company': company,
      'salary': salary,
      'location': location,
      'description': description,
      'category': category,
      'is_featured': isFeatured ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
