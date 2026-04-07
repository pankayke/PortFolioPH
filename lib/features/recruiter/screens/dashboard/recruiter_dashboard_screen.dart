// lib/features/recruiter/screens/dashboard/recruiter_dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Recruiter dashboard - primary interface for approved recruiters.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() =>
      _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecruiterJobManagerProvider>().loadJobs(refresh: true);
      context.read<RecruiterApplicationManagerProvider>().loadApplications(
        refresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recruiter Dashboard'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          body: _buildBody(),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton(
                  onPressed: () => context.push(AppRoutes.recruiterJobCreate),
                  tooltip: 'Create Job',
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Applicants',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildJobsTab();
      case 2:
        return _buildApplicantsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Consumer3<AuthProvider, RecruiterJobManagerProvider,
        RecruiterApplicationManagerProvider>(
      builder: (context, authProvider, jobsProvider, appsProvider, _) {
        final user = authProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card with company
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user?.fullName ?? "Recruiter"}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.location ?? 'Your Company',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Find talented candidates for your roles',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats grid
              Text('Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context,
                    title: 'Open Jobs',
                    value: '${jobsProvider.openJobCount}',
                    icon: Icons.work,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Applications',
                    value: '${appsProvider.applications.length}',
                    icon: Icons.assignment,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Reviewed',
                    value: '${appsProvider.reviewingCount}',
                    icon: Icons.group,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Shortlisted',
                    value: '${appsProvider.shortlistedCount}',
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Post New Job'),
                  onPressed: () => context.push(AppRoutes.recruiterJobCreate),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.work),
                  label: const Text('View All Jobs'),
                  onPressed: () => context.push(AppRoutes.recruiterJobsList),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Manage your posted jobs and hiring pipeline.'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.recruiterJobCreate),
            icon: const Icon(Icons.add),
            label: const Text('Post New Job'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.recruiterJobsList),
            icon: const Icon(Icons.work_outline),
            label: const Text('Open My Jobs'),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Review applicants and update decisions.'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.recruiterApplications),
            icon: const Icon(Icons.group_outlined),
            label: const Text('Open Applicants'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Keep your recruiter profile updated.'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.editProfile),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.notificationSettings),
            icon: const Icon(Icons.notifications_outlined),
            label: const Text('Notification Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    context.go(AppRoutes.login);
  }
}
