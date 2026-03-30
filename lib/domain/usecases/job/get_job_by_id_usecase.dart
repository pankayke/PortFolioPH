// lib/domain/usecases/job/get_job_by_id_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class GetJobByIdUseCase {
  final JobRepository _repository;

  const GetJobByIdUseCase(this._repository);

  Future<Either<Failure, JobEntity>> call(int jobId) async {
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

    return _repository.getJobById(jobId);
  }
}
