// lib/presentation/screens/dashboard/applied_jobs_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Screen showing all job applications submitted by the current user.
//
// Features:
//   • Lists all applications with job details and status
//   • Filter by status (Applied, Shortlisted, Rejected, Accepted)
//   • Shows salary range, location, and company info
//   • Displays interview information if scheduled
//   • Withdraw application option
//   • Tap to view full job details
//   • Pagination for large lists
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/features/seeker/models/seeker_application_model.dart';
import 'package:portfolioph/features/seeker/providers/seeker_application_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load applications on screen init
    Future.microtask(() {
      context.read<SeekerApplicationProvider>().loadApplications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more when reaching bottom
      context
          .read<SeekerApplicationProvider>()
          .loadApplications(page: context.read<SeekerApplicationProvider>().currentPage + 1);
    }
  }

  void _applyStatusFilter(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    context.read<SeekerApplicationProvider>().loadApplications(
          status: status,
          refresh: true,
        );
  }

  Future<void> _withdrawApplication(SeekerApplication application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: Text(
          'Are you sure you want to withdraw your application for ${application.jobTitle}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (mounted) {
      try {
        await context
            .read<SeekerApplicationProvider>()
            .withdrawApplication(application.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application withdrawn')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error withdrawing application: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SeekerApplicationProvider>(
      builder: (context, provider, _) {
        return PremiumAppBackground(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Applied Jobs'),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                // Refresh applications by loading with page 1
                await context
                    .read<SeekerApplicationProvider>()
                    .loadApplications(refresh: true);
              },
              child: Column(
                children: [
                  // ── Status Filter ───────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All (${provider.applicationCount})',
                          isSelected: _selectedStatus == null,
                          onPressed: () => _applyStatusFilter(null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Applied (${provider.pendingCount})',
                          isSelected: _selectedStatus == 'applied',
                          onPressed: () => _applyStatusFilter('applied'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Shortlisted (${provider.shortlistedCount})',
                          isSelected: _selectedStatus == 'shortlisted',
                          onPressed: () => _applyStatusFilter('shortlisted'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Accepted (${provider.acceptedCount})',
                          isSelected: _selectedStatus == 'accepted',
                          onPressed: () => _applyStatusFilter('accepted'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Rejected (${provider.rejectedCount})',
                          isSelected: _selectedStatus == 'rejected',
                          onPressed: () => _applyStatusFilter('rejected'),
                        ),
                      ],
                    ),
                  ),

                  // ── Applications List ───────────────────────────────────────
                  Expanded(
                    child: provider.isLoading && provider.applications.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : provider.applications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 64,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No applications yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start applying to jobs to see them here',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(
                                AppConstants.spacingMd),
                                itemCount: provider.applications.length +
                                    (provider.isLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == provider.applications.length) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final application =
                                      provider.applications[index];
                                  return _buildApplicationCard(
                                    application,
                                    onWithdraw: () =>
                                        _withdrawApplication(application),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
    );
  }

  Widget _buildApplicationCard(
    SeekerApplication application, {
    required VoidCallback onWithdraw,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to job details if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.recruiterName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(application.status),
                ],
              ),
              const SizedBox(height: 12),

              // Info row: Location, Salary
              Row(
                children: [
                  if (application.jobLocation != null) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      application.jobLocation!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (application.salaryMin != null &&
                      application.salaryMax != null) ...[
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${application.salaryMin!.toStringAsFixed(0)} - ${application.salaryMax!.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Applied date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Applied ${_formatDate(application.appliedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              // Interview info if present
              if (application.hasInterview) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.video_call_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Interview scheduled for ${_formatDate(application.interviewDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!application.isRejected && !application.isWithdrawn)
                    TextButton(
                      onPressed: onWithdraw,
                      child: const Text('Withdraw'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final textColor = _getStatusTextColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusDisplay(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'applied':
        return const Color(0xFFE3F2FD);
      case 'reviewing':
        return const Color(0xFFFFF3E0);
      case 'shortlisted':
        return const Color(0xFFF1F8E9);
      case 'accepted':
        return const Color(0xFFE8F5E9);
      case 'rejected':
        return const Color(0xFFFFEBEE);
      case 'withdrawn':
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'applied':
        return const Color(0xFF1565C0);
      case 'reviewing':
        return const Color(0xFFE65100);
      case 'shortlisted':
        return const Color(0xFF558B2F);
      case 'accepted':
        return const Color(0xFF2E7D32);
      case 'rejected':
        return const Color(0xFFC62828);
      case 'withdrawn':
        return const Color(0xFF424242);
      default:
        return const Color(0xFF424242);
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'applied':
        return 'Applied';
      case 'reviewing':
        return 'Reviewing';
      case 'shortlisted':
        return 'Shortlisted';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
