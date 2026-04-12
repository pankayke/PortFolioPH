import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';

class AddEditEducationScreen extends StatefulWidget {
  final int userId;
  final EducationModel? initialEducation;

  const AddEditEducationScreen({
    super.key,
    required this.userId,
    this.initialEducation,
  });

  @override
  State<AddEditEducationScreen> createState() => _AddEditEducationScreenState();
}

class _AddEditEducationScreenState extends State<AddEditEducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _gradeController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentlyStudying = false;
  bool _isSaving = false;
  int _currentStep = 0;

  bool get _isEdit => widget.initialEducation != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialEducation;
    if (initial == null) return;

    _institutionController.text = initial.institution;
    _degreeController.text = initial.degree;
    _fieldOfStudyController.text = initial.fieldOfStudy;
    _gradeController.text = initial.grade?.toString() ?? '';
    _startDate = _parseIso(initial.startDate);
    _endDate = _parseIso(initial.endDate);
    _isCurrentlyStudying =
        (initial.endDate == null || initial.endDate!.isEmpty);
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _gradeController.dispose();
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
    final firstDate = DateTime(1950);
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

    if (!_isCurrentlyStudying && _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('End date is required.')));
      return;
    }

    final gradeParsed = _gradeController.text.trim().isNotEmpty
        ? double.tryParse(_gradeController.text.trim())
        : null;
    final grade = gradeParsed?.toString();

    final education = EducationModel(
      id: widget.initialEducation?.id,
      userId: widget.userId,
      institution: _institutionController.text.trim(),
      degree: _degreeController.text.trim(),
      fieldOfStudy: _fieldOfStudyController.text.trim(),
      startDate: _toIso(_startDate),
      endDate: _isCurrentlyStudying ? '' : _toIso(_endDate),
      grade: grade,
      sortOrder: widget.initialEducation?.sortOrder ?? 0,
      createdAt:
          widget.initialEducation?.createdAt ??
          DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );

    final educationProvider = context.read<EducationProvider>();
    setState(() => _isSaving = true);

    final success = _isEdit
        ? await educationProvider.updateEducation(education)
        : await educationProvider.addEducation(education);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final error = educationProvider.errorMessage;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'An error occurred.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit Education' : 'Add Education';
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
        title: const Text('Institution & Degree'),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            TextFormField(
              controller: _institutionController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Institution Name',
                hintText: 'e.g., Lyceum Northwestern University',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Institution name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _degreeController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Degree',
                hintText: 'e.g., Bachelor of Science',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Degree is required.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Field of Study & Grade'),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            TextFormField(
              controller: _fieldOfStudyController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Field of Study',
                hintText: 'e.g., Information Technology',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Field of study is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _gradeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'GPA/Grade (Optional)',
                hintText: 'e.g., 3.75 or 96%',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final grade = double.tryParse(value.trim());
                if (grade == null) {
                  return 'Enter a valid number.';
                }
                if (grade < 0 || grade > 4.0) {
                  return 'Grade should be between 0 and 4.0.';
                }
                return null;
              },
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
              value: _isCurrentlyStudying,
              onChanged: (value) {
                setState(() => _isCurrentlyStudying = value ?? false);
              },
              title: const Text('Currently studying'),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isCurrentlyStudying) ...[
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
            _buildConfirmRow('Institution', _institutionController.text),
            _buildConfirmRow('Degree', _degreeController.text),
            _buildConfirmRow('Field of Study', _fieldOfStudyController.text),
            if (_gradeController.text.trim().isNotEmpty)
              _buildConfirmRow('Grade', _gradeController.text),
            _buildConfirmRow(
              'Start Date',
              _startDate == null
                  ? '—'
                  : DateFormat('MMM dd, yyyy').format(_startDate!),
            ),
            _buildConfirmRow(
              'Current Status',
              _isCurrentlyStudying
                  ? 'Currently studying'
                  : DateFormat(
                      'MMM dd, yyyy',
                    ).format(_endDate ?? DateTime.now()),
            ),
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
