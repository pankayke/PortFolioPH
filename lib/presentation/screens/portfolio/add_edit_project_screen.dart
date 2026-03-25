import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/validators.dart';
import 'package:portfolioph/data/models/project_model.dart';
import 'package:portfolioph/data/services/image_storage_service.dart';
import 'package:portfolioph/presentation/providers/portfolio_provider.dart';

class AddEditProjectScreen extends StatefulWidget {
  final int userId;
  final int portfolioId;
  final ProjectModel? initialProject;

  const AddEditProjectScreen({
    super.key,
    required this.userId,
    required this.portfolioId,
    this.initialProject,
  });

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _repoUrlController = TextEditingController();
  final _liveDemoUrlController = TextEditingController();
  final ImageStorageService _imageStorageService = ImageStorageService();

  List<String> _imagePaths = [];
  bool _isSaving = false;
  bool _isFeatured = false;
  int _currentStep = 0;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _isEditMode => widget.initialProject != null;

  @override
  void initState() {
    super.initState();
    final project = widget.initialProject;
    if (project != null) {
      _titleController.text = project.title;
      _descriptionController.text = project.description ?? '';
      _techStackController.text = project.techStack ?? '';
      _repoUrlController.text = project.repositoryUrl ?? '';
      _liveDemoUrlController.text = project.liveDemoUrl ?? '';
      _isFeatured = project.isFeatured;
      _imagePaths = project.imagePaths.isNotEmpty
          ? List<String>.from(project.imagePaths)
          : project.thumbnailPath == null
          ? <String>[]
          : <String>[project.thumbnailPath!];

      if (project.startDate != null && project.startDate!.isNotEmpty) {
        _startDate = DateTime.tryParse(project.startDate!);
      }
      if (project.endDate != null && project.endDate!.isNotEmpty) {
        _endDate = DateTime.tryParse(project.endDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _repoUrlController.dispose();
    _liveDemoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final updatedImages = await _imageStorageService.pickAndStoreImages(
      existingPaths: _imagePaths,
      maxImages: AppConstants.maxProjectImages,
    );

    if (!mounted) return;

    setState(() {
      _imagePaths = updatedImages;
    });

    if (updatedImages.length == AppConstants.maxProjectImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 5 images reached.')),
      );
    }
  }

  Future<void> _removeImage(String imagePath) async {
    await _imageStorageService.deleteImage(imagePath);
    if (!mounted) return;

    setState(() {
      _imagePaths = _imagePaths
          .where((path) => path != imagePath)
          .toList(growable: false);
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
    );

    if (!mounted || selected == null) return;

    setState(() {
      if (isStart) {
        _startDate = selected;
        if (_endDate != null && _endDate!.isBefore(selected)) {
          _endDate = null;
        }
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final initial = widget.initialProject;

    final project = ProjectModel(
      id: initial?.id,
      portfolioId: widget.portfolioId,
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      techStack: _techStackController.text.trim().isEmpty
          ? null
          : _techStackController.text.trim(),
      repositoryUrl: _repoUrlController.text.trim().isEmpty
          ? null
          : _repoUrlController.text.trim(),
      liveDemoUrl: _liveDemoUrlController.text.trim().isEmpty
          ? null
          : _liveDemoUrlController.text.trim(),
      thumbnailPath: _imagePaths.isEmpty ? null : _imagePaths.first,
      imagePaths: _imagePaths,
      startDate: _startDate?.toUtc().toIso8601String(),
      endDate: _endDate?.toUtc().toIso8601String(),
      isFeatured: _isFeatured,
      sortOrder: initial?.sortOrder ?? 0,
      createdAt: initial?.createdAt ?? nowIso,
      updatedAt: nowIso,
    );

    final provider = context.read<PortfolioProvider>();
    final success = _isEditMode
        ? await provider.updateProject(project, userId: widget.userId)
        : await provider.addProject(project, userId: widget.userId);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.errorMessage ?? 'Unable to save project.'),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Portfolio Entry' : 'Add Portfolio Entry',
        ),
      ),
      body: SafeArea(
        child: Form(
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
                                  _saveProject();
                                } else {
                                  setState(() => _currentStep += 1);
                                }
                              },
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isLastStep
                                    ? Icons.save_outlined
                                    : Icons.arrow_forward,
                              ),
                        label: Text(
                          isLastStep
                              ? (_isEditMode ? 'Save Changes' : 'Create Entry')
                              : 'Continue',
                        ),
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
      ),
    );
  }

  List<Step> _buildSteps(BuildContext context) {
    return [
      Step(
        title: const Text('Basics'),
        isActive: _currentStep >= 0,
        content: Column(
          children: [
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Entry Title',
                hintText: 'Science Fair Exhibit',
              ),
              validator: (value) => AppValidators.validateRequired(
                value,
                fieldName: 'Entry title',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _descriptionController,
              maxLength: AppConstants.maxProjectDescriptionLength,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your work, process, and results.',
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _techStackController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tools / Skills Used',
                hintText: 'Canva, Google Docs, Flutter',
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Links & Dates'),
        isActive: _currentStep >= 1,
        content: Column(
          children: [
            TextFormField(
              controller: _repoUrlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Reference Link (Optional)',
                hintText: 'https://example.com/reference',
              ),
              validator: AppValidators.validateOptionalUrl,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextFormField(
              controller: _liveDemoUrlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Output / Presentation Link (Optional)',
                hintText: 'https://example.com/presentation',
              ),
              validator: AppValidators.validateOptionalUrl,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            SwitchListTile.adaptive(
              value: _isFeatured,
              onChanged: (value) => setState(() => _isFeatured = value),
              contentPadding: EdgeInsets.zero,
              title: const Text('Feature this project'),
              subtitle: const Text(
                'Featured entries appear on your dashboard.',
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Start Date',
                    value: _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: _DateButton(
                    label: 'End Date',
                    value: _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Gallery'),
        isActive: _currentStep >= 2,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Entry Gallery (${_imagePaths.length}/${AppConstants.maxProjectImages})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            if (_imagePaths.isEmpty)
              const Text(
                'No images selected yet.',
                style: TextStyle(color: Colors.grey),
              )
            else
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppConstants.spacingSm),
                  itemBuilder: (context, index) {
                    final imagePath = _imagePaths[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMd,
                          ),
                          child: Image.file(
                            File(imagePath),
                            width: 120,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 120,
                                  height: 110,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(imagePath),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    ];
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Select'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';

    return OutlinedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(label), const SizedBox(height: 2), Text(text)],
        ),
      ),
    );
  }
}
