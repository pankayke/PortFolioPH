// lib/presentation/screens/resume/resume_export_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// ResumeExportScreen – Export portfolio/resume in multiple formats
//
// Allows users to choose and export:
//   • Academic Portfolio PDF (comprehensive, CHED/DOST aligned)
//   • Professional Resume (1-page or multi-page)
//   • Download to device
//
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/providers/certification_provider.dart';
import 'package:portfolioph/presentation/providers/education_provider.dart';
import 'package:portfolioph/presentation/providers/experience_provider.dart';
import 'package:portfolioph/presentation/providers/student_achievements_provider.dart';
import 'package:portfolioph/presentation/providers/student_essays_provider.dart';
import 'package:portfolioph/presentation/providers/student_reflections_provider.dart';
import 'package:portfolioph/presentation/providers/student_skills_provider.dart';
import 'package:portfolioph/services/resume_pdf_generator.dart';
import 'package:portfolioph/services/student_portfolio_pdf_generator.dart';

enum ExportFormat { academicPortfolio, resumeBrief, resumeDetailed }

class ResumeExportScreen extends StatefulWidget {
  const ResumeExportScreen({super.key});

  @override
  State<ResumeExportScreen> createState() => _ResumeExportScreenState();
}

class _ResumeExportScreenState extends State<ResumeExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.academicPortfolio;
  bool _isExporting = false;

  Future<void> _exportDocument() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final auth = context.read<AuthProvider>();
      final student = auth.currentUser;
      if (student == null) {
        throw Exception('User not authenticated');
      }

      // ── Gather all data ──────────────────────────────────────────────────
      final skills = context.read<StudentSkillsProvider>().skills;
      final experience = context.read<ExperienceProvider>().experience;
      final education = context.read<EducationProvider>().education;
      final certifications = context
          .read<CertificationProvider>()
          .certifications;
      final achievements = context
          .read<StudentAchievementsProvider>()
          .achievements;
      final reflections = context
          .read<StudentReflectionsProvider>()
          .reflections;
      final essays = context.read<StudentEssaysProvider>().essays;

      Uint8List bytes;
      String fileName;

      // ── Generate PDF based on selected format ─────────────────────────────
      if (_selectedFormat == ExportFormat.academicPortfolio) {
        final generator = StudentPortfolioPdfGenerator();
        bytes = await generator.generate(
          student: student,
          reflections: reflections,
          skills: skills,
          education: education,
          experience: experience,
          essays: essays,
          achievements: achievements,
          certifications: certifications,
        );
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'academic_portfolio_$timestamp.pdf';
      } else if (_selectedFormat == ExportFormat.resumeBrief) {
        final generator = ResumePdfGenerator();
        bytes = await generator.generate(
          student: student,
          skills: skills,
          experience: experience,
          education: education,
          certifications: certifications,
          layoutType: ResumeLayoutType.brief,
        );
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'resume_brief_$timestamp.pdf';
      } else {
        // Detailed resume
        final generator = ResumePdfGenerator();
        bytes = await generator.generate(
          student: student,
          skills: skills,
          experience: experience,
          education: education,
          certifications: certifications,
          achievements: achievements,
          reflections: reflections,
          layoutType: ResumeLayoutType.detailed,
        );
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = 'resume_detailed_$timestamp.pdf';
      }

      if (!mounted) return;

      // ── Save to device (or show download message for web) ─────────────────
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF generated successfully! Web download will be implemented next. '
              '($fileName - ${(bytes.length / 1024).toStringAsFixed(2)} KB)',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported: ${file.path}'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Close screen after successful export
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Export PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Format Selection ─────────────────────────────────────────────
            Text('Choose Export Format', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Select the PDF type that best fits your purpose.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),

            RadioGroup<ExportFormat>(
              groupValue: _selectedFormat,
              onChanged: (value) {
                if (_isExporting || value == null) return;
                setState(() => _selectedFormat = value);
              },
              child: Column(
                children: [
                  // ── Academic Portfolio ─────────────────────────────────────
                  Card(
                    child: RadioListTile<ExportFormat>(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      title: const Text('Academic Portfolio'),
                      subtitle: const Text(
                        'Comprehensive portfolio with all sections (CHED/DOST aligned). '
                        'Perfect for academic records.',
                      ),
                      value: ExportFormat.academicPortfolio,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Brief Resume ───────────────────────────────────────────
                  Card(
                    child: RadioListTile<ExportFormat>(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      title: const Text('Student Resume (Brief)'),
                      subtitle: const Text(
                        '1-page resume with your key school and project highlights. '
                        'Ideal for internship or entry-level applications.',
                      ),
                      value: ExportFormat.resumeBrief,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Detailed Resume ────────────────────────────────────────
                  Card(
                    child: RadioListTile<ExportFormat>(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      title: const Text('Student Resume (Detailed)'),
                      subtitle: const Text(
                        'Multi-page resume with complete academic and portfolio details.',
                      ),
                      value: ExportFormat.resumeDetailed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Format Details ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Format Details', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  _buildFormatDetails(theme),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Info Note ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '💡 Tip: Update your information first. The PDF will be saved to your Documents folder.',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 92),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isExporting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _isExporting ? null : _exportDocument,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatDetails(ThemeData theme) {
    final details = {
      'Academic Portfolio': [
        '✓ Full student profile',
        '✓ Academic reflections & mood tracking',
        '✓ Skills tracker (by category)',
        '✓ All education records',
        '✓ All work experience',
        '✓ Essays & achievements',
        '✓ Certifications & credentials',
        '✓ CHED/DOST aligned structure',
      ],
      'Resume (Brief)': [
        '✓ Contact information',
        '✓ Student summary',
        '✓ Top skills (max 10)',
        '✓ Latest school/work experiences',
        '✓ Education summary',
        '✓ Latest certifications',
        '✓ 1 page format',
      ],
      'Resume (Detailed)': [
        '✓ Contact information',
        '✓ Student summary',
        '✓ Complete skills list',
        '✓ Full school/work experience',
        '✓ All education records',
        '✓ All certifications',
        '✓ Achievements & reflections',
        '✓ Multi-page format',
      ],
    };

    final currentDetails = _selectedFormat == ExportFormat.academicPortfolio
        ? details['Academic Portfolio']!
        : _selectedFormat == ExportFormat.resumeBrief
        ? details['Resume (Brief)']!
        : details['Resume (Detailed)']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: currentDetails
          .map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(detail, style: theme.textTheme.bodySmall),
            ),
          )
          .toList(),
    );
  }
}
