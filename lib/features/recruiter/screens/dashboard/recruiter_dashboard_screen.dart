import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/features/recruiter/repositories/recruiter_repository_impl.dart';
import 'package:portfolioph/features/recruiter/screens/ats/applicant_tracking_screen.dart';
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
      context.read<RecruiterJobManagerProvider>().loadJobs(refresh: true);
      context.read<RecruiterApplicationManagerProvider>().loadApplications(
        refresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPostTab = _selectedIndex == 3;
    return PremiumAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A66C2), Color(0xFF38BDF8)],
                  ),
                ),
                child: const Icon(Icons.apartment_rounded, size: 18),
              ),
              const SizedBox(width: 10),
              Text(_tabs[_selectedIndex].label),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final isDark = themeProvider.themeMode == ThemeMode.dark;
                return IconButton(
                  onPressed: () => themeProvider.toggleDarkMode(),
                  icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                );
              },
            ),
            IconButton(
              onPressed: () => context.push(AppRoutes.notificationSettings),
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
            ),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
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
              _RecruiterOverviewTab(onJumpToAts: () => _goToTab(2)),
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
              backgroundColor: Colors.transparent,
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

class _RecruiterOverviewTab extends StatelessWidget {
  final VoidCallback onJumpToAts;

  const _RecruiterOverviewTab({required this.onJumpToAts});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, RecruiterJobManagerProvider,
        RecruiterApplicationManagerProvider>(
      builder: (context, authProvider, jobsProvider, appsProvider, _) {
        final user = authProvider.currentUser;
        final recentApplicants = appsProvider.applications.take(4).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await jobsProvider.loadJobs(refresh: true);
            await appsProvider.loadApplications(refresh: true);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              _GlassCard(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F172A),
                    const Color(0xFF1D4ED8).withValues(alpha: 0.90),
                    const Color(0xFF38BDF8).withValues(alpha: 0.76),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${user?.fullName ?? 'Recruiter'}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user?.location ?? 'Your hiring workspace',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.82),
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  RecruiterGlowChip(label: 'Premium Hiring'),
                                  RecruiterGlowChip(label: 'Fast Review Mode'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white.withValues(alpha: 0.18),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                          ),
                          child: const Icon(Icons.apartment_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Active Jobs',
                      value: jobsProvider.openJobCount.toString(),
                      icon: Icons.work,
                      accent: const Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: 'Applicants',
                      value: appsProvider.applications.length.toString(),
                      icon: Icons.groups,
                      accent: const Color(0xFF60A5FA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Interviews',
                      value: appsProvider.acceptedCount.toString(),
                      icon: Icons.videocam,
                      accent: const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: 'Shortlisted',
                      value: appsProvider.shortlistedCount.toString(),
                      icon: Icons.verified,
                      accent: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _GlassCard(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A66C2).withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.14),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Applicants',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Candidate activity in the last review cycle',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: onJumpToAts,
                      child: const Text('View ATS'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              SizedBox(
                height: 148,
                child: recentApplicants.isEmpty
                    ? const _GlassCard(child: Center(child: Text('No applicants yet.')))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentApplicants.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final app = recentApplicants[index];
                          return SizedBox(
                            width: 240,
                            child: _ApplicantPreviewCard(app: app),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
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
                const _GlassCard(child: Text('No jobs posted yet.')),
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
                const _GlassCard(child: Text('No candidates yet.')),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
      fillColor: Colors.white.withValues(alpha: 0.50),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.80)),
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
    final user = context.watch<AuthProvider>().currentUser;
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
      ],
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
    return GlassCard(
      padding: padding,
      gradient: gradient,
      borderRadius: BorderRadius.circular(20),
      blurSigma: 20,
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
          const Spacer(),
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

class _ApplicantPreviewCard extends StatelessWidget {
  final RecruiterApplication app;

  const _ApplicantPreviewCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = app.applicantName.isNotEmpty
        ? app.applicantName
            .trim()
            .split(' ')
            .take(2)
            .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
            .join()
        : '?';

    return _GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.16),
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.applicantLocation.isNotEmpty
                          ? app.applicantLocation
                          : 'Candidate',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              RecruiterGlowChip(
                label: app.statusDisplay,
                glowColor: app.isAccepted
                    ? colorScheme.tertiary
                    : app.isRejected
                        ? colorScheme.error
                        : colorScheme.primary,
              ),
            ],
          ),
          const Spacer(),
          Text(
            app.coverLetter?.trim().isNotEmpty == true
                ? app.coverLetter!.trim().split(' ').take(8).join(' ')
                : 'No cover letter preview available.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _matchScore(app),
                  minHeight: 6,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(_matchScore(app) * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _matchScore(RecruiterApplication app) {
    if (app.isAccepted) return 0.96;
    if (app.isShortlisted) return 0.82;
    if (app.isReviewing) return 0.65;
    if (app.isRejected) return 0.22;
    return 0.48;
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
