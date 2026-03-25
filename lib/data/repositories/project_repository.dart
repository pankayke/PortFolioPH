// lib/data/repositories/project_repository.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:sqflite/sqflite.dart';
import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/project_model.dart';

class ProjectRepository {
  final DatabaseService _db;
  bool _schemaEnsured = false;

  ProjectRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  Future<int> insert(ProjectModel project) async {
    await _ensureSchema();
    final db = await _db.getDatabase();
    return db.insert(
      'projects',
      project.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<ProjectModel?> findById(int id) async {
    await _ensureSchema();
    final db = await _db.getDatabase();
    final rows = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ProjectModel.fromMap(rows.first);
  }

  Future<List<ProjectModel>> findByPortfolioId(
    int portfolioId, {
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    await _ensureSchema();
    final db = await _db.getDatabase();
    final hasSearch = searchQuery != null && searchQuery.trim().isNotEmpty;
    final trimmedQuery = searchQuery?.trim();

    final rows = await db.query(
      'projects',
      where: hasSearch
          ? '''
            portfolio_id = ?
            AND (
              LOWER(title) LIKE LOWER(?)
              OR LOWER(COALESCE(description, '')) LIKE LOWER(?)
              OR LOWER(COALESCE(tech_stack, '')) LIKE LOWER(?)
            )
          '''
          : 'portfolio_id = ?',
      whereArgs: hasSearch
          ? [
              portfolioId,
              '%$trimmedQuery%',
              '%$trimmedQuery%',
              '%$trimmedQuery%',
            ]
          : [portfolioId],
      orderBy: 'sort_order ASC, created_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(ProjectModel.fromMap).toList();
  }

  Future<List<ProjectModel>> findFeaturedByUserId(int userId) async {
    await _ensureSchema();
    final db = await _db.getDatabase();
    final rows = await db.query(
      'projects',
      where: 'user_id = ? AND is_featured = 1',
      whereArgs: [userId],
      orderBy: 'sort_order ASC',
    );
    return rows.map(ProjectModel.fromMap).toList();
  }

  Future<int> update(ProjectModel project) async {
    await _ensureSchema();
    final db = await _db.getDatabase();
    return db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> delete(int id) async {
    await _ensureSchema();
    final db = await _db.getDatabase();
    return db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _ensureSchema() async {
    if (_schemaEnsured) return;

    final db = await _db.getDatabase();
    final columns = await db.rawQuery('PRAGMA table_info(projects)');
    final hasImagePaths = columns.any((c) => c['name'] == 'image_paths');

    if (!hasImagePaths) {
      await db.execute('ALTER TABLE projects ADD COLUMN image_paths TEXT');
    }

    _schemaEnsured = true;
  }
}
