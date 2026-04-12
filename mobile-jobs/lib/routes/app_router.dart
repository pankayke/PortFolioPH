import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/jobs/job_list_screen.dart';
import '../presentation/screens/jobs/job_detail_screen.dart';
import '../presentation/screens/jobs/post_job_screen.dart';
import '../presentation/screens/applications/my_applications_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final authProvider = context.read<AuthProvider>();
      final isGoingToSplash = state.uri.path == '/splash';
      if (!authProvider.isInitialized && !isGoingToSplash) {
        return '/splash';
      }

      final isAuthenticated = authProvider.isAuthenticated;
      final isGoingToAuth = state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          isGoingToSplash;

      if (isAuthenticated && isGoingToAuth) {
        return '/jobs';
      }

      if (!isAuthenticated && !isGoingToAuth) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Job Routes
      GoRoute(
        path: '/jobs',
        builder: (context, state) => const JobListScreen(),
      ),
      GoRoute(
        path: '/jobs/:id',
        builder: (context, state) {
          final jobId = int.parse(state.pathParameters['id'] ?? '0');
          return JobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/post-job',
        builder: (context, state) => const PostJobScreen(),
      ),

      // Application Routes
      GoRoute(
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
    ],
  );
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.restoreSession();
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      context.go(authProvider.isAuthenticated ? '/jobs' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.work, size: 50, color: colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Job Platform',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find Your Dream Job',
              style: TextStyle(
                color: colorScheme.onPrimary.withValues(alpha: 0.76),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
