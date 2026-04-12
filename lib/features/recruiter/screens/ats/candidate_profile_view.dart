import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/presentation/providers/file_download_provider.dart';
import 'package:portfolioph/presentation/widgets/file_download_widgets.dart';
import 'package:portfolioph/presentation/widgets/gwa_tracker_widget.dart';
import 'package:portfolioph/presentation/widgets/student_portfolio_sections.dart';

class CandidateProfileView extends StatefulWidget {
  final RecruiterApplication application;

  const CandidateProfileView({super.key, required this.application});

  @override
  State<CandidateProfileView> createState() => _CandidateProfileViewState();
}

class _CandidateProfileViewState extends State<CandidateProfileView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final application = widget.application;
    final skills = _inferSkills(application);
    final hasResume = application.resumeUrl?.isNotEmpty == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GlassCard(
          blurSigma: 22,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.16),
                      colorScheme.secondary.withValues(alpha: 0.10),
                      colorScheme.surface.withValues(alpha: 0.84),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.70)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
                          child: Text(
                            application.applicantName.isNotEmpty
                                ? application.applicantName[0].toUpperCase()
                                : '?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                application.applicantName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                application.applicantEmail,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  GlassGlowChip(label: application.statusDisplay),
                                  if (application.applicantLocation.isNotEmpty)
                                    GlassGlowChip(
                                      label: application.applicantLocation,
                                      glowColor: colorScheme.secondary,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (hasResume)
                          Consumer<FileDownloadProvider>(
                            builder: (context, downloadProvider, _) {
                              return DownloadButton(
                                label: 'CV',
                                icon: Icons.file_download_outlined,
                                isLoading: downloadProvider.isDownloading,
                                onPressed: () async {
                                  if (downloadProvider.isDownloading) return;
                                  await downloadProvider.downloadApplicantCV(application.id);
                                },
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricPill(
                            label: 'Skills',
                            value: skills.length.toString(),
                            icon: Icons.star_outline,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricPill(
                            label: 'Portfolio',
                            value: hasResume ? 'Ready' : 'Missing',
                            icon: Icons.folder_open_outlined,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricPill(
                            label: 'Cover',
                            value: application.coverLetter == null ? '0' : '1',
                            icon: Icons.description_outlined,
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                blurSigma: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Snapshot',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StudentPortfolioSections(
                      controller: _tabController,
                      reflectionsCount: _countFromText(application.coverLetter),
                      skillsCount: skills.length,
                      educationCount: application.resumeUrl == null ? 0 : 1,
                      experienceCount: application.resumeUrl == null ? 0 : 1,
                      essaysCount: application.coverLetter == null ? 0 : 1,
                      achievementsCount: application.isAccepted ? 1 : 0,
                      certificationsCount: application.resumeUrl == null
                          ? 0
                          : 1,
                    ),
                    const SizedBox(height: 16),
                    GwaTrackerWidget(education: const <EducationModel>[]),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                blurSigma: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (skills.isEmpty)
                      Text(
                        'No structured skills were provided. Review cover letter and resume details below.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills
                            .map((skill) => GlassGlowChip(label: skill))
                            .toList(growable: false),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _inferSkills(RecruiterApplication application) {
    final raw = <String>[
      if (application.coverLetter?.trim().isNotEmpty == true)
        ...application.coverLetter!
            .split(RegExp(r'[\n,;]'))
            .map((part) => part.trim())
            .where((part) => part.length > 2),
      if (application.resumeUrl?.trim().isNotEmpty == true) 'Resume attached',
    ];
    return raw.toSet().take(6).toList(growable: false);
  }

  int _countFromText(String? text) {
    final tokens = text
        ?.split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.length > 3)
        .toList(growable: false);
    if (tokens == null || tokens.isEmpty) return 0;
    return tokens.length > 8 ? 8 : tokens.length;
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
