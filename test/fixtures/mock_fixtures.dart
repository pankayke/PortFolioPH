// test/fixtures/mock_fixtures.dart

import 'package:portfolioph/domain/entities/index.dart';

/// Provides reusable test fixtures for all tests
class MockFixtures {
  // ============ Auth Fixtures ============

  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test@123456';
  static const String testName = 'Test User';

  static UserEntity createTestUser({
    int id = 1,
    String email = testEmail,
    String name = testName,
    UserRole role = UserRole.jobSeeker,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserEntity(
    id: id,
    email: email,
    name: name,
    role: role,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
  );

  static UserEntity createTestRecruiter({
    int id = 1,
    String email = 'recruiter@example.com',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => createTestUser(
    id: id,
    email: email,
    name: 'Test Recruiter',
    role: UserRole.recruiter,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static UserEntity createTestAdmin({
    int id = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => createTestUser(
    id: id,
    email: 'admin@example.com',
    name: 'Test Admin',
    role: UserRole.admin,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // ============ Job Posting Fixtures ============

  static JobPostEntity createTestJob({
    int id = 1,
    String title = 'Flutter Developer',
    String description = 'Experienced Flutter developer needed',
    String location = 'Remote',
    double salary = 50000,
    SalaryDuration salaryDuration = SalaryDuration.annual,
    EmploymentType employmentType = EmploymentType.fullTime,
    int experience = 2,
    List<String> skills = const ['Flutter', 'Dart'],
    int recruiterId = 1,
    JobStatus status = JobStatus.open,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JobPostEntity(
    id: id,
    title: title,
    description: description,
    location: location,
    salary: salary,
    salaryDuration: salaryDuration,
    employmentType: employmentType,
    experience: experience,
    skills: skills,
    recruiterId: recruiterId,
    status: status,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
  );

  static List<JobPostEntity> createTestJobs({
    int count = 2,
    int startId = 1,
    int recruiterId = 1,
  }) => List.generate(
    count,
    (index) => createTestJob(
      id: startId + index,
      title: 'Job ${startId + index}',
      recruiterId: recruiterId,
    ),
  );

  static JobFilters createJobFilters({
    String? location,
    EmploymentType? employmentType,
    double? minSalary,
    double? maxSalary,
    int? minExperience,
    List<String>? skills,
  }) => JobFilters(
    location: location,
    employmentType: employmentType,
    minSalary: minSalary,
    maxSalary: maxSalary,
    minExperience: minExperience,
    skills: skills,
  );

  // ============ Application Fixtures ============

  static ApplicationEntity createTestApplication({
    int id = 1,
    int jobId = 1,
    int jobSeekerId = 1,
    ApplicationStatus status = ApplicationStatus.pending,
    String? coverLetter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ApplicationEntity(
    id: id,
    jobId: jobId,
    jobSeekerId: jobSeekerId,
    status: status,
    coverLetter: coverLetter,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
  );

  static List<ApplicationEntity> createTestApplications({
    int count = 3,
    int startId = 1,
    int jobId = 1,
    int startJobSeekerId = 1,
  }) => List.generate(
    count,
    (index) => createTestApplication(
      id: startId + index,
      jobId: jobId,
      jobSeekerId: startJobSeekerId + index,
    ),
  );

  // ============ Notification Fixtures ============

  static NotificationEntity createTestNotification({
    int id = 1,
    int userId = 1,
    String title = 'Test Notification',
    String message = 'This is a test notification',
    NotificationType type = NotificationType.jobUpdate,
    bool isRead = false,
    DateTime? createdAt,
  }) => NotificationEntity(
    id: id,
    userId: userId,
    title: title,
    message: message,
    type: type,
    isRead: isRead,
    createdAt: createdAt ?? DateTime.now(),
  );

  // ============ Validation Fixtures ============

  static const String validEmail = 'valid@example.com';
  static const String invalidEmail = 'invalid.email';
  static const String validPassword = 'Valid@123456';
  static const String weakPassword = 'weak';
  static const String validPhoneNumber = '+1234567890';
  static const String invalidPhoneNumber = 'invalid_phone';
}
