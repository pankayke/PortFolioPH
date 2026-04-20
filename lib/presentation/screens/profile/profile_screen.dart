// lib/presentation/screens/profile/profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Profile tab.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/mixins/screen_mixins.dart';
import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';
import 'package:portfolioph/presentation/providers/file_download_provider.dart';
import 'package:portfolioph/presentation/providers/skills_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
import 'package:portfolioph/presentation/widgets/file_download_widgets.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with UserAwareScreenMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadDataForUserWithId((userId) {
      context.read<ExperienceProvider>().loadForUser(userId);
      context.read<SkillsProvider>().loadForUser(userId);
      context.read<EducationProvider>().loadForUser(userId);
      context.read<CertificationProvider>().loadForUser(userId);
    });
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No active session. Please log in again.')),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final displayName = (user.fullName?.trim().isNotEmpty ?? false)
        ? user.fullName!
        : user.username;
    final roleLabel = user.role
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
    final locationBadges = (user.location?.trim().isNotEmpty ?? false)
        ? user.location!
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
        : const <String>[];
    final experience = context.watch<ExperienceProvider>().experience;
    final skills = context.watch<SkillsProvider>().skills;
    final education = context.watch<EducationProvider>().education;
    final certifications = context
        .watch<CertificationProvider>()
        .certifications;

    return PremiumAppBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: themeProvider.themeMode == ThemeMode.dark
                      ? const Icon(Icons.light_mode_outlined)
                      : const Icon(Icons.dark_mode_outlined),
                  tooltip: 'Toggle theme',
                  onPressed: () => themeProvider.toggleDarkMode(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Log Out',
              onPressed: () => _logout(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.16),
                    colorScheme.secondary.withValues(alpha: 0.10),
                  ],
                ),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  _Avatar(imagePath: user.avatarPath, displayName: displayName),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locationBadges.isNotEmpty
                              ? '$roleLabel | ${locationBadges.first}'
                              : roleLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        if (locationBadges.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: locationBadges
                                .map(
                                  (badge) => Chip(
                                    label: Text(badge),
                                    avatar: const Icon(Icons.flag, size: 14),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _InfoChip(
                              icon: Icons.pin_drop_outlined,
                              text: user.location ?? 'No location',
                            ),
                            _InfoChip(
                              icon: Icons.language_outlined,
                              text: user.websiteUrl ?? 'No website',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _ProfileMomentumCard(
              displayName: displayName,
              roleLabel: roleLabel,
              experienceCount: experience.length,
              skillsCount: skills.length,
              educationCount: education.length,
              certificationCount: certifications.length,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'About',
              child: Text(
                (user.bio?.trim().isNotEmpty ?? false)
                    ? user.bio!
                    : 'Add a short bio to introduce your strengths to recruiters.',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Experience',
              child: experience.isEmpty
                  ? const Text(
                      'No experience added yet. Add your latest role in Resume.',
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${experience.first.jobTitle} @ ${experience.first.company}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${experience.first.startDate ?? 'Start date not set'}'
                          '${experience.first.isCurrent ? ' - Present' : (experience.first.endDate != null ? ' - ${experience.first.endDate}' : '')}',
                        ),
                        if (experience.first.description?.trim().isNotEmpty ??
                            false) ...[
                          const SizedBox(height: 6),
                          Text(experience.first.description!),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Skills',
              child: skills.isEmpty
                  ? const Text(
                      'No skills added yet. Add your strongest skills in the Skills tab.',
                    )
                  : Column(
                      children: skills
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(child: Text(item.name)),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < item.proficiency
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 18,
                                        color: index < item.proficiency
                                            ? AppConstants.warningColor
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Resume / CV',
              child: Consumer<FileDownloadProvider>(
                builder: (context, downloadProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download your current CV or upload a fresh version.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: DownloadButton(
                          label: 'Download CV',
                          icon: Icons.file_download_outlined,
                          isLoading: downloadProvider.isDownloading,
                          onPressed: () {
                            if (downloadProvider.isDownloading) return;
                            downloadProvider.downloadMyCV();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.upload_file_outlined),
                          label: const Text('Upload CV'),
                          onPressed: () {
                            context.push(AppRoutes.seekerCvUpload);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Education & Certifications',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (education.isEmpty && certifications.isEmpty)
                    const Text(
                      'No education or certifications added yet. Add them in Resume to strengthen your profile.',
                    ),
                  if (education.isNotEmpty)
                    Text(
                      '${education.first.degree} - ${education.first.institution}',
                    ),
                  if (certifications.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(certifications.take(2).map((c) => c.name).join(' • ')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Contact',
              child: Column(
                children: [
                  _ContactRow(
                    icon: Icons.alternate_email_rounded,
                    value: user.username,
                  ),
                  const Divider(height: 16),
                  _ContactRow(
                    icon: Icons.phone_outlined,
                    value: user.phoneNumber ?? 'No phone number',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Preferences',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    subtitle: const Text('Theme, display, and app preferences'),
                    onTap: () => context.push('/settings'),
                  ),
                  if (user.role == AppConstants.roleAdmin) ...[
                    const Divider(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: const Text('Admin dashboard'),
                      subtitle: const Text('Manage platform-level features'),
                      onTap: () => context.push('/admin-dashboard'),
                    ),
                  ],
                  if (user.role == AppConstants.roleTeacher ||
                      user.role == AppConstants.roleCoordinator ||
                      user.role == AppConstants.roleAdmin) ...[
                    const Divider(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.groups_2_outlined),
                      title: const Text('Teacher dashboard'),
                      subtitle: const Text(
                        'View student progress by class and section',
                      ),
                      onTap: () => context.push('/teacher-dashboard'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imagePath;
  final String displayName;

  const _Avatar({required this.imagePath, required this.displayName});

  @override
  Widget build(BuildContext context) {
    if (imagePath != null && imagePath!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 36,
        backgroundImage: FileImage(File(imagePath!)),
      );
    }

    return CircleAvatar(
      radius: 36,
      child: Text(
        displayName.characters.first.toUpperCase(),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(text, overflow: TextOverflow.ellipsis),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        gradient: LinearGradient(
          colors: [
            colorScheme.surface.withValues(alpha: 0.92),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.68),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProfileMomentumCard extends StatelessWidget {
  final String displayName;
  final String roleLabel;
  final int experienceCount;
  final int skillsCount;
  final int educationCount;
  final int certificationCount;

  const _ProfileMomentumCard({
    required this.displayName,
    required this.roleLabel,
    required this.experienceCount,
    required this.skillsCount,
    required this.educationCount,
    required this.certificationCount,
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
            colorScheme.tertiary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Pulse',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$displayName • $roleLabel',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(AppRoutes.editProfile),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricTile(
                label: 'Experience',
                value: '$experienceCount',
                icon: Icons.work_outline,
              ),
              _MetricTile(
                label: 'Skills',
                value: '$skillsCount',
                icon: Icons.star_outline,
              ),
              _MetricTile(
                label: 'Education',
                value: '$educationCount',
                icon: Icons.school_outlined,
              ),
              _MetricTile(
                label: 'Certs',
                value: '$certificationCount',
                icon: Icons.verified_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.seekerCvUpload),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Upload CV'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}
