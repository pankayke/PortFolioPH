import 'package:sqflite/sqflite.dart';

import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';

class JobFeedRepository {
  final DatabaseService _databaseService;

  JobFeedRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  Future<List<JobListingModel>> findAll() async {
    final db = await _databaseService.getDatabase();
    var rows = await db.query('jobs', orderBy: 'sort_order ASC, id ASC');
    if (rows.isEmpty) {
      await _seedIfEmpty(db);
      rows = await db.query('jobs', orderBy: 'sort_order ASC, id ASC');
    }

    return rows.map(JobListingModel.fromMap).toList(growable: false);
  }

  Future<int> countAll() async {
    final db = await _databaseService.getDatabase();
    final rows = await db.rawQuery('SELECT COUNT(*) AS count FROM jobs');
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> insert(JobListingModel job) async {
    final db = await _databaseService.getDatabase();
    return db.insert(
      'jobs',
      job.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _seedIfEmpty(Database db) async {
    final countRows = await db.rawQuery('SELECT COUNT(*) AS count FROM jobs');
    final count = (countRows.first['count'] as int?) ?? 0;
    if (count > 0) return;

    final now = DateTime.now().toUtc().toIso8601String();
    final seedJobs = <Map<String, dynamic>>[
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
        'created_at': now,
        'updated_at': now,
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
        'created_at': now,
        'updated_at': now,
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
        'created_at': now,
        'updated_at': now,
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
        'created_at': now,
        'updated_at': now,
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
        'created_at': now,
        'updated_at': now,
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
        'created_at': now,
        'updated_at': now,
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
        'created_at': now,
        'updated_at': now,
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
        'created_at': now,
        'updated_at': now,
      },
    ];

    final batch = db.batch();
    for (final job in seedJobs) {
      batch.insert('jobs', job, conflictAlgorithm: ConflictAlgorithm.abort);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }
}
