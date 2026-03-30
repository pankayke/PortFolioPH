// lib/domain/repositories/user_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Abstract contract for user profile operations
// Implemented by: UserRepositoryImpl (in data layer)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../entities/index.dart';
import '../failures/failures.dart';

abstract class UserRepository {
  /// Get user profile by ID
  /// Returns: UserEntity
  /// Throws: NotFoundFailure, NetworkFailure
  Future<Either<Failure, UserEntity>> getUserById(int userId);

  /// Search users by name/email
  /// Returns: List of UserEntity
  /// Throws: ValidationFailure, NetworkFailure
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);

  /// Update current user profile
  /// Returns: Updated UserEntity
  /// Throws: ValidationFailure, NetworkFailure
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? bio,
    String? location,
    String? websiteUrl,
    String? avatarUrl,
  });

  /// Check if user has admin role
  /// Returns: true if admin, false otherwise
  /// Throws: NetworkFailure
  Future<Either<Failure, bool>> isAdmin();
}
