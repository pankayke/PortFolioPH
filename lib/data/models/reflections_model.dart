// lib/data/models/reflections_model.dart
// Table: reflections

class ReflectionModel {
  final int? id;
  final int userId;
  final int? projectId;
  final String title;
  final String content;
  final String mood;
  final String reflectionDate;
  final String createdAt;
  final String updatedAt;

  const ReflectionModel({
    this.id,
    required this.userId,
    this.projectId,
    required this.title,
    required this.content,
    this.mood = 'okay',
    required this.reflectionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReflectionModel.fromMap(Map<String, dynamic> map) => ReflectionModel(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    projectId: map['project_id'] as int?,
    title: map['title'] as String,
    content: map['content'] as String,
    mood: map['mood'] as String? ?? 'okay',
    reflectionDate: map['reflection_date'] as String,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'project_id': projectId,
    'title': title,
    'content': content,
    'mood': mood,
    'reflection_date': reflectionDate,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  ReflectionModel copyWith({
    int? id,
    int? userId,
    int? projectId,
    String? title,
    String? content,
    String? mood,
    String? reflectionDate,
    String? createdAt,
    String? updatedAt,
  }) => ReflectionModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    content: content ?? this.content,
    mood: mood ?? this.mood,
    reflectionDate: reflectionDate ?? this.reflectionDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
