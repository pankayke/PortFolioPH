// lib/features/recruiter/screens/approval/recruiter_rejected_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Screen for recruiters whose account was rejected.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/features/recruiter/screens/approval/recruiter_approval_widgets.dart';

class RecruiterRejectedScreen extends StatelessWidget {
  const RecruiterRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;

        return PremiumAppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Account Status'),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authProvider.logout();
                    context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            DesignTokens.accentPhilippineRed.withValues(alpha: isDark ? 0.30 : 0.20),
                            Colors.orange.withValues(
                              alpha: isDark ? 0.24 : 0.16,
                            ),
                          ],
                        ),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.40,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DesignTokens.accentPhilippineRed.withValues(alpha: 0.20),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 50,
                        color: DesignTokens.accentPhilippineRed,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Account Not Approved',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unfortunately, your recruiter account application was not approved.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    RecruiterGlassCard(
                      gradient: LinearGradient(
                        colors: [
                          DesignTokens.accentPhilippineRed.withValues(alpha: isDark ? 0.24 : 0.16),
                          colorScheme.surface.withValues(
                            alpha: isDark ? 0.24 : 0.12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Information',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 16),
                          RecruiterDetailRow(
                            label: 'Name',
                            value: user?.fullName ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          RecruiterDetailRow(
                            label: 'Email',
                            value: user?.email ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          RecruiterDetailRow(
                            label: 'Status',
                            value: 'Rejected',
                            valueColor: DesignTokens.accentPhilippineRed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RecruiterGlassCard(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: isDark ? 0.22 : 0.14),
                          colorScheme.surface.withValues(
                            alpha: isDark ? 0.24 : 0.12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.tertiary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Possible Reasons',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Incomplete or inaccurate company information\n'
                            '• Non-compliance with platform policies\n'
                            '• Suspicious or fraudulent activity\n'
                            '• Policy violations\n'
                            '• Other verification concerns',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RecruiterGlassCard(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withValues(
                            alpha: isDark ? 0.22 : 0.14,
                          ),
                          colorScheme.surface.withValues(
                            alpha: isDark ? 0.24 : 0.12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.help_outline_rounded,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Need Help?',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'If you believe this is a mistake, please contact our support team at support@jobplatform.com',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          authProvider.logout();
                          context.go(AppRoutes.login);
                        },
                        child: const Text('Back to Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
