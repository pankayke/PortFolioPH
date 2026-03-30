import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/mixins/animation_mixins.dart';
import 'package:portfolioph/core/mixins/screen_mixins.dart';
import 'package:portfolioph/core/utils/helpers.dart';
import 'package:portfolioph/data/models/skills_model.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/skills_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';
import 'package:portfolioph/presentation/widgets/theme_toggle_button.dart';

// Helper function to get proficiency label
String _getProficiencyLabel(int level) {
  switch (level) {
    case 1:
      return 'Poor';
    case 2:
      return 'Basic';
    case 3:
      return 'Intermediate';
    case 4:
      return 'Advanced';
    case 5:
      return 'Highly Skilled';
    default:
      return 'Unknown';
  }
}

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen>
    with TickerProviderStateMixin, BokehAnimationMixin, UserAwareScreenMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeBokehAnimation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    disposeBokehAnimation();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadDataForUserWithId((userId) {
      context.read<SkillsProvider>().loadForUser(userId);
    });
  }

  Future<void> _showAddSkillDialog(int userId) async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    double proficiency = 3;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Skill'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Skill name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category (e.g. Mobile, Backend)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proficiency: ${proficiency.toInt()}/5',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            _getProficiencyLabel(proficiency.toInt()),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: proficiency,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _getProficiencyLabel(proficiency.toInt()),
                      onChanged: (value) {
                        setStateDialog(() => proficiency = value);
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

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Skill name is required.')));
      return;
    }

    final now = AppHelpers.nowIso();
    final model = SkillsModel(
      userId: userId,
      name: nameController.text.trim(),
      category: categoryController.text.trim().isEmpty
          ? 'General'
          : categoryController.text.trim(),
      proficiency: proficiency.toInt(),
      dateAdded: now,
      createdAt: now,
      updatedAt: now,
    );

    await context.read<SkillsProvider>().addSkill(model);
    if (!mounted) return;
    await context.read<SkillsProvider>().loadForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.id;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to manage your skills.')),
      );
    }

    return PremiumAppBackground(
      animation: bokehController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Skills Tracker'),
          actions: const [ThemeToggleButton()],
        ),
        body: Consumer<SkillsProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search skill or category',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.updateSearchQuery('');
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  onChanged: provider.updateSearchQuery,
                ),
                const SizedBox(height: AppConstants.spacingMd),
                // Proficiency Scale Legend
                ExpansionTile(
                  title: const Text('Proficiency Scale'),
                  initiallyExpanded: false,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProficiencyLevelItem(
                            level: 1,
                            label: 'Poor',
                            description: 'Beginner level, first steps',
                          ),
                          _ProficiencyLevelItem(
                            level: 2,
                            label: 'Basic',
                            description: 'Can perform simple tasks',
                          ),
                          _ProficiencyLevelItem(
                            level: 3,
                            label: 'Intermediate',
                            description: 'Competent, handles most scenarios',
                          ),
                          _ProficiencyLevelItem(
                            level: 4,
                            label: 'Advanced',
                            description: 'Expert level, mentors others',
                          ),
                          _ProficiencyLevelItem(
                            level: 5,
                            label: 'Highly Skilled',
                            description: 'Master level, leading expertise',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (provider.skills.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.spacingMd),
                      child: Text(
                        'No skills yet. Tap the + button to add one.',
                      ),
                    ),
                  )
                else
                  ...provider.skills.map(
                    (skill) => Card(
                      child: ListTile(
                        title: Text(skill.name),
                        subtitle: Text(skill.category),
                        trailing: _SkillLevelBadge(level: skill.proficiency),
                      ),
                    ),
                  ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'fab_skills',
          onPressed: () => _showAddSkillDialog(userId),
          tooltip: 'Add Skill',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _SkillLevelBadge extends StatelessWidget {
  final int level;

  const _SkillLevelBadge({required this.level});

  Color _getColorForLevel(BuildContext context) {
    switch (level) {
      case 1:
        return Colors.red.withValues(alpha: 0.12);
      case 2:
        return Colors.orange.withValues(alpha: 0.12);
      case 3:
        return Colors.amber.withValues(alpha: 0.12);
      case 4:
        return Colors.lightGreen.withValues(alpha: 0.12);
      case 5:
        return Colors.green.withValues(alpha: 0.12);
      default:
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _getColorForLevel(context),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$level/5',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            _getProficiencyLabel(level),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ProficiencyLevelItem extends StatelessWidget {
  final int level;
  final String label;
  final String description;

  const _ProficiencyLevelItem({
    required this.level,
    required this.label,
    required this.description,
  });

  Color _getColorForLevel() {
    switch (level) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColorForLevel().withValues(alpha: 0.2),
              border: Border.all(color: _getColorForLevel(), width: 2),
            ),
            child: Center(
              child: Text(
                '$level',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getColorForLevel(),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
