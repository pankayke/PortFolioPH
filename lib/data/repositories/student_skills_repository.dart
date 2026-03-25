import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/student_skills_model.dart';

class StudentSkillsRepository {
  final DatabaseService _db;

  StudentSkillsRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  Future<int> insert(StudentSkillsModel skill) async {
    final db = await _db.getDatabase();
    return db.insert(
      'skills_tracker',
      skill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<StudentSkillsModel>> findByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'skills_tracker',
      where: 'user_id = ?',
      whereArgs: [studentId],
      orderBy: 'date_added DESC, name ASC',
    );
    return rows.map(StudentSkillsModel.fromMap).toList(growable: false);
  }

  Future<int> countByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM skills_tracker WHERE user_id = ?',
      [studentId],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> update(StudentSkillsModel skill) async {
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
