import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/features/recruiter/models/application_model.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_application_manager_provider.dart';
import 'package:portfolioph/features/recruiter/screens/ats/candidate_profile_view.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class ApplicantTrackingScreen extends StatefulWidget {
  final bool compactMode;

  const ApplicantTrackingScreen({super.key, this.compactMode = false});

  @override
  State<ApplicantTrackingScreen> createState() =>
      _ApplicantTrackingScreenState();
}

class _ApplicantTrackingScreenState extends State<ApplicantTrackingScreen> {
  String? _selectedStatus;
  RecruiterApplication? _selectedApplication;

  @override
  Widget build(BuildContext context) {
    return PremiumAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: widget.compactMode
            ? null
            : AppBar(
                title: const Text('Applicant Tracking'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
        body: Consumer<RecruiterApplicationManagerProvider>(
          builder: (context, provider, _) {
            final applications = _filteredApplications(provider.applications);
            final selected =
                _selectedApplication ??
                (applications.isNotEmpty ? applications.first : null);

            return RefreshIndicator(
              onRefresh: () => provider.loadApplications(refresh: true),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wideLayout = constraints.maxWidth >= 920;

                  final listPane = _buildListPane(
                    context,
                    provider,
                    applications,
                  );
                  final detailPane = selected == null
                      ? _emptyState(context)
                      : CandidateProfileView(application: selected);

                  if (wideLayout && !widget.compactMode) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(width: 360, child: listPane),
                          const SizedBox(width: 16),
                          Expanded(child: detailPane),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      listPane,
                      const SizedBox(height: 16),
                      detailPane,
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  List<RecruiterApplication> _filteredApplications(
    List<RecruiterApplication> applications,
  ) {
    if (_selectedStatus == null) return applications;
    return applications
        .where((app) => app.status == _selectedStatus)
        .toList(growable: false);
  }

  Widget _buildListPane(
    BuildContext context,
    RecruiterApplicationManagerProvider provider,
    List<RecruiterApplication> applications,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.14),
                  colorScheme.surface.withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.70),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Talent Queue',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${applications.length} live',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Move quickly through incoming applicants and keep the flow visible.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusFilterChip(
                  label: 'All',
                  selected: _selectedStatus == null,
                  onTap: () => setState(() => _selectedStatus = null),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Shortlisted',
                  selected: _selectedStatus == 'shortlisted',
                  onTap: () => setState(() => _selectedStatus = 'shortlisted'),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Pending',
                  selected: _selectedStatus == 'pending',
                  onTap: () => setState(() => _selectedStatus = 'pending'),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Rejected',
                  selected: _selectedStatus == 'rejected',
                  onTap: () => setState(() => _selectedStatus = 'rejected'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${applications.length} candidate${applications.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.isLoading && applications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (applications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.person_search_outlined,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No candidates match this filter yet. Try switching status tabs or clear filters.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: widget.compactMode ? 220 : 420,
              child: ListView.separated(
                itemCount: applications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final application = applications[index];
                  final isSelected = _selectedApplication?.id == application.id;

                  return InkWell(
                    onTap: () =>
                        setState(() => _selectedApplication = application),
                    child: GlassCard(
                      borderRadius: BorderRadius.circular(18),
                      padding: const EdgeInsets.all(14),
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.18),
                                colorScheme.surface.withValues(alpha: 0.12),
                              ],
                            )
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                child: Text(
                                  application.applicantName.isNotEmpty
                                      ? application.applicantName[0]
                                            .toUpperCase()
                                      : '?',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
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
                                      application.applicantName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      application.applicantEmail,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              GlassGlowChip(label: application.statusDisplay),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  application.applicantLocation.isNotEmpty
                                      ? application.applicantLocation
                                      : 'Location unavailable',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(
                                  () => _selectedApplication = application,
                                ),
                                child: const Text('Open'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return GlassCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Select a candidate to inspect their premium profile.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
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
      backgroundColor: colorScheme.surface.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.75),
      ),
    );
  }
}
