// test/providers/job_feed_provider_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Tests for JobFeedProvider with online-only, real-time polling.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';
import 'package:portfolioph/data/repositories/job_feed_repository.dart';
import 'package:portfolioph/data/services/job_matching_service.dart';
import 'package:portfolioph/presentation/providers/job_feed_provider.dart';

class MockJobFeedRepository extends Mock implements JobFeedRepository {}

class MockJobMatchingService extends Mock implements JobMatchingService {}

void main() {
  group('JobFeedProvider', () {
    late JobFeedProvider provider;
    late MockJobFeedRepository mockRepository;
    late MockJobMatchingService mockMatchingService;

    setUp(() {
      mockRepository = MockJobFeedRepository();
      mockMatchingService = MockJobMatchingService();
      provider = JobFeedProvider(
        repository: mockRepository,
        matchingService: mockMatchingService,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state is empty', () {
      expect(provider.jobs, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
      expect(provider.isPollingActive, false);
    });

    test('loadJobs fetches from API', () async {
      final mockJobs = [
        JobListingModel(
          id: 1,
          title: 'Test Job',
          company: 'Test Co',
          salary: '₱25k',
          location: 'Remote',
          description: 'Test description',
          category: 'IT',
          isFeatured: false,
          sortOrder: 1,
        ),
      ];

      when(mockRepository.findAll()).thenAnswer((_) async => mockJobs);

      expect(provider.isLoading, false);

      await provider.loadJobs();

      expect(provider.jobs, hasLength(1));
      expect(provider.jobs[0].title, 'Test Job');
      expect(provider.isLoading, false);
      verify(mockRepository.findAll()).called(1);
    });

    test('loadJobs handles errors gracefully', () async {
      when(mockRepository.findAll()).thenThrow(Exception('Network error'));

      await provider.loadJobs();

      expect(provider.jobs, isEmpty);
      expect(provider.errorMessage, isNotNull);
      expect(provider.errorMessage, contains('Network error'));
    });

    test('refresh calls loadJobs', () async {
      final mockJobs = [
        JobListingModel(
          id: 1,
          title: 'Test Job',
          company: 'Test Co',
          salary: '₱25k',
          location: 'Remote',
          description: 'Test description',
          category: 'IT',
          isFeatured: false,
          sortOrder: 1,
        ),
      ];

      when(mockRepository.findAll()).thenAnswer((_) async => mockJobs);

      await provider.refresh();

      expect(provider.jobs, hasLength(1));
      verify(mockRepository.findAll()).called(1);
    });

    test('startPolling activates polling', () async {
      when(mockRepository.findAll()).thenAnswer((_) async => []);

      expect(provider.isPollingActive, false);

      provider.startPolling();

      expect(provider.isPollingActive, true);

      await Future.delayed(const Duration(milliseconds: 100));

      provider.stopPolling();
      expect(provider.isPollingActive, false);
    });

    test('stopPolling deactivates polling', () async {
      when(mockRepository.findAll()).thenAnswer((_) async => []);

      provider.startPolling();
      expect(provider.isPollingActive, true);

      provider.stopPolling();
      expect(provider.isPollingActive, false);
    });

    test('isSaved and toggleSave work correctly', () {
      expect(provider.isSaved(1), false);

      provider.toggleSave(1);
      expect(provider.isSaved(1), true);

      provider.toggleSave(1);
      expect(provider.isSaved(1), false);
    });

    test('getJobScore returns alignment score or null', () {
      expect(provider.getJobScore(999), isNull);

      // Score would be set by loadJobsWithAlignment
      // This is a simple getter test
    });

    test('dispose stops polling', () async {
      when(mockRepository.findAll()).thenAnswer((_) async => []);

      provider.startPolling();
      expect(provider.isPollingActive, true);

      provider.dispose();
      expect(provider.isPollingActive, false);
    });

    test('loadJobs clears previous scores', () async {
      final mockJobs = [
        JobListingModel(
          id: 1,
          title: 'Job 1',
          company: 'Co 1',
          salary: '₱25k',
          location: 'Remote',
          description: 'Desc 1',
          category: 'IT',
          isFeatured: false,
          sortOrder: 1,
        ),
        JobListingModel(
          id: 2,
          title: 'Job 2',
          company: 'Co 2',
          salary: '₱30k',
          location: 'Office',
          description: 'Desc 2',
          category: 'HR',
          isFeatured: false,
          sortOrder: 2,
        ),
      ];

      when(mockRepository.findAll()).thenAnswer((_) async => mockJobs);

      await provider.loadJobs();
      expect(provider.jobs, hasLength(2));

      // Scores should be cleared on new load
      expect(provider.getJobScore(1), isNull);
      expect(provider.getJobScore(2), isNull);
    });
  });
}
