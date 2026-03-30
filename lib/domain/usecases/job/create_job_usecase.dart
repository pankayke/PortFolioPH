// lib/domain/usecases/job/create_job_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/index.dart';
import '../../failures/failures.dart';
import '../../repositories/index.dart';

class CreateJobUseCase {
  final JobRepository _repository;

  const CreateJobUseCase(this._repository);

  Future<Either<Failure, JobEntity>> call({
    required String title,
    required String description,
    required String location,
    required JobType jobType,
    int? salaryMin,
    int? salaryMax,
    List<String>? requiredSkills,
    DateTime? deadline,
  }) async {
    // ✅ Domain validation
    final validation = _validate(
      title,
      description,
      location,
      salaryMin,
      salaryMax,
      deadline,
    );
    if (validation != null) {
      return Left(validation);
    }

    return _repository.createJob(
      title: title,
      description: description,
      location: location,
      jobType: jobType,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      requiredSkills: requiredSkills,
      deadline: deadline,
    );
  }

  Failure? _validate(
    String title,
    String description,
    String location,
    int? salaryMin,
    int? salaryMax,
    DateTime? deadline,
  ) {
    final errors = <String, List<String>>{};

    if (title.isEmpty || title.length < 3) {
      errors['title'] = ['required, min 3 characters'];
    }

    if (description.isEmpty || description.length < 20) {
      errors['description'] = ['required, min 20 characters'];
    }

    if (location.isEmpty) {
      errors['location'] = ['required'];
    }

    if (salaryMin != null && salaryMin < 0) {
      errors['salary_min'] = ['must be >= 0'];
    }

    if (salaryMax != null && salaryMax < 0) {
      errors['salary_max'] = ['must be >= 0'];
    }

    if (salaryMin != null && salaryMax != null && salaryMin > salaryMax) {
      errors['salary'] = ['min cannot exceed max'];
    }

    if (deadline != null && deadline.isBefore(DateTime.now())) {
      errors['deadline'] = ['must be in the future'];
    }

    if (errors.isNotEmpty) {
      return ValidationFailure(
        message: 'Job creation validation failed',
        fieldErrors: errors,
      );
    }

    return null;
  }
}
