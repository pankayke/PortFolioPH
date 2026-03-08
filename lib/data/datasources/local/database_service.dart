// lib/data/datasources/local/database_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// SQLite database service – Singleton pattern.
// Manages database lifecycle: open, close, get, migrate.
//
// Tables (10 total, Sprint 1 schema – version 1):
//   1. users
//   2. portfolios
//   3. projects
//   4. skills
//   5. education
//   6. work_experience
//   7. certifications
//   8. contacts
//   9. theme_settings
//  10. app_settings
//
// Rules enforced:
//   - Parameterised SQL only (no string concatenation for user data)
//   - Foreign keys enabled on every connection
//   - migrate() is called inside onUpgrade for future versions
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/core/constants/app_constants.dart';

class DatabaseService {
  // ── Singleton boilerplate ─────────────────────────────────────────────────────
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  Database? _database;

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Returns the open database. Opens it on first call (lazy init).
  /// On web the database is backed by IndexedDB via [databaseFactoryFfiWeb].
  Future<Database> getDatabase() async {
    _database ??= await _open();
    return _database!;
  }

  /// Explicitly opens the database (idempotent).
  Future<void> open() async {
    _database ??= await _open();
  }

  /// Closes the database connection.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  // ── Private – open & schema ───────────────────────────────────────────────────

  Future<Database> _open() async {
    // On web, sqflite_common_ffi_web uses IndexedDB; a bare filename is the
    // database key. On native platforms, use the documents directory.
    final String path;
    if (kIsWeb) {
      path = AppConstants.dbName;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, AppConstants.dbName);
    }

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Enable foreign key enforcement on every new connection.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Called once when the database file is first created.
  Future<void> _onCreate(Database db, int version) async {
    await _runMigration1(db);
  }

  /// Called when the stored version < [version]. Apply incremental patches.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      switch (v) {
        case 2:
          // TODO(sprint-N): add await _runMigration2(db);
          break;
      }
    }
  }

  // ── Migration 1 – initial schema ──────────────────────────────────────────────

  Future<void> _runMigration1(Database db) async {
    final batch = db.batch();

    // ── Table 1: users ──────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        username      TEXT    NOT NULL UNIQUE,
        email         TEXT    NOT NULL UNIQUE,
        password_hash TEXT    NOT NULL,
        full_name     TEXT,
        bio           TEXT,
        avatar_path   TEXT,
        phone_number  TEXT,
        location      TEXT,
        website_url   TEXT,
        created_at    TEXT    NOT NULL,
        updated_at    TEXT    NOT NULL
      )
    ''');

    // ── Table 2: portfolios ─────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS portfolios (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER NOT NULL,
        title        TEXT    NOT NULL,
        summary      TEXT,
        template_id  TEXT,
        is_public    INTEGER NOT NULL DEFAULT 0,
        custom_url   TEXT,
        created_at   TEXT    NOT NULL,
        updated_at   TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ── Table 3: projects ────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        portfolio_id    INTEGER NOT NULL,
        user_id         INTEGER NOT NULL,
        title           TEXT    NOT NULL,
        description     TEXT,
        tech_stack      TEXT,
        repository_url  TEXT,
        live_demo_url   TEXT,
        thumbnail_path  TEXT,
        start_date      TEXT,
        end_date        TEXT,
        is_featured     INTEGER NOT NULL DEFAULT 0,
        sort_order      INTEGER NOT NULL DEFAULT 0,
        created_at      TEXT    NOT NULL,
        updated_at      TEXT    NOT NULL,
        FOREIGN KEY (portfolio_id) REFERENCES portfolios(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id)      REFERENCES users(id)      ON DELETE CASCADE
      )
    ''');

    // ── Table 4: skills ────────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS skills (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id             INTEGER NOT NULL,
        name                TEXT    NOT NULL,
        category            TEXT    NOT NULL,
        level               TEXT    NOT NULL DEFAULT 'intermediate',
        years_of_experience INTEGER NOT NULL DEFAULT 0,
        sort_order          INTEGER NOT NULL DEFAULT 0,
        created_at          TEXT    NOT NULL,
        updated_at          TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ── Table 5: education ─────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS education (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id        INTEGER NOT NULL,
        institution    TEXT    NOT NULL,
        degree         TEXT    NOT NULL,
        field_of_study TEXT    NOT NULL,
        description    TEXT,
        grade          TEXT,
        start_date     TEXT,
        end_date       TEXT,
        is_current     INTEGER NOT NULL DEFAULT 0,
        sort_order     INTEGER NOT NULL DEFAULT 0,
        created_at     TEXT    NOT NULL,
        updated_at     TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ── Table 6: work_experience ───────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS work_experience (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id          INTEGER NOT NULL,
        company          TEXT    NOT NULL,
        job_title        TEXT    NOT NULL,
        employment_type  TEXT,
        location         TEXT,
        description      TEXT,
        start_date       TEXT,
        end_date         TEXT,
        is_current       INTEGER NOT NULL DEFAULT 0,
        sort_order       INTEGER NOT NULL DEFAULT 0,
        created_at       TEXT    NOT NULL,
        updated_at       TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ── Table 7: certifications ────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS certifications (
        id                   INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id              INTEGER NOT NULL,
        name                 TEXT    NOT NULL,
        issuing_organization TEXT    NOT NULL,
        credential_id        TEXT,
        credential_url       TEXT,
        issue_date           TEXT,
        expiry_date          TEXT,
        does_expire          INTEGER NOT NULL DEFAULT 1,
        image_path           TEXT,
        sort_order           INTEGER NOT NULL DEFAULT 0,
        created_at           TEXT    NOT NULL,
        updated_at           TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ── Table 8: contacts ──────────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       INTEGER NOT NULL,
        platform      TEXT    NOT NULL,
        url           TEXT    NOT NULL,
        display_label TEXT,
        sort_order    INTEGER NOT NULL DEFAULT 0,
        created_at    TEXT    NOT NULL,
        updated_at    TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ── Table 9: theme_settings ────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS theme_settings (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id           INTEGER NOT NULL UNIQUE,
        theme_mode        TEXT    NOT NULL DEFAULT 'system',
        primary_color_hex TEXT,
        updated_at        TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ── Table 10: app_settings ─────────────────────────────────────────────────
    batch.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       INTEGER NOT NULL,
        setting_key   TEXT    NOT NULL,
        setting_value TEXT    NOT NULL,
        updated_at    TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE (user_id, setting_key)
      )
    ''');

    // ── Indexes ────────────────────────────────────────────────────────────────
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_portfolios_user ON portfolios(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_projects_portfolio ON projects(portfolio_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_skills_user ON skills(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_education_user ON education(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_experience_user ON work_experience(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_certifications_user ON certifications(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_contacts_user ON contacts(user_id)',
    );

    await batch.commit(noResult: true);
  }
}
