import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/job_provider.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  String _jobType = 'full_time';
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  bool _remote = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Job')),
      body: Consumer<JobProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Job title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _jobType,
                  decoration: const InputDecoration(labelText: 'Job type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'full_time', child: Text('Full time')),
                    DropdownMenuItem(
                        value: 'part_time', child: Text('Part time')),
                    DropdownMenuItem(
                        value: 'contract', child: Text('Contract')),
                    DropdownMenuItem(
                        value: 'internship', child: Text('Internship')),
                  ],
                  onChanged: (value) =>
                      setState(() => _jobType = value ?? 'full_time'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryMinController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Salary min (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salaryMaxController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Salary max (optional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _requirementsController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Requirements'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Remote work allowed'),
                  value: _remote,
                  onChanged: (value) => setState(() => _remote = value),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline'),
                  subtitle: Text(
                    '${_deadline.year}-${_deadline.month.toString().padLeft(2, '0')}-${_deadline.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDeadline,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: provider.isLoading ? null : _submit,
                  child: Text(provider.isLoading ? 'Posting...' : 'Post Job'),
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _deadline,
    );
    if (selected == null || !mounted) return;
    setState(() => _deadline = selected);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final salaryMin = double.tryParse(_salaryMinController.text.trim());
    final salaryMax = double.tryParse(_salaryMaxController.text.trim());

    if (salaryMin != null && salaryMax != null && salaryMin > salaryMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salary min cannot exceed salary max.')),
      );
      return;
    }

    final provider = context.read<JobProvider>();
    final success = await provider.createJob(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      requirements: _requirementsController.text.trim(),
      jobType: _jobType,
      location: _locationController.text.trim(),
      deadlineAt: _deadline.toIso8601String(),
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      remote: _remote,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Job posted successfully.'
            : (provider.error ?? 'Failed to post job.')),
      ),
    );
    if (success) Navigator.of(context).pop();
  }
}
