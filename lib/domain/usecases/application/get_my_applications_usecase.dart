// lib/domain/usecases/application/get_my_applications_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class GetMyApplicationsUseCase {
  final ApplicationRepository _repository;

  const GetMyApplicationsUseCase(this._repository);

  /// Get all applications for current user
  /// For seekers: their applied jobs
  /// For recruiters: applications received on their jobs
  Future<Either<Failure, List<ApplicationEntity>>> call() =>
      _repository.getMyApplications();
}
