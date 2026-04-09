import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/job_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _coverLetterController = TextEditingController();
  final _resumeUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<JobProvider>().getJobDetail(widget.jobId);
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _resumeUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Consumer<JobProvider>(
        builder: (context, provider, _) {
          final job = provider.selectedJob;

          if (provider.isLoading && job == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && job == null) {
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
                      onPressed: () => provider.getJobDetail(widget.jobId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (job == null) {
            return const Center(child: Text('Job not found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('${job.location} • ${job.jobType} • ${job.salaryRange}'),
              const SizedBox(height: 16),
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(job.description),
              const SizedBox(height: 16),
              Text('Requirements', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(job.requirements),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: provider.isLoading ? null : _applyForJob,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Apply for this job'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _applyForJob() async {
    final provider = context.read<JobProvider>();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Submit Application', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _coverLetterController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Cover Letter (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _resumeUrlController,
                decoration: const InputDecoration(labelText: 'Resume URL (optional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (ok != true || !mounted) return;

    final success = await provider.applyJob(
      jobId: widget.jobId,
      coverLetter: _coverLetterController.text.trim().isEmpty
          ? null
          : _coverLetterController.text.trim(),
      resumeUrl: _resumeUrlController.text.trim().isEmpty
          ? null
          : _resumeUrlController.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Application submitted.' : (provider.error ?? 'Failed to apply.'),
        ),
      ),
    );
  }
}
