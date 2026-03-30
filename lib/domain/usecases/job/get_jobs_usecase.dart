// lib/domain/usecases/job/get_jobs_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class GetJobsUseCase {
  final JobRepository _repository;

  const GetJobsUseCase(this._repository);

  /// Get paginated jobs with optional filters
  /// page: 1-indexed
  /// perPage: 1-100 records per page
  Future<Either<Failure, JobsPage>> call({
    int page = 1,
    int perPage = 20,
    String? search,
    String? location,
    List<String>? skills,
  }) async {
    // ✅ Domain validation
    if (page < 1) {
      return Left(
        ValidationFailure(
          message: 'Page must be >= 1',
          fieldErrors: {
            'page': ['must be >= 1'],
          },
        ),
      );
    }

    if (perPage < 1 || perPage > 100) {
      return Left(
        ValidationFailure(
          message: 'Results per page must be 1-100',
          fieldErrors: {
            'per_page': ['must be 1-100'],
          },
        ),
      );
    }

    return _repository.getJobs(
      pagination: PaginationParams(page: page, perPage: perPage),
      filters: JobSearchParams(
        search: search,
        location: location,
        skills: skills,
      ),
    );
  }
}
