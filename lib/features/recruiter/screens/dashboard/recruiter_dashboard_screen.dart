import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_dashboard_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';
import 'package:portfolioph/features/recruiter/screens/ats/applicant_tracking_screen.dart';
import 'package:portfolioph/features/recruiter/screens/dashboard/recruiter_dashboard_overview_tab.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
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
    final dashboardTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    ).copyWith(
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: const Color(0xFF111827),
            displayColor: const Color(0xFF111827),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
      ),
    );

    return Theme(
      data: dashboardTheme,
      child: PremiumAppBackground(
        child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Opacity(
            opacity: 0.85,
            child: Text(
              _selectedIndex == 0 ? 'Jobs & Opportunities' : _tabs[_selectedIndex].label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Consumer<RecruiterDashboardProvider>(
              builder: (context, dashboardProvider, _) {
                final count = dashboardProvider.notificationCount;
                return IconButton(
                  onPressed: () => context.push(AppRoutes.notificationSettings),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined),
                      if (count > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
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
                  final initial = (user?.fullName ?? 'R').trim().isNotEmpty
                      ? (user?.fullName ?? 'R').trim()[0].toUpperCase()
                      : 'R';
                  final isDark = themeProvider.themeMode == ThemeMode.dark;

                  return PopupMenuButton<String>(
                    tooltip: 'Profile',
                    onSelected: (value) {
                      switch (value) {
                        case 'theme':
                          final nextIsDark = themeProvider.themeMode != ThemeMode.dark;
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
                                duration: const Duration(milliseconds: 1400),
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
                          children: [
                            Icon(Icons.business_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Company Profile'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 10),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: IndexedStack(
            key: ValueKey(_selectedIndex),
            index: _selectedIndex,
            children: [
              RecruiterDashboardOverviewTab(onJumpToAts: () => _goToTab(2)),
              const _RecruiterJobsTab(),
              const ApplicantTrackingScreen(compactMode: true),
              _RecruiterJobCreateTab(onPosted: () => _goToTab(1)),
              const _RecruiterCompanyProfileTab(),
            ],
          ),
        ),
        floatingActionButton: isPostTab
            ? null
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A66C2), Color(0xFF0284C7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A66C2).withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
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
              backgroundColor: Colors.white,
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
}

class _RecruiterJobsTab extends StatefulWidget {
  const _RecruiterJobsTab();

  @override
  State<_RecruiterJobsTab> createState() => _RecruiterJobsTabState();
}

class _RecruiterJobsTabState extends State<_RecruiterJobsTab> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    return Consumer<RecruiterJobManagerProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.loadJobs(refresh: true, status: _status),
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
                        provider.loadJobs(refresh: true);
                      },
                    ),
                    const SizedBox(width: 8),
                    _StatusFilterChip(
                      label: 'Active',
                      selected: _status == 'approved',
                      onTap: () {
                        setState(() => _status = 'approved');
                        provider.loadJobs(refresh: true, status: 'approved');
                      },
                    ),
                    const SizedBox(width: 8),
                    _StatusFilterChip(
                      label: 'Draft',
                      selected: _status == 'draft',
                      onTap: () {
                        setState(() => _status = 'draft');
                        provider.loadJobs(refresh: true, status: 'draft');
                      },
                    ),
                    const SizedBox(width: 8),
                    _StatusFilterChip(
                      label: 'Closed',
                      selected: _status == 'closed',
                      onTap: () {
                        setState(() => _status = 'closed');
                        provider.loadJobs(refresh: true, status: 'closed');
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
                    const Color(0xFF0A66C2).withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.10),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${provider.jobs.length} postings',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
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
                  child: Text('No jobs posted yet. Create your first listing in the Create tab.'),
                ),
              ...provider.jobs.map((job) => _JobCard(job: job)),
            ],
          ),
        );
      },
    );
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
                    const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.10),
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
                  child: Text('No candidates yet. Move new applicants through ATS once they apply.'),
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
              onChanged: (value) => setState(() => _jobType = value ?? 'full_time'),
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
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully.')),
      );
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
    return Consumer3<AuthProvider, RecruiterJobManagerProvider,
        RecruiterApplicationManagerProvider>(
      builder: (context, authProvider, jobsProvider, appsProvider, _) {
        final user = authProvider.currentUser;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GlassCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
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
                        backgroundColor: Colors.white.withValues(alpha: 0.28),
                        child: const Icon(Icons.business),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Company Name',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(user?.location ?? 'Philippines'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      RecruiterGlowChip(label: 'Verified Employer'),
                      RecruiterGlowChip(label: 'Premium Profile'),
                      RecruiterGlowChip(label: '${jobsProvider.jobs.length} live jobs'),
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
                  Text('Company Description', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    (user?.bio?.trim().isNotEmpty ?? false)
                        ? user!.bio!
                        : 'Complete your company profile to attract the right candidates.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
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
                  const Color(0xFF1E293B).withValues(alpha: 0.88),
                  const Color(0xFF2563EB).withValues(alpha: 0.28),
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
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
                          accent: const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: 'Applicants',
                          value: appsProvider.applications.length.toString(),
                          icon: Icons.groups_outlined,
                          accent: const Color(0xFF34D399),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add fresh roles and keep your profile polished so candidates feel momentum when they land here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
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
                  glowColor: job.isClosed ? Colors.redAccent : const Color(0xFF38BDF8),
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
                if (job.isDeadlinePassed) RecruiterGlowChip(label: 'Deadline passed', glowColor: Colors.orangeAccent),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => context.push('/recruiter/jobs/${job.id}/edit'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => provider.closeJob(job.id),
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Close'),
                ),
                TextButton.icon(
                  onPressed: () => provider.deleteJob(job.id),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final RecruiterApplication app;

  const _ApplicantCard({required this.app});

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: Text(
                    app.applicantName.isNotEmpty ? app.applicantName[0].toUpperCase() : '?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
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
                  RecruiterGlowChip(label: app.applicantLocation, glowColor: const Color(0xFF60A5FA)),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
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
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app.applicantName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _quickAction(context, 'Shortlist', () {
                      provider.updateApplicationStatus(app.id, 'shortlisted');
                    }),
                    _quickAction(context, 'Reject', () {
                      provider.updateApplicationStatus(app.id, 'rejected');
                    }),
                    _quickAction(context, 'Hire', () {
                      provider.updateApplicationStatus(app.id, 'accepted');
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickAction(BuildContext context, String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: () {
        onTap();
        Navigator.of(context).pop();
      },
      child: Text(label),
    );
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
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.72)),
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
