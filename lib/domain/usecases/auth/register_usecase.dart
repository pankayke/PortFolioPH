// lib/domain/usecases/auth/register_usecase.dart
// ─────────────────────────────────────────────────────────────────────────────
// Register a new user - Domain business logic with validation
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  /// Register new user with validation
  /// Validates: email format, password strength, name length
  /// Returns: UserEntity on success
  /// Throws: ValidationFailure, DuplicateEmailFailure, NetworkFailure
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // ✅ Validation logic belongs in domain layer (business rules)
    final validation = _validateInput(email, password, name);
    if (validation != null) {
      return Left(validation);
    }

    // ✅ Repository call - repository enforces database constraints
    return _repository.register(
      email: email,
      password: password,
      name: name,
      role: role,
    );
  }

  /// Validate registration inputs according to business rules
  Failure? _validateInput(String email, String password, String name) {
    // Email validation
    if (!_isValidEmail(email)) {
      return ValidationFailure(
        message: 'Invalid email format',
        fieldErrors: {
          'email': ['must be a valid email address'],
        },
      );
    }

    // Password strength
    if (password.length < 8) {
      return ValidationFailure(
        message: 'Password too short',
        fieldErrors: {
          'password': ['must be at least 8 characters'],
        },
      );
    }

    if (!_hasNumeric(password)) {
      return ValidationFailure(
        message: 'Password too weak',
        fieldErrors: {
          'password': ['must contain at least one number'],
        },
      );
    }

    // Name validation
    if (name.isEmpty || name.length < 2) {
      return ValidationFailure(
        message: 'Invalid name',
        fieldErrors: {
          'name': ['required, must be at least 2 characters'],
        },
      );
    }

    return null; // All validations passed
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  bool _hasNumeric(String str) => RegExp(r'\d').hasMatch(str);
}
