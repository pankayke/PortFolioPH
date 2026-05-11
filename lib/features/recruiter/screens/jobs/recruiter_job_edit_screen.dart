import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return PremiumAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Job'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FutureBuilder(
          future: provider.getJob(widget.jobId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: RecruiterGlassCard(
                    child: Text(provider.error ?? 'Failed to load job.'),
                  ),
                ),
              );
            }

            final job = snapshot.data!;
            _populateForm(job);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RecruiterGlassCard(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.14),
                      colorScheme.surface.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Job Posting',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Refine the role details, salary, and publishing status without breaking the existing posting.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                RecruiterGlassCard(
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
                        Row(
                          children: [
                            Expanded(
                              child: _glassField(
                                controller: _salaryMinController,
                                label: 'Salary Min',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _glassField(
                                controller: _salaryMaxController,
                                label: 'Salary Max',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: _glassDecoration('Status'),
                          dropdownColor: colorScheme.surface,
                          style: Theme.of(context).textTheme.bodyMedium,
                          items: const [
                            DropdownMenuItem(
                              value: 'draft',
                              child: Text('Draft'),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'approved',
                              child: Text('Approved'),
                            ),
                            DropdownMenuItem(
                              value: 'closed',
                              child: Text('Closed'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _status = value ?? _status),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
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

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Job updated successfully.'),
                                ),
                              );
                              context.go(AppRoutes.recruiterJobsList);
                            } catch (_) {
                              if (!context.mounted) return;
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
                    icon: const Icon(Icons.save_outlined),
                    label: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _glassDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: DesignTokens.accentPurple),
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
      decoration: _glassDecoration(label),
    );
  }
}
