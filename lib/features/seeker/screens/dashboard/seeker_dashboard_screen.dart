// lib/features/seeker/screens/dashboard/seeker_dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Job Seeker dashboard - primary interface.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/seeker/constants/seeker_filter_values.dart';
import 'package:portfolioph/features/seeker/screens/jobs/saved_jobs_screen.dart';
import 'package:portfolioph/features/seeker/screens/profile/cv_upload_screen.dart';
import 'package:portfolioph/features/notifications/providers/notification_provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_application_provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_job_list_provider.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/file_download_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
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
  final TextEditingController _jobSearchController = TextEditingController();
  final TextEditingController _locationSearchController =
      TextEditingController();
  String? _selectedEmploymentType;
  bool _remoteOnly = false;
  String? _applicationStatusFilter;
  String _applicationSort = 'applied_at';
  Timer? _jobSearchDebounce;
  Timer? _locationSearchDebounce;
  final Set<int> _applyingJobIds = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _primeData();
    });
  }

  @override
  void dispose() {
    _jobSearchDebounce?.cancel();
    _locationSearchDebounce?.cancel();
    _jobSearchController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  Future<void> _primeData() async {
    final jobProvider = context.read<SeekerJobListProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    if (jobProvider.jobs.isEmpty) {
      await jobProvider.loadJobs(refresh: true);
    }

    if (!notificationProvider.hasLoaded ||
        notificationProvider.notifications.isEmpty) {
      await notificationProvider.loadNotifications(refresh: true);
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
      if (!jobProvider.isLoading) {
        _loadJobsWithActiveFilters(refresh: true);
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

  Future<void> _performJobSearch(String query) async {
    final trimmed = query.trim();

    if (_selectedIndex != 1) {
      setState(() => _selectedIndex = 1);
    }

    if (trimmed.isEmpty) {
      await _clearJobFilters();
      return;
    }

    _jobSearchController.text = trimmed;
    await _loadJobsWithActiveFilters(refresh: true);
  }

  Future<void> _loadJobsWithActiveFilters({bool refresh = true}) async {
    final jobsProvider = context.read<SeekerJobListProvider>();
    final search = _jobSearchController.text.trim();
    final location = _locationSearchController.text.trim();

    await jobsProvider.loadJobs(
      search: search.isEmpty ? null : search,
      employmentType: _selectedEmploymentType,
      location: _remoteOnly ? 'Remote' : (location.isEmpty ? null : location),
      refresh: refresh,
    );
  }

  Future<void> _setEmploymentTypeFilter(String? value) async {
    setState(() => _selectedEmploymentType = value);
    await _loadJobsWithActiveFilters(refresh: true);
  }

  Future<void> _setRemoteOnlyFilter(bool value) async {
    setState(() => _remoteOnly = value);
    await _loadJobsWithActiveFilters(refresh: true);
  }

  Future<void> _clearJobFilters() async {
    setState(() {
      _selectedEmploymentType = null;
      _remoteOnly = false;
    });
    _jobSearchController.clear();
    _locationSearchController.clear();
    await context.read<SeekerJobListProvider>().clearFilters();
  }

  void _scheduleJobSearchDebounce(String value) {
    _jobSearchDebounce?.cancel();
    _jobSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _loadJobsWithActiveFilters(refresh: true);
    });
  }

  void _scheduleLocationDebounce(String value) {
    _locationSearchDebounce?.cancel();
    _locationSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _loadJobsWithActiveFilters(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthProvider, String>((authProvider) {
      final user = authProvider.currentUser;
      return user?.fullName ?? user?.username ?? 'Job Seeker';
    });
    final unreadCount = context.select<NotificationProvider, int>(
      (notificationProvider) => notificationProvider.unreadCount,
    );

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.digit1, alt: true): _SwitchTabIntent(
          0,
        ),
        SingleActivator(LogicalKeyboardKey.digit2, alt: true): _SwitchTabIntent(
          1,
        ),
        SingleActivator(LogicalKeyboardKey.digit3, alt: true): _SwitchTabIntent(
          2,
        ),
        SingleActivator(LogicalKeyboardKey.digit4, alt: true): _SwitchTabIntent(
          3,
        ),
        SingleActivator(LogicalKeyboardKey.slash, alt: true):
            _ShowShortcutHelpIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _SwitchTabIntent: CallbackAction<_SwitchTabIntent>(
            onInvoke: (intent) {
              _onTabChanged(intent.index);
              return null;
            },
          ),
          _ShowShortcutHelpIntent: CallbackAction<_ShowShortcutHelpIntent>(
            onInvoke: (intent) {
              _showShortcutHelp(context);
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: PremiumAppBackground(
            lite: true,
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
                unreadNotificationCount: unreadCount,
                onSearchTap: () => _onTabChanged(1),
                onSearchSubmitted: _performJobSearch,
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
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work),
                    label: 'Jobs',
                  ),
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
          ),
        ),
      ),
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
        final upcomingInterviews =
            applicationsProvider.applications
                .where((a) => a.hasInterview && a.isUpcomingInterview)
                .toList(growable: false)
              ..sort((a, b) => a.interviewDate!.compareTo(b.interviewDate!));

        return SingleChildScrollView(
          key: const PageStorageKey<String>('seeker_overview_scroll'),
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
              if (upcomingInterviews.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Interviews',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...upcomingInterviews
                            .take(2)
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${item.jobTitle} • ${_formatDateTime(item.interviewDate!)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              if (upcomingInterviews.isNotEmpty) const SizedBox(height: 24),

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
          return _buildJobsSkeleton();
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

        return RefreshIndicator(
          onRefresh: () => _loadJobsWithActiveFilters(refresh: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis != Axis.vertical) return false;
              final threshold = notification.metrics.maxScrollExtent * 0.80;
              if (notification.metrics.pixels >= threshold &&
                  jobsProvider.hasMore &&
                  !jobsProvider.isLoading &&
                  jobsProvider.jobs.isNotEmpty) {
                jobsProvider.loadMoreJobs();
              }
              return false;
            },
            child: ListView.separated(
              key: const PageStorageKey<String>('seeker_jobs_list'),
              cacheExtent: 900,
              padding: const EdgeInsets.all(16),
              itemCount: jobsProvider.jobs.isEmpty
                  ? 2
                  : jobsProvider.jobs.length + 2,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (jobsProvider.error != null &&
                              jobsProvider.jobs.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Showing cached jobs due to sync issue: ${jobsProvider.error}'
                                '${jobsProvider.lastSyncedAt != null ? ' • Last synced ${_syncLabel(jobsProvider.lastSyncedAt!)}' : ''}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          TextField(
                            controller: _jobSearchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search jobs by title or keyword',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSubmitted: _performJobSearch,
                            onChanged: _scheduleJobSearchDebounce,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _locationSearchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Location (e.g. New York, Remote)',
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSubmitted: (val) {
                              if (val.trim().toLowerCase() == 'remote') {
                                setState(() => _remoteOnly = true);
                              }
                              _loadJobsWithActiveFilters(refresh: true);
                            },
                            onChanged: _scheduleLocationDebounce,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('All Types'),
                                selected: _selectedEmploymentType == null,
                                onSelected: (_) =>
                                    _setEmploymentTypeFilter(null),
                              ),
                              ChoiceChip(
                                label: const Text('Full-time'),
                                selected:
                                    _selectedEmploymentType ==
                                    SeekerFilterValues.fullTime,
                                onSelected: (_) =>
                                    _setEmploymentTypeFilter(
                                      SeekerFilterValues.fullTime,
                                    ),
                              ),
                              ChoiceChip(
                                label: const Text('Part-time'),
                                selected:
                                    _selectedEmploymentType ==
                                    SeekerFilterValues.partTime,
                                onSelected: (_) =>
                                    _setEmploymentTypeFilter(
                                      SeekerFilterValues.partTime,
                                    ),
                              ),
                              ChoiceChip(
                                label: const Text('Contract'),
                                selected:
                                    _selectedEmploymentType ==
                                    SeekerFilterValues.contract,
                                onSelected: (_) =>
                                    _setEmploymentTypeFilter(
                                      SeekerFilterValues.contract,
                                    ),
                              ),
                              FilterChip(
                                label: const Text('Remote Only'),
                                selected: _remoteOnly,
                                onSelected: _setRemoteOnlyFilter,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: _clearJobFilters,
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

                if (jobsProvider.jobs.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        jobsProvider.searchQuery?.isNotEmpty == true
                            ? 'No jobs found for "${jobsProvider.searchQuery}".'
                            : 'No jobs available right now. Pull down to refresh.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                if (jobsProvider.jobs.isNotEmpty &&
                    index == jobsProvider.jobs.length + 1) {
                  if (jobsProvider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (!jobsProvider.hasMore) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('You reached the end of job listings.'),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final job = jobsProvider.jobs[index - 1];
                return Card(
                  key: ValueKey('seeker-job-${job.id}'),
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
                              tooltip: job.isSaved == true
                                  ? 'Remove from saved jobs'
                                  : 'Save job',
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
                            onPressed:
                                job.hasApplied ||
                                    job.deadlineExpired ||
                                    _applyingJobIds.contains(job.id)
                                ? null
                                : () async {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    setState(() => _applyingJobIds.add(job.id));
                                    try {
                                      await applicationProvider.applyForJob(
                                        job.id,
                                      );
                                      if (!mounted) return;
                                      jobsProvider.markJobAsApplied(job.id);
                                    } catch (_) {
                                      if (!mounted) return;
                                      messenger
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              applicationProvider.error ??
                                                  'Unable to submit application.',
                                            ),
                                          ),
                                        );
                                    }
                                    if (!mounted) return;
                                    setState(
                                      () => _applyingJobIds.remove(job.id),
                                    );
                                  },
                            child: _applyingJobIds.contains(job.id)
                                ? Semantics(
                                    label: 'Submitting application',
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : Text(
                                    job.hasApplied
                                        ? 'Applied'
                                        : (job.deadlineExpired
                                              ? 'Deadline Closed'
                                              : 'Apply Now'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
          return _buildApplicationsSkeleton();
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

        return RefreshIndicator(
          onRefresh: applicationProvider.refreshApplications,
          child: ListView.separated(
            key: const PageStorageKey<String>('seeker_applications_list'),
            cacheExtent: 900,
            padding: const EdgeInsets.all(16),
            itemCount: applicationProvider.applications.isEmpty
                ? 2
                : applicationProvider.applications.length + 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('All'),
                              selected: _applicationStatusFilter == null,
                              onSelected: (_) async {
                                setState(() => _applicationStatusFilter = null);
                                await applicationProvider.loadApplications(
                                  refresh: true,
                                  status: null,
                                );
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Applied'),
                              selected: _applicationStatusFilter == 'applied',
                              onSelected: (_) async {
                                setState(
                                  () => _applicationStatusFilter = 'applied',
                                );
                                await applicationProvider.filterByStatus(
                                  'applied',
                                );
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Reviewing'),
                              selected: _applicationStatusFilter == 'reviewing',
                              onSelected: (_) async {
                                setState(
                                  () => _applicationStatusFilter = 'reviewing',
                                );
                                await applicationProvider.filterByStatus(
                                  'reviewing',
                                );
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Shortlisted'),
                              selected:
                                  _applicationStatusFilter == 'shortlisted',
                              onSelected: (_) async {
                                setState(
                                  () =>
                                      _applicationStatusFilter = 'shortlisted',
                                );
                                await applicationProvider.filterByStatus(
                                  'shortlisted',
                                );
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Accepted'),
                              selected: _applicationStatusFilter == 'accepted',
                              onSelected: (_) async {
                                setState(
                                  () => _applicationStatusFilter = 'accepted',
                                );
                                await applicationProvider.filterByStatus(
                                  'accepted',
                                );
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Rejected'),
                              selected: _applicationStatusFilter == 'rejected',
                              onSelected: (_) async {
                                setState(
                                  () => _applicationStatusFilter = 'rejected',
                                );
                                await applicationProvider.filterByStatus(
                                  'rejected',
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Sort by:'),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _applicationSort,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'applied_at',
                                    child: Text('Most Recent'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'status',
                                    child: Text('Status'),
                                  ),
                                ],
                                onChanged: (value) async {
                                  if (value == null ||
                                      value == _applicationSort) {
                                    return;
                                  }
                                  setState(() => _applicationSort = value);
                                  await applicationProvider.sortBy(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _statPill(
                              context,
                              Icons.schedule_outlined,
                              '${applicationProvider.pendingCount} pending',
                            ),
                            _statPill(
                              context,
                              Icons.star_outline_rounded,
                              '${applicationProvider.shortlistedCount} shortlisted',
                            ),
                            _statPill(
                              context,
                              Icons.check_circle_outline,
                              '${applicationProvider.acceptedCount} accepted',
                            ),
                            _statPill(
                              context,
                              Icons.cancel_outlined,
                              '${applicationProvider.rejectedCount} rejected',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (applicationProvider.applications.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No applications found for the selected filter.',
                    ),
                  ),
                );
              }

              final application = applicationProvider.applications[index - 1];
              return Card(
                key: ValueKey('seeker-application-${application.id}'),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  title: Text(application.jobTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${application.recruiterName} • ${application.statusDisplay} • ${application.applicationAgeDisplay}',
                      ),
                      if (application.notes != null &&
                          application.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Note: ${application.notes}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      if (application.hasInterview) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Interview: ${_formatDateTime(application.interviewDate!)}',
                        ),
                        if (application.interviewLocation != null &&
                            application.interviewLocation!.isNotEmpty)
                          Text('Location: ${application.interviewLocation}'),
                        if (application.videoInterviewLink != null &&
                            application.videoInterviewLink!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Tooltip(
                                message: 'Copy interview meeting link',
                                child: OutlinedButton.icon(
                                  onPressed: () => _copyInterviewLink(
                                    context,
                                    application.videoInterviewLink!,
                                  ),
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy meeting link'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                  trailing: application.isApplied || application.isReviewing
                      ? TextButton(
                          onPressed: () => _confirmWithdrawApplication(
                            context,
                            applicationProvider,
                            application.id,
                          ),
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

  Future<void> _confirmWithdrawApplication(
    BuildContext context,
    SeekerApplicationProvider provider,
    int applicationId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final shouldWithdraw = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
          'This will remove your active application from the recruiter pipeline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (shouldWithdraw != true || !mounted) return;

    await provider.withdrawApplication(applicationId);
    if (!mounted) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            provider.error == null
                ? 'Application withdrawn.'
                : (provider.error ?? 'Unable to withdraw application.'),
          ),
        ),
      );
  }

  Widget _buildProfileTab() {
    return Consumer3<AuthProvider, FileDownloadProvider, ThemeProvider>(
      builder: (context, authProvider, downloadProvider, themeProvider, _) {
        final user = authProvider.currentUser;
        final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
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
            SwitchListTile(
              secondary: Icon(
                isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Applies across job seeker and recruiter'),
              value: isDarkMode,
              onChanged: (_) => themeProvider.toggleDarkMode(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyInterviewLink(BuildContext context, String link) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Interview link copied to clipboard.')),
      );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  String _syncLabel(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _showShortcutHelp(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alt+1: Dashboard'),
            Text('Alt+2: Jobs'),
            Text('Alt+3: Applications'),
            Text('Alt+4: Profile'),
            SizedBox(height: 8),
            Text('Alt+/: Show this help'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: Navigator.of(dialogContext).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSkeleton() {
    return ListView(
      key: const PageStorageKey<String>('seeker_jobs_skeleton'),
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonCard(height: 220),
        SizedBox(height: 12),
        _SkeletonCard(height: 180),
        SizedBox(height: 12),
        _SkeletonCard(height: 180),
      ],
    );
  }

  Widget _buildApplicationsSkeleton() {
    return ListView(
      key: const PageStorageKey<String>('seeker_applications_skeleton'),
      padding: const EdgeInsets.all(16),
      children: const [
        _SkeletonCard(height: 140),
        SizedBox(height: 12),
        _SkeletonCard(height: 120),
        SizedBox(height: 12),
        _SkeletonCard(height: 120),
      ],
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

class _SkeletonCard extends StatelessWidget {
  final double height;

  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _SwitchTabIntent extends Intent {
  final int index;
  const _SwitchTabIntent(this.index);
}

class _ShowShortcutHelpIntent extends Intent {
  const _ShowShortcutHelpIntent();
}
