// lib/domain/usecases/application/apply_to_job_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class ApplyToJobUseCase {
  final ApplicationRepository _repository;

  const ApplyToJobUseCase(this._repository);

  Future<Either<Failure, ApplicationEntity>> call({
    required int jobId,
    String? coverLetter,
  }) async {
    if (jobId <= 0) {
      return Left(
        ValidationFailure(
          message: 'Invalid job ID',
          fieldErrors: {
            'job_id': ['must be positive'],
          },
        ),
      );
    }

    if (coverLetter != null && coverLetter.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Cover letter cannot be empty if provided',
          fieldErrors: {
            'cover_letter': ['cannot be empty'],
          },
        ),
      );
    }

    return _repository.applyToJob(jobId: jobId, coverLetter: coverLetter);
  }
}
