import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';
import 'package:portfolioph/core/mixins/animation_mixins.dart';
import 'package:portfolioph/core/mixins/screen_mixins.dart';
import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';
import 'package:portfolioph/presentation/providers/job_feed_provider.dart';
import 'package:portfolioph/presentation/providers/navigation_provider.dart';
import 'package:portfolioph/presentation/providers/portfolio_provider.dart';
import 'package:portfolioph/presentation/providers/reflections_provider.dart';
import 'package:portfolioph/presentation/providers/skills_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
import 'package:portfolioph/features/seeker/providers/seeker_application_provider.dart';
import 'package:portfolioph/presentation/widgets/job_feed_widgets.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, UserAwareScreenMixin, BokehAnimationMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  final TextEditingController _dashboardSearchController =
      TextEditingController();
  bool _didInitUserLoad = false;
  String _dashboardJobSearchQuery = '';
  final Set<int> _expandedPreviewJobIds = <int>{};

  void _togglePreviewJobDescription(int jobId) {
    setState(() {
      if (_expandedPreviewJobIds.contains(jobId)) {
        _expandedPreviewJobIds.remove(jobId);
      } else {
        _expandedPreviewJobIds.add(jobId);
      }
    });
  }

  static const List<String> _rotationCategories = [
    'Week 1: IT / Dev Jobs',
    'Week 2: Admin / HR / Sales',
    'Week 3: Creative / Freelance',
    'Week 4: Fresh Grad / OJT',
  ];

  @override
  void initState() {
    super.initState();
    initializeBokehAnimation();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    // Stop polling only when this screen is fully disposed.
    context.read<JobFeedProvider>().stopPolling();
    _fadeController.dispose();
    _scaleController.dispose();
    _dashboardSearchController.dispose();
    disposeBokehAnimation();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitUserLoad) return;
    _didInitUserLoad = true;

    loadDataForUserWithId((userId) {
      // Keep live jobs updated while dashboard is visible.
      // Starting polling inside the post-frame user-load path avoids
      // notifyListeners during the build phase.
      context.read<JobFeedProvider>().startPolling();

      // Load all user data
      context.read<PortfolioProvider>().loadForUser(userId);
      context.read<CertificationProvider>().loadForUser(userId);
      context.read<SkillsProvider>().loadForUser(userId);
      context.read<ReflectionsProvider>().loadForUser(userId);
      context.read<ExperienceProvider>().loadForUser(userId);
      context.read<EducationProvider>().loadForUser(userId);

      // Load jobs with alignment scoring based on user profile
      _loadJobsWithAlignment();
    });
  }

  /// Load jobs with alignment scoring based on user profile.
  Future<void> _loadJobsWithAlignment() async {
    if (!mounted) return;

    final user = context.read<AuthProvider>().currentUser;
    final userSkills = context.read<SkillsProvider>().skills;
    final userExperience = context.read<ExperienceProvider>().experience;
    final userEducation = context.read<EducationProvider>().education;
    final userCerts = context.read<CertificationProvider>().certifications;
    final userProjects = context.read<PortfolioProvider>().projects;

    await context.read<JobFeedProvider>().loadJobsWithAlignment(
      userSkills: userSkills,
      userExperience: userExperience,
      userEducation: userEducation,
      userCertifications: userCerts,
      userProjects: userProjects,
      userLocation: user?.location,
    );
  }

  Future<void> _refresh(int userId) async {
    await Future.wait([
      context.read<PortfolioProvider>().loadForUser(userId),
      context.read<CertificationProvider>().loadForUser(userId),
      context.read<SkillsProvider>().loadForUser(userId),
      context.read<ReflectionsProvider>().loadForUser(userId),
      context.read<ExperienceProvider>().loadForUser(userId),
      context.read<EducationProvider>().loadForUser(userId),
    ]);

    // Recompute alignment only after profile signals are refreshed.
    await _loadJobsWithAlignment();
  }

  Future<void> _quickApply(JobListingModel job) async {
    final submitted = await showQuickApplySheet(context, job);

    if (!mounted || !submitted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied to ${job.company}! Good luck, kabayan 🇵🇭'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to continue.')),
      );
    }

    final displayName = (user.fullName?.trim().isNotEmpty ?? false)
        ? user.fullName!
        : user.username;

    final portfolios = context.select<PortfolioProvider, int>(
      (provider) => provider.portfolios.length,
    );
    final certifications = context.select<CertificationProvider, int>(
      (provider) => provider.certifications.length,
    );
    final skills = context.select<SkillsProvider, int>(
      (provider) => provider.skills.length,
    );
    final reflections = context.select<ReflectionsProvider, int>(
      (provider) => provider.reflections.length,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PremiumAppBackground(
      animation: bokehController,
      lite: true,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _refresh(user.id!),
          color: colorScheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Consumer2<JobFeedProvider, SeekerApplicationProvider>(
                builder: (context, jobsProvider, applicationsProvider, _) {
                  return Column(
                    children: [
                      // Welcome Hero Card
                      FadeTransition(
                        opacity: _fadeController,
                        child: ScaleTransition(
                          scale: _scaleController,
                          child: _buildWelcomeCard(
                            context,
                            displayName,
                            isDark,
                            colorScheme,
                            jobsProvider.jobs.length,
                            jobsProvider.savedJobIds.length,
                            skills,
                            portfolios,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildMomentumStrip(
                        jobsProvider,
                        applicationsProvider,
                        isDark,
                        colorScheme,
                      ),
                      const SizedBox(height: 24),

                      // Jobs & Opportunities
                      _buildJobsOpportunitiesSection(
                        jobsProvider,
                        isDark,
                        colorScheme,
                      ),
                      const SizedBox(height: 24),

                      // Live Job Feed
                      _buildJobFeedSection(jobsProvider, isDark, colorScheme),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // Progress Overview
              _buildProgressOverview(
                portfolios,
                certifications,
                skills,
                reflections,
                isDark,
                colorScheme,
              ),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(context, user, isDark, colorScheme),
              const SizedBox(height: 32),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Opacity(
            opacity: 0.8,
            child: Text(
              'Jobs & Opportunities',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Section Builders
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildWelcomeCard(
    BuildContext context,
    String displayName,
    bool isDark,
    ColorScheme colorScheme,
    int liveJobsCount,
    int savedJobsCount,
    int skillsCount,
    int portfoliosCount,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(13)
                : Colors.white.withAlpha(127),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(26)
                  : Colors.white.withAlpha(89),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(102)
                    : Colors.black.withAlpha(26),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${displayName.toLowerCase()}! 👋',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppConstants.lightBg2
                                      : AppConstants.darkBg1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Para sa mga Pinoy na gustong-gusto mag-progress! 🇵🇭',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF475569),
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                DesignTokens.accentBlueBright,
                                DesignTokens.accentPurple,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withAlpha(90),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              displayName.characters.first.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          onPressed: () =>
                              context.push(AppRoutes.notificationSettings),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.white.withAlpha(18)
                                : Colors.black.withAlpha(13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildStatPill(
                      'Live Jobs: $liveJobsCount',
                      colorScheme,
                      isDark,
                    ),
                    _buildStatPill(
                      'Saved: $savedJobsCount',
                      colorScheme,
                      isDark,
                    ),
                    _buildStatPill('Skills: $skillsCount', colorScheme, isDark),
                    _buildStatPill(
                      'Portfolio: $portfoliosCount',
                      colorScheme,
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, ColorScheme colorScheme, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withAlpha(isDark ? 52 : 30),
                DesignTokens.accentPurple.withAlpha(isDark ? 36 : 24),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withAlpha(77),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(46),
                blurRadius: 14,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentumStrip(
    JobFeedProvider jobsProvider,
    SeekerApplicationProvider applicationsProvider,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final featuredJobs = jobsProvider.jobs.take(3).toList(growable: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withAlpha(isDark ? 58 : 28),
                DesignTokens.accentPurple.withAlpha(isDark ? 42 : 20),
                Colors.white.withAlpha(isDark ? 12 : 64),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 40 : 120),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 26),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
        padding: const EdgeInsets.all(14),
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
                            'Momentum Board',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'A live snapshot of your job hunt this week.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? const Color(0xFFD7E0EA)
                                      : const Color(0xFF475569),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(isDark ? 18 : 160),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withAlpha(isDark ? 28 : 120),
                        ),
                      ),
                      child: Text(
                        '${jobsProvider.jobs.length} live roles',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildStatPill(
                      'Pending: ${applicationsProvider.pendingCount}',
                      colorScheme,
                      isDark,
                    ),
                    _buildStatPill(
                      'Applied: ${applicationsProvider.applicationCount}',
                      colorScheme,
                      isDark,
                    ),
                    _buildStatPill(
                      'Saved: ${jobsProvider.savedJobIds.length}',
                      colorScheme,
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Featured roles',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 154,
                  child: featuredJobs.isEmpty
                      ? _buildMomentumEmptyState(isDark)
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredJobs.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final job = featuredJobs[index];
                            final score = jobsProvider.getJobScore(
                              job.id ?? -1,
                            );
                            return _featuredRoleCard(
                              title: job.title,
                              company: job.company,
                              location: job.location,
                              score: score,
                              isDark: isDark,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMomentumEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(isDark ? 12 : 160),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(isDark ? 20 : 110)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded),
          const SizedBox(height: 8),
          Text(
            'No live roles yet.',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Pull to refresh and new opportunities will appear here.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _featuredRoleCard({
    required String title,
    required String company,
    required String location,
    required double? score,
    required bool isDark,
  }) {
    final scoreLabel = score == null
        ? 'New'
        : '${(score * 100).toStringAsFixed(0)}% match';

    return Container(
      width: 198,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(isDark ? 14 : 168),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(isDark ? 24 : 120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: score == null
                  ? Colors.white.withAlpha(isDark ? 16 : 140)
                  : DesignTokens.accentBlueBright.withAlpha(34),
            ),
            child: Text(
              scoreLabel,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsOpportunitiesSection(
    JobFeedProvider jobsProvider,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final searchTerm = _dashboardJobSearchQuery.trim().toLowerCase();
    final filteredJobs = searchTerm.isEmpty
        ? jobsProvider.jobs
        : jobsProvider.jobs
              .where((job) {
                final haystack =
                    '${job.title} ${job.company} ${job.location} ${job.description}'
                        .toLowerCase();
                return haystack.contains(searchTerm);
              })
              .toList(growable: false);
    final previewJobs = filteredJobs.take(2).toList(growable: false);
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0x4D1E293B)
                : Colors.white.withAlpha(178),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 38 : 120),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 95 : 28),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jobs & Opportunities',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(16),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withAlpha(26),
                              ),
                            ),
                            child: const Icon(Icons.tune_rounded, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(isDark ? 13 : 77),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withAlpha(isDark ? 26 : 102),
                          ),
                        ),
                        child: TextField(
                          controller: _dashboardSearchController,
                          cursorColor: isDark
                              ? Colors.white.withAlpha(220)
                              : const Color(0xFF1E293B),
                          onChanged: (value) {
                            setState(() {
                              _dashboardJobSearchQuery = value;
                            });
                          },
                          onSubmitted: (value) {
                            setState(() {
                              _dashboardJobSearchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search jobs, companies, skills...',
                            prefixIconColor: isDark
                                ? Colors.white.withAlpha(170)
                                : const Color(0xFF334155),
                            suffixIconColor: isDark
                                ? Colors.white.withAlpha(170)
                                : const Color(0xFF334155),
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white.withAlpha(127)
                                  : const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 36,
                            ),
                            suffixIcon: _dashboardJobSearchQuery.trim().isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      _dashboardSearchController.clear();
                                      setState(() {
                                        _dashboardJobSearchQuery = '';
                                      });
                                    },
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withAlpha(220)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _JobCategoriesCarousel(
                  categories: _rotationCategories,
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
                if (searchTerm.isNotEmpty && filteredJobs.isEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'No jobs found for "${_dashboardJobSearchQuery.trim()}".',
                    style: textTheme.bodyMedium,
                  ),
                ],
                if (previewJobs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...previewJobs.map(
                    (job) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildPreviewJobCard(job, isDark, colorScheme),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewJobCard(
    JobListingModel job,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final jobScore = context.read<JobFeedProvider>().getJobScore(job.id ?? -1);
    final (badgeLabel, badgeColorHex) = _getAlignmentBadge(jobScore);
    final badgeColor = Color(
      int.parse(badgeColorHex.replaceFirst('#', '0xff')),
    );
    final jobId = job.id ?? job.title.hashCode;
    final isExpanded = _expandedPreviewJobIds.contains(jobId);
    final showSeeMore = job.description.trim().length > 140;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(13)
                : Colors.white.withAlpha(166),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAlpha(isDark ? 26 : 120),
            ),
          ),
          padding: const EdgeInsets.all(12),
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
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job.company} • ${job.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFAEB9C3)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (jobScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(38),
                        border: Border.all(color: badgeColor.withAlpha(127)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(jobScore * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                job.description,
                maxLines: isExpanded ? null : 3,
                overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFFD7E0EA) : const Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              if (showSeeMore)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => _togglePreviewJobDescription(jobId),
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.accentPurple,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(isExpanded ? 'See less' : 'See more'),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: badgeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          DesignTokens.accentPurple,
                          DesignTokens.accentBlueBright,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => _quickApply(job),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, String) _getAlignmentBadge(double? score) {
    if (score == null) return ('No Score', '#999999');

    if (score >= 0.75) return ('Excellent Match', '#10B981');
    if (score >= 0.50) return ('Good Match', '#3B82F6');
    if (score >= 0.25) return ('Possible Fit', '#F59E0B');

    return ('Review Job', '#EF4444');
  }

  Widget _buildProgressOverview(
    int portfolios,
    int certifications,
    int skills,
    int reflections,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCardPremium(
                context,
                'Portfolios',
                portfolios.toString(),
                Icons.folder_open_rounded,
                const Color(0xFF14B8A6),
                isDark,
                subLabel: 'Profile strength',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCardPremium(
                context,
                'Certifications',
                certifications.toString(),
                Icons.card_membership_rounded,
                DesignTokens.accentBlueBright,
                isDark,
                subLabel: certifications == 0
                    ? 'Add certification'
                    : 'Career proof',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCompactMetricChip(
                'Skills',
                skills.toString(),
                DesignTokens.accentPurple,
                isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactMetricChip(
                'Reflections',
                reflections.toString(),
                const Color(0xFFF59E0B),
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCardPremium(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color accentColor,
    bool isDark, {
    String? subLabel,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withAlpha(38), accentColor.withAlpha(13)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withAlpha(77), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withAlpha(38),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
        padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: accentColor, size: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: accentColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppConstants.lightBg2
                        : AppConstants.darkBg1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subLabel ?? label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? const Color(0xFFAEB9C3)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMetricChip(
    String label,
    String value,
    Color accent,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark
            ? Colors.white.withAlpha(10)
            : Colors.white.withAlpha(170),
        border: Border.all(color: accent.withAlpha(90), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobFeedSection(
    JobFeedProvider jobsProvider,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Job Feed',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (jobsProvider.isLoading && jobsProvider.jobs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          )
        else if (jobsProvider.errorMessage != null && jobsProvider.jobs.isEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.white.withAlpha(102),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(26)
                        : Colors.white.withAlpha(51),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Unable to load live jobs right now.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull to refresh or check backend connection.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (jobsProvider.jobs.isEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.white.withAlpha(102),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(26)
                        : Colors.white.withAlpha(51),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No live jobs found right now. Pull to refresh.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            itemCount: jobsProvider.jobs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final job = jobsProvider.jobs[index];
              final jobId = job.id ?? -1;

              return JobFeedCard(
                job: job,
                index: index,
                saved: jobId > 0 && jobsProvider.isSaved(jobId),
                onApply: () => _quickApply(job),
                onSaveToggle: () {
                  if (jobId <= 0) return;
                  context.read<JobFeedProvider>().toggleSave(jobId);
                },
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Shared ${job.title} with your network.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    dynamic user,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(13)
                    : Colors.white.withAlpha(127),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(26)
                      : Colors.white.withAlpha(89),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    context,
                    Icons.description_outlined,
                    'Resume & Portfolio',
                    'Track achievements & build portfolio',
                    () {
                      context.read<NavigationProvider>().goPortfolio();
                      if (GoRouterState.of(context).uri.path !=
                          AppRoutes.dashboard) {
                        context.go(AppRoutes.dashboard);
                      }
                    },
                    colorScheme,
                  ),
                  Divider(height: 1, color: Colors.white.withAlpha(26)),
                  _buildActionTile(
                    context,
                    Icons.people_alt_outlined,
                    'Saved Jobs',
                    'Review your shortlisted opportunities',
                    () => context.push(AppRoutes.seekerSavedJobs),
                    colorScheme,
                  ),
                  Divider(height: 1, color: Colors.white.withAlpha(26)),
                  _buildActionTile(
                    context,
                    Icons.dark_mode_outlined,
                    'Theme & Display',
                    'Customize appearance & accessibility',
                    () => context.push(AppRoutes.settings),
                    colorScheme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFAEB9C3)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.primary.withAlpha(128),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobCategoriesCarousel extends StatefulWidget {
  final List<String> categories;
  final ColorScheme colorScheme;
  final bool isDark;

  const _JobCategoriesCarousel({
    required this.categories,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  State<_JobCategoriesCarousel> createState() => _JobCategoriesCarouselState();
}

class _JobCategoriesCarouselState extends State<_JobCategoriesCarousel> {
  int _currentCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 80,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() => _currentCategoryIndex = index);
            },
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final isActive = index == _currentCategoryIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedScale(
                  scale: isActive ? 1.0 : 0.92,
                  duration: const Duration(milliseconds: 300),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isActive
                                ? [
                                    widget.colorScheme.primary.withAlpha(51),
                                    widget.colorScheme.primary.withAlpha(25),
                                  ]
                                : [
                                    Colors.white.withAlpha(10),
                                    Colors.white.withAlpha(5),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? widget.colorScheme.primary.withAlpha(102)
                                : Colors.white.withAlpha(26),
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: () =>
                              setState(() => _currentCategoryIndex = index),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                category,
                                textAlign: TextAlign.center,
                                style:
                                    (textTheme.bodyMedium ?? const TextStyle())
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isActive
                                              ? widget.colorScheme.primary
                                              : null,
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.categories.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == _currentCategoryIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentCategoryIndex
                        ? widget.colorScheme.primary
                        : Colors.grey.withAlpha(102),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
