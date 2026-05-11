import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/mixins/animation_mixins.dart';
import 'package:portfolioph/core/mixins/screen_mixins.dart';
import 'package:portfolioph/core/utils/helpers.dart';
import 'package:portfolioph/data/models/student_essay_model.dart';
import 'package:portfolioph/data/models/student_achievement_model.dart';
import 'package:portfolioph/data/models/student_reflections_model.dart';
import 'package:portfolioph/data/models/student_skills_model.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';
import 'package:portfolioph/presentation/providers/student_essays_provider.dart';
import 'package:portfolioph/presentation/providers/student_achievements_provider.dart';
import 'package:portfolioph/presentation/providers/student_reflections_provider.dart';
import 'package:portfolioph/presentation/providers/student_skills_provider.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
import 'package:portfolioph/presentation/screens/resume/add_edit_certification_screen.dart';
import 'package:portfolioph/presentation/screens/resume/add_edit_education_screen.dart';
import 'package:portfolioph/presentation/screens/resume/add_edit_experience_screen.dart';
import 'package:portfolioph/presentation/screens/resume/resume_export_screen.dart';
import 'package:portfolioph/presentation/widgets/gwa_tracker_widget.dart';
import 'package:portfolioph/presentation/widgets/student_portfolio_sections.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class ResumeScreen extends StatefulWidget {
  const ResumeScreen({super.key});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen>
    with TickerProviderStateMixin, BokehAnimationMixin, UserAwareScreenMixin {
  late final TabController _tabController;
  bool _didInitUserLoad = false;

  static const BorderRadius _dialogRadius = BorderRadius.all(
    Radius.circular(20),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    initializeBokehAnimation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    disposeBokehAnimation();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitUserLoad) return;
    _didInitUserLoad = true;
    loadDataForUserWithId((userId) {
      context.read<CertificationProvider>().loadForUser(userId);
      context.read<EducationProvider>().loadForUser(userId);
      context.read<ExperienceProvider>().loadForUser(userId);
      context.read<StudentReflectionsProvider>().loadForStudent(userId);
      context.read<StudentSkillsProvider>().loadForStudent(userId);
      context.read<StudentEssaysProvider>().loadForStudent(userId);
      context.read<StudentAchievementsProvider>().loadForStudent(userId);
    });
  }

  Future<void> _openAddCertification(int userId) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditCertificationScreen(userId: userId),
      ),
    );

    if (didSave == true && mounted) {
      await context.read<CertificationProvider>().loadForUser(userId);
    }
  }

  Future<void> _addReflection(int userId) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String mood = 'okay';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: _dialogRadius),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              title: const Text('Add Reflection'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Reflection',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: mood,
                      decoration: const InputDecoration(labelText: 'Mood'),
                      items: const [
                        DropdownMenuItem(value: 'happy', child: Text('Happy')),
                        DropdownMenuItem(value: 'okay', child: Text('Okay')),
                        DropdownMenuItem(
                          value: 'challenged',
                          child: Text('Challenged'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() => mood = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true || !mounted) return;
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and reflection are required.')),
      );
      return;
    }

    final now = AppHelpers.nowIso();
    final model = StudentReflectionModel(
      studentId: userId,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      mood: mood,
      reflectionDate: now,
      createdAt: now,
      updatedAt: now,
    );

    await context.read<StudentReflectionsProvider>().addReflection(model);
    if (!mounted) return;
    await context.read<StudentReflectionsProvider>().loadForStudent(userId);
  }

  Future<void> _addStudentSkill(int userId) async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    int proficiency = 3;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: _dialogRadius),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: const Text('Add Academic Skill'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Skill name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: proficiency,
                    decoration: const InputDecoration(
                      labelText: 'Proficiency (1-5)',
                    ),
                    items: List.generate(
                      5,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => proficiency = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (shouldSave != true || !mounted) return;

    if (nameController.text.trim().isEmpty ||
        categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill name and category are required.')),
      );
      return;
    }

    final now = AppHelpers.nowIso();
    final skill = StudentSkillsModel(
      studentId: userId,
      skillName: nameController.text.trim(),
      category: categoryController.text.trim(),
      proficiency: proficiency,
      dateAdded: now,
      createdAt: now,
      updatedAt: now,
    );

    await context.read<StudentSkillsProvider>().addSkill(skill);
    if (!mounted) return;
    await context.read<StudentSkillsProvider>().loadForStudent(userId);
  }

  Future<void> _addEducation(int userId) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditEducationScreen(userId: userId)),
    );

    if (didSave == true && mounted) {
      await context.read<EducationProvider>().loadForUser(userId);
    }
  }

  Future<void> _addAchievement(int userId) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String category = 'Academic';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: _dialogRadius),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: const Text('Add Achievement'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Academic',
                        child: Text('Academic'),
                      ),
                      DropdownMenuItem(
                        value: 'Leadership',
                        child: Text('Leadership'),
                      ),
                      DropdownMenuItem(
                        value: 'Community',
                        child: Text('Community'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => category = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (shouldSave != true || !mounted) return;
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Achievement title and description are required.'),
        ),
      );
      return;
    }

    final now = AppHelpers.nowIso();
    final achievement = StudentAchievementModel(
      studentId: userId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: category,
      dateAchieved: now,
      createdAt: now,
      updatedAt: now,
    );

    await context.read<StudentAchievementsProvider>().addAchievement(
      achievement,
    );
    if (!mounted) return;
    await context.read<StudentAchievementsProvider>().loadForStudent(userId);
  }

  Future<void> _addEssay(int userId) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String category = 'Academic';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: _dialogRadius),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: const Text('Add Essay'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contentController,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: 'Essay body'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Academic',
                        child: Text('Academic'),
                      ),
                      DropdownMenuItem(
                        value: 'Personal',
                        child: Text('Personal'),
                      ),
                      DropdownMenuItem(
                        value: 'Scholarship',
                        child: Text('Scholarship'),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => category = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (shouldSave != true || !mounted) return;
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Essay title and content are required.')),
      );
      return;
    }

    final now = AppHelpers.nowIso();
    final essay = StudentEssayModel(
      studentId: userId,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      category: category,
      createdAt: now,
      updatedAt: now,
    );

    await context.read<StudentEssaysProvider>().addEssay(essay);
    if (!mounted) return;
    await context.read<StudentEssaysProvider>().loadForStudent(userId);
  }

  Future<void> _deleteEssay(int userId, StudentEssayModel essay) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: _dialogRadius),
        title: const Text('Delete essay?'),
        content: Text('This will remove "${essay.title}" from your portfolio.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context.read<StudentEssaysProvider>().deleteEssay(
      essay,
    );
    if (!mounted) return;

    if (!success) {
      final error = context.read<StudentEssaysProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to delete essay.')),
      );
      return;
    }

    await context.read<StudentEssaysProvider>().loadForStudent(userId);
  }

  Future<void> _deleteAchievement(
    int userId,
    StudentAchievementModel achievement,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: _dialogRadius),
        title: const Text('Delete achievement?'),
        content: Text(
          'This will remove "${achievement.title}" from your portfolio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final success = await context
        .read<StudentAchievementsProvider>()
        .deleteAchievement(achievement);
    if (!mounted) return;

    if (!success) {
      final error = context.read<StudentAchievementsProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to delete achievement.')),
      );
      return;
    }

    await context.read<StudentAchievementsProvider>().loadForStudent(userId);
  }

  Future<void> _addExperience(int userId) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditExperienceScreen(userId: userId),
      ),
    );

    if (didSave == true && mounted) {
      await context.read<ExperienceProvider>().loadForUser(userId);
    }
  }

  Future<void> _exportAcademicPdf(int userId) async {
    // Open ResumeExportScreen to let user choose format
    final didExport = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ResumeExportScreen()));

    if (didExport == true && mounted) {
      // Optionally refresh data or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Export completed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user?.id == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to manage your academic portfolio.'),
        ),
      );
    }

    final userId = user!.id!;

    return PremiumAppBackground(
      animation: bokehController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Resume & Portfolio'),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: themeProvider.themeMode == ThemeMode.dark
                      ? const Icon(Icons.light_mode_outlined)
                      : const Icon(Icons.dark_mode_outlined),
                  tooltip: 'Toggle theme',
                  onPressed: () => themeProvider.toggleDarkMode(),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child:
                  Consumer6<
                    CertificationProvider,
                    EducationProvider,
                    ExperienceProvider,
                    StudentAchievementsProvider,
                    StudentReflectionsProvider,
                    StudentSkillsProvider
                  >(
                    builder:
                        (
                          context,
                          certs,
                          edu,
                          exp,
                          achievements,
                          refs,
                          skills,
                          _,
                        ) {
                          final essays = context.watch<StudentEssaysProvider>();
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: () => _exportAcademicPdf(userId),
                                    icon: const Icon(
                                      Icons.picture_as_pdf_outlined,
                                    ),
                                    label: const Text('Export PDF'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StudentPortfolioSections(
                                  controller: _tabController,
                                  reflectionsCount: refs.reflections.length,
                                  skillsCount: skills.skills.length,
                                  educationCount: edu.education.length,
                                  experienceCount: exp.experience.length,
                                  essaysCount: essays.essays.length,
                                  achievementsCount:
                                      achievements.achievements.length,
                                  certificationsCount:
                                      certs.certifications.length,
                                ),
                              ],
                            ),
                          );
                        },
                  ),
            ),
            Consumer<EducationProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: GwaTrackerWidget(education: provider.education),
                );
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Consumer<StudentReflectionsProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.reflections.isEmpty) {
                        return const _EmptyTabState(
                          message:
                              'No reflections yet. Tap + to add your first entry.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        children: provider.reflections
                            .map(
                              (r) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.menu_book_outlined),
                                  title: Text(r.title),
                                  subtitle: Text(
                                    r.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(r.mood),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                  Consumer<StudentSkillsProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.skills.isEmpty) {
                        return const _EmptyTabState(
                          message: 'No tracked skills yet. Tap + to add one.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        children: provider.skills
                            .map(
                              (s) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.auto_graph_outlined,
                                  ),
                                  title: Text(s.skillName),
                                  subtitle: Text(s.category),
                                  trailing: Text('${s.proficiency}/5'),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                  Consumer<EducationProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.education.isEmpty) {
                        return const _EmptyTabState(
                          message:
                              'No education entries yet. Tap + to add your school history.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        children: provider.education
                            .map(
                              (e) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.school_outlined),
                                  title: Text(
                                    '${e.degree} in ${e.fieldOfStudy}',
                                  ),
                                  subtitle: Text(e.institution),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                  Consumer<ExperienceProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.experience.isEmpty) {
                        return const _EmptyTabState(
                          message:
                              'No work experience entries yet. Tap + to add your latest role.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        children: provider.experience
                            .map(
                              (e) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.work_outline),
                                  title: Text(e.jobTitle),
                                  subtitle: Text(e.company),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                  Consumer<StudentEssaysProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.essays.isEmpty) {
                        return const _EmptyTabState(
                          message: 'No essays recorded yet. Tap + to add one.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        children: provider.essays
                            .map(
                              (essay) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.article_outlined),
                                  title: Text(essay.title),
                                  subtitle: Text(
                                    '${essay.category} • ${essay.content}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete essay',
                                    onPressed: () =>
                                        _deleteEssay(userId, essay),
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                  Consumer<StudentAchievementsProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.achievements.isEmpty) {
                        return const _EmptyTabState(
                          message:
                              'No achievements recorded yet. Tap + to add one.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        children: provider.achievements
                            .map(
                              (a) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.emoji_events_outlined,
                                  ),
                                  title: Text(a.title),
                                  subtitle: Text(
                                    '${a.category} • ${a.description}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: 'Delete achievement',
                                    onPressed: () =>
                                        _deleteAchievement(userId, a),
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                  Consumer<CertificationProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.certifications.isEmpty) {
                        return const _EmptyTabState(
                          message: 'No certifications yet. Tap + to add one.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
                        children: provider.certifications
                            .map(
                              (c) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.workspace_premium_outlined,
                                  ),
                                  title: Text(c.name),
                                  subtitle: Text(c.issuingOrganization),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'resume_primary_fab',
          onPressed: () {
            switch (_tabController.index) {
              case 0:
                _addReflection(userId);
                break;
              case 1:
                _addStudentSkill(userId);
                break;
              case 2:
                _addEducation(userId);
                break;
              case 3:
                _addExperience(userId);
                break;
              case 4:
                _addEssay(userId);
                break;
              case 5:
                _addAchievement(userId);
                break;
              case 6:
                _openAddCertification(userId);
                break;
              default:
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Add flow for this section will be expanded next.',
                    ),
                  ),
                );
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Entry'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final String message;

  const _EmptyTabState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(padding: const EdgeInsets.all(24), child: Text(message)),
    );
  }
}
