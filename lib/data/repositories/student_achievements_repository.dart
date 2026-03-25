import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/student_achievement_model.dart';

class StudentAchievementsRepository {
  final DatabaseService _db;

  StudentAchievementsRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  Future<int> insert(StudentAchievementModel achievement) async {
    final db = await _db.getDatabase();
    return db.insert(
      'achievements',
      achievement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<StudentAchievementModel>> findByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'achievements',
      where: 'user_id = ?',
      whereArgs: [studentId],
      orderBy: 'date_achieved DESC, created_at DESC',
    );
    return rows.map(StudentAchievementModel.fromMap).toList(growable: false);
  }

  Future<int> countByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM achievements WHERE user_id = ?',
      [studentId],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> delete(int id) async {
    final db = await _db.getDatabase();
    return db.delete('achievements', where: 'id = ?', whereArgs: [id]);
  }
}
