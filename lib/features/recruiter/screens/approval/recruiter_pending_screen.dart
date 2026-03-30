// lib/features/recruiter/screens/approval/recruiter_pending_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Screen for recruiters awaiting admin approval.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class RecruiterPendingScreen extends StatelessWidget {
  const RecruiterPendingScreen({Key? key}) : super(key: key);

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
                      color: Colors.amber[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 50,
                      color: Colors.amber[800],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Account Under Review',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  Text(
                    'Your recruiter account is currently under review by our admin team.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Details',
                            style: Theme.of(context).textTheme.titleMedium,
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
                            label: 'Company',
                            value: user?.location ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            context,
                            label: 'Status',
                            value: 'Pending',
                            valueColor: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info text
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
                            Icon(Icons.info, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'What happens next?',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: Colors.blue[700]),
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
