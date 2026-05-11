import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';
import 'package:portfolioph/features/recruiter/models/recruiter_dashboard_summary.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_dashboard_provider.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/features/recruiter/utils/recruiter_identity_utils.dart';
import 'package:portfolioph/features/recruiter/widgets/dashboard_activity_item.dart';
import 'package:portfolioph/features/recruiter/widgets/dashboard_job_card.dart';
import 'package:portfolioph/features/recruiter/widgets/dashboard_stat_card.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class RecruiterDashboardOverviewTab extends StatelessWidget {
  final VoidCallback onJumpToAts;

  const RecruiterDashboardOverviewTab({super.key, required this.onJumpToAts});

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      AuthProvider,
      RecruiterDashboardProvider,
      RecruiterJobManagerProvider,
      RecruiterApplicationManagerProvider
    >(
      builder: (context, authProvider, dashboardProvider, jobsProvider, appsProvider, _) {
        final summary = dashboardProvider.summary;

        if (dashboardProvider.isLoading && summary == null) {
          return _DashboardLoadingState(
            onRefresh: () async {
              await Future.wait([
                dashboardProvider.loadDashboard(refresh: true),
                jobsProvider.loadJobs(refresh: true),
                appsProvider.loadApplications(refresh: true),
              ]);
            },
          );
        }

        if (summary == null) {
          return _DashboardErrorState(
            message:
                dashboardProvider.error ??
                'Unable to load recruiter dashboard.',
            onRetry: () async {
              await dashboardProvider.loadDashboard(refresh: true);
            },
          );
        }

        final user = authProvider.currentUser;
        final recruiterName = RecruiterIdentityUtils.recruiterDisplayName(user);
        final companyName = RecruiterIdentityUtils.companyDisplayName(user);
        final activityFeed = _buildActivityFeed(summary);
        final topJobs = summary.topJobs.isNotEmpty
            ? summary.topJobs
            : summary.recentJobs.take(3).toList();
        final upcomingInterviews =
            summary.recentApplications
                .where(
                  (application) =>
                      application.interviewDate != null &&
                      application.interviewDate!.isAfter(DateTime.now()),
                )
                .toList(growable: false)
              ..sort((a, b) => a.interviewDate!.compareTo(b.interviewDate!));

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              dashboardProvider.loadDashboard(refresh: true),
              jobsProvider.loadJobs(refresh: true),
              appsProvider.loadApplications(refresh: true),
            ]);
          },
          child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              _HeroCard(
                recruiterName: recruiterName,
                companyName: companyName,
                newApplicants: summary.newApplicationsCount,
                activeJobs: summary.activeJobs,
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.12,
                children: [
                  DashboardStatCard(
                    label: 'Total Jobs Posted',
                    value: summary.totalJobs.toString(),
                    icon: Icons.work_outline_rounded,
                    accent: DesignTokens.accentPurple,
                    caption: 'Live roles',
                  ),
                  DashboardStatCard(
                    label: 'Active Jobs',
                    value: summary.activeJobs.toString(),
                    icon: Icons.bolt_rounded,
                    accent: DesignTokens.accentTeal,
                    caption: 'Hiring now',
                  ),
                  DashboardStatCard(
                    label: 'Total Applications',
                    value: summary.totalApplications.toString(),
                    icon: Icons.groups_rounded,
                    accent: const Color(0xFFF7B500),
                    caption: 'Pipeline volume',
                  ),
                  DashboardStatCard(
                    label: 'New Applications',
                    value: summary.newApplicationsCount.toString(),
                    icon: Icons.notification_add_outlined,
                    accent: DesignTokens.accentPurple,
                    caption: 'Last 24h',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (upcomingInterviews.isNotEmpty)
                RecruiterGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Upcoming Interviews',
                        subtitle: 'Scheduled candidate touchpoints',
                        actionLabel: 'ATS',
                        onAction: onJumpToAts,
                      ),
                      const SizedBox(height: 10),
                      ...upcomingInterviews
                          .take(3)
                          .map(
                            (application) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${application.applicantName} • ${application.jobTitle} • ${_formatInterviewDate(application.interviewDate!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              if (upcomingInterviews.isNotEmpty) const SizedBox(height: 14),
              RecruiterGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Quick Actions',
                      subtitle: 'Move from insight to action quickly.',
                      actionLabel: 'Manage',
                      onAction: () => context.push(AppRoutes.recruiterJobsList),
                    ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Post Job',
                      subtitle: 'Create a new opening',
                      onTap: () => context.push(AppRoutes.recruiterJobCreate),
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.work_history_outlined,
                      label: 'Manage Jobs',
                      subtitle: 'Review live and draft roles',
                      onTap: () => context.push(AppRoutes.recruiterJobsList),
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      icon: Icons.groups_outlined,
                      label: 'View Applications',
                      subtitle: 'Open the ATS snapshot',
                      onTap: onJumpToAts,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              RecruiterGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Analytics Widget',
                      subtitle:
                          'Applications over the last 7 days and your top roles.',
                    ),
                    const SizedBox(height: 14),
                    RepaintBoundary(
                      child: _ApplicationsChart(
                        stats: summary.applicationStatsByDay,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Top 3 Jobs by Applicants',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (topJobs.isEmpty)
                      _EmptyInlineState(
                        title: 'No live jobs yet',
                        subtitle:
                            'Post the first role to populate performance trends.',
                        onTap: () => context.push(AppRoutes.recruiterJobCreate),
                      )
                    else
                      ...topJobs.map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TopJobRow(job: job),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              RecruiterGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Recent Activity Feed',
                      subtitle:
                          'Latest applicants and recent job postings in one place.',
                      actionLabel: 'ATS',
                      onAction: onJumpToAts,
                    ),
                    const SizedBox(height: 12),
                    if (activityFeed.isEmpty)
                      _EmptyInlineState(
                        title: 'No recent activity',
                        subtitle:
                            'Activity will appear here once you post jobs and receive applicants.',
                        onTap: () => context.push(AppRoutes.recruiterJobCreate),
                      )
                    else
                      ...activityFeed.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DashboardActivityItem(
                            title: entry.title,
                            subtitle: entry.subtitle,
                            meta: entry.meta,
                            icon: entry.icon,
                            accent: entry.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              RecruiterGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'Job Performance Cards',
                      subtitle:
                          'Quick action cards for your strongest and newest roles.',
                    ),
                    const SizedBox(height: 12),
                    if (topJobs.isEmpty)
                      _EmptyInlineState(
                        title: 'No jobs to review yet',
                        subtitle:
                            'Once you post roles, they will appear here with applicant counts.',
                        onTap: () => context.push(AppRoutes.recruiterJobCreate),
                      )
                    else
                      ...topJobs.map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DashboardJobCard(
                            job: job,
                            onEdit: () => context.push(
                              AppRoutes.recruiterJobEdit.replaceFirst(
                                ':id',
                                '${job.id}',
                              ),
                            ),
                            onView: () => context.push(
                              AppRoutes.recruiterJobDetail.replaceFirst(
                                ':id',
                                '${job.id}',
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              RecruiterGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      title: 'ATS Snapshot',
                      subtitle:
                          'A fast read on where candidates are in the pipeline.',
                      actionLabel: 'Open ATS',
                      onAction: onJumpToAts,
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.25,
                      children: [
                        _AtsMetricCard(
                          label: 'Pending',
                          value: summary.pendingApplications,
                          accent: const Color(0xFFF7B500),
                        ),
                        _AtsMetricCard(
                          label: 'Reviewed',
                          value: summary.reviewedApplications,
                          accent: DesignTokens.accentPurple,
                        ),
                        _AtsMetricCard(
                          label: 'Shortlisted',
                          value: summary.shortlistedApplications,
                          accent: DesignTokens.accentTeal,
                        ),
                        _AtsMetricCard(
                          label: 'Rejected',
                          value: summary.rejectedApplications,
                          accent: DesignTokens.accentPhilippineRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FooterPulse(summary: summary),
            ],
          ),
        );
      },
    );
  }

  List<_DashboardActivityEntry> _buildActivityFeed(
    RecruiterDashboardSummary summary,
  ) {
    final entries = <_DashboardActivityEntry>[];

    for (final application in summary.recentApplications.take(5)) {
      final accent = _statusColor(application.status);
      entries.add(
        _DashboardActivityEntry(
          title:
              '${application.applicantName} applied for ${application.jobTitle}',
          subtitle:
              '${application.statusDisplay} · ${application.applicantEmail}',
          meta: _relativeLabel(application.createdAt),
          icon: Icons.person_add_alt_1_rounded,
          accent: accent,
          sortKey: application.createdAt,
        ),
      );
    }

    for (final job in summary.recentJobs.take(5)) {
      entries.add(
        _DashboardActivityEntry(
          title: 'Posted ${job.title}',
          subtitle: '${job.location} · ${job.applicationCount} applicants',
          meta: _relativeLabel(job.createdAt),
          icon: Icons.work_outline_rounded,
          accent: job.isClosed
              ? DesignTokens.accentPhilippineRed
              : DesignTokens.accentTeal,
          sortKey: job.createdAt,
        ),
      );
    }

    entries.sort((a, b) => b.sortKey.compareTo(a.sortKey));
    return entries.take(5).toList(growable: false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return DesignTokens.accentTeal;
      case 'shortlisted':
        return DesignTokens.accentPurple;
      case 'reviewed':
        return DesignTokens.accentPurple;
      case 'rejected':
        return DesignTokens.accentPhilippineRed;
      default:
        return const Color(0xFFF7B500);
    }
  }

  String _relativeLabel(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String _formatInterviewDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _HeroCard extends StatelessWidget {
  final String recruiterName;
  final String companyName;
  final int newApplicants;
  final int activeJobs;

  const _HeroCard({
    required this.recruiterName,
    required this.companyName,
    required this.newApplicants,
    required this.activeJobs,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return RecruiterGlassCard(
      padding: const EdgeInsets.all(18),
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
                      'Welcome back, $recruiterName. Track your hiring pipeline at a glance.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDark
                      ? colorScheme.primaryContainer.withValues(alpha: 0.72)
                      : DesignTokens.lightBase,
                  border: Border.all(
                    color: isDark
                        ? colorScheme.primary.withValues(alpha: 0.45)
                        : DesignTokens.accentPurple.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  color: isDark ? colorScheme.primary : DesignTokens.accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: companyName),
              _Badge(label: '$newApplicants new applicants'),
              _Badge(label: '$activeJobs active jobs'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.78 : 1,
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.75),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.primaryContainer.withValues(
                    alpha: isDark ? 0.85 : 1,
                  ),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationsChart extends StatelessWidget {
  final List<RecruiterDashboardDayStat> stats;

  const _ApplicationsChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final maxCount = stats.fold<int>(
      0,
      (previous, stat) => stat.count > previous ? stat.count : previous,
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Applications over time',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last 7 days',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              maxCount == 0 ? '0 apps' : '$maxCount peak',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: DesignTokens.accentBlueBright,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (stats.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: isDark ? 0.70 : 1,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Text(
              'No application data available yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats
                  .map(
                    (stat) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: maxCount == 0
                                  ? 8
                                  : 20 + ((stat.count / maxCount) * 90),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    DesignTokens.accentBlueBright,
                                    DesignTokens.accentBlue,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              stat.label,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              stat.count.toString(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }
}

class _TopJobRow extends StatelessWidget {
  final Job job;

  const _TopJobRow({required this.job});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final maxApplicants = job.applicationCount == 0 ? 1 : job.applicationCount;
    final isActive = job.status == 'approved' || job.status == 'active';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.78 : 1,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isActive ? DesignTokens.accentTeal : DesignTokens.accentPhilippineRed).withValues(
                    alpha: isDark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (isActive ? DesignTokens.accentTeal : DesignTokens.accentPhilippineRed).withValues(
                      alpha: isDark ? 0.40 : 0.24,
                    ),
                  ),
                ),
                child: Text(
                  isActive ? 'Active' : 'Closed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? (isDark ? DesignTokens.accentTeal : DesignTokens.accentTeal)
                        : (isDark ? DesignTokens.accentPhilippineRed : DesignTokens.accentPhilippineRed),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(job.location, style: Theme.of(context).textTheme.bodySmall),
              Text('${job.applicationCount} applicants'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: job.applicationCount / maxApplicants,
              backgroundColor: colorScheme.surface.withValues(
                alpha: isDark ? 0.92 : 1,
              ),
              valueColor: const AlwaysStoppedAnimation<Color>(
                DesignTokens.accentPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtsMetricCard extends StatelessWidget {
  final String label;
  final int value;
  final Color accent;

  const _AtsMetricCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.78 : 1,
        ),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.40 : 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _FooterPulse extends StatelessWidget {
  final RecruiterDashboardSummary summary;

  const _FooterPulse({required this.summary});

  @override
  Widget build(BuildContext context) {
    return RecruiterGlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: _PulseStat(
              label: 'Jobs with applicants',
              value: summary.jobsWithApplicationCount.toString(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PulseStat(
              label: 'New applicants',
              value: summary.newApplicationsCount.toString(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PulseStat(
              label: 'ATS pending',
              value: summary.pendingApplications.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseStat extends StatelessWidget {
  final String label;
  final String value;

  const _PulseStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.70 : 1,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInlineState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EmptyInlineState({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.78 : 1,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onTap,
            child: const Text('Create a job'),
          ),
        ],
      ),
    );
  }
}

class _DashboardActivityEntry {
  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final Color accent;
  final DateTime sortKey;

  const _DashboardActivityEntry({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.accent,
    required this.sortKey,
  });
}

class _DashboardLoadingState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _DashboardLoadingState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          const _DashboardSkeletonBlock(height: 132),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.12,
            children: const [
              _DashboardSkeletonBlock(height: 110),
              _DashboardSkeletonBlock(height: 110),
              _DashboardSkeletonBlock(height: 110),
              _DashboardSkeletonBlock(height: 110),
            ],
          ),
          const SizedBox(height: 14),
          const _DashboardSkeletonBlock(height: 220),
          const SizedBox(height: 14),
          const _DashboardSkeletonBlock(height: 260),
        ],
      ),
    );
  }
}

class _DashboardSkeletonBlock extends StatelessWidget {
  final double height;

  const _DashboardSkeletonBlock({required this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return RecruiterGlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.55 : 0.72,
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _DashboardErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const SizedBox(height: 80),
        RecruiterGlassCard(
          child: Column(
            children: [
              const Icon(Icons.error_outline_rounded, size: 32),
              const SizedBox(height: 12),
              Text(
                'Dashboard unavailable',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => onRetry(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: isDark ? 0.92 : 1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
