// lib/domain/usecases/auth/logout_usecase.dart

import 'package:dartz/dartz.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.logout();
}
