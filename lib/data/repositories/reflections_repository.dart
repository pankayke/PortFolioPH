import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/reflections_model.dart';

class ReflectionsRepository {
  final DatabaseService _db;

  ReflectionsRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  Future<int> insert(ReflectionModel reflection) async {
    final db = await _db.getDatabase();
    return db.insert(
      'reflections',
      reflection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<ReflectionModel>> findByUserId(int userId) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'reflections',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'reflection_date DESC, created_at DESC',
    );
    return rows.map(ReflectionModel.fromMap).toList();
  }

  Future<int> update(ReflectionModel reflection) async {
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
