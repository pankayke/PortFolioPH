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

import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/navigation_provider.dart';
import 'package:portfolioph/presentation/providers/portfolio_provider.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';
import 'package:portfolioph/presentation/providers/job_feed_provider.dart';
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

    /// Navigation provider — manages app-wide navigation state
    ChangeNotifierProvider<NavigationProvider>(
      create: (_) => NavigationProvider(),
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
