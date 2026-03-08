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
import 'package:portfolioph/data/services/profile_service.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _schoolController = TextEditingController();
  final _courseController = TextEditingController();

  final _profileService = ProfileService();
  final _imagePicker = ImagePicker();

  String? _avatarPath;
  String? _selectedYearLevel;
  bool _isSaving = false;

  static const List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Graduate',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _schoolController.dispose();
    _courseController.dispose();
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
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) {
      context.go('/login');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build the bio note: "School | Course | Year Level"
      final schoolInfo = [
        _schoolController.text.trim(),
        _courseController.text.trim(),
        _selectedYearLevel ?? '',
      ].where((s) => s.isNotEmpty).join(' · ');

      final updated = user.copyWith(
        avatarPath: _avatarPath ?? user.avatarPath,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        location: schoolInfo.isEmpty ? user.location : schoolInfo,
      );

      final saved = await _profileService.updateProfile(updated);
      authProvider.updateCurrentUser(saved);

      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Set Up Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => context.go('/dashboard'),
            child: const Text('Skip', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Avatar ───────────────────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: _avatarImage(),
                        child: _avatarPath == null
                            ? Text(
                                user != null
                                    ? (user.fullName?.isNotEmpty == true
                                          ? user.fullName![0].toUpperCase()
                                          : user.username[0].toUpperCase())
                                    : '?',
                                style: const TextStyle(
                                  fontSize: AppConstants.fontSizeDisplay,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarSourceSheet,
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppConstants.spacingXs,
                            ),
                            decoration: const BoxDecoration(
                              color: AppConstants.accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // ── Card for form fields ─────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Bio ──────────────────────────────────────────
                        TextFormField(
                          controller: _bioController,
                          maxLines: 3,
                          maxLength: AppConstants.maxBioLength,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Bio (optional)',
                            hintText: 'A short intro about yourself…',
                            prefixIcon: Icon(Icons.edit_note_rounded),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        // ── School ───────────────────────────────────────
                        TextFormField(
                          controller: _schoolController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'School / University (optional)',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        // ── Course ───────────────────────────────────────
                        TextFormField(
                          controller: _courseController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Course (optional)',
                            hintText: 'e.g. BSIT, BSCS, BSIS…',
                            prefixIcon: Icon(Icons.book_outlined),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        // ── Year Level ───────────────────────────────────
                        DropdownButtonFormField<String>(
                          value: _selectedYearLevel,
                          decoration: const InputDecoration(
                            labelText: 'Year Level (optional)',
                            prefixIcon: Icon(Icons.stairs_outlined),
                          ),
                          items: _yearLevels
                              .map(
                                (y) =>
                                    DropdownMenuItem(value: y, child: Text(y)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedYearLevel = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // ── Save button ──────────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? 'Saving…' : 'Save & Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Avatar image provider ─────────────────────────────────────────────────────
  ImageProvider<Object>? _avatarImage() {
    if (_avatarPath == null) return null;
    if (kIsWeb) return NetworkImage(_avatarPath!);
    return FileImage(File(_avatarPath!));
  }
}
