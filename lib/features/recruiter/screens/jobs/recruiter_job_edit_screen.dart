import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';

class RecruiterJobEditScreen extends StatefulWidget {
  final int jobId;

  const RecruiterJobEditScreen({super.key, required this.jobId});

  @override
  State<RecruiterJobEditScreen> createState() => _RecruiterJobEditScreenState();
}

class _RecruiterJobEditScreenState extends State<RecruiterJobEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  String _status = 'approved';
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    super.dispose();
  }

  void _populateForm(dynamic job) {
    if (_initialized) return;
    _titleController.text = job.title;
    _descriptionController.text = job.description;
    _locationController.text = job.location;
    _salaryMinController.text = job.salaryMin?.toString() ?? '';
    _salaryMaxController.text = job.salaryMax?.toString() ?? '';
    _status = job.status;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RecruiterJobManagerProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: FutureBuilder(
        future: provider.getJob(widget.jobId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(provider.error ?? 'Failed to load job.'),
            );
          }

          final job = snapshot.data!;
          _populateForm(job);

          return SingleChildScrollView(
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
                  TextFormField(
                    controller: _salaryMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Salary Min'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _salaryMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Salary Max'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'approved', child: Text('Approved')),
                      DropdownMenuItem(value: 'closed', child: Text('Closed')),
                    ],
                    onChanged: (value) => setState(() => _status = value ?? _status),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => _isSaving = true);

                              try {
                                await provider.updateJob(job.id, {
                                  'title': _titleController.text.trim(),
                                  'description': _descriptionController.text.trim(),
                                  'location': _locationController.text.trim(),
                                  'salary_min': double.tryParse(
                                    _salaryMinController.text.trim(),
                                  ),
                                  'salary_max': double.tryParse(
                                    _salaryMaxController.text.trim(),
                                  ),
                                  'status': _status,
                                });

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Job updated successfully.'),
                                  ),
                                );
                                context.go(AppRoutes.recruiterJobsList);
                              } catch (_) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      provider.error ?? 'Failed to update job.',
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isSaving = false);
                                }
                              }
                            },
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
