// lib/features/recruiter/screens/approval/recruiter_rejected_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Screen for recruiters whose account was rejected.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class RecruiterRejectedScreen extends StatelessWidget {
  const RecruiterRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Account Status'),
            automaticallyImplyLeading: false,
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
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.cancel, size: 50, color: Colors.red[800]),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Account Not Approved',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  Text(
                    'Unfortunately, your recruiter account application was not approved.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Details
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Information',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.red[800]),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            label: 'Name',
                            value: user?.fullName ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            label: 'Email',
                            value: user?.email ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            label: 'Status',
                            value: 'Rejected',
                            valueColor: Colors.red[800],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reason card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Possible Reasons',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.orange[700]),
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
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Support info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Need Help?',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.blue[700]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'If you believe this is a mistake, please contact our support team at support@jobplatform.com',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
