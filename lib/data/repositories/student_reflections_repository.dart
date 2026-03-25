import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/student_reflections_model.dart';

class StudentReflectionsRepository {
  final DatabaseService _db;

  StudentReflectionsRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  Future<int> insert(StudentReflectionModel reflection) async {
    final db = await _db.getDatabase();
    return db.insert(
      'reflections',
      reflection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<StudentReflectionModel>> findByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'reflections',
      where: 'user_id = ?',
      whereArgs: [studentId],
      orderBy: 'reflection_date DESC, created_at DESC',
    );
    return rows.map(StudentReflectionModel.fromMap).toList(growable: false);
  }

  Future<int> countByStudentId(int studentId) async {
    final db = await _db.getDatabase();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM reflections WHERE user_id = ?',
      [studentId],
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> update(StudentReflectionModel reflection) async {
    final db = await _db.getDatabase();
    return db.update(
      'reflections',
      reflection.toMap(),
      where: 'id = ?',
      whereArgs: [reflection.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.getDatabase();
    return db.delete('reflections', where: 'id = ?', whereArgs: [id]);
  }
}
