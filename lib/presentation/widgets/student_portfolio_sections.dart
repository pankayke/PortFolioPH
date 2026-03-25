import 'package:flutter/material.dart';

class StudentPortfolioSections extends StatelessWidget {
  final TabController controller;
  final int reflectionsCount;
  final int skillsCount;
  final int educationCount;
  final int experienceCount;
  final int essaysCount;
  final int achievementsCount;
  final int certificationsCount;

  const StudentPortfolioSections({
    super.key,
    required this.controller,
    required this.reflectionsCount,
    required this.skillsCount,
    required this.educationCount,
    required this.experienceCount,
    required this.essaysCount,
    required this.achievementsCount,
    required this.certificationsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: controller,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Reflections'),
            Tab(text: 'Skills'),
            Tab(text: 'Education'),
            Tab(text: 'Experience'),
            Tab(text: 'Essays'),
            Tab(text: 'Achievements'),
            Tab(text: 'Certificates'),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _CounterChip(label: 'Reflections', value: reflectionsCount),
              _CounterChip(label: 'Skills', value: skillsCount),
              _CounterChip(label: 'Education', value: educationCount),
              _CounterChip(label: 'Experience', value: experienceCount),
              _CounterChip(label: 'Essays', value: essaysCount),
              _CounterChip(label: 'Achievements', value: achievementsCount),
              _CounterChip(label: 'Certificates', value: certificationsCount),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterChip extends StatelessWidget {
  final String label;
  final int value;

  const _CounterChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      label: Text('$label: $value'),
    );
  }
}
