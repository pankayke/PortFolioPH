import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/job_provider.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<JobProvider>().fetchJobs(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            tooltip: 'Post Job',
            onPressed: () => context.push('/post-job'),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.jobs.isEmpty) {
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
                      onPressed: () => provider.fetchJobs(page: 1),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.jobs.isEmpty) {
            return const Center(child: Text('No jobs found.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchJobs(page: 1),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.jobs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = provider.jobs[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    title: Text(job.title),
                    subtitle: Text(
                      '${job.location} • ${job.salaryRange} • ${job.jobType}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/jobs/${job.id}'),
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
