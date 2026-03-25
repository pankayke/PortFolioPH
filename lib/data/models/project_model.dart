// lib/data/models/project_model.dart
// Table: projects  (many-to-one with portfolios)
// ─────────────────────────────────────────────────────────────────────────────

class ProjectModel {
  final int? id;
  final int portfolioId;
  final int userId;
  final String title;
  final String? description;
  final String? techStack; // comma-separated list
  final String? repositoryUrl;
  final String? liveDemoUrl;
  final String? thumbnailPath;
  final List<String> imagePaths;
  final String? startDate;
  final String? endDate;
  final bool isFeatured;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  const ProjectModel({
    this.id,
    required this.portfolioId,
    required this.userId,
    required this.title,
    this.description,
    this.techStack,
    this.repositoryUrl,
    this.liveDemoUrl,
    this.thumbnailPath,
    this.imagePaths = const [],
    this.startDate,
    this.endDate,
    this.isFeatured = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
    id: map['id'] as int?,
    portfolioId: map['portfolio_id'] as int,
    userId: map['user_id'] as int,
    title: map['title'] as String,
    description: map['description'] as String?,
    techStack: map['tech_stack'] as String?,
    repositoryUrl: map['repository_url'] as String?,
    liveDemoUrl: map['live_demo_url'] as String?,
    thumbnailPath: map['thumbnail_path'] as String?,
    imagePaths: _decodeImagePaths(map['image_paths'] as String?),
    startDate: map['start_date'] as String?,
    endDate: map['end_date'] as String?,
    isFeatured: (map['is_featured'] as int? ?? 0) == 1,
    sortOrder: map['sort_order'] as int? ?? 0,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'portfolio_id': portfolioId,
    'user_id': userId,
    'title': title,
    'description': description,
    'tech_stack': techStack,
    'repository_url': repositoryUrl,
    'live_demo_url': liveDemoUrl,
    'thumbnail_path': thumbnailPath,
    'image_paths': _encodeImagePaths(imagePaths),
    'start_date': startDate,
    'end_date': endDate,
    'is_featured': isFeatured ? 1 : 0,
    'sort_order': sortOrder,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  ProjectModel copyWith({
    int? id,
    int? portfolioId,
    int? userId,
    String? title,
    String? description,
    String? techStack,
    String? repositoryUrl,
    String? liveDemoUrl,
    String? thumbnailPath,
    List<String>? imagePaths,
    String? startDate,
    String? endDate,
    bool? isFeatured,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
  }) => ProjectModel(
    id: id ?? this.id,
    portfolioId: portfolioId ?? this.portfolioId,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    techStack: techStack ?? this.techStack,
    repositoryUrl: repositoryUrl ?? this.repositoryUrl,
    liveDemoUrl: liveDemoUrl ?? this.liveDemoUrl,
    thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    imagePaths: imagePaths ?? this.imagePaths,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    isFeatured: isFeatured ?? this.isFeatured,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() =>
      'ProjectModel(id: $id, portfolioId: $portfolioId, title: $title)';

  static List<String> _decodeImagePaths(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split('|||')
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);
  }

  static String? _encodeImagePaths(List<String> paths) {
    if (paths.isEmpty) return null;
    return paths.join('|||');
  }
}
