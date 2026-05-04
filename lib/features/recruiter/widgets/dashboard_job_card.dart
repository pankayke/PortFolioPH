import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/recruiter/models/job_model.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';

class DashboardJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onEdit;
  final VoidCallback? onView;

  const DashboardJobCard({
    super.key,
    required this.job,
    this.onEdit,
    this.onView,
  });

  bool get _isActive => job.status == 'approved' || job.status == 'active';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _isActive ? colorScheme.primary : colorScheme.error;
    return RecruiterGlassCard(
      padding: const EdgeInsets.all(16),
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
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.26),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _isActive ? 'Active' : 'Closed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniMetric(
                label: 'Applicants',
                value: job.applicationCount.toString(),
              ),
              const SizedBox(width: 10),
              _MiniMetric(
                label: 'Status',
                value: _isActive ? 'Open' : 'Closed',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed:
                      onEdit ??
                      () => context.push(
                        AppRoutes.recruiterJobEdit.replaceFirst(
                          ':id',
                          job.id.toString(),
                        ),
                      ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed:
                      onView ??
                      () => context.push(
                        AppRoutes.recruiterJobDetail.replaceFirst(
                          ':id',
                          job.id.toString(),
                        ),
                      ),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainerHighest.withValues(
            alpha: isDark ? 0.72 : 1,
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.75),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
