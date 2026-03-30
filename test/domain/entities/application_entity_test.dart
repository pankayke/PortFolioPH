// test/domain/entities/application_entity_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolioph/domain/entities/index.dart';

void main() {
  group('ApplicationEntity', () {
    final now = DateTime.now();

    final testApplication = ApplicationEntity(
      id: 1,
      jobId: 1,
      jobSeekerId: 1,
      status: ApplicationStatus.pending,
      coverLetter: 'I am interested in this role',
      createdAt: now,
      updatedAt: now,
    );

    test('should create application entity with required fields', () {
      expect(testApplication.id, 1);
      expect(testApplication.jobId, 1);
      expect(testApplication.jobSeekerId, 1);
      expect(testApplication.status, ApplicationStatus.pending);
    });

    test('should have equality based on all properties', () {
      final app1 = testApplication;
      final app2 = testApplication;
      expect(app1, app2);
    });

    test('should differ when properties change', () {
      final app1 = testApplication;
      final app2 = testApplication.copyWith(id: 2);
      expect(app1 == app2, false);
    });

    test('should support different application statuses', () {
      expect(
        testApplication.copyWith(status: ApplicationStatus.pending).status,
        ApplicationStatus.pending,
      );
      expect(
        testApplication.copyWith(status: ApplicationStatus.reviewed).status,
        ApplicationStatus.reviewed,
      );
      expect(
        testApplication.copyWith(status: ApplicationStatus.accepted).status,
        ApplicationStatus.accepted,
      );
      expect(
        testApplication.copyWith(status: ApplicationStatus.rejected).status,
        ApplicationStatus.rejected,
      );
    });

    test('should allow optional cover letter', () {
      expect(testApplication.coverLetter, 'I am interested in this role');

      final noLetterApp = testApplication.copyWith(coverLetter: null);
      expect(noLetterApp.coverLetter, null);
    });

    test('should track timestamps', () {
      final olderNow = now.subtract(const Duration(hours: 1));
      expect(testApplication.createdAt.isAfter(olderNow), true);
    });

    test('should link to job and job seeker', () {
      expect(testApplication.jobId, 1);
      expect(testApplication.jobSeekerId, 1);
    });

    test('should support status transitions', () {
      var app = testApplication;

      // pending -> reviewed
      app = app.copyWith(status: ApplicationStatus.reviewed);
      expect(app.status, ApplicationStatus.reviewed);

      // reviewed -> accepted
      app = app.copyWith(status: ApplicationStatus.accepted);
      expect(app.status, ApplicationStatus.accepted);
    });

    test('should support rejection after review', () {
      var app = testApplication;

      app = app.copyWith(status: ApplicationStatus.reviewed);
      expect(app.status, ApplicationStatus.reviewed);

      app = app.copyWith(status: ApplicationStatus.rejected);
      expect(app.status, ApplicationStatus.rejected);
    });

    test('should handle long cover letters', () {
      final longLetter = 'A' * 5000;
      final app = testApplication.copyWith(coverLetter: longLetter);
      expect(app.coverLetter!.length, 5000);
    });

    test('should parse ApplicationStatus from string', () {
      expect(
        ApplicationStatus.fromString('pending'),
        ApplicationStatus.pending,
      );
      expect(
        ApplicationStatus.fromString('reviewed'),
        ApplicationStatus.reviewed,
      );
      expect(
        ApplicationStatus.fromString('accepted'),
        ApplicationStatus.accepted,
      );
      expect(
        ApplicationStatus.fromString('rejected'),
        ApplicationStatus.rejected,
      );
      expect(
        ApplicationStatus.fromString('invalid'),
        ApplicationStatus.pending,
      ); // default
    });
  });
}

extension _ApplicationEntityCopyWith on ApplicationEntity {
  ApplicationEntity copyWith({
    int? id,
    int? jobId,
    int? jobSeekerId,
    ApplicationStatus? status,
    String? coverLetter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ApplicationEntity(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    jobSeekerId: jobSeekerId ?? this.jobSeekerId,
    status: status ?? this.status,
    coverLetter: coverLetter ?? this.coverLetter,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
