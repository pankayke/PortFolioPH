class StudentSkillsModel {
  final int? id;
  final int studentId;
  final String skillName;
  final String category;
  final int proficiency;
  final String dateAdded;
  final int projectsLinked;
  final String createdAt;
  final String updatedAt;

  const StudentSkillsModel({
    this.id,
    required this.studentId,
    required this.skillName,
    required this.category,
    this.proficiency = 3,
    required this.dateAdded,
    this.projectsLinked = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentSkillsModel.fromMap(Map<String, dynamic> map) {
    return StudentSkillsModel(
      id: map['id'] as int?,
      studentId: map['user_id'] as int,
      skillName: map['name'] as String,
      category: map['category'] as String,
      proficiency: map['proficiency'] as int? ?? 3,
      dateAdded: map['date_added'] as String,
      projectsLinked: map['projects_linked'] as int? ?? 0,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': studentId,
      'name': skillName,
      'category': category,
      'proficiency': proficiency,
      'date_added': dateAdded,
      'projects_linked': projectsLinked,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  StudentSkillsModel copyWith({
    int? id,
    int? studentId,
    String? skillName,
    String? category,
    int? proficiency,
    String? dateAdded,
    int? projectsLinked,
    String? createdAt,
    String? updatedAt,
  }) {
    return StudentSkillsModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      skillName: skillName ?? this.skillName,
      category: category ?? this.category,
      proficiency: proficiency ?? this.proficiency,
      dateAdded: dateAdded ?? this.dateAdded,
      projectsLinked: projectsLinked ?? this.projectsLinked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
