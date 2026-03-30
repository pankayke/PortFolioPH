// lib/domain/usecases/application/update_application_status_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class UpdateApplicationStatusUseCase {
  final ApplicationRepository _repository;

  const UpdateApplicationStatusUseCase(this._repository);

  /// Update application status (recruiter-only)
  /// Recruiters can: pending→reviewed, reviewed→shortlisted/rejected, rejected→pending
  Future<Either<Failure, ApplicationEntity>> call({
    required int applicationId,
    required ApplicationStatus newStatus,
  }) async {
    if (applicationId <= 0) {
      return Left(
        ValidationFailure(
          message: 'Invalid application ID',
          fieldErrors: {
            'application_id': ['must be positive'],
          },
        ),
      );
    }

    return _repository.updateApplicationStatus(
      applicationId: applicationId,
      status: newStatus,
    );
  }
}
