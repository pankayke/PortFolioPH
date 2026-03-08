// lib/presentation/screens/splash/splash_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Splash screen: shows logo + animated loader, opens DB, then redirects.
//
// Flow:
//   1. Show brand logo + loading indicator.
//   2. Open SQLite DB (database_service).
//   3. After DB ready (min 3 s) → check SharedPreferences for userId.
//      - Found  → router redirect fires (handled by AppRouter guard).
//      - Missing → navigate to /login.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/datasources/local/database_service.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation for the logo.
    _fadeController = AnimationController(
      vsync: this,
      duration: AppConstants.durationSlow,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Kick off the async init after first frame to avoid blocking paint.
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    // Run DB open and minimum splash timer concurrently.
    await Future.wait([
      DatabaseService().open(),
      Future.delayed(AppConstants.splashDuration),
    ]);

    if (!mounted) return;

    // Let AuthProvider attempt session restore.
    final authProvider = context.read<AuthProvider>();
    final hasSession = await authProvider.restoreSession();

    if (!mounted) return;

    if (hasSession) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── App logo placeholder ───────────────────────────────────────
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  size: 72,
                  color: AppConstants.primaryColor,
                ),
              ),

              const SizedBox(height: AppConstants.spacingLg),

              // ── App name ───────────────────────────────────────────────────
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: AppConstants.spacingSm),

              Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),

              const SizedBox(height: AppConstants.spacingXxl),

              // ── Loading indicator ─────────────────────────────────────────
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
