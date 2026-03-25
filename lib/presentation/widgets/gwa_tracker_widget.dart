import 'package:flutter/material.dart';

import 'package:portfolioph/data/models/education_model.dart';

class GwaTrackerWidget extends StatelessWidget {
  final List<EducationModel> education;

  const GwaTrackerWidget({super.key, required this.education});

  @override
  Widget build(BuildContext context) {
    final grades = education
        .map((item) => _parseGrade(item.grade))
        .whereType<double>()
        .toList(growable: false);

    final hasGrades = grades.isNotEmpty;
    final gwa = hasGrades
        ? grades.reduce((value, element) => value + element) / grades.length
        : null;

    final gwaText = gwa == null ? 'N/A' : gwa.toStringAsFixed(2);
    final status = _gwaStatus(gwa);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calculate_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GWA Tracker',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasGrades
                        ? 'Computed from ${grades.length} grade entr${grades.length == 1 ? 'y' : 'ies'}.'
                        : 'Add grades in Education to compute your GWA.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(gwaText, style: Theme.of(context).textTheme.headlineSmall),
                Text(status, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static double? _parseGrade(String? rawGrade) {
    if (rawGrade == null) return null;
    final normalized = rawGrade.trim();
    if (normalized.isEmpty) return null;

    final number = double.tryParse(normalized.replaceAll(',', '.'));
    if (number == null) return null;
    if (number < 1.0 || number > 5.0) return null;
    return number;
  }

  static String _gwaStatus(double? gwa) {
    if (gwa == null) return 'No result yet';
    if (gwa <= 1.5) return 'Excellent standing';
    if (gwa <= 2.0) return 'Very good standing';
    if (gwa <= 2.5) return 'Good standing';
    if (gwa <= 3.0) return 'Satisfactory';
    return 'Needs improvement';
  }
}
