// lib/features/recruiter/screens/approval/recruiter_pending_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Screen for recruiters awaiting admin approval.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/features/recruiter/screens/approval/recruiter_approval_widgets.dart';

class RecruiterPendingScreen extends StatelessWidget {
  const RecruiterPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
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
                            Colors.amber.withValues(
                              alpha: isDark ? 0.34 : 0.24,
                            ),
                            Colors.orange.withValues(
                              alpha: isDark ? 0.28 : 0.18,
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
                            color: const Color(0xFFF7B500).withValues(alpha: 0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.hourglass_empty_rounded,
                        size: 50,
                        color: Color(0xFFF7B500),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Account Under Review',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your recruiter account is currently under review by our admin team.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    const RecruiterGlassCard(child: _PendingContent()),
                    const SizedBox(height: 20),
                    RecruiterGlassCard(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.surface.withValues(
                            alpha: isDark ? 0.28 : 0.14,
                          ),
                          colorScheme.primary.withValues(
                            alpha: isDark ? 0.20 : 0.12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'What happens next?',
                                  style: Theme.of(context).textTheme.titleMedium
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
                            '• Our admin team will verify your recruiter profile\n'
                            '• This usually takes 24-48 hours\n'
                            '• You will receive an email notification once approved\n'
                            '• You can then access all recruiter features',
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

class _PendingContent extends StatelessWidget {
  const _PendingContent();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        RecruiterDetailRow(label: 'Name', value: user?.fullName ?? 'N/A'),
        const SizedBox(height: 8),
        RecruiterDetailRow(label: 'Email', value: user?.email ?? 'N/A'),
        const SizedBox(height: 8),
        RecruiterDetailRow(label: 'Company', value: user?.location ?? 'N/A'),
        const SizedBox(height: 8),
        RecruiterDetailRow(
          label: 'Status',
          value: 'Pending',
          valueColor: const Color(0xFFF7B500),
        ),
      ],
    );
  }
}
