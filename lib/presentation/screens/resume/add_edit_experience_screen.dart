import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';

class AddEditExperienceScreen extends StatefulWidget {
  final int userId;
  final ExperienceModel? initialExperience;

  const AddEditExperienceScreen({
    super.key,
    required this.userId,
    this.initialExperience,
  });

  @override
  State<AddEditExperienceScreen> createState() =>
      _AddEditExperienceScreenState();
}

class _AddEditExperienceScreenState extends State<AddEditExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentlyEmployed = false;
  bool _isSaving = false;
  int _currentStep = 0;
  String _employmentType = 'Full-time';
  static const List<String> _employmentTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Temporary',
    'Internship',
    'Freelance',
  ];

  bool get _isEdit => widget.initialExperience != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialExperience;
    if (initial == null) return;

    _companyController.text = initial.company;
    _jobTitleController.text = initial.jobTitle;
    _descriptionController.text = initial.description ?? '';
    _locationController.text = initial.location ?? '';
    _startDate = _parseIso(initial.startDate);
    _endDate = _parseIso(initial.endDate);
    _isCurrentlyEmployed =
        (initial.endDate == null || initial.endDate!.isEmpty);
    if (initial.employmentType != null) {
      _employmentType = initial.employmentType!;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  DateTime? _parseIso(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }

  String _toIso(DateTime? date) {
    if (date == null) return '';
    return date.toUtc().toIso8601String();
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initial = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime(1990);
    final lastDate = DateTime.now().add(const Duration(days: 365 * 4));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix errors in the form.')),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Start date is required.')));
      return;
    }

    if (!_isCurrentlyEmployed && _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('End date is required.')));
      return;
    }

    final experience = ExperienceModel(
      id: widget.initialExperience?.id,
      userId: widget.userId,
      company: _companyController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      employmentType: _employmentType,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      startDate: _toIso(_startDate),
      endDate: _isCurrentlyEmployed ? '' : _toIso(_endDate),
      isCurrent: _isCurrentlyEmployed,
      sortOrder: widget.initialExperience?.sortOrder ?? 0,
      createdAt:
          widget.initialExperience?.createdAt ??
          DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    final experienceProvider = context.read<ExperienceProvider>();
    setState(() => _isSaving = true);

    final success = _isEdit
      ? await experienceProvider.updateExperience(experience)
      : await experienceProvider.addExperience(experience);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final error = experienceProvider.errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'An error occurred.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit Experience' : 'Add Experience';
    final steps = _buildSteps(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (index) => setState(() => _currentStep = index),
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == steps.length - 1;
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 170,
                    child: FilledButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () {
                              if (isLastStep) {
                                _submit();
                              } else {
                                setState(() => _currentStep += 1);
                              }
                            },
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isLastStep
                                  ? Icons.save_outlined
                                  : Icons.arrow_forward,
                            ),
                      label: Text(isLastStep ? 'Save Entry' : 'Continue'),
                    ),
                  ),
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _currentStep -= 1),
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: steps,
        ),
      ),
    );
  }

  List<Step> _buildSteps(BuildContext context) {
    return [
      Step(
        title: const Text('Company & Job Title'),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            TextFormField(
              controller: _companyController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                hintText: 'e.g., TechCorp Inc.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Company name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _jobTitleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                hintText: 'e.g., Software Developer',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Job title is required.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Details'),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _employmentType,
              decoration: const InputDecoration(labelText: 'Employment Type'),
              items: _employmentTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _employmentType = value);
                }
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g., Manila, Philippines',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _descriptionController,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
              minLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Describe your responsibilities and achievements...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Dates'),
        isActive: _currentStep >= 2,
        content: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      hintText: _startDate == null
                          ? 'Select start date'
                          : DateFormat('MMM dd, yyyy').format(_startDate!),
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    onTap: () => _selectDate(isStartDate: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            CheckboxListTile(
              value: _isCurrentlyEmployed,
              onChanged: (value) {
                setState(() => _isCurrentlyEmployed = value ?? false);
              },
              title: const Text('Currently employed here'),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isCurrentlyEmployed) ...[
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        hintText: _endDate == null
                            ? 'Select end date'
                            : DateFormat('MMM dd, yyyy').format(_endDate!),
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      onTap: () => _selectDate(isStartDate: false),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      Step(
        title: const Text('Confirm'),
        isActive: _currentStep >= 3,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow('Company', _companyController.text),
            _buildConfirmRow('Job Title', _jobTitleController.text),
            _buildConfirmRow('Employment Type', _employmentType),
            if (_locationController.text.trim().isNotEmpty)
              _buildConfirmRow('Location', _locationController.text),
            _buildConfirmRow(
              'Start Date',
              _startDate == null
                  ? '—'
                  : DateFormat('MMM dd, yyyy').format(_startDate!),
            ),
            _buildConfirmRow(
              'Employment Status',
              _isCurrentlyEmployed
                  ? 'Currently employed'
                  : DateFormat(
                      'MMM dd, yyyy',
                    ).format(_endDate ?? DateTime.now()),
            ),
            if (_descriptionController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Description', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                _descriptionController.text,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
