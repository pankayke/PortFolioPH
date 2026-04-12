// lib/features/seeker/screens/dashboard/seeker_dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job Seeker dashboard - primary interface.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/seeker/screens/jobs/saved_jobs_screen.dart';
import 'package:portfolioph/features/seeker/screens/profile/cv_upload_screen.dart';
import 'package:portfolioph/features/seeker/providers/seeker_application_provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_job_list_provider.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/file_download_provider.dart';
import 'package:portfolioph/presentation/widgets/file_download_widgets.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';
import 'package:portfolioph/presentation/widgets/premium_titan_mobile_header.dart';

class SeekerDashboardScreen extends StatefulWidget {
  const SeekerDashboardScreen({super.key});

  @override
  State<SeekerDashboardScreen> createState() => _SeekerDashboardScreenState();
}

class _SeekerDashboardScreenState extends State<SeekerDashboardScreen> {
  int _selectedIndex = 0;
  bool _compactHeader = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _primeData();
    });
  }

  Future<void> _primeData() async {
    final jobProvider = context.read<SeekerJobListProvider>();

    if (jobProvider.jobs.isEmpty) {
      await jobProvider.loadJobs(refresh: true);
    }

    if (!mounted) return;
    final applicationProvider = context.read<SeekerApplicationProvider>();

    if (applicationProvider.applications.isEmpty) {
      await applicationProvider.loadApplications(refresh: true);
    }
  }

  void _onTabChanged(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    if (index == 1) {
      final jobProvider = context.read<SeekerJobListProvider>();
      if (jobProvider.jobs.isEmpty && !jobProvider.isLoading) {
        jobProvider.loadJobs(refresh: true);
      }
    }

    if (index == 2) {
      final applicationProvider = context.read<SeekerApplicationProvider>();
      if (applicationProvider.applications.isEmpty &&
          !applicationProvider.isLoading) {
        applicationProvider.loadApplications(refresh: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final userName = user?.fullName ?? user?.username ?? 'Job Seeker';

        return PremiumAppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PremiumTitanMobileHeader(
              title: _selectedIndex == 0
                  ? 'Dashboard'
                  : _selectedIndex == 1
                  ? 'Jobs'
                  : _selectedIndex == 2
                  ? 'Applications'
                  : 'Profile',
              greeting: 'Welcome back',
              userName: userName,
              compact: _compactHeader,
              onSearchTap: () => _onTabChanged(1),
              onSearchSubmitted: (_) => _onTabChanged(1),
              onNotificationTap: () =>
                  context.push(AppRoutes.notificationSettings),
              onProfileTap: () => _onTabChanged(3),
              onLogoutTap: () => _logout(context),
            ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.axis != Axis.vertical) return false;
                final shouldCompact = notification.metrics.pixels > 18;
                if (shouldCompact != _compactHeader) {
                  setState(() => _compactHeader = shouldCompact);
                }
                return false;
              },
              child: _buildBody(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onTabChanged,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Applications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
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
        return _buildApplicationsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Consumer3<
      AuthProvider,
      SeekerJobListProvider,
      SeekerApplicationProvider
    >(
      builder: (context, authProvider, jobsProvider, applicationsProvider, _) {
        final user = authProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user?.fullName ?? "User"}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Find your next opportunity',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _statPill(
                            context,
                            Icons.work_outline,
                            '${jobsProvider.jobCount} open jobs',
                          ),
                          _statPill(
                            context,
                            Icons.assignment_outlined,
                            '${applicationsProvider.applicationCount} applications',
                          ),
                          _statPill(
                            context,
                            Icons.schedule,
                            '${applicationsProvider.pendingCount} pending',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.work,
                      label: 'Browse Jobs',
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.assignment,
                      label: 'My Applications',
                      onTap: () => setState(() => _selectedIndex = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.bookmark_outline,
                      label: 'Saved Jobs',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SavedJobsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.upload_file_outlined,
                      label: 'Upload CV',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CVUploadScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (applicationsProvider.applicationCount == 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No recent activity yet. Your latest applications will appear here.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: applicationsProvider.applications
                          .take(3)
                          .map(
                            (a) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.approval_outlined),
                              title: Text(a.jobTitle),
                              subtitle: Text(
                                '${a.statusDisplay} • ${a.applicationAgeDisplay}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobsTab() {
    return Consumer2<SeekerJobListProvider, SeekerApplicationProvider>(
      builder: (context, jobsProvider, applicationProvider, _) {
        if (jobsProvider.isLoading && jobsProvider.jobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (jobsProvider.error != null && jobsProvider.jobs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  Text(jobsProvider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => jobsProvider.loadJobs(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (jobsProvider.jobs.isEmpty) {
          return const Center(
            child: Text('No jobs available right now. Pull down to refresh.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => jobsProvider.loadJobs(refresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobsProvider.jobs.length + 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search jobs by title or keyword',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isEmpty) {
                              jobsProvider.clearFilters();
                            } else {
                              jobsProvider.searchJobs(value.trim());
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: jobsProvider.clearFilters,
                              icon: const Icon(Icons.filter_alt_off_outlined),
                              label: const Text('Clear Filters'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonalIcon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const SavedJobsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bookmarks_outlined),
                              label: const Text('Saved'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              final job = jobsProvider.jobs[index - 1];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (job.isSaved == true) {
                                jobsProvider.unsaveJob(job.id);
                              } else {
                                jobsProvider.saveJob(job.id);
                              }
                            },
                            icon: Icon(
                              job.isSaved == true
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.recruiterName} • ${job.location}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${job.salaryDisplay} • ${job.employmentType}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        job.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonal(
                          onPressed: job.hasApplied
                              ? null
                              : () => applicationProvider.applyForJob(job.id),
                          child: Text(job.hasApplied ? 'Applied' : 'Apply Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildApplicationsTab() {
    return Consumer<SeekerApplicationProvider>(
      builder: (context, applicationProvider, _) {
        if (applicationProvider.isLoading &&
            applicationProvider.applications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (applicationProvider.error != null &&
            applicationProvider.applications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  Text(applicationProvider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        applicationProvider.loadApplications(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (applicationProvider.applications.isEmpty) {
          return const Center(
            child: Text('No applications yet. Apply to a job to track progress here.'),
          );
        }

        return RefreshIndicator(
          onRefresh: applicationProvider.refreshApplications,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applicationProvider.applications.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final application = applicationProvider.applications[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  title: Text(application.jobTitle),
                  subtitle: Text(
                    '${application.recruiterName} • ${application.statusDisplay} • ${application.applicationAgeDisplay}',
                  ),
                  trailing: application.isApplied || application.isReviewing
                      ? TextButton(
                          onPressed: () => applicationProvider
                              .withdrawApplication(application.id),
                          child: const Text('Withdraw'),
                        )
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer2<AuthProvider, FileDownloadProvider>(
      builder: (context, authProvider, downloadProvider, _) {
        final user = authProvider.currentUser;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(
                        _initialFromName(user?.fullName ?? user?.username),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? user?.username ?? 'User',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(user?.email ?? ''),
                    const SizedBox(height: 6),
                    Text(user?.location ?? 'Location not set'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_outlined),
              title: const Text('Download My CV'),
              subtitle: const Text('Save your latest resume file locally'),
              trailing: DownloadButton(
                label: 'Download',
                isLoading: downloadProvider.isDownloading,
                onPressed: () {
                  if (downloadProvider.isDownloading) return;
                  downloadProvider.downloadMyCV();
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('Upload or Replace CV'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CVUploadScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks_outlined),
              title: const Text('Saved Jobs'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SavedJobsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => context.push(AppRoutes.settings),
            ),
          ],
        );
      },
    );
  }

  Widget _statPill(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14), const SizedBox(width: 6), Text(label)],
      ),
    );
  }

  String _initialFromName(String? value) {
    final cleaned = (value ?? '').trim();
    if (cleaned.isEmpty) return 'U';
    return cleaned.substring(0, 1).toUpperCase();
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    context.go(AppRoutes.login);
  }
}
