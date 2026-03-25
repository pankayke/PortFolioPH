// lib/data/models/skills_model.dart
// Table: skills_tracker

class SkillsModel {
  final int? id;
  final int userId;
  final String name;
  final String category;
  final int proficiency; // 1 to 5
  final String dateAdded;
  final int projectsLinked;
  final String createdAt;
  final String updatedAt;

  const SkillsModel({
    this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.proficiency = 3,
    required this.dateAdded,
    this.projectsLinked = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SkillsModel.fromMap(Map<String, dynamic> map) => SkillsModel(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    name: map['name'] as String,
    category: map['category'] as String,
    proficiency: map['proficiency'] as int? ?? 3,
    dateAdded: map['date_added'] as String,
    projectsLinked: map['projects_linked'] as int? ?? 0,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'name': name,
    'category': category,
    'proficiency': proficiency,
    'date_added': dateAdded,
    'projects_linked': projectsLinked,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  SkillsModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? category,
    int? proficiency,
    String? dateAdded,
    int? projectsLinked,
    String? createdAt,
    String? updatedAt,
  }) => SkillsModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    category: category ?? this.category,
    proficiency: proficiency ?? this.proficiency,
    dateAdded: dateAdded ?? this.dateAdded,
    projectsLinked: projectsLinked ?? this.projectsLinked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
