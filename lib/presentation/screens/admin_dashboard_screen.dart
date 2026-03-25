import 'package:flutter/material.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/student_achievements_repository.dart';
import 'package:portfolioph/data/repositories/student_essays_repository.dart';
import 'package:portfolioph/data/repositories/student_reflections_repository.dart';
import 'package:portfolioph/data/repositories/student_skills_repository.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final UserRepository _userRepository = UserRepository();
  final StudentReflectionsRepository _reflectionsRepository =
      StudentReflectionsRepository();
  final StudentSkillsRepository _skillsRepository = StudentSkillsRepository();
  final StudentAchievementsRepository _achievementsRepository =
      StudentAchievementsRepository();
  final StudentEssaysRepository _essaysRepository = StudentEssaysRepository();

  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  List<_StudentPortfolioSnapshot> _allRows = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final students = await _userRepository.findByRoles(const [
        AppConstants.roleStudent,
        AppConstants.roleUser,
      ]);
      final rows = <_StudentPortfolioSnapshot>[];

      for (final student in students) {
        final studentId = student.id;
        if (studentId == null) continue;

        final reflections = await _reflectionsRepository.countByStudentId(
          studentId,
        );
        final skills = await _skillsRepository.countByStudentId(studentId);
        final achievements = await _achievementsRepository.countByStudentId(
          studentId,
        );
        final essays = await _essaysRepository.countByStudentId(studentId);

        rows.add(
          _StudentPortfolioSnapshot(
            user: student,
            reflectionsCount: reflections,
            skillsCount: skills,
            essaysCount: essays,
            achievementsCount: achievements,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _allRows = rows;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRows = _searchQuery.trim().isEmpty
        ? _allRows
        : _allRows
              .where((row) {
                final search = _searchQuery.toLowerCase();
                final name = (row.user.fullName ?? row.user.username)
                    .toLowerCase();
                final email = row.user.email.toLowerCase();
                final section = (row.user.location ?? '').toLowerCase();
                return name.contains(search) ||
                    email.contains(search) ||
                    section.contains(search);
              })
              .toList(growable: false);

    final totalReflections = _allRows.fold<int>(
      0,
      (sum, row) => sum + row.reflectionsCount,
    );
    final totalSkills = _allRows.fold<int>(
      0,
      (sum, row) => sum + row.skillsCount,
    );
    final totalEssays = _allRows.fold<int>(
      0,
      (sum, row) => sum + row.essaysCount,
    );
    final totalAchievements = _allRows.fold<int>(
      0,
      (sum, row) => sum + row.achievementsCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_outlined),
              labelText: 'Search students by name, email, or section',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _AdminStatCard(
            icon: Icons.school_outlined,
            title: 'Students',
            description: '${_allRows.length} total student accounts',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _AdminStatCard(
            icon: Icons.menu_book_outlined,
            title: 'Academic Reflections',
            description: '$totalReflections entries recorded',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _AdminStatCard(
            icon: Icons.auto_graph_outlined,
            title: 'Skills Tracker',
            description: '$totalSkills entries recorded',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _AdminStatCard(
            icon: Icons.edit_note_outlined,
            title: 'Essays',
            description: '$totalEssays entries recorded',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _AdminStatCard(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            description: '$totalAchievements entries recorded',
          ),
          const SizedBox(height: AppConstants.spacingMd),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Failed to load dashboard: $_error'),
            )
          else if (filteredRows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No students matched your search.'),
            )
          else
            ...filteredRows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(
                      row.user.fullName?.trim().isNotEmpty == true
                          ? row.user.fullName!
                          : row.user.username,
                    ),
                    subtitle: Text(
                      '${row.user.email}\nSection: ${row.user.location ?? 'Unassigned'}',
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Reflections: ${row.reflectionsCount}'),
                        Text('Skills: ${row.skillsCount}'),
                        Text('Essays: ${row.essaysCount}'),
                        Text('Achievements: ${row.achievementsCount}'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AdminStatCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

class _StudentPortfolioSnapshot {
  final UserModel user;
  final int reflectionsCount;
  final int skillsCount;
  final int essaysCount;
  final int achievementsCount;

  const _StudentPortfolioSnapshot({
    required this.user,
    required this.reflectionsCount,
    required this.skillsCount,
    required this.essaysCount,
    required this.achievementsCount,
  });
}
