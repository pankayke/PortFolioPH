import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';

class RecruiterJobDetailScreen extends StatefulWidget {
  final int jobId;

  const RecruiterJobDetailScreen({super.key, required this.jobId});

  @override
  State<RecruiterJobDetailScreen> createState() => _RecruiterJobDetailScreenState();
}

class _RecruiterJobDetailScreenState extends State<RecruiterJobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<RecruiterJobManagerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/recruiter/jobs/${widget.jobId}/edit'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: provider.getJob(widget.jobId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(provider.error ?? 'Failed to load job details.'),
            );
          }

          final job = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${job.location} • ${job.jobType} • ${job.status}'),
              const SizedBox(height: 16),
              Text(job.description),
              const SizedBox(height: 16),
              Text('Salary: ${job.salaryDisplay}'),
              const SizedBox(height: 8),
              Text('Applications: ${job.applicationCount}'),
              const SizedBox(height: 8),
              Text(
                'Deadline: ${job.deadline != null ? job.deadline!.toLocal().toString().split(" ").first : 'N/A'}',
              ),
              const SizedBox(height: 16),
              Text(
                'Required Skills',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.requiredSkills
                    .map((s) => Chip(label: Text(s)))
                    .toList(growable: false),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: job.status == 'closed'
                    ? null
                    : () async {
                        await provider.closeJob(job.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Job closed successfully.')),
                        );
                        context.go(AppRoutes.recruiterJobsList);
                      },
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Close Job'),
              ),
            ],
          );
        },
      ),
    );
  }
}
