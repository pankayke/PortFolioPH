// lib/presentation/screens/profile/profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Profile tab.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> _regionalBadges = ['Cebu', 'Manila', 'Davao'];

  static const List<({String skill, int rating})> _skillRatings = [
    (skill: 'Email Management', rating: 5),
    (skill: 'Canva', rating: 4),
    (skill: 'Zoom Coordination', rating: 5),
    (skill: 'Customer Support', rating: 4),
  ];

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
                          'Virtual Assistant | Cebu | 50+ Connections',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _regionalBadges
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
            _SectionCard(
              title: 'About',
              child: Text(
                (user.bio?.trim().isNotEmpty ?? false)
                    ? user.bio!
                    : 'No bio yet. You can add this in profile setup/edit later.',
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Experience',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Virtual Assistant @ RemoteBoss',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  const Text('Jan 2025 - Present • ₱25k/mo'),
                  const SizedBox(height: 6),
                  const Text(
                    'Managed emails and calendar workflows for 5 CEOs.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _SectionCard(
              title: 'Skills',
              child: Column(
                children: _skillRatings
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.skill)),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < item.rating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 18,
                                  color: index < item.rating
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
              title: 'Education & Certifications',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BS IT - LNU 2024 • Dean\'s Lister'),
                  SizedBox(height: 6),
                  Text('Google IT Support • TESDA Bookkeeping'),
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
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
