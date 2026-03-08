// lib/presentation/screens/dashboard/dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Dashboard / Home tab – Sprint 2 implementation.
//
// Shows personalised greeting, stat cards (Projects, Skills, Education, etc.),
// and a quick-action area.
// Full data population happens in Sprint 3 (real portfolio CRUD).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final displayName = user?.fullName?.isNotEmpty == true
        ? user!.fullName!
        : (user?.username ?? 'there');

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $displayName! 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              // TODO (Sprint 4): open notifications panel
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          // ── Welcome card ───────────────────────────────────────
          Card(
            color: AppConstants.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to PortFolioPH',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    AppConstants.appTagline,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // ── Section heading ──────────────────────────────────
          Text(
            'Your Progress',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppConstants.spacingSm),

          // ── Stat cards grid ─────────────────────────────────
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.spacingMd,
            mainAxisSpacing: AppConstants.spacingMd,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _StatCard(
                icon: Icons.folder_rounded,
                label: 'Portfolios',
                count: 0,
                color: Color(0xFF1976D2),
              ),
              _StatCard(
                icon: Icons.code_rounded,
                label: 'Projects',
                count: 0,
                color: Color(0xFF388E3C),
              ),
              _StatCard(
                icon: Icons.bar_chart_rounded,
                label: 'Skills',
                count: 0,
                color: Color(0xFFF57C00),
              ),
              _StatCard(
                icon: Icons.school_rounded,
                label: 'Education',
                count: 0,
                color: Color(0xFF7B1FA2),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // ── Quick actions heading ───────────────────────────
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppConstants.spacingSm),

          // ── Action list ───────────────────────────────────
          Card(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create Portfolio',
                  subtitle: 'Coming in Sprint 3',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.upload_file_rounded,
                  label: 'Export Resume (PDF)',
                  subtitle: 'Coming in Sprint 7',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ActionTile(
                  icon: Icons.share_rounded,
                  label: 'Share Portfolio',
                  subtitle: 'Coming in Sprint 7',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card widget ────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action tile widget ──────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(label),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
