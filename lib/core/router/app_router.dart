// lib/core/router/app_router.dart
// ─────────────────────────────────────────────────────────────────────────────
// Application router built with GoRouter 14+.
//
// ─── Route hierarchy ──────────────────────────────────────────────────────────
//   /splash           → SplashScreen
//   /login            → LoginScreen
//   /register         → RegisterScreen
//   /dashboard        → MainScaffold (bottom-nav shell)
//     /portfolio      │
//     /resume         │  tabs are handled via NavigationProvider,
//     /skills         │  not as sub-routes, to keep IndexedStack alive.
//     /profile        │
//   ── Future routes (Sprint 2 – 8) ─────────────────────────────────────────
//   /portfolio/new         → AddPortfolioScreen
//   /portfolio/:id         → PortfolioDetailScreen
//   /project/new           → AddProjectScreen
//   /project/:id           → ProjectDetailScreen
//   /resume/education/new  → AddEducationScreen
//   /resume/experience/new → AddExperienceScreen
//   /settings              → SettingsScreen
// ─────────────────────────────────────────────────────────────────────────────

import 'package:go_router/go_router.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/presentation/screens/auth/login_screen.dart';
import 'package:portfolioph/presentation/screens/auth/profile_setup_screen.dart';
import 'package:portfolioph/presentation/screens/auth/register_screen.dart';
import 'package:portfolioph/features/recruiter/screens/dashboard/recruiter_dashboard_screen.dart';
import 'package:portfolioph/features/recruiter/screens/ats/applicant_tracking_screen.dart';
import 'package:portfolioph/features/recruiter/screens/approval/recruiter_pending_screen.dart';
import 'package:portfolioph/features/recruiter/screens/approval/recruiter_rejected_screen.dart';
import 'package:portfolioph/features/recruiter/screens/jobs/recruiter_job_detail_screen.dart';
import 'package:portfolioph/features/recruiter/screens/jobs/recruiter_job_edit_screen.dart';
import 'package:portfolioph/presentation/screens/portfolio/add_edit_project_screen.dart';
import 'package:portfolioph/presentation/screens/portfolio/project_detail_screen.dart';
import 'package:portfolioph/presentation/screens/profile/edit_profile_screen.dart';
import 'package:portfolioph/presentation/screens/profile/notification_settings_screen.dart';
import 'package:portfolioph/presentation/screens/admin/filament_admin_screen.dart';
import 'package:portfolioph/presentation/screens/main_scaffold.dart';
import 'package:portfolioph/presentation/screens/settings/settings_screen.dart';
import 'package:portfolioph/presentation/screens/splash/splash_screen.dart';
import 'package:portfolioph/presentation/screens/teacher_dashboard_screen.dart';

// ── Named route constants ──────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String dashboard = '/dashboard';

  // ── Recruiter routes ──────────────────────────────────────────────────────
  static const String recruiterDashboard = '/recruiter/dashboard';
  static const String recruiterJobCreate = '/recruiter/jobs/create';
  static const String recruiterJobsList = '/recruiter/jobs';
  static const String recruiterJobDetail = '/recruiter/jobs/:id';
  static const String recruiterJobEdit = '/recruiter/jobs/:id/edit';
  static const String recruiterApplications = '/recruiter/applications';
  static const String recruiterPending = '/recruiter/pending';
  static const String recruiterRejected = '/recruiter/rejected';

  // ── Seeker routes ────────────────────────────────────────────────────────
  static const String seekerDashboard = '/seeker/dashboard';
  static const String seekerJobsList = '/seeker/jobs';
  static const String seekerJobDetail = '/seeker/jobs/:id';
  static const String seekerApplications = '/seeker/applications';
  static const String seekerProfile = '/seeker/profile';

  // ── Reserved for future sprints ────────────────────────────────────────────
  static const String editProfile = '/profile/edit';
  static const String notificationSettings = '/notifications/settings';
  static const String portfolioNew = '/portfolio/new';
  static const String portfolioDetail = '/portfolio/:id';
  static const String projectNew = '/project/new';
  static const String projectDetail = '/project/:id';
  static const String resumeEducationNew = '/resume/education/new';
  static const String resumeExperienceNew = '/resume/experience/new';
  static const String settings = '/settings';
  static const String adminDashboard = '/admin-dashboard';
  static const String teacherDashboard = '/teacher-dashboard';
}

// ── Router factory ─────────────────────────────────────────────────────────────
class AppRouter {
  AppRouter._();

  /// Build and return a [GoRouter] instance that reads [AuthProvider] for
  /// auth-redirect decisions.
  static GoRouter create(AuthProvider authProvider) => GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // ── Auth redirect guard ──────────────────────────────────────────
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final location = state.uri.path;
      final role = authProvider.currentUser?.role;

      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;
      final isSplash = location == AppRoutes.splash;

      // Always allow splash through – it manages its own redirect after init.
      if (isSplash) return null;

      // Unauthenticated user trying to access a protected route → login.
      if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;

      // Authenticated user trying to access login/register → role-based home.
      if (isAuthenticated && isAuthRoute) {
        return role == AppConstants.roleRecruiter
            ? AppRoutes.recruiterDashboard
            : AppRoutes.dashboard;
      }

      if (isAuthenticated &&
          role != AppConstants.roleRecruiter &&
          location.startsWith('/recruiter')) {
        return AppRoutes.dashboard;
      }

      // Recruiters use dedicated recruiter UI, not seeker dashboard shell.
      if (isAuthenticated &&
          role == AppConstants.roleRecruiter &&
          location == AppRoutes.dashboard) {
        return AppRoutes.recruiterDashboard;
      }

      if (isAuthenticated &&
          role != AppConstants.roleRecruiter &&
          location == AppRoutes.recruiterDashboard) {
        return AppRoutes.dashboard;
      }

      // All other cases allowed (including onboarding routes for authenticated users)
      return null;
    },

    // ── Routes ──────────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Profile setup (post-registration) ────────────────────────
      GoRoute(
        path: AppRoutes.profileSetup,
        name: 'profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // ── Recruiter home (separate UI) ─────────────────────────────
      GoRoute(
        path: AppRoutes.recruiterDashboard,
        name: 'recruiter-dashboard',
        builder: (context, state) => const RecruiterDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.recruiterJobCreate,
        name: 'recruiter-job-create',
        builder: (context, state) =>
            const RecruiterDashboardScreen(initialTab: 3),
      ),
      GoRoute(
        path: AppRoutes.recruiterJobsList,
        name: 'recruiter-jobs-list',
        builder: (context, state) =>
            const RecruiterDashboardScreen(initialTab: 1),
      ),
      GoRoute(
        path: AppRoutes.recruiterJobDetail,
        name: 'recruiter-job-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const RecruiterDashboardScreen();
          return RecruiterJobDetailScreen(jobId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.recruiterJobEdit,
        name: 'recruiter-job-edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const RecruiterDashboardScreen();
          return RecruiterJobEditScreen(jobId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.recruiterApplications,
        name: 'recruiter-applications',
        builder: (context, state) => const ApplicantTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.recruiterPending,
        name: 'recruiter-pending',
        builder: (context, state) => const RecruiterPendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.recruiterRejected,
        name: 'recruiter-rejected',
        builder: (context, state) => const RecruiterRejectedScreen(),
      ),

      // ── Protected: dashboard shell ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const MainScaffold(),
      ),

      // ── Future sprint routes (placeholders) ───────────────────────────────
      GoRoute(
        path: AppRoutes.portfolioNew,
        name: 'portfolio-new',
        builder: (context, state) => const MainScaffold(), // TODO Sprint 3
      ),
      GoRoute(
        path: AppRoutes.portfolioDetail,
        name: 'portfolio-detail',
        builder: (context, state) => const MainScaffold(), // TODO Sprint 3
      ),
      GoRoute(
        path: AppRoutes.projectNew,
        name: 'project-new',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic>) {
            return const MainScaffold();
          }

          final userId = extra['userId'] as int?;
          final portfolioId = extra['portfolioId'] as int?;
          if (userId == null || portfolioId == null) {
            return const MainScaffold();
          }

          return AddEditProjectScreen(userId: userId, portfolioId: portfolioId);
        },
      ),
      GoRoute(
        path: AppRoutes.projectDetail,
        name: 'project-detail',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic>) {
            return const MainScaffold();
          }

          final project = extra['project'];
          final userId = extra['userId'] as int?;
          if (project is! ProjectModel || userId == null) {
            return const MainScaffold();
          }

          return ProjectDetailScreen(project: project, userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.resumeEducationNew,
        name: 'resume-education-new',
        builder: (context, state) => const MainScaffold(), // TODO Sprint 4
      ),
      GoRoute(
        path: AppRoutes.resumeExperienceNew,
        name: 'resume-experience-new',
        builder: (context, state) => const MainScaffold(), // TODO Sprint 4
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'admin-dashboard',
        builder: (context, state) {
          final user = authProvider.currentUser;
          if (user == null || user.role != AppConstants.roleAdmin) {
            return const MainScaffold();
          }
          return const FilamentAdminScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.teacherDashboard,
        name: 'teacher-dashboard',
        builder: (context, state) {
          final user = authProvider.currentUser;
          final role = user?.role;
          if (role != AppConstants.roleTeacher &&
              role != AppConstants.roleCoordinator &&
              role != AppConstants.roleAdmin) {
            return const MainScaffold();
          }
          return const TeacherDashboardScreen();
        },
      ),
    ],
  );
}
