// lib/presentation/screens/profile/edit_profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Screen for editing user profile with form validation and file uploads.
//
// Features:
//   • Text fields: name, email, location, bio, website
//   • Image picker: upload profile avatar
//   • Form validation: email format, required fields
//   • Loading state: button disabled during submission
//   • Error handling: inline error messages with retry
//   • Success: navigate back to profile screen
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/config/app_config.dart';
import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/exceptions/custom_exceptions.dart';
import 'package:portfolioph/core/utils/logging_utils.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/profile_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _phoneController;

  File? _selectedAvatar;
  File? _selectedResume;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser != null) {
      _nameController = TextEditingController(text: currentUser.fullName ?? '');
      _emailController = TextEditingController(text: currentUser.email);
      _bioController = TextEditingController(text: currentUser.bio ?? '');
      _locationController = TextEditingController(text: currentUser.location ?? '');
      _websiteController = TextEditingController(text: currentUser.websiteUrl ?? '');
      _phoneController = TextEditingController(text: currentUser.phoneNumber ?? '');
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _bioController = TextEditingController();
      _locationController = TextEditingController();
      _websiteController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedAvatar = File(image.path);
        });
      }
    } catch (e) {
      AppLogger.error('Avatar picker error', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  /// Picks a PDF resume file with validation.
  /// 
  /// Validates:
  /// - File must be PDF (.pdf extension)
  /// - File size must be < 5MB
  /// - Shows error message if validation fails
  /// 
  /// Production Implementation:
  /// Add `file_picker: ^5.3.0` to pubspec.yaml and uncomment FilePicker code below.
  /// 
  /// For MVP, demonstrates validation approach even without picker.
  Future<void> _pickResume() async {
    try {
      // Production: Uncomment when file_picker is added to pubspec.yaml
      // 
      // const List<String> extensions = ['pdf'];
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: extensions,
      //   onFileLoading: (FilePickerStatus status) {
      //     debugPrint('File picker status: $status');
      //   },
      // );
      //
      // if (result != null && result.files.isNotEmpty) {
      //   final pickedFile = result.files.first;
      //   final file = File(pickedFile.path!);
      //
      //   // Validate using FilePickerService
      //   final errorMessage = FilePickerService.validateResume(file);
      //   if (errorMessage != null) {
      //     if (mounted) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(content: Text(errorMessage)),
      //       );
      //     }
      //     return;
      //   }
      //
      //   // Valid file - store selection
      //   setState(() {
      //     _selectedResume = file;
      //   });
      // }
      
      // MVP: Show informational message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Resume: Add file_picker: ^5.3.0 to pubspec.yaml'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
      
      debugPrint('''
      === RESUME UPLOAD GUIDE ===
      To enable PDF resume uploads in production:
      
      1. Add to pubspec.yaml:
         file_picker: ^5.3.0
      
      2. Run: flutter pub get
      
      3. Uncomment FilePicker code in _pickResume() method
      
      4. Platform-specific setup:
         - Android: Update AndroidManifest.xml permissions
         - iOS: Update Info.plist with NSPhotoLibraryUsageDescription
         - Windows: No additional setup needed
      
      5. Validation is handled by FilePickerService
      ''');
    } catch (e) {
      debugPrint('Error in resume picker: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _submit(ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await profileProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        websiteUrl: _websiteController.text.trim(),
        avatarFile: _selectedAvatar,
        resumeFile: _selectedResume,
      );

      if (!mounted) return;

      if (success) {
        // Update auth provider with new profile
        final updatedUser = profileProvider.currentProfile;
        if (updatedUser != null) {
          context.read<AuthProvider>().updateCurrentUser(updatedUser);
        }
        context.go('/profile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.errorMessage ?? 'Update failed'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _submit(profileProvider),
            ),
          ),
        );
      }
    } on UnauthorizedException {
      // Handle token expiry
      AppLogger.warning('Token expired');
      if (mounted) {
        await context.read<AuthProvider>().handleTokenExpired();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your session has expired. Please log in again.'),
            ),
          );
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('No active session')),
      );
    }

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        return PremiumAppBackground(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Avatar Section ───────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              image: _selectedAvatar != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedAvatar!),
                                      fit: BoxFit.cover,
                                    )
                                  : (currentUser.avatarPath != null
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/storage/${currentUser.avatarPath}',
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: _selectedAvatar == null &&
                                    currentUser.avatarPath == null
                                ? Icon(
                                    Icons.person_outline,
                                    size: 50,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed:
                                profileProvider.isLoading ? null : _pickAvatar,
                            child: const Text('Change Avatar'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // ── Name ────────────────────────────────────────────────
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        label: Text('Full Name'),
                        hintText: 'Enter your full name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Email ───────────────────────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        label: Text('Email'),
                        hintText: 'Enter your email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Phone Number ────────────────────────────────────────
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        label: Text('Phone Number'),
                        hintText: 'Enter your phone number',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // ── Location ────────────────────────────────────────────
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        label: Text('Location'),
                        hintText: 'Enter your location',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Bio ─────────────────────────────────────────────────
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        label: Text('Bio'),
                        hintText: 'Tell us about yourself',
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),

                    // ── Website URL ────────────────────────────────────────
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        label: Text('Website/Portfolio URL'),
                        hintText: 'https://example.com',
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Resume Upload ───────────────────────────────────────
                    Text(
                      'Resume (Optional)',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resume info
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedResume != null
                                          ? _selectedResume!.path.split('/').last
                                          : 'No resume selected',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'PDF only, max 5MB',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                            onPressed: profileProvider.isLoading
                                ? null
                                : _pickResume,
                            child: const Text('Choose PDF'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Error Message ───────────────────────────────────────
                    if (profileProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: Text(
                          profileProvider.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Submit Button ───────────────────────────────────────
                    FilledButton(
                      onPressed: profileProvider.isLoading
                          ? null
                          : () => _submit(profileProvider),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: profileProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
