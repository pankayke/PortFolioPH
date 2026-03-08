// lib/presentation/screens/profile/profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Profile tab – Sprint 1 placeholder.
// TODO (Sprint 5): avatar picker, bio editor, contact links.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/widgets/common/placeholder_tab_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log Out',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: user == null
          ? const PlaceholderTabBody(
              icon: Icons.person_rounded,
              title: 'Profile',
              subtitle: 'No user session found.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                // ── Avatar circle ─────────────────────────────────────────
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppConstants.primaryColor,
                    child: Text(
                      user.fullName != null
                          ? user.fullName![0].toUpperCase()
                          : user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeDisplay,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                Center(
                  child: Text(
                    user.fullName ?? user.username,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Center(
                  child: Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Divider(height: AppConstants.spacingXl),
                // ── Placeholder note ─────────────────────────────────────
                const PlaceholderTabBody(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle:
                      'Sprint 5 will add bio editor,\navatar upload, and contact links.',
                ),
              ],
            ),
    );
  }
}
