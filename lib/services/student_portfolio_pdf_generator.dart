// lib/services/student_portfolio_pdf_generator.dart
// ─────────────────────────────────────────────────────────────────────────────
// StudentPortfolioPdfGenerator – Academic Portfolio PDF Export
//
// Generates a comprehensive academic portfolio PDF for students, including:
//   • Student profile (name, email, contact)
//   • Academic reflections, skills, education, experience
//   • Achievements, certifications, and essays
//   • CHED/DOST aligned formatting for Philippine academic standards
//
// Usage:
//   final generator = StudentPortfolioPdfGenerator();
//   final bytes = await generator.generate(
//     student: userModel,
//     reflections: userReflections,
//     // ... other params
//   );
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/models/student_essay_model.dart';
import 'package:portfolioph/data/models/student_achievement_model.dart';
import 'package:portfolioph/data/models/student_reflections_model.dart';
import 'package:portfolioph/data/models/student_skills_model.dart';
import 'package:portfolioph/data/models/user_model.dart';

class StudentPortfolioPdfGenerator {
  static const String _generatedFooter =
      'Generated for academic documentation purposes (CHED/DOST aligned structure).';

  static String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Present';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM yyyy', 'en_US').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<Uint8List> generate({
    required UserModel student,
    required List<StudentReflectionModel> reflections,
    required List<StudentSkillsModel> skills,
    required List<EducationModel> education,
    required List<ExperienceModel> experience,
    required List<StudentEssayModel> essays,
    required List<StudentAchievementModel> achievements,
    required List<CertificationModel> certifications,
    String schoolName = 'LNU',
    String program = 'BSIT',
  }) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => [
          // ── Title Section ────────────────────────────────────────────────────
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'STUDENT ACADEMIC PORTFOLIO',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '$schoolName • $program',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 2),
                pw.Divider(),
              ],
            ),
          ),
          pw.SizedBox(height: 8),

          // ── Student Profile Header ────────────────────────────────────────
          _buildProfileSection(student),
          pw.SizedBox(height: 10),

          // ── Academic Reflections ──────────────────────────────────────────
          if (reflections.isNotEmpty) _buildReflectionsSection(reflections),

          // ── Skills Tracker ────────────────────────────────────────────────
          if (skills.isNotEmpty) _buildSkillsSection(skills),

          // ── Education ─────────────────────────────────────────────────────
          if (education.isNotEmpty) _buildEducationSection(education),

          // ── Work Experience ──────────────────────────────────────────────
          if (experience.isNotEmpty) _buildExperienceSection(experience),

          // ── Essays ────────────────────────────────────────────────────────
          if (essays.isNotEmpty) _buildEssaysSection(essays),

          // ── Achievements ─────────────────────────────────────────────────
          if (achievements.isNotEmpty) _buildAchievementsSection(achievements),

          // ── Certifications ───────────────────────────────────────────────
          if (certifications.isNotEmpty)
            _buildCertificationsSection(certifications),

          // ── Footer ───────────────────────────────────────────────────────
          pw.SizedBox(height: 12),
          pw.Divider(),
          pw.Text(
            _generatedFooter,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return document.save();
  }

  // ── Profile Section ──────────────────────────────────────────────────────
  pw.Widget _buildProfileSection(UserModel student) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('STUDENT PROFILE'),
        _profileKeyValue(
          'Full Name',
          student.fullName?.trim().isNotEmpty == true
              ? student.fullName!
              : student.username,
        ),
        _profileKeyValue('Email', student.email),
        if (student.phoneNumber?.isNotEmpty == true)
          _profileKeyValue('Mobile', student.phoneNumber!),
        if (student.location?.isNotEmpty == true)
          _profileKeyValue('Location', student.location!),
        if (student.bio?.isNotEmpty == true)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'About',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.Text(student.bio!, style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 8),
            ],
          ),
      ],
    );
  }

  // ── Reflections Section ──────────────────────────────────────────────────
  pw.Widget _buildReflectionsSection(List<StudentReflectionModel> reflections) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('ACADEMIC REFLECTIONS'),
        ...reflections.map((item) => _buildReflectionItem(item)),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildReflectionItem(StudentReflectionModel item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: item.title,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: ' • Mood: ${item.mood}'),
              ],
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
          if (item.content.isNotEmpty == true)
            pw.Text(item.content, style: const pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  // ── Skills Section ───────────────────────────────────────────────────────
  pw.Widget _buildSkillsSection(List<StudentSkillsModel> skills) {
    final grouped = <String, List<StudentSkillsModel>>{};
    for (final skill in skills) {
      final category = skill.category;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(skill);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('SKILLS TRACKER'),
        ...grouped.entries.map(
          (entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
                pw.Text(
                  entry.value
                      .map((s) => '${s.skillName} (${s.proficiency}/5)')
                      .join(', '),
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // ── Education Section ────────────────────────────────────────────────────
  pw.Widget _buildEducationSection(List<EducationModel> education) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('EDUCATION'),
        ...education.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '${item.degree} in ${item.fieldOfStudy}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: ' • ${item.institution}'),
                    ],
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                if (item.grade != null)
                  pw.Text(
                    'GPA: ${item.grade}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                pw.Text(
                  _formatDate(item.startDate),
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor(0.5, 0.5, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // ── Experience Section ───────────────────────────────────────────────────
  pw.Widget _buildExperienceSection(List<ExperienceModel> experience) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('WORK EXPERIENCE'),
        ...experience.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: item.jobTitle,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: ' • ${item.company}'),
                    ],
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                if (item.location?.isNotEmpty == true)
                  pw.Text(
                    item.location!,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                if (item.description?.isNotEmpty == true)
                  pw.Text(
                    item.description!,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // ── Essays Section ───────────────────────────────────────────────────────
  pw.Widget _buildEssaysSection(List<StudentEssayModel> essays) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('ESSAYS'),
        ...essays.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: item.title,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: ' • ${item.category}'),
                ],
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // ── Achievements Section ─────────────────────────────────────────────────
  pw.Widget _buildAchievementsSection(
    List<StudentAchievementModel> achievements,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('ACHIEVEMENTS'),
        ...achievements.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: item.title,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      if (item.category.isNotEmpty == true)
                        pw.TextSpan(text: ' • ${item.category}'),
                    ],
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                if (item.description.isNotEmpty == true)
                  pw.Text(
                    item.description,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // ── Certifications Section ───────────────────────────────────────────────
  pw.Widget _buildCertificationsSection(
    List<CertificationModel> certifications,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionHeader('CERTIFICATIONS'),
        ...certifications.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: item.name,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.TextSpan(text: ' • ${item.issuingOrganization}'),
                    ],
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.Text(
                  'Issued: ${_formatDate(item.issueDate)}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor(0.5, 0.5, 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper: Section header with underline ─────────────────────────────
  pw.Widget _sectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 1.5)),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  // ── Helper: Key-value pair for profile ─────────────────────────────────
  pw.Widget _profileKeyValue(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$key: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
            pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
