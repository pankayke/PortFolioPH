// lib/domain/usecases/auth/restore_session_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class RestoreSessionUseCase {
  final AuthRepository _repository;

  const RestoreSessionUseCase(this._repository);

  /// Restore user session from stored token
  /// Returns: UserEntity if session valid, null if no session
  Future<Either<Failure, UserEntity?>> call() => _repository.restoreSession();
}
