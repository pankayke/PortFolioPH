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

import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/screens/auth/login_screen.dart';
import 'package:portfolioph/presentation/screens/auth/profile_setup_screen.dart';
import 'package:portfolioph/presentation/screens/auth/register_screen.dart';
import 'package:portfolioph/presentation/screens/main_scaffold.dart';
import 'package:portfolioph/presentation/screens/splash/splash_screen.dart';

// ── Named route constants ──────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String dashboard = '/dashboard';

  // ── Reserved for future sprints ────────────────────────────────────────────
  static const String portfolioNew = '/portfolio/new';
  static const String portfolioDetail = '/portfolio/:id';
  static const String projectNew = '/project/new';
  static const String projectDetail = '/project/:id';
  static const String resumeEducationNew = '/resume/education/new';
  static const String resumeExperienceNew = '/resume/experience/new';
  static const String settings = '/settings';
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

      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;
      final isSplash = location == AppRoutes.splash;

      // Always allow splash through – it manages its own redirect after init.
      if (isSplash) return null;

      // Unauthenticated user hitting a protected route → login.
      if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;

      // Authenticated user hitting an auth route → dashboard.
      if (isAuthenticated && isAuthRoute) return AppRoutes.dashboard;

      return null; // No redirect needed.
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
        builder: (context, state) => const MainScaffold(), // TODO Sprint 3
      ),
      GoRoute(
        path: AppRoutes.projectDetail,
        name: 'project-detail',
        builder: (context, state) => const MainScaffold(), // TODO Sprint 3
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
        builder: (context, state) => const MainScaffold(), // TODO Sprint 6
      ),
    ],
  );
}
