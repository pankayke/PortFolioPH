import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/features/seeker/models/seeker_application_model.dart';
import 'package:portfolioph/features/seeker/models/seeker_job_model.dart';

void main() {
  group('SeekerJob.fromJson', () {
    test('normalizes snake_case payload and numeric strings', () {
      final job = SeekerJob.fromJson({
        'id': '200',
        'recruiter_id': '77',
        'recruiter_name': 'TechCorp',
        'recruiter_logo': 'https://cdn.example.com/logo.png',
        'title': 'Mobile Engineer',
        'description': 'Build and ship high-quality apps',
        'category': 'Engineering',
        'location': 'Taguig',
        'salary_min': '50000.50',
        'salary_max': '85000',
        'employment_type': 'full_time',
        'experience_level': 'mid',
        'required_skills': ['Flutter', 'REST', 123],
        'required_qualifications': 'BS Computer Science',
        'deadline': '2026-07-01T00:00:00Z',
        'total_applications': '19',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-02T00:00:00Z',
        'application_status': 'applied',
        'is_saved': '1',
      });

      expect(job.id, 200);
      expect(job.recruiterId, 77);
      expect(job.salaryMin, 50000.5);
      expect(job.salaryMax, 85000.0);
      expect(job.totalApplications, 19);
      expect(job.requiredSkills, ['Flutter', 'REST', '123']);
      expect(job.applicationStatus, 'applied');
      expect(job.isSaved, isTrue);
    });

    test('supports camelCase payload fields', () {
      final job = SeekerJob.fromJson({
        'id': 201,
        'recruiterId': 90,
        'recruiterName': 'DesignHub',
        'recruiterLogo': '',
        'title': 'UX Writer',
        'description': 'Create clear product copy',
        'category': 'Design',
        'location': 'Remote',
        'employmentType': 'part_time',
        'experienceLevel': 'entry',
        'requiredSkills': const ['Writing'],
        'deadline': '2026-08-01T00:00:00Z',
        'totalApplications': 0,
        'createdAt': '2026-04-01T00:00:00Z',
        'updatedAt': '2026-04-02T00:00:00Z',
      });

      expect(job.id, 201);
      expect(job.recruiterId, 90);
      expect(job.requiredSkills, ['Writing']);
      expect(job.applicationStatus, 'none');
      expect(job.isSaved, isFalse);
    });

    test('falls back to nested recruiter and job_type aliases', () {
      final job = SeekerJob.fromJson({
        'id': 202,
        'title': 'Platform Engineer',
        'description': 'Maintain platform reliability',
        'category': 'Engineering',
        'location': 'Makati',
        'job_type': 'contract',
        'required_skills': const ['Terraform'],
        'deadline': '2026-08-01T00:00:00Z',
        'applications_count': 14,
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-02T00:00:00Z',
        'recruiter': {
          'id': 11,
          'name': 'Infra Corp',
          'logo': 'https://cdn.example.com/infra.png',
        },
      });

      expect(job.recruiterId, 11);
      expect(job.recruiterName, 'Infra Corp');
      expect(job.recruiterLogo, 'https://cdn.example.com/infra.png');
      expect(job.employmentType, 'contract');
      expect(job.totalApplications, 14);
    });
  });

  group('SeekerApplication.fromJson', () {
    test('normalizes mixed naming and parses numeric strings', () {
      final application = SeekerApplication.fromJson({
        'id': '900',
        'job_id': '222',
        'job_title': 'Frontend Developer',
        'recruiter_name': 'BuildLabs',
        'recruiter_logo': '',
        'job_location': 'BGC',
        'salary_min': '35000',
        'salary_max': '55000.25',
        'status': 'reviewing',
        'notes': 'Initial screening done',
        'interview_date': '2026-06-03T10:00:00Z',
        'interview_location': 'Video Call',
        'video_interview_link': 'https://meet.example.com/abc',
        'applied_at': '2026-04-05T00:00:00Z',
        'updated_at': '2026-04-06T00:00:00Z',
      });

      expect(application.id, 900);
      expect(application.jobId, 222);
      expect(application.salaryMin, 35000.0);
      expect(application.salaryMax, 55000.25);
      expect(application.status, 'reviewing');
      expect(application.hasInterview, isTrue);
      expect(application.videoInterviewLink, 'https://meet.example.com/abc');
    });

    test('falls back to nested job and recruiter payload', () {
      final application = SeekerApplication.fromJson({
        'id': 901,
        'status': 'applied',
        'applied_at': '2026-04-10T00:00:00Z',
        'job': {
          'id': 303,
          'title': 'SRE',
          'location': 'Remote',
          'salary_min': 70000,
          'salary_max': 110000,
          'recruiter': {
            'name': 'Ops Team',
            'logo': 'https://cdn.example.com/ops.png',
          },
        },
      });

      expect(application.jobId, 303);
      expect(application.jobTitle, 'SRE');
      expect(application.jobLocation, 'Remote');
      expect(application.salaryMin, 70000);
      expect(application.salaryMax, 110000);
      expect(application.recruiterName, 'Ops Team');
      expect(application.recruiterLogo, 'https://cdn.example.com/ops.png');
    });
  });
}
