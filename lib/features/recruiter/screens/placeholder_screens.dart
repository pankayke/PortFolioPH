// Functional recruiter screens used by recruiter routes.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';

// Job Create Screen
class JobCreateScreen extends StatefulWidget {
  const JobCreateScreen({super.key});

  @override
  State<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends State<JobCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _skillsController = TextEditingController();

  String _jobType = 'full_time';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<RecruiterJobManagerProvider>();

    try {
      await provider.createJob(
        CreateJobRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          salaryMin: double.tryParse(_salaryMinController.text.trim()),
          salaryMax: double.tryParse(_salaryMaxController.text.trim()),
          jobType: _jobType,
          requiredSkills: _skillsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          deadline: null,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to create job.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (v) => (v == null || v.trim().length < 5)
                    ? 'Title must be at least 5 characters.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().length < 20)
                    ? 'Description must be at least 20 characters.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Location is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _jobType,
                decoration: const InputDecoration(labelText: 'Job Type'),
                items: const [
                  DropdownMenuItem(value: 'full_time', child: Text('Full Time')),
                  DropdownMenuItem(value: 'part_time', child: Text('Part Time')),
                  DropdownMenuItem(value: 'contract', child: Text('Contract')),
                  DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
                ],
                onChanged: (value) => setState(() => _jobType = value ?? 'full_time'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryMinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Salary Min (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryMaxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Salary Max (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Required Skills (comma-separated)',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Post Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Recruiter Jobs List Screen
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
      context.read<RecruiterJobManagerProvider>().loadJobs(refresh: true);
    });
  }

  Future<void> _refresh() async {
    await context.read<RecruiterJobManagerProvider>().loadJobs(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: Consumer<RecruiterJobManagerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.jobs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text('No jobs posted yet.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: provider.jobs.length,
              itemBuilder: (context, index) {
                final job = provider.jobs[index];
                return ListTile(
                  onTap: () => context.push('/recruiter/jobs/${job.id}'),
                  title: Text(job.title),
                  subtitle: Text(
                    '${job.location} • ${job.status} • ${job.applicationCount} applicants',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/recruiter/jobs/${job.id}/edit'),
                      ),
                      if (job.status != 'closed')
                        IconButton(
                          icon: const Icon(Icons.pause_circle_outline),
                          onPressed: () => provider.closeJob(job.id),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => provider.deleteJob(job.id),
                      ),
                    ],
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

// Applicants Screen
class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecruiterApplicationManagerProvider>().loadApplications(
            refresh: true,
          );
    });
  }

  Future<void> _updateStatus(int applicationId, String status) async {
    await context.read<RecruiterApplicationManagerProvider>().updateApplicationStatus(
          applicationId,
          status,
        );
  }

  Future<void> _openReviewModal(RecruiterApplication app) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          app.applicantName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(label: Text(app.statusDisplay)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(app.applicantEmail),
                  if (app.applicantPhone.isNotEmpty) Text(app.applicantPhone),
                  if (app.applicantLocation.isNotEmpty) Text(app.applicantLocation),
                  const SizedBox(height: 16),
                  Text(
                    'Cover Letter',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(app.coverLetter?.trim().isNotEmpty == true
                      ? app.coverLetter!
                      : 'No cover letter provided.'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'reviewed');
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Mark Reviewed'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'shortlisted');
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Shortlist'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'accepted');
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Accept'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'rejected');
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: Consumer<RecruiterApplicationManagerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.applications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.applications.isEmpty) {
            return const Center(child: Text('No applications yet.'));
          }

          return ListView.builder(
            itemCount: provider.applications.length,
            itemBuilder: (context, index) {
              final app = provider.applications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.applicantName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(app.applicantEmail),
                      const SizedBox(height: 6),
                      Text('Status: ${app.statusDisplay}'),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: () => _openReviewModal(app),
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Review Application'),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => _updateStatus(app.id, 'pending'),
                            child: const Text('Pending'),
                          ),
                          OutlinedButton(
                            onPressed: () => _updateStatus(app.id, 'reviewed'),
                            child: const Text('Reviewed'),
                          ),
                          OutlinedButton(
                            onPressed: () => _updateStatus(app.id, 'shortlisted'),
                            child: const Text('Shortlist'),
                          ),
                          OutlinedButton(
                            onPressed: () => _updateStatus(app.id, 'accepted'),
                            child: const Text('Accept'),
                          ),
                          OutlinedButton(
                            onPressed: () => _updateStatus(app.id, 'rejected'),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Seeker Jobs List Screen
class SeekerJobListScreen extends StatelessWidget {
  const SeekerJobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Jobs')),
      body: const Center(child: Text('Browse Jobs - Coming Soon')),
    );
  }
}

// Seeker Profile Screen
class SeekerProfileScreen extends StatelessWidget {
  const SeekerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: const Center(child: Text('Profile - Coming Soon')),
    );
  }
}
