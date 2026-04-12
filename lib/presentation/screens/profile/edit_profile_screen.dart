// lib/presentation/screens/profile/edit_profile_screen.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
    _nameController = TextEditingController(text: currentUser?.fullName ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _bioController = TextEditingController(text: currentUser?.bio ?? '');
    _locationController = TextEditingController(text: currentUser?.location ?? '');
    _websiteController = TextEditingController(text: currentUser?.websiteUrl ?? '');
    _phoneController = TextEditingController(text: currentUser?.phoneNumber ?? '');
  }

  Future<void> _pickAvatar() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() => _selectedAvatar = File(image.path));
    } catch (e) {
      AppLogger.error('Avatar picker error', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickResume() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume upload is available from the CV screen.'),
      ),
    );
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
        final updatedUser = profileProvider.currentProfile;
        if (updatedUser != null) {
          context.read<AuthProvider>().updateCurrentUser(updatedUser);
        }
        context.go('/profile');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.errorMessage ?? 'Update failed'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _submit(profileProvider),
          ),
        ),
      );
    } on UnauthorizedException {
      AppLogger.warning('Token expired');
      if (!mounted) return;
      await context.read<AuthProvider>().handleTokenExpired();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
        ),
      );
      context.go('/login');
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
        final colorScheme = Theme.of(context).colorScheme;

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
                    _EditProfileHeaderCard(
                      name: currentUser.fullName ?? currentUser.username,
                      email: currentUser.email,
                      role: currentUser.role,
                      location: currentUser.location,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _AvatarCard(
                      avatarFile: _selectedAvatar,
                      avatarPath: currentUser.avatarPath,
                      onPickAvatar: profileProvider.isLoading ? null : _pickAvatar,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _SectionPanel(
                      title: 'Identity',
                      subtitle: 'These details help recruiters and collaborators find you.',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
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
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: 'Enter your phone number',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'Enter your location',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              hintText: 'Tell us about yourself',
                            ),
                            maxLines: 4,
                            maxLength: 500,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _websiteController,
                            decoration: const InputDecoration(
                              labelText: 'Website/Portfolio URL',
                              hintText: 'https://example.com',
                            ),
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value != null && value.isNotEmpty &&
                                  !value.startsWith('http://') &&
                                  !value.startsWith('https://')) {
                                return 'URL must start with http:// or https://';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    _SectionPanel(
                      title: 'Resume / CV',
                      subtitle: 'Keep your portfolio ready for recruiters.',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: colorScheme.primary,
                                  ),
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
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'PDF only, max 5MB',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: colorScheme.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonalIcon(
                              onPressed: profileProvider.isLoading ? null : _pickResume,
                              icon: const Icon(Icons.upload_file_outlined),
                              label: const Text('Choose PDF'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    if (profileProvider.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.errorContainer.withValues(alpha: 0.42),
                              colorScheme.surface.withValues(alpha: 0.82),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                profileProvider.errorMessage!,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save Changes', style: TextStyle(fontSize: 16)),
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

class _EditProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String? location;

  const _EditProfileHeaderCard({
    required this.name,
    required this.email,
    required this.role,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.16),
            colorScheme.secondary.withValues(alpha: 0.12),
            colorScheme.surface.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep your profile fresh so recruiters see a complete picture at a glance.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniChip(context, name),
              _miniChip(context, email),
              _miniChip(context, role),
              if (location != null && location!.trim().isNotEmpty) _miniChip(context, location!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  final File? avatarFile;
  final String? avatarPath;
  final VoidCallback? onPickAvatar;
  final ColorScheme colorScheme;

  const _AvatarCard({
    required this.avatarFile,
    required this.avatarPath,
    required this.onPickAvatar,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarFile != null || (avatarPath?.trim().isNotEmpty ?? false);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        gradient: LinearGradient(
          colors: [
            colorScheme.surface.withValues(alpha: 0.96),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.68)),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22), width: 2),
              image: avatarFile != null
                  ? DecorationImage(image: FileImage(avatarFile!), fit: BoxFit.cover)
                  : (avatarPath != null && avatarPath!.trim().isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/storage/$avatarPath',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null),
            ),
            child: !hasAvatar
                ? Icon(Icons.person_outline, size: 50, color: colorScheme.primary)
                : null,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: onPickAvatar,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Change Avatar'),
          ),
        ],
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        gradient: LinearGradient(
          colors: [
            colorScheme.surface.withValues(alpha: 0.96),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.68)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
