// lib/presentation/screens/admin/filament_admin_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Filament Admin Dashboard Preview
// Shows what the Laravel Filament admin interface looks like
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class FilamentAdminScreen extends StatefulWidget {
  const FilamentAdminScreen({super.key});

  @override
  State<FilamentAdminScreen> createState() => _FilamentAdminScreenState();
}

class _FilamentAdminScreenState extends State<FilamentAdminScreen> {
  int _selectedIndex = 0;

  final List<String> _tabs = ['Dashboard', 'Users', 'Jobs', 'Applications', 'Analytics'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filament Admin Dashboard'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.blue.shade900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Job Platform Admin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(color: Colors.white24),
                ..._tabs.asMap().entries.map((entry) {
                  int index = entry.key;
                  String tab = entry.value;
                  bool isSelected = _selectedIndex == index;

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.blue.shade700,
                    title: Text(
                      tab,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () => setState(() => _selectedIndex = index),
                  );
                }),
                const Spacer(),
                const Divider(color: Colors.white24),
                ListTile(
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
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildContent(),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        // Stats cards
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _StatCard(title: 'Total Users', value: '1,234', icon: Icons.people),
              _StatCard(title: 'Active Jobs', value: '89', icon: Icons.work),
              _StatCard(title: 'Applications', value: '456', icon: Icons.assignment),
              _StatCard(title: 'Pending Approval', value: '23', icon: Icons.pending_actions),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Recent Activity
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...[
                '📝 New job posted by John Doe',
                '👤 User registered: jane.smith@email.com',
                '✅ Application approved for React Developer',
                '⏳ 3 new applications waiting',
              ].map((activity) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(activity),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'User Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('+ New User'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              _buildDataRow('John Doe', 'john@example.com', 'Job Seeker', 'Active'),
              _buildDataRow('Jane Smith', 'jane@example.com', 'Recruiter', 'Active'),
              _buildDataRow('Admin', 'admin@example.com', 'Admin', 'Active'),
              _buildDataRow('Bob Johnson', 'bob@example.com', 'Job Seeker', 'Inactive'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Job Postings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('+ New Job'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Position')),
              DataColumn(label: Text('Company')),
              DataColumn(label: Text('Applications')),
              DataColumn(label: Text('Posted')),
              DataColumn(label: Text('Status')),
            ],
            rows: [
              _buildJobDataRow('Flutter Developer', 'Tech Corp', '15', '2 days ago', 'Active'),
              _buildJobDataRow('Senior React Dev', 'StartUp Inc', '8', '5 days ago', 'Active'),
              _buildJobDataRow('UI/UX Designer', 'Design Studio', '12', '1 week ago', 'Closed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Applications & Approvals',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle),
              label: const Text('Bulk Approve'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Candidate')),
              DataColumn(label: Text('Job')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: [
              _buildAppDataRow('Alice Wonder', 'Flutter Dev', 'Pending'),
              _buildAppDataRow('Charlie Brown', 'React Dev', 'Approved'),
              _buildAppDataRow('Diana Prince', 'UI Designer', 'Pending'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Insights',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Growth (Last 30 Days)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                color: Colors.blue.shade50,
                child: const Center(
                  child: Text('📊 Chart would display here in actual Filament admin'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Metrics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Avg Time to Hire', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('12.5 days', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Placement Rate', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('87%', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Avg Applications/Job', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('5.3', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(String name, String email, String role, String status) {
    return DataRow(
      cells: [
        DataCell(Text(name)),
        DataCell(Text(email)),
        DataCell(Chip(label: Text(role))),
        DataCell(
          Chip(
            label: Text(status),
            backgroundColor: status == 'Active' ? Colors.green.shade100 : Colors.grey.shade200,
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete, size: 16), onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildJobDataRow(String position, String company, String apps, String posted, String status) {
    return DataRow(
      cells: [
        DataCell(Text(position)),
        DataCell(Text(company)),
        DataCell(Text(apps)),
        DataCell(Text(posted)),
        DataCell(
          Chip(
            label: Text(status),
            backgroundColor: status == 'Active' ? Colors.green.shade100 : Colors.grey.shade200,
          ),
        ),
      ],
    );
  }

  DataRow _buildAppDataRow(String candidate, String job, String status) {
    return DataRow(
      cells: [
        DataCell(Text(candidate)),
        DataCell(Text(job)),
        DataCell(
          Chip(
            label: Text(status),
            backgroundColor: status == 'Pending' ? Colors.orange.shade100 : Colors.green.shade100,
          ),
        ),
        DataCell(
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Approve', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () {},
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
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
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
              Icon(icon, color: Colors.blue.shade400),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
          ),
        ],
      ),
    );
  }
}
