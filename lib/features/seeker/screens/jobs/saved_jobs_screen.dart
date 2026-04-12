import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/features/seeker/providers/seeker_application_provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_job_list_provider.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SeekerJobListProvider>().loadSavedJobs(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Jobs')),
      body: Consumer2<SeekerJobListProvider, SeekerApplicationProvider>(
        builder: (context, jobsProvider, applicationProvider, _) {
          if (jobsProvider.isLoading && jobsProvider.savedJobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (jobsProvider.error != null && jobsProvider.savedJobs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    Text(jobsProvider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => jobsProvider.loadSavedJobs(refresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (jobsProvider.savedJobs.isEmpty) {
            return const Center(
              child: Text('No saved jobs yet. Bookmark jobs to see them here.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => jobsProvider.loadSavedJobs(refresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: jobsProvider.savedJobs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = jobsProvider.savedJobs[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job.recruiterName} • ${job.location}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${job.salaryDisplay} • ${job.employmentType}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                await jobsProvider.unsaveJob(job.id);
                                if (!mounted) return;
                                await jobsProvider.loadSavedJobs(refresh: true);
                              },
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              label: const Text('Remove'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: job.hasApplied
                                  ? null
                                  : () => applicationProvider.applyForJob(job.id),
                              child: Text(job.hasApplied ? 'Applied' : 'Apply'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
