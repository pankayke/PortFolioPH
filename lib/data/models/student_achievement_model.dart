class StudentAchievementModel {
  final int? id;
  final int studentId;
  final String title;
  final String description;
  final String category;
  final String dateAchieved;
  final String createdAt;
  final String updatedAt;

  const StudentAchievementModel({
    this.id,
    required this.studentId,
    required this.title,
    required this.description,
    this.category = 'general',
    required this.dateAchieved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentAchievementModel.fromMap(Map<String, dynamic> map) {
    return StudentAchievementModel(
      id: map['id'] as int?,
      studentId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String? ?? 'general',
      dateAchieved: map['date_achieved'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': studentId,
      'title': title,
      'description': description,
      'category': category,
      'date_achieved': dateAchieved,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  StudentAchievementModel copyWith({
    int? id,
    int? studentId,
    String? title,
    String? description,
    String? category,
    String? dateAchieved,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentAchievementModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dateAchieved: dateAchieved ?? this.dateAchieved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
