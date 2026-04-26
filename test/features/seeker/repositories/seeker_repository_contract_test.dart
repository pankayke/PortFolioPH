import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/features/seeker/repositories/seeker_repository_impl.dart';

class FakeApiService extends ApiService {
  FakeApiService() : super(const FlutterSecureStorage());

  dynamic getResponse;
  dynamic postResponse;
  dynamic deleteResponse;
  Object? getError;
  Object? postError;
  Object? deleteError;

  String? lastGetPath;
  Map<String, dynamic>? lastGetQuery;
  String? lastPostPath;
  dynamic lastPostData;
  String? lastDeletePath;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastGetPath = path;
    lastGetQuery = queryParameters;
    if (getError != null) throw getError!;
    return getResponse;
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPostPath = path;
    lastPostData = data;
    if (postError != null) throw postError!;
    return postResponse;
  }

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastDeletePath = path;
    if (deleteError != null) throw deleteError!;
    return deleteResponse;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late FakeApiService apiService;
  late SeekerRepositoryImpl seekerRepo;
  late SeekerApplicationRepositoryImpl applicationRepo;

  setUp(() {
    AppConfig.initialize(Flavor.development);
    apiService = FakeApiService();
    seekerRepo = SeekerRepositoryImpl(apiService);
    applicationRepo = SeekerApplicationRepositoryImpl(apiService);
  });

  group('SeekerRepositoryImpl', () {
    test('getJobs maps API list response to model list', () async {
      apiService.getResponse = [
        {
          'id': '1',
          'recruiter_id': '10',
          'recruiter_name': 'Tech Corp',
          'recruiter_logo': '',
          'title': 'Flutter Engineer',
          'description': 'Build cross-platform apps',
          'category': 'Engineering',
          'location': 'Remote',
          'salary_min': '50000',
          'salary_max': '85000',
          'employment_type': 'full_time',
          'experience_level': 'mid',
          'required_skills': ['Flutter'],
          'deadline': '2026-12-01T00:00:00Z',
          'total_applications': '2',
          'created_at': '2026-04-01T00:00:00Z',
          'updated_at': '2026-04-02T00:00:00Z',
        },
      ];

      final result = await seekerRepo.getJobs(search: 'flutter');

      expect(result, hasLength(1));
      expect(result.first.id, 1);
      expect(result.first.salaryMin, 50000.0);
      expect(apiService.lastGetPath, '/jobs');
      expect(apiService.lastGetQuery?['search'], 'flutter');
    });

    test('getJobs propagates unauthorized errors', () async {
      apiService.getError = UnauthorizedException('Unauthorized');

      expect(() => seekerRepo.getJobs(), throwsA(isA<UnauthorizedException>()));
    });
  });

  group('SeekerApplicationRepositoryImpl', () {
    test('getApplications maps API list response to model list', () async {
      apiService.getResponse = [
        {
          'id': '99',
          'job_id': '15',
          'job_title': 'Backend Developer',
          'recruiter_name': 'Scale Labs',
          'recruiter_logo': '',
          'status': 'applied',
          'applied_at': '2026-04-09T00:00:00Z',
        },
      ];

      final result = await applicationRepo.getApplications(status: 'applied');

      expect(result, hasLength(1));
      expect(result.first.id, 99);
      expect(apiService.lastGetPath, '/applications');
      expect(apiService.lastGetQuery?['status'], 'applied');
    });

    test('applyForJob propagates validation errors', () async {
      apiService.postError = ValidationException('Already applied');

      expect(
        () => applicationRepo.applyForJob(123),
        throwsA(isA<ValidationException>()),
      );
    });

    test('withdrawApplication propagates server errors', () async {
      apiService.deleteError = ServerException('Server exploded');

      expect(
        () => applicationRepo.withdrawApplication(55),
        throwsA(isA<ServerException>()),
      );

      expect(apiService.lastDeletePath, '/applications/55');
    });
  });
}
