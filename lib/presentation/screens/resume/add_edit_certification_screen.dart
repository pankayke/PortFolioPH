import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';

class AddEditCertificationScreen extends StatefulWidget {
  final int userId;
  final CertificationModel? initialCertification;

  const AddEditCertificationScreen({
    super.key,
    required this.userId,
    this.initialCertification,
  });

  @override
  State<AddEditCertificationScreen> createState() =>
      _AddEditCertificationScreenState();
}

class _AddEditCertificationScreenState
    extends State<AddEditCertificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _credentialIdController = TextEditingController();
  final _credentialUrlController = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _doesExpire = true;
  bool _isSaving = false;
  int _currentStep = 0;
  String? _imagePath;

  bool get _isEdit => widget.initialCertification != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCertification;
    if (initial == null) return;

    _nameController.text = initial.name;
    _organizationController.text = initial.issuingOrganization;
    _credentialIdController.text = initial.credentialId ?? '';
    _credentialUrlController.text = initial.credentialUrl ?? '';
    _issueDate = _parseIso(initial.issueDate);
    _expiryDate = _parseIso(initial.expiryDate);
    _doesExpire = initial.doesExpire;
    _imagePath = initial.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _credentialIdController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit Certification' : 'Add Certification';
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
              child: Row(
                children: [
                  FilledButton.icon(
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
                    label: Text(isLastStep ? 'Save Certification' : 'Continue'),
                  ),
                  const SizedBox(width: 8),
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
        title: const Text('Details'),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Certification Name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Certification name is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _organizationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Issuing Organization',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Issuing organization is required.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _credentialIdController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Credential ID (optional)',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _credentialUrlController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Credential URL (optional)',
              ),
              validator: (value) {
                final input = value?.trim();
                if (input == null || input.isEmpty) return null;
                final uri = Uri.tryParse(input);
                if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                  return 'Please enter a valid URL.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Validity'),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            _DateInputTile(
              label: 'Issue Date',
              value: _issueDate,
              onTap: () => _pickDate(
                initialDate: _issueDate ?? DateTime.now(),
                onSelected: (date) => setState(() => _issueDate = date),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('This certification expires'),
              value: _doesExpire,
              onChanged: (value) {
                setState(() {
                  _doesExpire = value;
                  if (!value) _expiryDate = null;
                });
              },
            ),
            if (_doesExpire) ...[
              const SizedBox(height: AppConstants.spacingSm),
              _DateInputTile(
                label: 'Expiry Date',
                value: _expiryDate,
                onTap: () => _pickDate(
                  initialDate: _expiryDate ?? DateTime.now(),
                  onSelected: (date) => setState(() => _expiryDate = date),
                ),
              ),
            ],
          ],
        ),
      ),
      Step(
        title: const Text('Media'),
        isActive: _currentStep >= 2,
        content: _CertificationImageField(
          imagePath: _imagePath,
          onPick: _pickImage,
          onRemove: _removeImage,
        ),
      ),
    ];
  }

  Future<void> _pickImage() async {
    final provider = context.read<CertificationProvider>();
    final pickedPath = await provider.pickAndStoreImage();
    if (pickedPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Image not added. File may be too large or selection was cancelled.',
            ),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    final previous = _imagePath;
    setState(() => _imagePath = pickedPath);
    await provider.replaceImage(previousPath: previous, nextPath: pickedPath);
  }

  Future<void> _removeImage() async {
    final current = _imagePath;
    if (current == null) return;

    final provider = context.read<CertificationProvider>();
    await provider.deleteImagePath(current);

    if (!mounted) return;
    setState(() => _imagePath = null);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_doesExpire && _expiryDate != null && _issueDate != null) {
      if (_expiryDate!.isBefore(_issueDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expiry date cannot be earlier than issue date.'),
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    final now = DateTime.now().toUtc().toIso8601String();
    final old = widget.initialCertification;
    final certification = CertificationModel(
      id: old?.id,
      userId: widget.userId,
      name: _nameController.text.trim(),
      issuingOrganization: _organizationController.text.trim(),
      credentialId: _emptyToNull(_credentialIdController.text),
      credentialUrl: _emptyToNull(_credentialUrlController.text),
      issueDate: _issueDate?.toUtc().toIso8601String(),
      expiryDate: _doesExpire ? _expiryDate?.toUtc().toIso8601String() : null,
      doesExpire: _doesExpire,
      imagePath: _imagePath,
      sortOrder: old?.sortOrder ?? 0,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<CertificationProvider>();
    final success = _isEdit
        ? await provider.updateCertification(certification)
        : await provider.addCertification(certification);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to save certification.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 30),
    );

    if (selected == null) return;
    onSelected(selected);
  }

  DateTime? _parseIso(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String? _emptyToNull(String input) {
    final value = input.trim();
    return value.isEmpty ? null : value;
  }
}

class _DateInputTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateInputTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Tap to set date'
        : DateFormat.yMMMd().format(value!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(text),
      ),
    );
  }
}

class _CertificationImageField extends StatelessWidget {
  final String? imagePath;
  final Future<void> Function() onPick;
  final Future<void> Function() onRemove;

  const _CertificationImageField({
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificate Image (optional)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey.shade100,
          ),
          alignment: Alignment.center,
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  child: Image.file(
                    File(imagePath!),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image_outlined, size: 40),
                  ),
                )
              : const Icon(Icons.image_outlined, size: 40),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(hasImage ? 'Replace Image' : 'Add Image'),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: AppConstants.spacingSm),
              IconButton(
                tooltip: 'Remove image',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
