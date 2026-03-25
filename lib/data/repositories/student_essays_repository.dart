import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/student_essay_model.dart';

class StudentEssaysRepository {
  final DatabaseService _db;

  StudentEssaysRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  Future<int> insert(StudentEssayModel essay) async {
    final db = await _db.getDatabase();
    return db.insert(
      'essays',
      essay.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<StudentEssayModel>> findByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'essays',
      where: 'user_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC',
    );
    return rows.map(StudentEssayModel.fromMap).toList(growable: false);
  }

  Future<int> countByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM essays WHERE user_id = ?',
      [studentId],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> update(StudentEssayModel essay) async {
    final db = await _db.getDatabase();
    return db.update(
      'essays',
      essay.toMap(),
      where: 'id = ?',
      whereArgs: [essay.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.getDatabase();
    return db.delete('essays', where: 'id = ?', whereArgs: [id]);
  }
}
