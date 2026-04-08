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

class RecruiterPendingScreen extends StatelessWidget {
  const RecruiterPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
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
                            Colors.amber.withValues(alpha: 0.24),
                            Colors.orange.withValues(alpha: 0.18),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.hourglass_empty_rounded,
                        size: 50,
                        color: Colors.amber.shade200,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Account Under Review',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your recruiter account is currently under review by our admin team.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.84),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    const RecruiterGlassCard(
                      child: _PendingContent(),
                    ),
                    const SizedBox(height: 20),
                    RecruiterGlassCard(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.blue.withValues(alpha: 0.12),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade200),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'What happens next?',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(context, 'Name', user?.fullName ?? 'N/A'),
        const SizedBox(height: 8),
        _buildDetailRow(context, 'Email', user?.email ?? 'N/A'),
        const SizedBox(height: 8),
        _buildDetailRow(context, 'Company', user?.location ?? 'N/A'),
        const SizedBox(height: 8),
        _buildDetailRow(context, 'Status', 'Pending', valueColor: Colors.amber.shade200),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.white,
              ),
        ),
      ],
    );
  }
}
