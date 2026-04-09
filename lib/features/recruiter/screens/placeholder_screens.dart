// Functional recruiter screens used by recruiter routes.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job posted successfully.')));
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
    final colorScheme = Theme.of(context).colorScheme;

    return PremiumAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Create Job'),
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: RecruiterGlassCard(
            gradient: LinearGradient(
              colors: [
                colorScheme.surface.withValues(alpha: 0.18),
                colorScheme.primary.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _glassField(
                    controller: _titleController,
                    label: 'Job Title',
                    validator: (v) => (v == null || v.trim().length < 5)
                        ? 'Title must be at least 5 characters.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _glassField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 5,
                    validator: (v) => (v == null || v.trim().length < 20)
                        ? 'Description must be at least 20 characters.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _glassField(
                    controller: _locationController,
                    label: 'Location',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Location is required.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _jobType,
                    decoration: _glassDecoration(context, 'Job Type'),
                    dropdownColor: colorScheme.surface,
                    items: const [
                      DropdownMenuItem(
                        value: 'full_time',
                        child: Text('Full Time'),
                      ),
                      DropdownMenuItem(
                        value: 'part_time',
                        child: Text('Part Time'),
                      ),
                      DropdownMenuItem(
                        value: 'contract',
                        child: Text('Contract'),
                      ),
                      DropdownMenuItem(
                        value: 'freelance',
                        child: Text('Freelance'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _jobType = value ?? 'full_time'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _glassField(
                          controller: _salaryMinController,
                          label: 'Salary Min (optional)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _glassField(
                          controller: _salaryMaxController,
                          label: 'Salary Max (optional)',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _glassField(
                    controller: _skillsController,
                    label: 'Required Skills (comma-separated)',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
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
        ),
      ),
    );
  }

  InputDecoration _glassDecoration(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colorScheme.surface.withValues(alpha: 0.15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.50),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _glassDecoration(context, label),
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
    return PremiumAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('My Jobs'),
          backgroundColor: Colors.transparent,
        ),
        body: Consumer<RecruiterJobManagerProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.jobs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.jobs.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 120),
                    RecruiterGlassCard(
                      child: Center(child: Text('No jobs posted yet.')),
                    ),
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: RecruiterGlassCard(
                      onTap: () => context.push('/recruiter/jobs/${job.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${job.location} • ${job.applicationCount} applicants',
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              RecruiterGlowChip(
                                label: job.status.toUpperCase(),
                              ),
                              RecruiterGlowChip(label: job.salaryDisplay),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => context.push(
                                  '/recruiter/jobs/${job.id}/edit',
                                ),
                                label: const Text('Edit'),
                              ),
                              if (job.status != 'closed')
                                TextButton.icon(
                                  icon: const Icon(Icons.pause_circle_outline),
                                  onPressed: () => provider.closeJob(job.id),
                                  label: const Text('Close'),
                                ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => provider.deleteJob(job.id),
                                label: const Text('Delete'),
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
    await context
        .read<RecruiterApplicationManagerProvider>()
        .updateApplicationStatus(applicationId, status);
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
                  if (app.applicantLocation.isNotEmpty)
                    Text(app.applicantLocation),
                  const SizedBox(height: 16),
                  Text(
                    'Cover Letter',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.coverLetter?.trim().isNotEmpty == true
                        ? app.coverLetter!
                        : 'No cover letter provided.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'reviewed');
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Mark Reviewed'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'shortlisted');
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Shortlist'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'accepted');
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Accept'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await _updateStatus(app.id, 'rejected');
                          if (!context.mounted) return;
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
    return PremiumAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Applicants'),
          backgroundColor: Colors.transparent,
        ),
        body: Consumer<RecruiterApplicationManagerProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.applications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.applications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => provider.loadApplications(refresh: true),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 120),
                    RecruiterGlassCard(
                      child: Center(child: Text('No candidates yet.')),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadApplications(refresh: true),
              child: ListView.builder(
                itemCount: provider.applications.length,
                itemBuilder: (context, index) {
                  final app = provider.applications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: RecruiterGlassCard(
                      onTap: () => _openReviewModal(app),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.applicantName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(app.applicantEmail),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              RecruiterGlowChip(label: app.statusDisplay),
                              if (app.applicantLocation.isNotEmpty)
                                RecruiterGlowChip(
                                  label: app.applicantLocation,
                                  glowColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
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
