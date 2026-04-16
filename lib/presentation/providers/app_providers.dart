// lib/presentation/providers/app_providers.dart
// ─────────────────────────────────────────────────────────────────────────────
// Centralized application provider registry.
//
// Consolidates all ChangeNotifier providers in a single, maintainable location.
// Simplifies main.dart and enables easier provider management and testing.
//
// Usage in main.dart:
// ```dart
// MultiProvider(
//   providers: AppProviderRegistry.build(themeProvider),
//   child: App(),
// )
// ```
// ─────────────────────────────────────────────────────────────────────────────

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/core/services/file_download_service.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_dashboard_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/seeker/repositories/seeker_repository_impl.dart';
import 'package:portfolioph/features/seeker/providers/seeker_job_list_provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_application_provider.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/navigation_provider.dart';
import 'package:portfolioph/presentation/providers/file_download_provider.dart';
import 'package:portfolioph/presentation/providers/portfolio_provider.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';
import 'package:portfolioph/presentation/providers/job_feed_provider.dart';
import 'package:portfolioph/presentation/providers/profile_provider.dart';
import 'package:portfolioph/presentation/providers/reflections_provider.dart';
import 'package:portfolioph/presentation/providers/skills_provider.dart';
import 'package:portfolioph/presentation/providers/student_reflections_provider.dart';
import 'package:portfolioph/presentation/providers/student_essays_provider.dart';
import 'package:portfolioph/presentation/providers/student_achievements_provider.dart';
import 'package:portfolioph/presentation/providers/student_skills_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';

/// Centralized provider registry for all app-wide state providers.
///
/// This class consolidates provider initialization logic, making it easier to:
/// - Add/remove providers
/// - Track provider dependencies
/// - Test provider composition
/// - Maintain consistency across the app
class AppProviderRegistry {
  /// Returns the complete list of providers for the app.
  ///
  /// Pre-initialized providers (like themeProvider) are provided as values,
  /// while ephemeral providers are created fresh on app initialization.
  ///
  /// Provider organization:
  /// 1. **Core Providers** — Theme, Auth, Navigation (app-wide state)
  /// 2. **Feature Providers** — Domain-specific state (Portfolio, Skills, etc.)
  /// 3. **Content Providers** — User content (Reflections, Essays, etc.)
  static List<SingleChildWidget> build(ThemeProvider themeProvider) => [
    // ────────────────────────────────────────────────────────────────────────
    // CORE PROVIDERS — App-wide state management
    // ────────────────────────────────────────────────────────────────────────

    /// Theme provider (pre-initialized to prevent flicker)
    ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),

    /// Authentication provider — handles user login, registration, session
    ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

    /// Profile provider — handles user profile updates (upload avatar, edit bio, etc.)
    ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),

    /// Navigation provider — manages app-wide navigation state
    ChangeNotifierProvider<NavigationProvider>(
      create: (_) => NavigationProvider(),
    ),

    /// Shared secure storage instance for auth token and persisted secrets
    Provider<FlutterSecureStorage>(
      create: (_) => const FlutterSecureStorage(),
    ),

    // ────────────────────────────────────────────────────────────────────────
    // API & REPOSITORY PROVIDERS — Backend communication
    // ────────────────────────────────────────────────────────────────────────

    /// API Service — Dio HTTP client with token management and error handling
    ProxyProvider<FlutterSecureStorage, ApiService>(
      update: (_, storage, previous) => previous ?? ApiService(storage),
    ),

    /// File Download Service — Handles file downloads (CVs, exports) with progress tracking
    ProxyProvider<FlutterSecureStorage, FileDownloadService>(
      update: (_, storage, previous) =>
          previous ?? FileDownloadService(storage),
    ),

    /// File Download Provider — State management for file downloads
    ChangeNotifierProxyProvider<FileDownloadService, FileDownloadProvider>(
      create: (context) =>
          FileDownloadProvider(context.read<FileDownloadService>()),
      update: (_, service, previous) =>
          previous ?? FileDownloadProvider(service),
    ),

    /// Recruiter Repository — Job and application CRUD operations
    ProxyProvider<ApiService, RecruiterRepositoryImpl>(
      update: (_, apiService, previous) => RecruiterRepositoryImpl(apiService),
    ),

    /// Recruiter Application Repository — Application tracking for recruiters
    ProxyProvider<ApiService, ApplicationRepositoryImpl>(
      update: (_, apiService, previous) =>
          ApplicationRepositoryImpl(apiService),
    ),

    /// Seeker Repository — Job search and application management
    ProxyProvider<ApiService, SeekerRepositoryImpl>(
      update: (_, apiService, previous) => SeekerRepositoryImpl(apiService),
    ),

    /// Seeker Application Repository — Application tracking for job seekers
    ProxyProvider<ApiService, SeekerApplicationRepositoryImpl>(
      update: (_, apiService, previous) =>
          SeekerApplicationRepositoryImpl(apiService),
    ),

    // ────────────────────────────────────────────────────────────────────────
    // RECRUITER PROVIDERS — Recruiter dashboard and job management
    // ────────────────────────────────────────────────────────────────────────

    /// Recruiter Job Manager — handles recruiter job listings, CRUD, pagination
    ChangeNotifierProxyProvider<
      RecruiterRepositoryImpl,
      RecruiterJobManagerProvider
    >(
      create: (context) =>
          RecruiterJobManagerProvider(context.read<RecruiterRepositoryImpl>()),
      update: (_, repo, previous) =>
          previous ?? RecruiterJobManagerProvider(repo),
    ),

    /// Recruiter Application Manager — handles application viewing and updates
    ChangeNotifierProxyProvider<
      ApplicationRepositoryImpl,
      RecruiterApplicationManagerProvider
    >(
      create: (context) => RecruiterApplicationManagerProvider(
        context.read<ApplicationRepositoryImpl>(),
      ),
      update: (_, repo, previous) =>
          previous ?? RecruiterApplicationManagerProvider(repo),
    ),

    /// Recruiter Dashboard — aggregates recruiter analytics payloads
    ChangeNotifierProxyProvider<
      RecruiterRepositoryImpl,
      RecruiterDashboardProvider
    >(
      create: (context) => RecruiterDashboardProvider(
        context.read<RecruiterRepositoryImpl>(),
      ),
      update: (_, repo, previous) =>
          previous ?? RecruiterDashboardProvider(repo),
    ),

    // ────────────────────────────────────────────────────────────────────────
    // SEEKER PROVIDERS — Job search and application tracking
    // ────────────────────────────────────────────────────────────────────────

    /// Seeker Job List Provider — search, filter, and browse available jobs
    ChangeNotifierProxyProvider<SeekerRepositoryImpl, SeekerJobListProvider>(
      create: (context) =>
          SeekerJobListProvider(context.read<SeekerRepositoryImpl>()),
      update: (_, repo, previous) => previous ?? SeekerJobListProvider(repo),
    ),

    /// Seeker Application Provider — track applications and application status
    ChangeNotifierProxyProvider<
      SeekerApplicationRepositoryImpl,
      SeekerApplicationProvider
    >(
      create: (context) => SeekerApplicationProvider(
        context.read<SeekerApplicationRepositoryImpl>(),
      ),
      update: (_, repo, previous) =>
          previous ?? SeekerApplicationProvider(repo),
    ),

    // ────────────────────────────────────────────────────────────────────────
    // FEATURE PROVIDERS — Domain-specific state
    // ────────────────────────────────────────────────────────────────────────

    /// Portfolio provider — manages user portfolios, projects, overall portfolio state
    ChangeNotifierProvider<PortfolioProvider>(
      create: (_) => PortfolioProvider(),
    ),

    /// Skills provider — manages user skills, skill ratings, skill organization
    ChangeNotifierProvider<SkillsProvider>(create: (_) => SkillsProvider()),

    /// Certification provider — manages user certifications and credentials
    ChangeNotifierProvider<CertificationProvider>(
      create: (_) => CertificationProvider(),
    ),

    /// Education provider — manages education history, degrees, courses
    ChangeNotifierProvider<EducationProvider>(
      create: (_) => EducationProvider(),
    ),

    /// Experience provider — manages work experience, roles, employment history
    ChangeNotifierProvider<ExperienceProvider>(
      create: (_) => ExperienceProvider(),
    ),

    /// Job feed provider — manages job listings, recommendations, job search
    ChangeNotifierProvider<JobFeedProvider>(create: (_) => JobFeedProvider()),

    // ────────────────────────────────────────────────────────────────────────
    // CONTENT PROVIDERS — User-generated content and reflections
    // ────────────────────────────────────────────────────────────────────────

    /// Reflections provider — manages general reflections and user reflections
    ChangeNotifierProvider<ReflectionsProvider>(
      create: (_) => ReflectionsProvider(),
    ),

    /// Student reflections provider — manages student-specific reflections
    ChangeNotifierProvider<StudentReflectionsProvider>(
      create: (_) => StudentReflectionsProvider(),
    ),

    /// Student essays provider — manages student essay submissions and content
    ChangeNotifierProvider<StudentEssaysProvider>(
      create: (_) => StudentEssaysProvider(),
    ),

    /// Student achievements provider — manages student achievements and milestones
    ChangeNotifierProvider<StudentAchievementsProvider>(
      create: (_) => StudentAchievementsProvider(),
    ),

    /// Student skills provider — manages student-specific skills and competencies
    ChangeNotifierProvider<StudentSkillsProvider>(
      create: (_) => StudentSkillsProvider(),
    ),
  ];
}
