import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';

void main() {
  group('Recruiter Job.fromJson', () {
    test('parses salary and counters from numeric strings', () {
      final job = Job.fromJson({
        'id': '101',
        'title': 'Senior Flutter Developer',
        'description': 'Build production Flutter applications',
        'location': 'Makati City',
        'salary_min': '234124.00',
        'salary_max': '300000',
        'job_type': 'full_time',
        'required_skills': ['Flutter', 'Dart'],
        'status': 'active',
        'deadline': '2026-05-01T00:00:00Z',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-02T00:00:00Z',
        'applications_count': '7',
      });

      expect(job.id, 101);
      expect(job.salaryMin, 234124.0);
      expect(job.salaryMax, 300000.0);
      expect(job.applicationCount, 7);
      expect(job.requiredSkills, ['Flutter', 'Dart']);
    });

    test(
      'falls back to application_count when applications_count is missing',
      () {
        final job = Job.fromJson({
          'id': 12,
          'title': 'Backend Engineer',
          'description': 'Maintain APIs',
          'location': 'Remote',
          'salary_min': 60000,
          'salary_max': 90000,
          'job_type': 'contract',
          'required_skills': const [],
          'status': 'active',
          'created_at': '2026-04-01T00:00:00Z',
          'updated_at': '2026-04-02T00:00:00Z',
          'application_count': '11',
        });

        expect(job.applicationCount, 11);
      },
    );
  });

  group('RecruiterApplication.fromJson', () {
    test('parses ids from mixed numeric formats and nested user data', () {
      final application = RecruiterApplication.fromJson({
        'id': '44',
        'job_id': '1001',
        'user_id': '502',
        'status': 'pending',
        'resume_url': 'https://cdn.example.com/resume.pdf',
        'cover_letter': 'Looking forward to this role',
        'interview_date': '2026-06-10T09:00:00Z',
        'notes': 'Strong portfolio',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-02T00:00:00Z',
        'user': {
          'name': 'Ari Santos',
          'email': 'ari@example.com',
          'phone_number': '+639171234567',
          'location': 'Quezon City',
        },
      });

      expect(application.id, 44);
      expect(application.jobId, 1001);
      expect(application.userId, 502);
      expect(application.applicantName, 'Ari Santos');
      expect(application.applicantEmail, 'ari@example.com');
      expect(application.applicantPhone, '+639171234567');
      expect(application.applicantLocation, 'Quezon City');
      expect(application.isReviewing, isTrue);
    });
  });
}
