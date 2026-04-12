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
                      : _buildDetailPane(context, provider, selected);

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
          Text(
            'Talent Queue',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
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
              child: Text(
                'No candidates match this view yet.',
                style: Theme.of(context).textTheme.bodyMedium,
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
                          Text(
                            application.coverLetter?.trim().isNotEmpty == true
                                ? application.coverLetter!.trim()
                                : 'No cover letter preview available.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildDetailPane(
    BuildContext context,
    RecruiterApplicationManagerProvider provider,
    RecruiterApplication selected,
  ) {
    return ListView(
      shrinkWrap: true,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: provider.isLoading
                  ? null
                  : () => _openAddNoteDialog(provider, selected),
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('Add Note'),
              ),
              OutlinedButton.icon(
                onPressed: provider.isLoading
                  ? null
                  : () => _openInterviewDialog(provider, selected),
                icon: const Icon(Icons.event_outlined),
                label: const Text('Schedule Interview'),
              ),
              FilledButton.tonalIcon(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.updateApplicationStatus(
                        selected.id,
                        ApplicationStatus.shortlisted,
                      ),
                icon: const Icon(Icons.star_outline),
                label: const Text('Shortlist'),
              ),
              FilledButton.tonalIcon(
                onPressed: provider.isLoading
                    ? null
                    : () => provider.updateApplicationStatus(
                        selected.id,
                        ApplicationStatus.rejected,
                      ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Reject'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CandidateProfileView(application: selected),
      ],
    );
  }

  Future<void> _openAddNoteDialog(
    RecruiterApplicationManagerProvider provider,
    RecruiterApplication selected,
  ) async {
    final controller = TextEditingController(text: selected.notes ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Recruiter Note'),
          content: TextField(
            controller: controller,
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              hintText: 'Write evaluation notes for this candidate...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save Note'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    await provider.updateApplicationStatus(
      selected.id,
      selected.status,
      notes: result,
    );

    if (!mounted) return;
    setState(() {
      _selectedApplication = selected.copyWith(notes: result);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Candidate note saved.')),
    );
  }

  Future<void> _openInterviewDialog(
    RecruiterApplicationManagerProvider provider,
    RecruiterApplication selected,
  ) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (pickedTime == null || !mounted) return;

    final scheduledAt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final note =
        'Interview scheduled: ${scheduledAt.toLocal()} (${pickedTime.format(context)})';

    await provider.updateApplicationStatus(
      selected.id,
      ApplicationStatus.reviewing,
      notes: note,
    );

    if (!mounted) return;
    setState(() {
      _selectedApplication = selected.copyWith(
        status: ApplicationStatus.reviewing,
        notes: note,
        interviewDate: scheduledAt,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Interview schedule saved.')),
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
