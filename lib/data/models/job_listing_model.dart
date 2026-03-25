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
    return JobListingModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      company: map['company'] as String,
      salary: map['salary'] as String,
      location: map['location'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
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
