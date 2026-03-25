class StudentEssayModel {
  final int? id;
  final int studentId;
  final String title;
  final String content;
  final String category;
  final String createdAt;
  final String updatedAt;

  const StudentEssayModel({
    this.id,
    required this.studentId,
    required this.title,
    required this.content,
    this.category = 'general',
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentEssayModel.fromMap(Map<String, dynamic> map) {
    return StudentEssayModel(
      id: map['id'] as int?,
      studentId: map['user_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String? ?? 'general',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': studentId,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  StudentEssayModel copyWith({
    int? id,
    int? studentId,
    String? title,
    String? content,
    String? category,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentEssayModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
