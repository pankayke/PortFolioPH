import 'package:flutter/material.dart';

import 'package:portfolioph/core/styling/design_tokens.dart';
import 'package:portfolioph/data/models/job_listing_model.dart';

class StatBadge extends StatelessWidget {
  final String label;

  const StatBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class JobFeedCard extends StatefulWidget {
  final JobListingModel job;
  final bool saved;
  final int index;
  final VoidCallback onApply;
  final VoidCallback onSaveToggle;
  final VoidCallback onShare;

  const JobFeedCard({
    super.key,
    required this.job,
    required this.saved,
    required this.index,
    required this.onApply,
    required this.onSaveToggle,
    required this.onShare,
  });

  @override
  State<JobFeedCard> createState() => _JobFeedCardState();
}

class _JobFeedCardState extends State<JobFeedCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final shouldShowSeeMore = widget.job.description.trim().length > 140;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (widget.index * 90)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.job.title} @ ${widget.job.company}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Chip(
                    label: Text(widget.job.category),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${widget.job.salary} • ${widget.job.location}'),
              const SizedBox(height: 6),
              Text(
                widget.job.description,
                maxLines: _expanded ? null : 3,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if (shouldShowSeeMore)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.accentPurple,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(_expanded ? 'See less' : 'See more'),
                  ),
                ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: widget.onApply,
                      child: const Text('Apply'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: widget.onSaveToggle,
                      icon: Icon(
                        widget.saved ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(widget.saved ? 'Saved' : 'Save'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: widget.onShare,
                      child: const Text('Share'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showQuickApplySheet(
  BuildContext context,
  JobListingModel job,
) async {
  final noteController = TextEditingController();
  bool attachResume = true;

  final submitted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              4,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Apply • ${job.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Why should we hire you? (100 chars max)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLength: 100,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Masipag ako, mabilis matuto, at team player.',
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: attachResume,
                  title: const Text('Attach resume from profile'),
                  onChanged: (value) {
                    setSheetState(() => attachResume = value);
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (noteController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add a short intro first.'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Send Application'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  noteController.dispose();
  return submitted ?? false;
}
