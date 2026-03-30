// lib/domain/repositories/job_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Abstract contract for job-related operations
// Implemented by: JobRepositoryImpl (in data layer)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../entities/index.dart';
import '../failures/failures.dart';

class PaginationParams {
  final int page;
  final int perPage;

  const PaginationParams({this.page = 1, this.perPage = 20});

  Map<String, dynamic> toMap() => {'page': page, 'per_page': perPage};
}

class JobSearchParams {
  final String? search;
  final String? location;
  final List<String>? skills;
  final int? minSalary;
  final int? maxSalary;

  const JobSearchParams({
    this.search,
    this.location,
    this.skills,
    this.minSalary,
    this.maxSalary,
  });
}

class JobsPage {
  final List<JobEntity> jobs;
  final int total;
  final int page;
  final int perPage;

  const JobsPage({
    required this.jobs,
    required this.total,
    required this.page,
    required this.perPage,
  });

  bool get hasNext => (page * perPage) < total;
}

abstract class JobRepository {
  /// Fetch paginated job listings with optional filters
  /// Returns: JobsPage (jobs + pagination metadata)
  /// Throws: NetworkFailure, ServerFailure
  Future<Either<Failure, JobsPage>> getJobs({
    PaginationParams? pagination,
    JobSearchParams? filters,
  });

  /// Get single job by ID
  /// Returns: JobEntity with recruiter details
  /// Throws: NotFoundFailure, NetworkFailure
  Future<Either<Failure, JobEntity>> getJobById(int id);

  /// Create new job posting (recruiter-only)
  /// Returns: Created JobEntity with ID
  /// Throws: ValidationFailure, NetworkFailure, AuthorizationFailure
  Future<Either<Failure, JobEntity>> createJob({
    required String title,
    required String description,
    required String location,
    required JobType jobType,
    int? salaryMin,
    int? salaryMax,
    List<String>? requiredSkills,
    DateTime? deadline,
  });

  /// Update existing job (recruiter owner only)
  /// Returns: Updated JobEntity
  /// Throws: NotFoundFailure, AuthorizationFailure, ValidationFailure, NetworkFailure
  Future<Either<Failure, JobEntity>> updateJob({
    required int jobId,
    String? title,
    String? description,
    String? location,
    int? salaryMin,
    int? salaryMax,
    JobStatus? status,
    List<String>? requiredSkills,
  });

  /// Delete job posting (recruiter owner only)
  /// Throws: NotFoundFailure, AuthorizationFailure, NetworkFailure
  Future<Either<Failure, void>> deleteJob(int jobId);
}
