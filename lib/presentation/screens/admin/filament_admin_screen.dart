import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';

class FilamentAdminScreen extends StatefulWidget {
  const FilamentAdminScreen({super.key});

  @override
  State<FilamentAdminScreen> createState() => _FilamentAdminScreenState();
}

class _FilamentAdminScreenState extends State<FilamentAdminScreen> {
  late final ApiService _apiService;
  late final UserRepository _userRepository;

  int _selectedIndex = 0;
  String _userFilter = 'all';
  String _jobFilter = 'all';
  String _applicationFilter = 'all';
  String _searchQuery = '';

  int _userSortColumnIndex = 0;
  bool _userSortAscending = true;
  int _jobSortColumnIndex = 2;
  bool _jobSortAscending = false;
  int _applicationSortColumnIndex = 3;
  bool _applicationSortAscending = true;

  int _usersPage = 0;
  int _jobsPage = 0;
  int _applicationsPage = 0;
  static const int _rowsPerPage = 5;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _tabs = const [
    'Dashboard',
    'Users',
    'Jobs',
    'Applications',
    'Analytics',
  ];

  List<_AdminUser> _users = [
    const _AdminUser(
      id: 1,
      name: 'Maria Cruz',
      email: 'maria@portfolioph.com',
      role: 'job_seeker',
      status: 'active',
    ),
    const _AdminUser(
      id: 2,
      name: 'Tech Solutions Inc.',
      email: 'hr@techsolutions.com',
      role: 'recruiter',
      status: 'pending',
    ),
    const _AdminUser(
      id: 3,
      name: 'Admin User',
      email: 'admin@portfolioph.com',
      role: 'admin',
      status: 'active',
    ),
    const _AdminUser(
      id: 4,
      name: 'Juan Dela Cruz',
      email: 'juan@student.ph',
      role: 'job_seeker',
      status: 'suspended',
    ),
  ];

  List<_AdminJob> _jobs = [
    const _AdminJob(
      id: 11,
      title: 'Flutter Developer',
      company: 'Tech Corp',
      status: 'active',
      applications: 15,
      posted: '2 days ago',
    ),
    const _AdminJob(
      id: 12,
      title: 'Senior React Dev',
      company: 'StartUp Inc',
      status: 'flagged',
      applications: 8,
      posted: '5 days ago',
    ),
    const _AdminJob(
      id: 13,
      title: 'UI/UX Designer',
      company: 'Design Studio',
      status: 'closed',
      applications: 12,
      posted: '1 week ago',
    ),
  ];

  List<_AdminApplication> _applications = [
    const _AdminApplication(
      id: 21,
      candidate: 'Alice Wonder',
      job: 'Flutter Developer',
      status: 'pending',
      submitted: 'Today',
    ),
    const _AdminApplication(
      id: 22,
      candidate: 'Charlie Brown',
      job: 'Senior React Dev',
      status: 'approved',
      submitted: 'Yesterday',
    ),
    const _AdminApplication(
      id: 23,
      candidate: 'Diana Prince',
      job: 'UI/UX Designer',
      status: 'pending',
      submitted: '3 days ago',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(const FlutterSecureStorage());
    _userRepository = UserRepository(apiService: _apiService);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLiveData());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filament Admin Dashboard'),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users, jobs, applications...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.trim().toLowerCase()),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showMessage('No new notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1100;
          if (!compact) return const SizedBox.shrink();
          return Drawer(child: SafeArea(child: _buildSidebar(isCompact: true)));
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1100;

          final content = SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _buildContent(),
              ),
            ),
          );

          if (isCompact) {
            return content;
          }

          return Row(
            children: [
              SizedBox(width: 260, child: _buildSidebar(isCompact: false)),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar({required bool isCompact}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Job Platform Admin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(color: colorScheme.outlineVariant),
          ..._tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = _selectedIndex == index;

            return ListTile(
              selected: isSelected,
              selectedTileColor: colorScheme.primary.withValues(alpha: 0.18),
              leading: Icon(switch (index) {
                0 => Icons.dashboard_outlined,
                1 => Icons.people_outline,
                2 => Icons.work_outline,
                3 => Icons.assignment_outlined,
                _ => Icons.analytics_outlined,
              }, color: colorScheme.onPrimaryContainer),
              title: Text(
                tab,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() => _selectedIndex = index);
                if (isCompact && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            );
          }),
          const Spacer(),
          Divider(color: colorScheme.outlineVariant),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orangeAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.orangeAccent),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out from admin')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildUsers();
      case 2:
        return _buildJobs();
      case 3:
        return _buildApplications();
      case 4:
        return _buildAnalytics();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDashboard() {
    final activeUsers = _users.where((u) => u.status == 'active').length;
    final pendingRecruiters = _users
        .where((u) => u.role == 'recruiter' && u.status == 'pending')
        .length;
    final activeJobs = _jobs.where((j) => j.status == 'active').length;
    final pendingApps = _applications
        .where((a) => a.status == 'pending')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          MaterialBanner(
            content: Text(_errorMessage!),
            actions: [
              TextButton(onPressed: _refresh, child: const Text('Retry')),
            ],
          ),
        ],
        Text(
          'Dashboard',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _StatCard(
                title: 'Active Users',
                value: '$activeUsers',
                icon: Icons.people,
              ),
              _StatCard(
                title: 'Active Jobs',
                value: '$activeJobs',
                icon: Icons.work,
              ),
              _StatCard(
                title: 'Pending Apps',
                value: '$pendingApps',
                icon: Icons.assignment,
              ),
              _StatCard(
                title: 'Recruiters Pending',
                value: '$pendingRecruiters',
                icon: Icons.pending_actions,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _panel(
          title: 'Recent Activity',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _activityRow(
                Icons.person_add_outlined,
                'New user registered: hr@techsolutions.com',
              ),
              _activityRow(Icons.work_outline, 'Job posted: Flutter Developer'),
              _activityRow(
                Icons.verified_outlined,
                'Recruiter approved: Tech Solutions Inc.',
              ),
              _activityRow(
                Icons.assignment_outlined,
                '3 applications waiting for review',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsers() {
    final users = _users
        .where((user) {
          if (_userFilter == 'all') return true;
          return user.status == _userFilter;
        })
        .where((user) {
          if (_searchQuery.isEmpty) return true;
          return user.name.toLowerCase().contains(_searchQuery) ||
              user.email.toLowerCase().contains(_searchQuery) ||
              user.role.toLowerCase().contains(_searchQuery);
        })
        .toList(growable: false);

    final sortedUsers = List<_AdminUser>.from(users)
      ..sort((a, b) => _compareUsers(a, b, _userSortColumnIndex));
    if (!_userSortAscending) {
      sortedUsers.setAll(0, sortedUsers.reversed);
    }

    final pagedUsers = _paginate(sortedUsers, _usersPage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'User Management',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: 'Export CSV',
              onPressed: () => _showCsvDialog(
                title: 'Users CSV Export',
                csv: _usersToCsv(sortedUsers),
              ),
              icon: const Icon(Icons.download_outlined),
            ),
            Wrap(
              spacing: 8,
              children: [
                _filterChip(
                  'All',
                  _userFilter == 'all',
                  () => setState(() => _userFilter = 'all'),
                ),
                _filterChip(
                  'Active',
                  _userFilter == 'active',
                  () => setState(() => _userFilter = 'active'),
                ),
                _filterChip(
                  'Pending',
                  _userFilter == 'pending',
                  () => setState(() => _userFilter = 'pending'),
                ),
                _filterChip(
                  'Suspended',
                  _userFilter == 'suspended',
                  () => setState(() => _userFilter = 'suspended'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _panel(
          title: 'User Queue',
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _userSortColumnIndex,
                  sortAscending: _userSortAscending,
                  columns: [
                    DataColumn(
                      label: const Text('Name'),
                      onSort: (index, ascending) {
                        setState(() {
                          _userSortColumnIndex = index;
                          _userSortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('Email'),
                      onSort: (index, ascending) {
                        setState(() {
                          _userSortColumnIndex = index;
                          _userSortAscending = ascending;
                        });
                      },
                    ),
                    const DataColumn(label: Text('Role')),
                    DataColumn(
                      label: const Text('Status'),
                      onSort: (index, ascending) {
                        setState(() {
                          _userSortColumnIndex = index;
                          _userSortAscending = ascending;
                        });
                      },
                    ),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: pagedUsers
                      .map((user) => _buildUserRow(user))
                      .toList(growable: false),
                ),
              ),
              _paginationBar(
                page: _usersPage,
                totalItems: sortedUsers.length,
                onPrevious: _usersPage > 0
                    ? () => setState(() => _usersPage--)
                    : null,
                onNext: (_usersPage + 1) * _rowsPerPage < sortedUsers.length
                    ? () => setState(() => _usersPage++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobs() {
    final jobs = _jobs
        .where((job) {
          if (_jobFilter == 'all') return true;
          return job.status == _jobFilter;
        })
        .where((job) {
          if (_searchQuery.isEmpty) return true;
          return job.title.toLowerCase().contains(_searchQuery) ||
              job.company.toLowerCase().contains(_searchQuery) ||
              job.status.toLowerCase().contains(_searchQuery);
        })
        .toList(growable: false);

    final sortedJobs = List<_AdminJob>.from(jobs)
      ..sort((a, b) => _compareJobs(a, b, _jobSortColumnIndex));
    if (!_jobSortAscending) {
      sortedJobs.setAll(0, sortedJobs.reversed);
    }

    final pagedJobs = _paginate(sortedJobs, _jobsPage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Job Postings',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: 'Export CSV',
              onPressed: () => _showCsvDialog(
                title: 'Jobs CSV Export',
                csv: _jobsToCsv(sortedJobs),
              ),
              icon: const Icon(Icons.download_outlined),
            ),
            Wrap(
              spacing: 8,
              children: [
                _filterChip(
                  'All',
                  _jobFilter == 'all',
                  () => setState(() => _jobFilter = 'all'),
                ),
                _filterChip(
                  'Active',
                  _jobFilter == 'active',
                  () => setState(() => _jobFilter = 'active'),
                ),
                _filterChip(
                  'Flagged',
                  _jobFilter == 'flagged',
                  () => setState(() => _jobFilter = 'flagged'),
                ),
                _filterChip(
                  'Closed',
                  _jobFilter == 'closed',
                  () => setState(() => _jobFilter = 'closed'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _panel(
          title: 'Moderation Queue',
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _jobSortColumnIndex,
                  sortAscending: _jobSortAscending,
                  columns: [
                    DataColumn(
                      label: const Text('Position'),
                      onSort: (index, ascending) {
                        setState(() {
                          _jobSortColumnIndex = index;
                          _jobSortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('Company'),
                      onSort: (index, ascending) {
                        setState(() {
                          _jobSortColumnIndex = index;
                          _jobSortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      numeric: true,
                      label: const Text('Applications'),
                      onSort: (index, ascending) {
                        setState(() {
                          _jobSortColumnIndex = index;
                          _jobSortAscending = ascending;
                        });
                      },
                    ),
                    const DataColumn(label: Text('Posted')),
                    DataColumn(
                      label: const Text('Status'),
                      onSort: (index, ascending) {
                        setState(() {
                          _jobSortColumnIndex = index;
                          _jobSortAscending = ascending;
                        });
                      },
                    ),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: pagedJobs
                      .map((job) => _buildJobRow(job))
                      .toList(growable: false),
                ),
              ),
              _paginationBar(
                page: _jobsPage,
                totalItems: sortedJobs.length,
                onPrevious: _jobsPage > 0
                    ? () => setState(() => _jobsPage--)
                    : null,
                onNext: (_jobsPage + 1) * _rowsPerPage < sortedJobs.length
                    ? () => setState(() => _jobsPage++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplications() {
    final applications = _applications
        .where((application) {
          if (_applicationFilter == 'all') return true;
          return application.status == _applicationFilter;
        })
        .where((application) {
          if (_searchQuery.isEmpty) return true;
          return application.candidate.toLowerCase().contains(_searchQuery) ||
              application.job.toLowerCase().contains(_searchQuery) ||
              application.status.toLowerCase().contains(_searchQuery);
        })
        .toList(growable: false);

    final sortedApplications = List<_AdminApplication>.from(applications)
      ..sort((a, b) => _compareApplications(a, b, _applicationSortColumnIndex));
    if (!_applicationSortAscending) {
      sortedApplications.setAll(0, sortedApplications.reversed);
    }

    final pagedApplications = _paginate(sortedApplications, _applicationsPage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Applications & Approvals',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              tooltip: 'Export CSV',
              onPressed: () => _showCsvDialog(
                title: 'Applications CSV Export',
                csv: _applicationsToCsv(sortedApplications),
              ),
              icon: const Icon(Icons.download_outlined),
            ),
            Wrap(
              spacing: 8,
              children: [
                _filterChip(
                  'All',
                  _applicationFilter == 'all',
                  () => setState(() => _applicationFilter = 'all'),
                ),
                _filterChip(
                  'Pending',
                  _applicationFilter == 'pending',
                  () => setState(() => _applicationFilter = 'pending'),
                ),
                _filterChip(
                  'Approved',
                  _applicationFilter == 'approved',
                  () => setState(() => _applicationFilter = 'approved'),
                ),
                _filterChip(
                  'Rejected',
                  _applicationFilter == 'rejected',
                  () => setState(() => _applicationFilter = 'rejected'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _panel(
          title: 'Application Review',
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _applicationSortColumnIndex,
                  sortAscending: _applicationSortAscending,
                  columns: [
                    DataColumn(
                      label: const Text('Candidate'),
                      onSort: (index, ascending) {
                        setState(() {
                          _applicationSortColumnIndex = index;
                          _applicationSortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('Job'),
                      onSort: (index, ascending) {
                        setState(() {
                          _applicationSortColumnIndex = index;
                          _applicationSortAscending = ascending;
                        });
                      },
                    ),
                    DataColumn(
                      label: const Text('Status'),
                      onSort: (index, ascending) {
                        setState(() {
                          _applicationSortColumnIndex = index;
                          _applicationSortAscending = ascending;
                        });
                      },
                    ),
                    const DataColumn(label: Text('Submitted')),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: pagedApplications
                      .map((application) => _buildApplicationRow(application))
                      .toList(growable: false),
                ),
              ),
              _paginationBar(
                page: _applicationsPage,
                totalItems: sortedApplications.length,
                onPrevious: _applicationsPage > 0
                    ? () => setState(() => _applicationsPage--)
                    : null,
                onNext:
                    (_applicationsPage + 1) * _rowsPerPage <
                        sortedApplications.length
                    ? () => setState(() => _applicationsPage++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _compareUsers(_AdminUser a, _AdminUser b, int column) {
    return switch (column) {
      0 => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      1 => a.email.toLowerCase().compareTo(b.email.toLowerCase()),
      3 => a.status.toLowerCase().compareTo(b.status.toLowerCase()),
      _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };
  }

  int _compareJobs(_AdminJob a, _AdminJob b, int column) {
    return switch (column) {
      0 => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      1 => a.company.toLowerCase().compareTo(b.company.toLowerCase()),
      2 => a.applications.compareTo(b.applications),
      4 => a.status.toLowerCase().compareTo(b.status.toLowerCase()),
      _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    };
  }

  int _compareApplications(
    _AdminApplication a,
    _AdminApplication b,
    int column,
  ) {
    return switch (column) {
      0 => a.candidate.toLowerCase().compareTo(b.candidate.toLowerCase()),
      1 => a.job.toLowerCase().compareTo(b.job.toLowerCase()),
      2 => a.status.toLowerCase().compareTo(b.status.toLowerCase()),
      _ => a.candidate.toLowerCase().compareTo(b.candidate.toLowerCase()),
    };
  }

  List<T> _paginate<T>(List<T> items, int page) {
    final start = page * _rowsPerPage;
    if (start >= items.length) return <T>[];
    final end = (start + _rowsPerPage).clamp(0, items.length);
    return items.sublist(start, end);
  }

  Widget _paginationBar({
    required int page,
    required int totalItems,
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
  }) {
    final totalPages = totalItems == 0
        ? 1
        : ((totalItems - 1) ~/ _rowsPerPage) + 1;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Page ${page + 1} of $totalPages'),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Previous page',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _usersToCsv(List<_AdminUser> users) {
    final buffer = StringBuffer('name,email,role,status\n');
    for (final user in users) {
      buffer.writeln('${user.name},${user.email},${user.role},${user.status}');
    }
    return buffer.toString();
  }

  String _jobsToCsv(List<_AdminJob> jobs) {
    final buffer = StringBuffer('title,company,status,applications,posted\n');
    for (final job in jobs) {
      buffer.writeln(
        '${job.title},${job.company},${job.status},${job.applications},${job.posted}',
      );
    }
    return buffer.toString();
  }

  String _applicationsToCsv(List<_AdminApplication> applications) {
    final buffer = StringBuffer('candidate,job,status,submitted\n');
    for (final application in applications) {
      buffer.writeln(
        '${application.candidate},${application.job},${application.status},${application.submitted}',
      );
    }
    return buffer.toString();
  }

  Future<void> _showCsvDialog({
    required String title,
    required String csv,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(width: 560, child: SelectableText(csv)),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: csv));
                if (!context.mounted) return;
                Navigator.of(context).pop();
                _showMessage('CSV copied to clipboard');
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Insights',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _panel(
          title: 'User Growth (Last 30 Days)',
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('Growth trend chart preview')),
          ),
        ),
        const SizedBox(height: 24),
        _panel(
          title: 'Top Metrics',
          child: Row(
            children: [
              Expanded(
                child: _metricCard(
                  'Avg Time to Hire',
                  '12.5 days',
                  Icons.timer_outlined,
                ),
              ),
              Expanded(
                child: _metricCard(
                  'Placement Rate',
                  '87%',
                  Icons.verified_outlined,
                ),
              ),
              Expanded(
                child: _metricCard(
                  'Avg Applications/Job',
                  '5.3',
                  Icons.assessment_outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildUserRow(_AdminUser user) {
    return DataRow(
      cells: [
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(_roleChip(user.role)),
        DataCell(_statusChip(user.status)),
        DataCell(
          Wrap(
            spacing: 8,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit, size: 16),
                onPressed: () => _editUserStatus(user),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: Icon(Icons.delete_outline, size: 16),
                onPressed: () => _toggleUserStatus(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildJobRow(_AdminJob job) {
    return DataRow(
      cells: [
        DataCell(Text(job.title)),
        DataCell(Text(job.company)),
        DataCell(Text('${job.applications}')),
        DataCell(Text(job.posted)),
        DataCell(_statusChip(job.status)),
        DataCell(
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => _editJobStatus(job),
                child: const Text('Review'),
              ),
              TextButton(
                onPressed: () => _quickCloseJob(job),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildApplicationRow(_AdminApplication application) {
    return DataRow(
      cells: [
        DataCell(Text(application.candidate)),
        DataCell(Text(application.job)),
        DataCell(_statusChip(application.status)),
        DataCell(Text(application.submitted)),
        DataCell(
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _setApplicationStatus(application, 'approved'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Approve', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton(
                onPressed: () => _setApplicationStatus(application, 'rejected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Reject', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel({required String title, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _roleChip(String role) {
    final color = switch (role) {
      'admin' => Colors.red,
      'recruiter' => Colors.indigo,
      _ => Colors.blue,
    };

    return Chip(
      label: Text(role),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'active' || 'approved' => Colors.green,
      'pending' => Colors.orange,
      'flagged' || 'suspended' => Colors.red,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(status),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }

  Widget _activityRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    await _loadLiveData(forceRefresh: true);
  }

  Future<void> _loadLiveData({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _userRepository.findByRoles(const ['job_seeker', 'recruiter', 'admin']),
        _apiService.get('/jobs'),
        _apiService.get('/applications'),
      ]);

      final users = results[0] as List<UserModel>;
      final jobs = _extractList(results[1]);
      final applications = _extractList(results[2]);

      setState(() {
        _users = users.map(_adminUserFromModel).toList();
        _jobs = jobs.map(_adminJobFromMap).toList();
        _applications = applications.map(_adminApplicationFromMap).toList();
      });
    } catch (error) {
      debugPrint('[Admin] Failed to load live data: $error');
      setState(() {
        _errorMessage =
            'Live data could not be loaded. Showing the last known state.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editUserStatus(_AdminUser user) async {
    final userId = user.id;
    if (userId == null) {
      _showMessage('This user cannot be edited from the current data source');
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    var selectedRole = user.role;

    try {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit ${user.name}'),
            content: StatefulBuilder(
              builder: (context, setModalState) {
                return SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          decoration: const InputDecoration(labelText: 'Role'),
                          items: const [
                            DropdownMenuItem(
                              value: 'job_seeker',
                              child: Text('Job seeker'),
                            ),
                            DropdownMenuItem(
                              value: 'recruiter',
                              child: Text('Recruiter'),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text('Admin'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setModalState(() => selectedRole = value);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final updatedUser = UserModel(
                    id: userId,
                    username: user.name,
                    email: emailController.text.trim(),
                    passwordHash: '',
                    role: selectedRole,
                    fullName: nameController.text.trim(),
                    bio: null,
                    avatarPath: null,
                    phoneNumber: null,
                    location: '',
                    websiteUrl: '',
                    createdAt: '',
                    updatedAt: '',
                  );

                  await _userRepository.update(updatedUser);
                  if (!mounted) return;
                  navigator.pop();
                  await _loadLiveData(forceRefresh: true);
                  _showMessage(
                    '${updatedUser.fullName ?? updatedUser.username} updated',
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
    }
  }

  Future<void> _toggleUserStatus(_AdminUser user) async {
    final userId = user.id;
    if (userId == null) {
      _showMessage('This user cannot be deleted from the current data source');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete ${user.name}?'),
          content: const Text('This removes the account from the backend.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _userRepository.delete(userId);
    if (!mounted) return;
    await _loadLiveData(forceRefresh: true);
    _showMessage('${user.name} deleted');
  }

  Future<void> _editJobStatus(_AdminJob job) async {
    final jobId = job.id;
    if (jobId == null) {
      _showMessage('This job cannot be updated from the current data source');
      return;
    }

    var selected = job.status;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Review ${job.title}'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return DropdownButtonFormField<String>(
                initialValue: selected,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'flagged', child: Text('Flagged')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() => selected = value);
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await _apiService.put(
                  '/jobs/$jobId',
                  data: {'status': selected},
                );
                if (!mounted) return;
                navigator.pop();
                await _loadLiveData(forceRefresh: true);
                _showMessage('${job.title} marked as $selected');
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _quickCloseJob(_AdminJob job) async {
    final jobId = job.id;
    if (jobId == null) {
      _showMessage('This job cannot be updated from the current data source');
      return;
    }

    await _apiService.put('/jobs/$jobId', data: {'status': 'closed'});
    await _loadLiveData(forceRefresh: true);
    _showMessage('${job.title} is now closed');
  }

  Future<void> _setApplicationStatus(
    _AdminApplication application,
    String status,
  ) async {
    final applicationId = application.id;
    if (applicationId == null) {
      _showMessage(
        'This application cannot be updated from the current data source',
      );
      return;
    }

    await _apiService.put(
      '/applications/$applicationId/status',
      data: {'status': status},
    );
    await _loadLiveData(forceRefresh: true);
    _showMessage('${application.candidate} set to $status');
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data;
      }

      final items = response['items'];
      if (items is List) {
        return items;
      }

      final users = response['users'];
      if (users is List) {
        return users;
      }
    }

    return const [];
  }

  _AdminUser _adminUserFromModel(UserModel user) {
    final role = user.role.toLowerCase();
    return _AdminUser(
      id: user.id,
      name: (user.fullName?.trim().isNotEmpty ?? false)
          ? user.fullName!.trim()
          : user.username,
      email: user.email,
      role: role,
      status: switch (role) {
        'admin' => 'active',
        'recruiter' => 'pending',
        _ => 'active',
      },
    );
  }

  _AdminJob _adminJobFromMap(dynamic raw) {
    final job = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
    final applications = job['applications_count'] ?? job['applications'] ?? 0;
    final createdAt =
        job['created_at']?.toString() ?? job['posted_at']?.toString();
    return _AdminJob(
      id: _asInt(job['id']),
      title: _asString(job['title'] ?? job['job_title'] ?? job['position']),
      company: _asString(
        job['company_name'] ?? job['company'] ?? job['employer_name'],
      ),
      status: _asString(job['status'] ?? 'active'),
      applications: _asInt(applications),
      posted: _formatRelativeDate(createdAt),
    );
  }

  _AdminApplication _adminApplicationFromMap(dynamic raw) {
    final application = raw is Map<String, dynamic>
        ? raw
        : const <String, dynamic>{};
    final candidate = application['user'] is Map<String, dynamic>
        ? _asString(
            (application['user'] as Map<String, dynamic>)['full_name'] ??
                (application['user'] as Map<String, dynamic>)['name'],
          )
        : _asString(
            application['candidate_name'] ??
                application['applicant_name'] ??
                application['applicant'],
          );
    final jobTitle = application['job'] is Map<String, dynamic>
        ? _asString((application['job'] as Map<String, dynamic>)['title'])
        : _asString(application['job_title'] ?? application['position']);
    return _AdminApplication(
      id: _asInt(application['id']),
      candidate: candidate.isEmpty ? 'Unknown Candidate' : candidate,
      job: jobTitle.isEmpty ? 'Untitled Job' : jobTitle,
      status: _asString(application['status'] ?? 'pending'),
      submitted: _formatRelativeDate(
        application['created_at']?.toString() ??
            application['submitted_at']?.toString(),
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  String _formatRelativeDate(String? value) {
    if (value == null || value.isEmpty) return 'Recently';
    return value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Icon(icon, color: colorScheme.primary),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminUser {
  final int? id;
  final String name;
  final String email;
  final String role;
  final String status;

  const _AdminUser({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  _AdminUser copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? status,
  }) {
    return _AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}

class _AdminJob {
  final int? id;
  final String title;
  final String company;
  final String status;
  final int applications;
  final String posted;

  const _AdminJob({
    this.id,
    required this.title,
    required this.company,
    required this.status,
    required this.applications,
    required this.posted,
  });

  _AdminJob copyWith({
    int? id,
    String? title,
    String? company,
    String? status,
    int? applications,
    String? posted,
  }) {
    return _AdminJob(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      status: status ?? this.status,
      applications: applications ?? this.applications,
      posted: posted ?? this.posted,
    );
  }
}

class _AdminApplication {
  final int? id;
  final String candidate;
  final String job;
  final String status;
  final String submitted;

  const _AdminApplication({
    this.id,
    required this.candidate,
    required this.job,
    required this.status,
    required this.submitted,
  });

  _AdminApplication copyWith({
    int? id,
    String? candidate,
    String? job,
    String? status,
    String? submitted,
  }) {
    return _AdminApplication(
      id: id ?? this.id,
      candidate: candidate ?? this.candidate,
      job: job ?? this.job,
      status: status ?? this.status,
      submitted: submitted ?? this.submitted,
    );
  }
}
