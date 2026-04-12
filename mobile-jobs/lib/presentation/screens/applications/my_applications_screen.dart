import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/job_provider.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<JobProvider>().getMyApplications(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: Consumer<JobProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.myApplications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.myApplications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => provider.getMyApplications(page: 1),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.myApplications.isEmpty) {
            return const Center(child: Text('No applications yet.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.getMyApplications(page: 1),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myApplications.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = provider.myApplications[index];
                final jobTitle =
                    (app.job?['title'] ?? 'Job #${app.jobId}').toString();

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(jobTitle),
                    subtitle: Text('Status: ${app.status}'),
                    trailing: app.isPending
                        ? TextButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final ok = await provider.withdrawApplication(
                                app.id,
                              );
                              if (!context.mounted) return;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'Application withdrawn.'
                                        : (provider.error ??
                                            'Failed to withdraw application.'),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Withdraw'),
                          )
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
