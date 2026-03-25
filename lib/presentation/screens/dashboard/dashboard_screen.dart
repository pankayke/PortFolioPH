import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/mixins/animation_mixins.dart';
import 'package:portfolioph/core/mixins/screen_mixins.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';
import 'package:portfolioph/presentation/providers/job_feed_provider.dart';
import 'package:portfolioph/presentation/providers/portfolio_provider.dart';
import 'package:portfolioph/presentation/providers/reflections_provider.dart';
import 'package:portfolioph/presentation/providers/skills_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
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
  int _currentCategoryIndex = 0;

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
    _fadeController.dispose();
    _scaleController.dispose();
    disposeBokehAnimation();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadDataForUserWithId((userId) {
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
      _loadJobsWithAlignment(),
      Future<void>.delayed(const Duration(milliseconds: 700)),
    ]);
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

    final portfolios = context.watch<PortfolioProvider>().portfolios.length;
    final certifications = context
        .watch<CertificationProvider>()
        .certifications
        .length;
    final skills = context.watch<SkillsProvider>().skills.length;
    final reflections = context.watch<ReflectionsProvider>().reflections.length;
    final jobsProvider = context.watch<JobFeedProvider>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PremiumAppBackground(
      animation: bokehController,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _refresh(user.id!),
          color: colorScheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
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
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Jobs & Opportunities
              _buildJobsOpportunitiesSection(jobsProvider, isDark, colorScheme),
              const SizedBox(height: 24),

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

              // Live Job Feed
              _buildJobFeedSection(jobsProvider, isDark, colorScheme),
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
              onPressed: () => context.push('/settings'),
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
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
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
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                            ),
                            border: Border.all(
                              color: Colors.white.withAlpha(90),
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'M',
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
                          onPressed: () {},
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
                    _buildStatPill('Applied: 3', colorScheme, isDark),
                    _buildStatPill('Saved: 12', colorScheme, isDark),
                    _buildStatPill('Views: 2.4k', colorScheme, isDark),
                    _buildStatPill('50k+ users', colorScheme, isDark),
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
                const Color(0xFF8B5CF6).withAlpha(isDark ? 36 : 24),
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

  Widget _buildJobsOpportunitiesSection(
    JobFeedProvider jobsProvider,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final previewJobs = jobsProvider.jobs.take(2).toList(growable: false);
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
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
                          decoration: InputDecoration(
                            hintText: 'Search jobs, companies, skills...',
                            hintStyle: TextStyle(
                              color: Colors.white.withAlpha(isDark ? 127 : 153),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: Colors.white.withAlpha(isDark ? 127 : 153),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildJobCategoriesCarousel(isDark, colorScheme),
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

  Widget _buildJobCategoriesCarousel(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 80,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() => _currentCategoryIndex = index);
            },
            itemCount: _rotationCategories.length,
            itemBuilder: (context, index) {
              final category = _rotationCategories[index];
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
                                    colorScheme.primary.withAlpha(51),
                                    colorScheme.primary.withAlpha(25),
                                  ]
                                : [
                                    Colors.white.withAlpha(10),
                                    Colors.white.withAlpha(5),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? colorScheme.primary.withAlpha(102)
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
                                    (Theme.of(context).textTheme.bodyMedium ??
                                            const TextStyle())
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isActive
                                              ? colorScheme.primary
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
              _rotationCategories.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == _currentCategoryIndex ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentCategoryIndex
                        ? colorScheme.primary
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
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
                const Color(0xFF3B82F6),
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
                const Color(0xFF8B5CF6),
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
                    'No jobs available yet. Pull to refresh.',
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
                    () => context.go('/dashboard'),
                    colorScheme,
                  ),
                  Divider(height: 1, color: Colors.white.withAlpha(26)),
                  _buildActionTile(
                    context,
                    Icons.people_alt_outlined,
                    'Kapwa Pinoy Network',
                    'Mentorship • Cebu • Manila • Davao',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Networking module coming next sprint.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    colorScheme,
                  ),
                  Divider(height: 1, color: Colors.white.withAlpha(26)),
                  _buildActionTile(
                    context,
                    Icons.dark_mode_outlined,
                    'Theme & Display',
                    'Customize appearance & accessibility',
                    () => context.push('/settings'),
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
