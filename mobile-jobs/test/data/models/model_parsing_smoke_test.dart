import 'package:flutter_test/flutter_test.dart';
import 'package:job_platform/data/models/application_model.dart';
import 'package:job_platform/data/models/job_model.dart';

void main() {
  group('Mobile model parsing smoke tests', () {
    test('JobModel parses numeric string salary fields', () {
      final model = JobModel.fromJson({
        'id': 7,
        'recruiter_id': 13,
        'title': 'iOS Engineer',
        'description': 'Build native modules',
        'requirements': 'Swift',
        'job_type': 'full_time',
        'salary_min': '40000.50',
        'salary_max': '55000',
        'location': 'Cebu',
        'deadline_at': '2026-08-01T00:00:00Z',
        'created_at': '2026-04-09T00:00:00Z',
      });

      expect(model.salaryMin, 40000.5);
      expect(model.salaryMax, 55000.0);
      expect(model.salaryRange, contains('USD'));
    });

    test('ApplicationModel parses basic fields', () {
      final model = ApplicationModel.fromJson({
        'id': 12,
        'job_id': 7,
        'user_id': 99,
        'status': 'pending',
        'created_at': '2026-04-09T00:00:00Z',
      });

      expect(model.id, 12);
      expect(model.jobId, 7);
      expect(model.isPending, isTrue);
    });
  });
}
