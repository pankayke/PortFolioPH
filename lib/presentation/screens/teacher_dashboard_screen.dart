import 'package:flutter/material.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/data/models/user_model.dart';
import 'package:portfolioph/data/repositories/student_reflections_repository.dart';
import 'package:portfolioph/data/repositories/student_skills_repository.dart';
import 'package:portfolioph/data/repositories/user_repository.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final UserRepository _userRepository = UserRepository();
  final StudentReflectionsRepository _reflectionsRepository =
      StudentReflectionsRepository();
  final StudentSkillsRepository _skillsRepository = StudentSkillsRepository();

  bool _isLoading = true;
  String? _error;
  String _selectedSection = 'All Sections';
  List<_StudentProgress> _allRows = [];

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
        'student',
        'user',
      ]);
      final rows = <_StudentProgress>[];
      for (final student in students) {
        final reflections = await _reflectionsRepository.countByStudentId(
          student.id!,
        );
        final skills = await _skillsRepository.countByStudentId(student.id!);
        rows.add(
          _StudentProgress(
            user: student,
            reflectionsCount: reflections,
            skillsCount: skills,
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
    final filteredRows = _selectedSection == 'All Sections'
        ? _allRows
        : _allRows
              .where(
                (item) =>
                    (item.user.location ?? 'Unassigned') == _selectedSection,
              )
              .toList(growable: false);

    final sections = <String>{
      'All Sections',
      ..._allRows.map((item) => item.user.location ?? 'Unassigned'),
    }.toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher & Coordinator Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text('Failed to load dashboard: $_error'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: sections.contains(_selectedSection)
                        ? _selectedSection
                        : 'All Sections',
                    items: sections
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(growable: false),
                    decoration: const InputDecoration(
                      labelText: 'Class / Section filter',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedSection = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Students in view: ${filteredRows.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredRows.isEmpty
                        ? const Center(
                            child: Text('No students found for this section.'),
                          )
                        : ListView.separated(
                            itemCount: filteredRows.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final row = filteredRows[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.school_outlined),
                                  title: Text(
                                    row.user.fullName?.isNotEmpty == true
                                        ? row.user.fullName!
                                        : row.user.username,
                                  ),
                                  subtitle: Text(
                                    'Section: ${row.user.location ?? 'Unassigned'}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Reflections: ${row.reflectionsCount}',
                                      ),
                                      Text('Skills: ${row.skillsCount}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StudentProgress {
  final UserModel user;
  final int reflectionsCount;
  final int skillsCount;

  const _StudentProgress({
    required this.user,
    required this.reflectionsCount,
    required this.skillsCount,
  });
}
