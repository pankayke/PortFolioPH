// lib/domain/repositories/auth_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Abstract contract for authentication operations
// Implemented by: AuthRepositoryImpl (in data layer)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../entities/index.dart';
import '../failures/failures.dart';

abstract class AuthRepository {
  /// Register new user on platform
  /// Returns: UserEntity with token
  /// Throws: DuplicateEmailFailure, ValidationFailure, NetworkFailure
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });

  /// Authenticate user with credentials
  /// Returns: UserEntity with token on success
  /// Throws: AuthenticationFailure, NetworkFailure
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Logout - clear stored tokens
  Future<Either<Failure, void>> logout();

  /// Restore session from stored token (for app restart)
  /// Returns: null if no valid token found
  Future<Either<Failure, UserEntity?>> restoreSession();
}
