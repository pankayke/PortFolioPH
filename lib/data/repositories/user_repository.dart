// lib/data/repositories/user_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Data-layer repository for the `users` table.
// All SQL is parameterised. No business logic here – that belongs in use-cases.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:sqflite/sqflite.dart';
import 'package:portfolioph/core/utils/helpers.dart';
import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/user_model.dart';

class UserRepository {
  final DatabaseService _db;

  UserRepository({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  // ── Create ──────────────────────────────────────────────────────────────────
  Future<int> insert(UserModel user) async {
    final db = await _db.getDatabase();
    return db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ── Read ────────────────────────────────────────────────────────────────────
  Future<UserModel?> findById(int id) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel?> findByEmail(String email) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel?> findByUsername(String username) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<List<UserModel>> findByRoles(List<String> roles) async {
    if (roles.isEmpty) return const [];

    final db = await _db.getDatabase();
    final normalizedRoles = roles
        .map((role) => role.trim().toLowerCase())
        .where((role) => role.isNotEmpty)
        .toList(growable: false);

    if (normalizedRoles.isEmpty) return const [];

    final placeholders = List.filled(normalizedRoles.length, '?').join(', ');
    final rows = await db.query(
      'users',
      where: 'LOWER(role) IN ($placeholders)',
      whereArgs: normalizedRoles,
      orderBy: 'COALESCE(full_name, username) ASC',
    );

    return rows.map(UserModel.fromMap).toList(growable: false);
  }

  /// Verifies [plainPassword] against the stored hash for [email].
  /// Returns the [UserModel] on success, `null` on failure.
  Future<UserModel?> authenticate({
    required String email,
    required String plainPassword,
  }) async {
    final user = await findByEmail(email);
    if (user == null) return null;
    final hash = AppHelpers.hashPassword(plainPassword);
    if (user.passwordHash != hash) return null;
    return user;
  }

  Future<bool> hasUsersWithRole(String role) async {
    final db = await _db.getDatabase();
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'role = ?',
      whereArgs: [role],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<UserModel> promoteToAdmin(UserModel user) async {
    final elevatedUser = user.copyWith(role: 'admin');
    await update(elevatedUser);
    return elevatedUser;
  }

  Future<UserModel?> createIfMissingByEmail(UserModel user) async {
    final existingUser = await findByEmail(user.email);
    if (existingUser != null) {
      return existingUser;
    }

    final id = await insert(user);
    return user.copyWith(id: id);
  }

  // ── Update ──────────────────────────────────────────────────────────────────
  Future<int> update(UserModel user) async {
    final db = await _db.getDatabase();
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ── Delete ──────────────────────────────────────────────────────────────────
  Future<int> delete(int id) async {
    final db = await _db.getDatabase();
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
