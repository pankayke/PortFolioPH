// lib/domain/usecases/auth/login_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(
        ValidationFailure(
          message: 'Email and password are required',
          fieldErrors: {
            if (email.isEmpty) 'email': ['required'],
            if (password.isEmpty) 'password': ['required'],
          },
        ),
      );
    }

    if (!_isValidEmail(email)) {
      return Left(
        ValidationFailure(
          message: 'Invalid email format',
          fieldErrors: {
            'email': ['must be a valid email address'],
          },
        ),
      );
    }

    return _repository.login(email: email, password: password);
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}
