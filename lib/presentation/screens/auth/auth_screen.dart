import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';

/// Auth Screen
///
/// Authentication landing screen with login/register entry points.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingLg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.work_outline_rounded,
                              size: 56,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.appName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Para sa Pinoy students, freelancers, and professionals.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                Chip(label: Text('50k+ users')),
                                Chip(label: Text('10k jobs')),
                                Chip(label: Text('Cebu • Manila • Davao')),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => context.go('/login'),
                                child: const Text('Log In'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => context.go('/register'),
                                child: const Text('Create Account'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
                return GestureDetector(
                  onTap: () => context.read<ThemeProvider>().toggleDarkMode(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withAlpha(204),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
