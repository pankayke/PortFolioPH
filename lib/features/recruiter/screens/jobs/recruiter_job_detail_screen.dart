import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/features/recruiter/providers/recruiter_job_manager_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';
import 'package:portfolioph/features/recruiter/widgets/recruiter_glass_widgets.dart';

class RecruiterJobDetailScreen extends StatefulWidget {
  final int jobId;

  const RecruiterJobDetailScreen({super.key, required this.jobId});

  @override
  State<RecruiterJobDetailScreen> createState() =>
      _RecruiterJobDetailScreenState();
}

class _RecruiterJobDetailScreenState extends State<RecruiterJobDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<RecruiterJobManagerProvider>();

    return PremiumAppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Job Details'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                AppRoutes.recruiterJobEdit.replaceFirst(
                  ':id',
                  widget.jobId.toString(),
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: provider.getJob(widget.jobId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: RecruiterGlassCard(
                    child: Text(
                      provider.error ?? 'Failed to load job details.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              );
            }

            final job = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RecruiterGlassCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
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
                              job.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          RecruiterGlowChip(
                            label: job.status.toUpperCase(),
                            glowColor: job.isClosed
                                ? Colors.red
                                : const Color(0xFF38BDF8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${job.location} • ${job.jobType} • ${job.applicationCount} applicants',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.84),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          RecruiterGlowChip(label: job.salaryDisplay),
                          RecruiterGlowChip(
                            label: job.deadline != null
                                ? job.deadline!
                                      .toLocal()
                                      .toString()
                                      .split(' ')
                                      .first
                                : 'No deadline',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                RecruiterGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        job.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                RecruiterGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Skills',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: job.requiredSkills
                            .map((skill) => RecruiterGlowChip(label: skill))
                            .toList(growable: false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: job.status == 'closed'
                            ? null
                            : () async {
                                await provider.closeJob(job.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Job closed successfully.'),
                                  ),
                                );
                                context.go(AppRoutes.recruiterJobsList);
                              },
                        icon: const Icon(Icons.pause_circle_outline),
                        label: const Text('Close Job'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
