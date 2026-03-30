// lib/domain/repositories/application_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Abstract contract for job application operations
// Implemented by: ApplicationRepositoryImpl (in data layer)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../entities/index.dart';
import '../failures/failures.dart';

abstract class ApplicationRepository {
  /// Seeker applies to a job
  /// Returns: Created ApplicationEntity
  /// Throws: DuplicateApplicationFailure, NotFoundFailure (job), ValidationFailure, NetworkFailure
  Future<Either<Failure, ApplicationEntity>> applyToJob({
    required int jobId,
    String? coverLetter,
  });

  /// Get seeker's applications (seeker-only)
  /// Returns: List of ApplicationEntity
  /// Throws: AuthorizationFailure, NetworkFailure
  Future<Either<Failure, List<ApplicationEntity>>> getMyApplications();

  /// Get applications for a job (recruiter owner only)
  /// Returns: List of ApplicationEntity
  /// Throws: NotFoundFailure (job), AuthorizationFailure, NetworkFailure
  Future<Either<Failure, List<ApplicationEntity>>> getJobApplications(
    int jobId,
  );

  /// Get application details by ID
  /// Returns: ApplicationEntity
  /// Throws: NotFoundFailure, AuthorizationFailure, NetworkFailure
  Future<Either<Failure, ApplicationEntity>> getApplicationById(int id);

  /// Update application status (recruiter owner only)
  /// Returns: Updated ApplicationEntity
  /// Throws: NotFoundFailure, AuthorizationFailure, ValidationFailure, NetworkFailure
  Future<Either<Failure, ApplicationEntity>> updateApplicationStatus({
    required int applicationId,
    required ApplicationStatus status,
  });

  /// Withdraw application (seeker owner only, if not decided)
  /// Throws: NotFoundFailure, AuthorizationFailure, ValidationFailureError, NetworkFailure
  Future<Either<Failure, void>> withdrawApplication(int applicationId);
}
