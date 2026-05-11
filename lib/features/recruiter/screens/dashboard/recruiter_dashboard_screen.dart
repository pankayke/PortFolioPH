import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/core/theme/motion_tokens.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_dashboard_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';
import 'package:portfolioph/features/recruiter/screens/ats/applicant_tracking_screen.dart';
import 'package:portfolioph/features/recruiter/screens/dashboard/recruiter_dashboard_overview_tab.dart';
import 'package:portfolioph/features/recruiter/utils/recruiter_identity_utils.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
import 'package:portfolioph/presentation/widgets/glass/glass_container.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  final int initialTab;

  const RecruiterDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<RecruiterDashboardScreen> createState() =>
      _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  static const List<_RecruiterTabItem> _tabs = [
    _RecruiterTabItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    _RecruiterTabItem(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'My Jobs',
    ),
    _RecruiterTabItem(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      label: 'ATS',
    ),
    _RecruiterTabItem(
      icon: Icons.add_box_outlined,
      activeIcon: Icons.add_box_rounded,
      label: 'Post',
    ),
    _RecruiterTabItem(
      icon: Icons.business_outlined,
      activeIcon: Icons.business_rounded,
      label: 'Company',
    ),
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, _tabs.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RecruiterDashboardProvider>().loadDashboard(refresh: true);
      context.read<RecruiterJobManagerProvider>().loadJobs(refresh: true);
      context.read<RecruiterApplicationManagerProvider>().loadApplications(
        refresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPostTab = _selectedIndex == 3;
    final isAtsTab = _selectedIndex == 2;
    final isCompanyTab = _selectedIndex == 4;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final safeBottomInset = MediaQuery.of(context).padding.bottom;
    final bodyBottomInset = isPostTab
      ? 16.0
      : isCompanyTab
        ? (safeBottomInset + 16.0)
        : isAtsTab
          ? (safeBottomInset + 40.0)
          : (safeBottomInset + 56.0);

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.digit1, alt: true):
            _RecruiterSwitchTabIntent(0),
        SingleActivator(LogicalKeyboardKey.digit2, alt: true):
            _RecruiterSwitchTabIntent(1),
        SingleActivator(LogicalKeyboardKey.digit3, alt: true):
            _RecruiterSwitchTabIntent(2),
        SingleActivator(LogicalKeyboardKey.digit4, alt: true):
            _RecruiterSwitchTabIntent(3),
        SingleActivator(LogicalKeyboardKey.digit5, alt: true):
            _RecruiterSwitchTabIntent(4),
        SingleActivator(LogicalKeyboardKey.slash, alt: true):
            _RecruiterShortcutHelpIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _RecruiterSwitchTabIntent: CallbackAction<_RecruiterSwitchTabIntent>(
            onInvoke: (intent) {
              _goToTab(intent.index);
              return null;
            },
          ),
          _RecruiterShortcutHelpIntent:
              CallbackAction<_RecruiterShortcutHelpIntent>(
                onInvoke: (intent) {
                  _showRecruiterShortcutHelp(context);
                  return null;
                },
              ),
        },
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: PremiumAppBackground(
            lite: true,
            child: Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: AppBar(
                title: Opacity(
                  opacity: 0.85,
                  child: Text(
                    _selectedIndex == 0
                        ? 'Jobs & Opportunities'
                        : _tabs[_selectedIndex].label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                backgroundColor: colorScheme.surface,
                elevation: 0,
                actions: [
                  Selector<RecruiterDashboardProvider, int>(
                    selector: (_, dashboardProvider) =>
                        dashboardProvider.notificationCount,
                    builder: (context, count, _) {
                      return IconButton(
                        onPressed: () =>
                            context.push(AppRoutes.notificationSettings),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_outlined),
                            if (count > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.accentPhilippineRed,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    count > 9 ? '9+' : '$count',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        tooltip: count > 0
                            ? '$count new applications'
                            : 'Notifications',
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Consumer2<AuthProvider, ThemeProvider>(
                      builder: (context, authProvider, themeProvider, _) {
                        final user = authProvider.currentUser;
                        final initial =
                            (user?.fullName ?? 'R').trim().isNotEmpty
                            ? (user?.fullName ?? 'R').trim()[0].toUpperCase()
                            : 'R';
                        final isDark =
                            themeProvider.themeMode == ThemeMode.dark;

                        return PopupMenuButton<String>(
                          tooltip: 'Profile',
                          onSelected: (value) {
                            switch (value) {
                              case 'theme':
                                final nextIsDark =
                                    themeProvider.themeMode != ThemeMode.dark;
                                themeProvider.toggleDarkMode();
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        nextIsDark
                                            ? 'Dark mode enabled'
                                            : 'Light mode enabled',
                                      ),
                                      duration: const Duration(
                                        milliseconds: 1400,
                                      ),
                                    ),
                                  );
                                break;
                              case 'company':
                                _goToTab(4);
                                break;
                              case 'logout':
                                _logout(context);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'theme',
                              child: Row(
                                children: [
                                  Icon(
                                    isDark
                                        ? Icons.light_mode_outlined
                                        : Icons.dark_mode_outlined,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    isDark
                                        ? 'Switch to Light Mode'
                                        : 'Switch to Dark Mode',
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'company',
                              child: Row(
                                children: const [
                                  Icon(Icons.business_outlined, size: 18),
                                  SizedBox(width: 10),
                                  Text('Company Profile'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: const [
                                  Icon(Icons.logout, size: 18),
                                  SizedBox(width: 10),
                                  Text('Logout'),
                                ],
                              ),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    DesignTokens.accentBlueBright,
                                    DesignTokens.accentPurple,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Colors.white.withAlpha(90),
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              body: AnimatedSwitcher(
                duration: MotionTokens.medium,
                switchInCurve: MotionTokens.emphasizedDecelerate,
                switchOutCurve: MotionTokens.emphasizedAccelerate,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bodyBottomInset),
                  child: IndexedStack(
                    key: ValueKey(_selectedIndex),
                    index: _selectedIndex,
                    children: [
                      RecruiterDashboardOverviewTab(
                        onJumpToAts: () => _goToTab(2),
                      ),
                      const _RecruiterJobsTab(),
                      const ApplicantTrackingScreen(compactMode: true),
                      _RecruiterJobCreateTab(onPosted: () => _goToTab(1)),
                      const _RecruiterCompanyProfileTab(),
                    ],
                  ),
                ),
              ),
              floatingActionButton: isPostTab
                  ? null
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            DesignTokens.accentBlue,
                            DesignTokens.accentPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DesignTokens.accentBlue.withAlpha(96),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () => _goToTab(3),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        icon: const Icon(Icons.add),
                        label: const Text('Post Job'),
                      ),
                    ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _GlassCard(
                  padding: EdgeInsets.zero,
                  child: NavigationBar(
                    selectedIndex: _selectedIndex,
                    backgroundColor: colorScheme.surfaceContainer,
                    onDestinationSelected: _goToTab,
                    destinations: _tabs
                        .map(
                          (tab) => NavigationDestination(
                            icon: Icon(tab.icon),
                            selectedIcon: Icon(tab.activeIcon),
                            label: tab.label,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  Future<void> _showRecruiterShortcutHelp(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alt+1: Home'),
            Text('Alt+2: My Jobs'),
            Text('Alt+3: ATS'),
            Text('Alt+4: Post'),
            Text('Alt+5: Company'),
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
}

class _RecruiterJobsTab extends StatefulWidget {
  const _RecruiterJobsTab();

  @override
  State<_RecruiterJobsTab> createState() => _RecruiterJobsTabState();
}

class _RecruiterJobsTabState extends State<_RecruiterJobsTab> {
  static const String _statusPrefKey = 'recruiter_jobs_status_filter';
  static const String _searchPrefKey = 'recruiter_jobs_search_filter';

  String? _status;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _restoreFilterPreset();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _restoreFilterPreset() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getString(_statusPrefKey);
    final savedSearch = prefs.getString(_searchPrefKey) ?? '';
    if (!mounted) return;

    setState(() {
      _status = (savedStatus == null || savedStatus.isEmpty)
          ? null
          : savedStatus;
      _searchController.text = savedSearch;
    });

    final provider = context.read<RecruiterJobManagerProvider>();
    await provider.loadJobs(
      refresh: true,
      status: _status,
      search: savedSearch.trim().isEmpty ? null : savedSearch.trim(),
    );
  }

  Future<void> _persistFilterPreset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusPrefKey, _status ?? '');
    await prefs.setString(_searchPrefKey, _searchController.text.trim());
  }

  void _scheduleSearchDebounce(RecruiterJobManagerProvider provider) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      _persistFilterPreset();
      provider.loadJobs(
        refresh: true,
        status: _status,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecruiterJobManagerProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.loadJobs(refresh: true, status: _status),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis != Axis.vertical) return false;
              final threshold = notification.metrics.maxScrollExtent * 0.80;
              if (notification.metrics.pixels >= threshold &&
                  provider.hasMore &&
                  !provider.isLoading &&
                  provider.jobs.isNotEmpty) {
                provider.loadMoreJobs();
              }
              return false;
            },
            child: ListView(
              key: const PageStorageKey<String>('recruiter_jobs_list'),
              cacheExtent: 300,
              padding: const EdgeInsets.all(16),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusFilterChip(
                        label: 'All',
                        selected: _status == null,
                        onTap: () {
                          setState(() => _status = null);
                          _persistFilterPreset();
                          provider.loadJobs(
                            refresh: true,
                            search: _searchController.text.trim().isEmpty
                                ? null
                                : _searchController.text.trim(),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _StatusFilterChip(
                        label: 'Active',
                        selected: _status == 'approved',
                        onTap: () {
                          setState(() => _status = 'approved');
                          _persistFilterPreset();
                          provider.loadJobs(
                            refresh: true,
                            status: 'approved',
                            search: _searchController.text.trim().isEmpty
                                ? null
                                : _searchController.text.trim(),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _StatusFilterChip(
                        label: 'Draft',
                        selected: _status == 'draft',
                        onTap: () {
                          setState(() => _status = 'draft');
                          _persistFilterPreset();
                          provider.loadJobs(
                            refresh: true,
                            status: 'draft',
                            search: _searchController.text.trim().isEmpty
                                ? null
                                : _searchController.text.trim(),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _StatusFilterChip(
                        label: 'Closed',
                        selected: _status == 'closed',
                        onTap: () {
                          setState(() => _status = 'closed');
                          _persistFilterPreset();
                          provider.loadJobs(
                            refresh: true,
                            status: 'closed',
                            search: _searchController.text.trim().isEmpty
                                ? null
                                : _searchController.text.trim(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _persistFilterPreset();
                    provider.loadJobs(
                      refresh: true,
                      status: _status,
                      search: value.trim().isEmpty ? null : value.trim(),
                    );
                  },
                  onChanged: (_) => _scheduleSearchDebounce(provider),
                  decoration: InputDecoration(
                    hintText: 'Search jobs by title or keyword',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (_searchController.text.trim().isEmpty) return;
                        _searchController.clear();
                        _persistFilterPreset();
                        provider.loadJobs(refresh: true, status: _status);
                      },
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear search',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.error != null && provider.jobs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _GlassCard(
                      child: Text(
                        'Showing cached jobs. Sync issue: ${provider.error}'
                        '${provider.lastSyncedAt != null ? ' • Last synced ${_formatSync(provider.lastSyncedAt!)}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                _GlassCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  gradient: LinearGradient(
                    colors: [
                      DesignTokens.accentPurple.withValues(alpha: 0.08),
                      Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${provider.jobs.length} postings',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        'Swipe or tap a card for actions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.isLoading && provider.jobs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.jobs.isEmpty)
                  const _GlassCard(
                    child: Text(
                      'No jobs posted yet. Create your first listing in the Create tab.',
                    ),
                  ),
                ...provider.jobs.map(
                  (job) => KeyedSubtree(
                    key: ValueKey('recruiter-job-${job.id}'),
                    child: _JobCard(job: job),
                  ),
                ),
                if (provider.jobs.isNotEmpty && provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (provider.jobs.isNotEmpty &&
                    !provider.isLoading &&
                    !provider.hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'All jobs loaded.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatSync(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _RecruiterAtsTab extends StatefulWidget {
  const _RecruiterAtsTab();

  @override
  State<_RecruiterAtsTab> createState() => _RecruiterAtsTabState();
}

class _RecruiterAtsTabState extends State<_RecruiterAtsTab> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    return Consumer<RecruiterApplicationManagerProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.loadApplications(refresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatusFilterChip(
                      label: 'All',
                      selected: _status == null,
                      onTap: () {
                        setState(() => _status = null);
                        provider.filterByStatus(null);
                      },
                    ),
                    const SizedBox(width: 8),
                    _StatusFilterChip(
                      label: 'Shortlisted',
                      selected: _status == 'shortlisted',
                      onTap: () {
                        setState(() => _status = 'shortlisted');
                        provider.filterByStatus('shortlisted');
                      },
                    ),
                    const SizedBox(width: 8),
                    _StatusFilterChip(
                      label: 'Rejected',
                      selected: _status == 'rejected',
                      onTap: () {
                        setState(() => _status = 'rejected');
                        provider.filterByStatus('rejected');
                      },
                    ),
                    const SizedBox(width: 8),
                    _StatusFilterChip(
                      label: 'Hired',
                      selected: _status == 'accepted',
                      onTap: () {
                        setState(() => _status = 'accepted');
                        provider.filterByStatus('accepted');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _GlassCard(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.accentPurple.withValues(alpha: 0.08),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.10),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${provider.applications.length} candidates',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      'Open a profile for the full timeline',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (provider.isLoading && provider.applications.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.applications.isEmpty)
                const _GlassCard(
                  child: Text(
                    'No candidates yet. Move new applicants through ATS once they apply.',
                  ),
                ),
              ...provider.applications.map((app) => _ApplicantCard(app: app)),
            ],
          ),
        );
      },
    );
  }
}

class _RecruiterJobCreateTab extends StatefulWidget {
  final VoidCallback onPosted;

  const _RecruiterJobCreateTab({required this.onPosted});

  @override
  State<_RecruiterJobCreateTab> createState() => _RecruiterJobCreateTabState();
}

class _RecruiterJobCreateTabState extends State<_RecruiterJobCreateTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _skillsController = TextEditingController();

  int _step = 0;
  String _jobType = 'full_time';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = ['Basics', 'Requirements', 'Compensation'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              sections.length,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                child: _StatusFilterChip(
                  label: sections[index],
                  selected: _step == index,
                  onTap: () => setState(() => _step = index),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _GlassCard(
          child: Form(
            key: _formKey,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _buildStepContent(),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post Job'),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration('Job title'),
              validator: (v) => (v == null || v.trim().length < 5)
                  ? 'Title must be at least 5 characters.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: _inputDecoration('Description'),
              validator: (v) => (v == null || v.trim().length < 20)
                  ? 'Description must be at least 20 characters.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration('Location'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Location is required.'
                  : null,
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _jobType,
              decoration: _inputDecoration('Job type'),
              items: const [
                DropdownMenuItem(value: 'full_time', child: Text('Full Time')),
                DropdownMenuItem(value: 'part_time', child: Text('Part Time')),
                DropdownMenuItem(value: 'contract', child: Text('Contract')),
                DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
              ],
              onChanged: (value) =>
                  setState(() => _jobType = value ?? 'full_time'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skillsController,
              decoration: _inputDecoration('Required skills (comma-separated)'),
            ),
          ],
        );
      default:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _salaryMinController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Salary minimum'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _salaryMaxController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Salary maximum'),
            ),
            const SizedBox(height: 10),
            Text(
              'Use monthly salary values to keep postings consistent.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
    }
  }

  InputDecoration _inputDecoration(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<RecruiterJobManagerProvider>();
    try {
      await provider.createJob(
        CreateJobRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          salaryMin: double.tryParse(_salaryMinController.text.trim()),
          salaryMax: double.tryParse(_salaryMaxController.text.trim()),
          jobType: _jobType,
          requiredSkills: _skillsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          deadline: null,
        ),
      );

      if (!mounted) return;
      await context.read<RecruiterJobManagerProvider>().refreshJobs();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job posted successfully.')));
      widget.onPosted();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to create job.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _RecruiterCompanyProfileTab extends StatelessWidget {
  const _RecruiterCompanyProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer3<
      AuthProvider,
      RecruiterJobManagerProvider,
      RecruiterApplicationManagerProvider
    >(
      builder: (context, authProvider, jobsProvider, appsProvider, _) {
        final user = authProvider.currentUser;
        final companyName = RecruiterIdentityUtils.companyDisplayName(user);
        final recruiterName = RecruiterIdentityUtils.recruiterDisplayName(user);
        final companyLocation = RecruiterIdentityUtils.companyLocation(user);
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = colorScheme.brightness == Brightness.dark;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GlassCard(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        colorScheme.surfaceContainerHigh.withValues(
                          alpha: 0.86,
                        ),
                        colorScheme.primaryContainer.withValues(alpha: 0.42),
                      ]
                    : const [Color(0xFFF7F8FC), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.surface.withValues(
                          alpha: isDark ? 0.35 : 0.28,
                        ),
                        child: Icon(
                          Icons.business,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(companyLocation),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Managed by $recruiterName',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      RecruiterGlowChip(label: 'Verified Employer'),
                      RecruiterGlowChip(label: 'Premium Profile'),
                      RecruiterGlowChip(
                        label: '${jobsProvider.jobs.length} live jobs',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (user?.bio?.trim().isNotEmpty ?? false)
                        ? user!.bio!
                        : 'Complete your company profile to attract the right candidates.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.editProfile),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Company Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _GlassCard(
              gradient: LinearGradient(
                colors: [
                  isDark
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.88,
                        )
                      : const Color(0xFFF1F5F9).withValues(alpha: 0.96),
                  isDark
                      ? colorScheme.primaryContainer.withValues(alpha: 0.34)
                      : const Color(0xFFBFDBFE).withValues(alpha: 0.72),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Brand Snapshot',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Icon(Icons.auto_awesome_rounded),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Open Roles',
                          value: jobsProvider.openJobCount.toString(),
                          icon: Icons.work_outline,
                          accent: DesignTokens.accentPurple,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: 'Applicants',
                          value: appsProvider.applications.length.toString(),
                          icon: Icons.groups_outlined,
                          accent: DesignTokens.accentTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add fresh roles and keep your profile polished so candidates feel momentum when they land here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;

  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RecruiterJobManagerProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                RecruiterGlowChip(
                  label: job.status.toUpperCase(),
                  glowColor: job.isClosed
                      ? DesignTokens.accentPhilippineRed
                      : DesignTokens.accentPurple,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${job.location} • ${job.salaryDisplay}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                RecruiterGlowChip(label: '${job.applicationCount} applicants'),
                if (job.isDeadlinePassed)
                  RecruiterGlowChip(
                    label: 'Deadline passed',
                    glowColor: Colors.orangeAccent,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Tooltip(
                  message: 'Edit job posting',
                  child: TextButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.recruiterJobEdit.replaceFirst(
                        ':id',
                        job.id.toString(),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                Tooltip(
                  message: job.isClosed
                      ? 'Job already closed'
                      : 'Close job posting',
                  child: TextButton.icon(
                    onPressed: job.isClosed
                        ? null
                        : () => _confirmCloseJob(context, provider),
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Close'),
                  ),
                ),
                Tooltip(
                  message: 'Delete job posting',
                  child: TextButton.icon(
                    onPressed: () => _confirmDeleteJob(context, provider),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCloseJob(
    BuildContext context,
    RecruiterJobManagerProvider provider,
  ) async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close this job?'),
        content: const Text(
          'Candidates will no longer be able to apply once this job is closed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Close Job'),
          ),
        ],
      ),
    );

    if (shouldClose != true || !context.mounted) return;
    try {
      await provider.closeJob(job.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Job closed successfully.')),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to close job.')),
        );
    }
  }

  Future<void> _confirmDeleteJob(
    BuildContext context,
    RecruiterJobManagerProvider provider,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this job?'),
        content: const Text(
          'This action cannot be undone and removes the listing from your dashboard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: const Text('Delete Job'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;
    try {
      await provider.deleteJob(job.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Job deleted successfully.')),
        );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to delete job.')),
        );
    }
  }
}

class _ApplicantCard extends StatelessWidget {
  final RecruiterApplication app;

  const _ApplicantCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.surface.withValues(
                    alpha: isDark ? 0.30 : 0.18,
                  ),
                  child: Text(
                    app.applicantName.isNotEmpty
                        ? app.applicantName[0].toUpperCase()
                        : '?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.applicantName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.applicantEmail,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                RecruiterGlowChip(label: app.statusDisplay),
                if (app.applicantLocation.isNotEmpty)
                  RecruiterGlowChip(
                    label: app.applicantLocation,
                    glowColor: DesignTokens.accentPurple,
                  ),
              ],
            ),
            const SizedBox(height: 8),
                      FilledButton(
              onPressed: () => _showQuickActions(context),
              child: const Text('Quick Actions'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuickActions(BuildContext context) async {
    final provider = context.read<RecruiterApplicationManagerProvider>();
    bool isSubmitting = false;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.applicantName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _quickAction(
                          context,
                          'Shortlist',
                          isSubmitting: isSubmitting,
                          onTap: () async {
                            final note = await _promptDecisionNote(
                              context,
                              title: 'Shortlist candidate',
                              hintText:
                                  'Optional note for recruiter team/candidate',
                            );
                            if (!context.mounted || note == null) return false;
                            setModalState(() => isSubmitting = true);
                            final ok = await _applyStatusUpdate(
                              context,
                              provider,
                              status: 'shortlisted',
                              notes: note,
                              successMessage: 'Candidate shortlisted.',
                            );
                            if (context.mounted) {
                              setModalState(() => isSubmitting = false);
                            }
                            return ok;
                          },
                        ),
                        _quickAction(
                          context,
                          'Reject',
                          isSubmitting: isSubmitting,
                          onTap: () async {
                            final note = await _promptDecisionNote(
                              context,
                              title: 'Reject candidate',
                              hintText: 'Optional reason for rejection',
                            );
                            if (!context.mounted || note == null) return false;
                            setModalState(() => isSubmitting = true);
                            final ok = await _applyStatusUpdate(
                              context,
                              provider,
                              status: 'rejected',
                              notes: note,
                              successMessage: 'Candidate rejected.',
                            );
                            if (context.mounted) {
                              setModalState(() => isSubmitting = false);
                            }
                            return ok;
                          },
                        ),
                        _quickAction(
                          context,
                          'Hire',
                          isSubmitting: isSubmitting,
                          onTap: () async {
                            final note = await _promptDecisionNote(
                              context,
                              title: 'Mark candidate as hired',
                              hintText: 'Optional onboarding note',
                            );
                            if (!context.mounted || note == null) return false;
                            setModalState(() => isSubmitting = true);
                            final ok = await _applyStatusUpdate(
                              context,
                              provider,
                              status: 'accepted',
                              notes: note,
                              successMessage: 'Candidate marked as hired.',
                            );
                            if (context.mounted) {
                              setModalState(() => isSubmitting = false);
                            }
                            return ok;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _applyStatusUpdate(
    BuildContext context,
    RecruiterApplicationManagerProvider provider, {
    required String status,
    String? notes,
    required String successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.updateApplicationStatus(app.id, status, notes: notes);
      if (!context.mounted) return false;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              provider.error ?? 'Unable to update application status.',
            ),
          ),
        );
      return false;
    }
  }

  Widget _quickAction(
    BuildContext context,
    String label, {
    required bool isSubmitting,
    required Future<bool> Function() onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
      onPressed: isSubmitting
          ? null
          : () async {
              final shouldClose = await onTap();
              if (!shouldClose || !context.mounted) return;
              Navigator.of(context).pop();
            },
      child: Text(label),
    );
  }

  Future<String?> _promptDecisionNote(
    BuildContext context, {
    required String title,
    required String hintText,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(''),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value;
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding,
      borderRadius: 18,
      blurStrength: 22,
      opacity: 0.30,
      borderOpacity: 0.18,
      shadowIntensity: 0.22,
      backgroundGradient: gradient,
      enableGlow: true,
      child: child,
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primary.withValues(alpha: 0.22),
      backgroundColor: colorScheme.surface.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.72),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _RecruiterTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _RecruiterTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _RecruiterSwitchTabIntent extends Intent {
  final int index;
  const _RecruiterSwitchTabIntent(this.index);
}

class _RecruiterShortcutHelpIntent extends Intent {
  const _RecruiterShortcutHelpIntent();
}
