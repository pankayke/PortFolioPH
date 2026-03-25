import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

/// DatabaseService
///
/// Singleton service for SQLite database operations.
/// Manages database initialization, schema creation, and transactions.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static sqflite.Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Get database instance
  Future<sqflite.Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  /// Initialize database
  Future<sqflite.Database> _initializeDatabase() async {
    final databasePath = await sqflite.getDatabasesPath();
    final path = join(databasePath, 'portfolioph.db');

    return sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables on first initialization
  Future<void> _onCreate(sqflite.Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        bio TEXT,
        profile_image_url TEXT,
        location TEXT,
        github_url TEXT,
        linkedin_url TEXT,
        portfolio_url TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 2. App Settings Table
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE NOT NULL,
        app_language TEXT DEFAULT 'en',
        app_theme TEXT DEFAULT 'light',
        notifications_enabled INTEGER DEFAULT 1,
        auto_sync_enabled INTEGER DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 3. Theme Settings Table
    await db.execute('''
      CREATE TABLE theme_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE NOT NULL,
        primary_color TEXT,
        accent_color TEXT,
        background_color TEXT,
        text_color TEXT,
        font_family TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 4. Portfolios Table
    await db.execute('''
      CREATE TABLE portfolios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        slug TEXT UNIQUE,
        is_active INTEGER DEFAULT 1,
        is_public INTEGER DEFAULT 0,
        view_count INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_portfolios_user_id ON portfolios(user_id)',
    );

    // 5. Projects Table
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        portfolio_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        short_description TEXT,
        image_url TEXT,
        project_url TEXT,
        github_url TEXT,
        technologies TEXT,
        start_date DATETIME,
        end_date DATETIME,
        is_featured INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (portfolio_id) REFERENCES portfolios(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_projects_portfolio_id ON projects(portfolio_id)',
    );
    await db.execute('CREATE INDEX idx_projects_user_id ON projects(user_id)');

    // 6. Skills Table
    await db.execute('''
      CREATE TABLE skills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        category TEXT,
        proficiency_level TEXT,
        years_of_experience INTEGER,
        endorsement_count INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_skills_user_id ON skills(user_id)');

    // 7. Experience Table
    await db.execute('''
      CREATE TABLE experience (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        job_title TEXT NOT NULL,
        company_name TEXT NOT NULL,
        description TEXT,
        start_date DATETIME NOT NULL,
        end_date DATETIME,
        is_current_position INTEGER DEFAULT 0,
        employment_type TEXT,
        location TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_experience_user_id ON experience(user_id)',
    );

    // 8. Education Table
    await db.execute('''
      CREATE TABLE education (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        school_name TEXT NOT NULL,
        degree TEXT NOT NULL,
        field_of_study TEXT,
        start_date DATETIME NOT NULL,
        end_date DATETIME,
        grade TEXT,
        activities TEXT,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_education_user_id ON education(user_id)',
    );

    // 9. Certifications Table
    await db.execute('''
      CREATE TABLE certifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        issuer TEXT NOT NULL,
        issue_date DATETIME NOT NULL,
        expiration_date DATETIME,
        credential_id TEXT,
        credential_url TEXT,
        description TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_certifications_user_id ON certifications(user_id)',
    );

    // 10. Contacts Table
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        contact_type TEXT NOT NULL,
        contact_value TEXT NOT NULL,
        is_primary INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_contacts_user_id ON contacts(user_id)');

    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Handle database upgrades/migrations
  Future<void> _onUpgrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // TODO: Implement migration logic for future schema changes
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> executeQuery(String sql) async {
    final db = await database;
    return db.rawQuery(sql);
  }

  /// Execute raw SQL update
  Future<int> executeUpdate(String sql) async {
    final db = await database;
    return db.rawUpdate(sql);
  }

  /// Get database instance
  Future<sqflite.Database> getDatabase() async {
    return database;
  }

  /// Get singleton instance
  static DatabaseService getInstance() {
    return _instance;
  }

  /// Delete entire database (for debugging only)
  Future<void> deleteDatabase() async {
    final databasePath = await sqflite.getDatabasesPath();
    final path = join(databasePath, 'portfolioph.db');
    await sqflite.deleteDatabase(path);
    _database = null;
  }
}
