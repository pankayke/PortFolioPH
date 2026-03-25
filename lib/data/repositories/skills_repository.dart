import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/skills_model.dart';

class SkillsRepository {
  final DatabaseService _db;

  SkillsRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  Future<int> insert(SkillsModel skill) async {
    final db = await _db.getDatabase();
    return db.insert(
      'skills_tracker',
      skill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<SkillsModel>> findByUserId(int userId) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'skills_tracker',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_added DESC, name ASC',
    );
    return rows.map(SkillsModel.fromMap).toList();
  }

  Future<int> update(SkillsModel skill) async {
    final db = await _db.getDatabase();
    return db.update(
      'skills_tracker',
      skill.toMap(),
      where: 'id = ?',
      whereArgs: [skill.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.getDatabase();
    return db.delete('skills_tracker', where: 'id = ?', whereArgs: [id]);
  }
}
