// lib/presentation/screens/auth/profile_setup_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Profile setup screen – Sprint 2.
//
// Shown once, immediately after successful registration.
// Lets the user fill in optional profile fields before reaching the dashboard.
//
// Fields:
//   • Avatar  — image_picker (camera or gallery); stored as local file path.
//   • Bio     — multi-line text, max AppConstants.maxBioLength chars.
//   • School  — free text.
//   • Course  — free text (e.g. BSIT, BSCS).
//   • Year Level — dropdown (1st – 4th + Graduate).
//
// On save → ProfileService.updateProfile → AuthProvider.updateCurrentUser
//         → navigate to /dashboard.
// Skip    → navigate to /dashboard without changes.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';
import 'package:portfolioph/data/services/profile_service.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _professionController = TextEditingController();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _courseController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _portfolioUrlController = TextEditingController();
  final _linkedinUrlController = TextEditingController();
  final _salaryExpectationController = TextEditingController();

  late ProfileService _profileService;
  bool _didInitService = false;
  final _imagePicker = ImagePicker();

  String? _avatarPath;
  String? _selectedYearLevel;
  String? _selectedExperience;
  String? _selectedAvailability;
  bool _isSaving = false;
  int _currentStep = 0;

  static const List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate',
  ];

  static const List<String> _experienceLevels = [
    'Entry Level (0-1 years)',
    'Junior (1-3 years)',
    'Intermediate (3-5 years)',
    'Senior (5-10 years)',
    'Expert (10+ years)',
  ];

  static const List<String> _availabilityOptions = [
    'Immediately Available',
    'Available in 2 weeks',
    'Available in 1 month',
    'Not currently available',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitService) return;
    _profileService = ProfileService(
      userRepository: context.read<UserRepository>(),
    );
    _didInitService = true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _schoolController.dispose();
    _courseController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _portfolioUrlController.dispose();
    _linkedinUrlController.dispose();
    _salaryExpectationController.dispose();
    super.dispose();
  }

  // ── Avatar picker ─────────────────────────────────────────────────────────────
  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _avatarPath = picked.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access image. Check permissions.'),
        ),
      );
    }
  }

  void _showAvatarSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────────
  Future<void> _handleSaveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User session expired.')));
        context.go('/login');
        return;
      }

      final schoolInfo = [
        _schoolController.text.trim(),
        _courseController.text.trim(),
        _selectedYearLevel ?? '',
      ].where((s) => s.isNotEmpty).join(' · ');

      final profileSummary = [
        _professionController.text.trim(),
        if (schoolInfo.isNotEmpty) schoolInfo,
        if (_selectedExperience?.trim().isNotEmpty ?? false)
          _selectedExperience!,
        if (_selectedAvailability?.trim().isNotEmpty ?? false)
          _selectedAvailability!,
        if (_skillsController.text.trim().isNotEmpty)
          'Skills: ${_skillsController.text.trim()}',
        if (_experienceController.text.trim().isNotEmpty)
          'Experience: ${_experienceController.text.trim()}',
        if (_salaryExpectationController.text.trim().isNotEmpty)
          'Salary expectation: ${_salaryExpectationController.text.trim()}',
      ].where((item) => item.isNotEmpty).join(' | ');

      final updated = user.copyWith(
        avatarPath: _avatarPath ?? user.avatarPath,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? (profileSummary.isEmpty ? null : profileSummary)
            : [
                _bioController.text.trim(),
                if (profileSummary.isNotEmpty) profileSummary,
              ].join('\n\n'),
        location: _locationController.text.trim().isEmpty
            ? schoolInfo
            : _locationController.text.trim(),
        websiteUrl: _portfolioUrlController.text.trim().isEmpty
            ? null
            : _portfolioUrlController.text.trim(),
      );

      final saved = await _profileService.updateProfile(updated);
      authProvider.updateCurrentUser(saved);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _skipProfileSetup() {
    context.go('/dashboard');
  }

  // ── Build ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 640;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withAlpha(20),
              colorScheme.primaryContainer.withAlpha(15),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Complete Your Profile',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Let employers know who you are',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _skipProfileSetup,
                          child: Text(
                            'Skip',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Progress indicator
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / 4,
                        minHeight: 4,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: _buildCurrentStep(context, theme),
                    ),

                    const SizedBox(height: 32),

                    // Navigation buttons
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _currentStep--);
                              },
                              child: const Text('Back'),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    if (_currentStep < 3) {
                                      setState(() => _currentStep++);
                                    } else {
                                      _handleSaveProfile();
                                    }
                                  },
                            child: Text(
                              _currentStep < 3 ? 'Next' : 'Complete Profile',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep(context, theme);
      case 1:
        return _buildEducationStep(context, theme);
      case 2:
        return _buildCareerStep(context, theme);
      case 3:
        return _buildLinksStep(context, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Basic Information
  Widget _buildBasicInfoStep(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _showAvatarSourceSheet,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppConstants.primaryColor.withAlpha(100),
                      width: 2,
                    ),
                  ),
                  child: _avatarPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: kIsWeb
                              ? Image.network(_avatarPath!, fit: BoxFit.cover)
                              : Image.file(
                                  File(_avatarPath!),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          size: 40,
                          color: AppConstants.primaryColor,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add a professional photo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Full Name
        TextFormField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person_outline_rounded),
            hintText: 'Your full name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number (Optional)',
            prefixIcon: Icon(Icons.phone_outlined),
            hintText: '+63 9XX XXX XXXX',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Location
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Province/City (Optional)',
            prefixIcon: Icon(Icons.location_on_outlined),
            hintText: 'e.g., Manila, Cebu, Davao',
          ),
        ),
        const SizedBox(height: 16),

        // Professional Title
        TextFormField(
          controller: _professionController,
          decoration: const InputDecoration(
            labelText: 'Professional Title/Role *',
            prefixIcon: Icon(Icons.work_outline_rounded),
            hintText: 'e.g., Senior UI/UX Designer',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Professional title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Bio
        TextFormField(
          controller: _bioController,
          maxLines: 4,
          maxLength: AppConstants.maxBioLength,
          decoration: const InputDecoration(
            labelText: 'Professional Bio (Optional)',
            prefixIcon: Icon(Icons.description_outlined),
            hintText: 'Brief summary about yourself and your expertise',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // Step 2: Education
  Widget _buildEducationStep(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Education Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),

        // School
        TextFormField(
          controller: _schoolController,
          decoration: const InputDecoration(
            labelText: 'School/University (Optional)',
            prefixIcon: Icon(Icons.school_outlined),
            hintText: 'e.g., University of the Philippines',
          ),
        ),
        const SizedBox(height: 16),

        // Course
        TextFormField(
          controller: _courseController,
          decoration: const InputDecoration(
            labelText: 'Degree/Course (Optional)',
            prefixIcon: Icon(Icons.book_outlined),
            hintText: 'e.g., Bachelor of Science in Information Technology',
          ),
        ),
        const SizedBox(height: 16),

        // Year Level
        DropdownButtonFormField<String>(
          initialValue: _selectedYearLevel,
          decoration: const InputDecoration(
            labelText: 'Year Level (Optional)',
            prefixIcon: Icon(Icons.calendar_today_outlined),
          ),
          items: _yearLevels
              .map(
                (level) => DropdownMenuItem(value: level, child: Text(level)),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedYearLevel = value);
          },
        ),
      ],
    );
  }

  // Step 3: Career Information
  Widget _buildCareerStep(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),

        // Experience Level
        DropdownButtonFormField<String>(
          initialValue: _selectedExperience,
          decoration: const InputDecoration(
            labelText: 'Experience Level (Optional)',
            prefixIcon: Icon(Icons.trending_up_outlined),
          ),
          items: _experienceLevels
              .map(
                (level) => DropdownMenuItem(value: level, child: Text(level)),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedExperience = value);
          },
        ),
        const SizedBox(height: 16),

        // Skills
        TextFormField(
          controller: _skillsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Key Skills (Optional)',
            prefixIcon: Icon(Icons.stars_outlined),
            hintText: 'e.g., UI/UX Design, Flutter, Figma, JavaScript',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),

        // Availability
        DropdownButtonFormField<String>(
          initialValue: _selectedAvailability,
          decoration: const InputDecoration(
            labelText: 'Availability (Optional)',
            prefixIcon: Icon(Icons.schedule_outlined),
          ),
          items: _availabilityOptions
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _selectedAvailability = value);
          },
        ),
        const SizedBox(height: 16),

        // Salary Expectation
        TextFormField(
          controller: _salaryExpectationController,
          decoration: const InputDecoration(
            labelText: 'Expected Salary (Optional)',
            prefixIcon: Icon(Icons.attach_money_outlined),
            hintText: 'e.g., PHP 50,000 - 70,000',
          ),
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  // Step 4: Links & Portfolio
  Widget _buildLinksStep(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Online Presence',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),

        // Portfolio URL
        TextFormField(
          controller: _portfolioUrlController,
          decoration: const InputDecoration(
            labelText: 'Portfolio Website (Optional)',
            prefixIcon: Icon(Icons.language_outlined),
            hintText: 'https://yourportfolio.com',
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),

        // LinkedIn URL
        TextFormField(
          controller: _linkedinUrlController,
          decoration: const InputDecoration(
            labelText: 'LinkedIn Profile (Optional)',
            prefixIcon: Icon(Icons.business_outlined),
            hintText: 'https://linkedin.com/in/yourprofile',
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 24),

        // Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✓ Profile Complete!',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your profile is ready to showcase to employers. You can always edit these details later in your profile settings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
