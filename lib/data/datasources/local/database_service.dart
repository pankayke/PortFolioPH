import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/core/constants/app_constants.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  Database? _database;

  Future<Database> getDatabase() async {
    _database ??= await _open();
    return _database!;
  }

  Future<void> open() async {
    _database ??= await _open();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> _open() async {
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

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    for (int v = 1; v <= version; v++) {
      switch (v) {
        case 1:
          await _runMigration1(db);
          break;
        case 2:
          await _runMigration2(db);
          break;
        case 3:
          await _runMigration3(db);
          break;
        case 4:
          await _runMigration4(db);
          break;
        case 5:
          await _runMigration5(db);
          break;
      }
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      switch (v) {
        case 2:
          await _runMigration2(db);
          break;
        case 3:
          await _runMigration3(db);
          break;
        case 4:
          await _runMigration4(db);
          break;
        case 5:
          await _runMigration5(db);
          break;
      }
    }
  }

  Future<void> _runMigration1(Database db) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        username      TEXT    NOT NULL UNIQUE,
        email         TEXT    NOT NULL UNIQUE,
        role          TEXT    NOT NULL DEFAULT 'user',
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

  Future<void> _runMigration2(Database db) async {
    final batch = db.batch();

    final userColumns = await db.rawQuery('PRAGMA table_info(users)');
    final hasRoleColumn = userColumns.any((column) => column['name'] == 'role');
    if (!hasRoleColumn) {
      batch.execute(
        "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'",
      );
    }

    batch.execute('''
      CREATE TABLE IF NOT EXISTS reflections (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        project_id  INTEGER,
        title       TEXT    NOT NULL,
        content     TEXT    NOT NULL,
        mood        TEXT    NOT NULL DEFAULT 'okay',
        reflection_date TEXT NOT NULL,
        created_at  TEXT    NOT NULL,
        updated_at  TEXT    NOT NULL,
        FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');

    batch.execute('''
      CREATE TABLE IF NOT EXISTS skills_tracker (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id         INTEGER NOT NULL,
        name            TEXT    NOT NULL,
        category        TEXT    NOT NULL,
        proficiency     INTEGER NOT NULL DEFAULT 3,
        date_added      TEXT    NOT NULL,
        projects_linked INTEGER NOT NULL DEFAULT 0,
        created_at      TEXT    NOT NULL,
        updated_at      TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_reflections_user ON reflections(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_reflections_project ON reflections(project_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_skills_tracker_user ON skills_tracker(user_id)',
    );

    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> _runMigration3(Database db) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE IF NOT EXISTS achievements (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       INTEGER NOT NULL,
        title         TEXT    NOT NULL,
        description   TEXT    NOT NULL,
        category      TEXT    NOT NULL DEFAULT 'general',
        date_achieved TEXT    NOT NULL,
        created_at    TEXT    NOT NULL,
        updated_at    TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_achievements_user ON achievements(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_achievements_date ON achievements(date_achieved)',
    );

    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> _runMigration4(Database db) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE IF NOT EXISTS essays (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        title       TEXT    NOT NULL,
        content     TEXT    NOT NULL,
        category    TEXT    NOT NULL DEFAULT 'general',
        created_at  TEXT    NOT NULL,
        updated_at  TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_essays_user ON essays(user_id)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_essays_created_at ON essays(created_at)',
    );

    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> _runMigration5(Database db) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE IF NOT EXISTS jobs (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT    NOT NULL,
        company     TEXT    NOT NULL,
        salary      TEXT    NOT NULL,
        location    TEXT    NOT NULL,
        description TEXT    NOT NULL,
        category    TEXT    NOT NULL,
        is_featured INTEGER NOT NULL DEFAULT 0,
        sort_order  INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL,
        updated_at  TEXT    NOT NULL
      )
    ''');

    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_jobs_category ON jobs(category)',
    );
    batch.execute(
      'CREATE INDEX IF NOT EXISTS idx_jobs_sort_order ON jobs(sort_order)',
    );

    await batch.commit(noResult: true, continueOnError: true);

    final seedCheck = await db.rawQuery('SELECT COUNT(*) AS count FROM jobs');
    final existingCount = (seedCheck.first['count'] as int?) ?? 0;
    if (existingCount > 0) return;

    final seededAt = DateTime.now().toUtc().toIso8601String();
    final seedBatch = db.batch();

    final jobs = <Map<String, dynamic>>[
      {
        'title': 'Virtual Assistant',
        'company': 'RemoteBoss PH',
        'salary': '₱25k/mo',
        'location': 'Work from Home',
        'description':
            'Handle CEO emails and schedules. Perfect for fresh grads.',
        'category': 'Freelance',
        'is_featured': 1,
        'sort_order': 1,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
      {
        'title': 'Content Writer',
        'company': 'KMC Solutions',
        'salary': '₱30k/mo',
        'location': 'Cebu',
        'description':
            'Write social media posts and blogs for lifestyle brands.',
        'category': 'Creative',
        'is_featured': 1,
        'sort_order': 2,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
      {
        'title': 'OJT Marketing Intern',
        'company': 'Cebu Pacific',
        'salary': '₱8k stipend',
        'location': 'Mactan',
        'description': '3-month internship with campaign and events exposure.',
        'category': 'Fresh Grad / OJT',
        'is_featured': 0,
        'sort_order': 3,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
      {
        'title': 'Customer Service Associate',
        'company': 'Concentrix Cebu',
        'salary': '₱22k/mo + benefits',
        'location': 'Cebu IT Park',
        'description':
            'Night-shift friendly role with communication allowance.',
        'category': 'BPO / Support',
        'is_featured': 0,
        'sort_order': 4,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
      {
        'title': 'Freelance Graphic Designer',
        'company': 'CreativeHub PH',
        'salary': '₱15k–₱50k/project',
        'location': 'Cebu',
        'description': 'Logo + social media kit design for MSME clients.',
        'category': 'Freelance',
        'is_featured': 0,
        'sort_order': 5,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
      {
        'title': 'Sales Executive',
        'company': 'Jollibee Foods Corp.',
        'salary': '₱18k + commission',
        'location': 'Metro malls',
        'description': 'Handle B2B accounts and retail partnerships.',
        'category': 'Sales',
        'is_featured': 0,
        'sort_order': 6,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
      {
        'title': 'Admin Assistant',
        'company': 'SMC Shared Services',
        'salary': '₱28k/mo',
        'location': 'Cebu IT Park',
        'description': 'Calendar, documentation, and operations support.',
        'category': 'Admin',
        'is_featured': 0,
        'sort_order': 7,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
      {
        'title': 'Food Delivery Rider',
        'company': 'Grab',
        'salary': 'Daily payout',
        'location': 'Nationwide',
        'description':
            'Flexible schedule. Motorbike and valid license required.',
        'category': 'Gig Work',
        'is_featured': 0,
        'sort_order': 8,
        'created_at': seededAt,
        'updated_at': seededAt,
      },
    ];

    for (final job in jobs) {
      seedBatch.insert('jobs', job, conflictAlgorithm: ConflictAlgorithm.abort);
    }

    await seedBatch.commit(noResult: true);
  }
}
