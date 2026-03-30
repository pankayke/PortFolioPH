// lib/services/resume_pdf_generator.dart
// ─────────────────────────────────────────────────────────────────────────────
// ResumePdfGenerator – Professional CV/Resume in Philippine-standard format.
//
// Supports:
//   • Brief Resume (1 page, essential info only)
//   • Detailed Resume (multi-page with all sections)
//   • Philippine CV format (CHED/DOST aligned, date formatting)
//
// Sections:
//   1. Header: Full name, contact, location
//   2. Professional Summary/Objective
//   3. Skills (categorized)
//   4. Work Experience (reverse chronological with descriptions)
//   5. Education (degrees, institutions, GPA)
//   6. Certifications
//   7. Achievements (optional, detailed view)
//   8. Academic Reflections (optional, detailed view)
//
// Usage:
//   final generator = ResumePdfGenerator();
//   final bytes = await generator.generate(
//     student: user,
//     skills: userSkills,
//     experience: userExperience,
//     // ... other params
//     layoutType: ResumeLayoutType.brief, // or detailed
//   );
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:portfolioph/data/models/certification_model.dart';
import 'package:portfolioph/data/models/education_model.dart';
import 'package:portfolioph/data/models/experience_model.dart';
import 'package:portfolioph/data/models/student_achievement_model.dart';
import 'package:portfolioph/data/models/student_reflections_model.dart';
import 'package:portfolioph/data/models/student_skills_model.dart';
import 'package:portfolioph/data/models/user_model.dart';

enum ResumeLayoutType { brief, detailed }

class ResumePdfGenerator {
  // ── Formatting helper: Convert ISO-8601 to readable date (Philippine format) ─
  static String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Present';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM yyyy', 'en_US').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  // ── Formatting helper: Format date range ──────────────────────────────────────
  static String _formatDateRange(
    String? startDate,
    String? endDate, {
    bool isCurrent = false,
  }) {
    final start = _formatDate(startDate);
    if (isCurrent || endDate == null || endDate.isEmpty) {
      return '$start – Present';
    }
    final end = _formatDate(endDate);
    return '$start – $end';
  }

  Future<Uint8List> generate({
    required UserModel student,
    required List<StudentSkillsModel> skills,
    required List<ExperienceModel> experience,
    required List<EducationModel> education,
    required List<CertificationModel> certifications,
    List<StudentAchievementModel> achievements = const [],
    List<StudentReflectionModel> reflections = const [],
    String schoolName = 'LNU',
    String program = 'BSIT',
    ResumeLayoutType layoutType = ResumeLayoutType.detailed,
  }) async {
    final document = pw.Document();

    // ── Build resume content based on layout type ──────────────────────────────
    if (layoutType == ResumeLayoutType.brief) {
      _buildBriefResume(
        document: document,
        student: student,
        skills: skills,
        experience: experience,
        education: education,
        certifications: certifications,
        schoolName: schoolName,
        program: program,
      );
    } else {
      _buildDetailedResume(
        document: document,
        student: student,
        skills: skills,
        experience: experience,
        education: education,
        certifications: certifications,
        achievements: achievements,
        reflections: reflections,
        schoolName: schoolName,
        program: program,
      );
    }

    return document.save();
  }

  // ── Build 1-page brief resume ──────────────────────────────────────────────
  void _buildBriefResume({
    required pw.Document document,
    required UserModel student,
    required List<StudentSkillsModel> skills,
    required List<ExperienceModel> experience,
    required List<EducationModel> education,
    required List<CertificationModel> certifications,
    required String schoolName,
    required String program,
  }) {
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (_) => [
          // ── Header with contact info ─────────────────────────────────────────
          _buildHeader(student),
          pw.SizedBox(height: 8),

          // ── Professional Summary ─────────────────────────────────────────────
          if (student.bio?.isNotEmpty == true)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('PROFESSIONAL SUMMARY'),
                pw.Text(student.bio!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 4),
              ],
            ),

          // ── Skills (top 10, categorized) ──────────────────────────────────
          if (skills.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('KEY SKILLS'),
                ..._formatSkillsByCategory(skills.take(10).toList()),
                pw.SizedBox(height: 4),
              ],
            ),

          // ── Work Experience (most recent only, up to 3) ─────────────────────
          if (experience.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('WORK EXPERIENCE'),
                ...experience.take(3).map((exp) => _buildExperienceEntry(exp)),
                pw.SizedBox(height: 4),
              ],
            ),

          // ── Education ────────────────────────────────────────────────────────
          if (education.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('EDUCATION'),
                ...education.map((edu) => _buildEducationEntry(edu)),
                pw.SizedBox(height: 4),
              ],
            ),

          // ── Certifications (if any) ──────────────────────────────────────────
          if (certifications.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('CERTIFICATIONS'),
                ...certifications
                    .take(5)
                    .map((cert) => _buildCertificationEntry(cert)),
              ],
            ),
        ],
      ),
    );
  }

  // ── Build multi-page detailed resume ───────────────────────────────────────
  void _buildDetailedResume({
    required pw.Document document,
    required UserModel student,
    required List<StudentSkillsModel> skills,
    required List<ExperienceModel> experience,
    required List<EducationModel> education,
    required List<CertificationModel> certifications,
    required List<StudentAchievementModel> achievements,
    required List<StudentReflectionModel> reflections,
    required String schoolName,
    required String program,
  }) {
    // ── Page 1: Contact, Summary, Skills, Experience, Education ──────────────
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        maxPages: 2,
        build: (_) => [
          _buildHeader(student),
          pw.SizedBox(height: 8),
          if (student.bio?.isNotEmpty == true)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('PROFESSIONAL SUMMARY'),
                pw.Text(student.bio!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 6),
              ],
            ),
          if (skills.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('SKILLS'),
                ..._formatSkillsByCategory(skills),
                pw.SizedBox(height: 6),
              ],
            ),
          if (experience.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('WORK EXPERIENCE'),
                ...experience.map((exp) => _buildExperienceEntryDetailed(exp)),
                pw.SizedBox(height: 6),
              ],
            ),
          if (education.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('EDUCATION'),
                ...education.map((edu) => _buildEducationEntry(edu)),
                pw.SizedBox(height: 6),
              ],
            ),
        ],
      ),
    );

    // ── Page 2 (if needed): Certifications, Achievements, Reflections ────────
    if (certifications.isNotEmpty ||
        achievements.isNotEmpty ||
        reflections.isNotEmpty) {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (_) => [
            _buildHeader(student, compact: true),
            pw.SizedBox(height: 8),
            if (certifications.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionTitle('CERTIFICATIONS'),
                  ...certifications.map(
                    (cert) => _buildCertificationEntryDetailed(cert),
                  ),
                  pw.SizedBox(height: 6),
                ],
              ),
            if (achievements.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionTitle('ACHIEVEMENTS'),
                  ...achievements
                      .take(8)
                      .map((ach) => _buildAchievementEntry(ach)),
                  pw.SizedBox(height: 6),
                ],
              ),
            if (reflections.isNotEmpty)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionTitle('ACADEMIC REFLECTIONS'),
                  ...reflections
                      .take(6)
                      .map((ref) => _buildReflectionEntry(ref)),
                ],
              ),
          ],
        ),
      );
    }
  }

  // ── Header with full name and contact info ────────────────────────────────
  pw.Widget _buildHeader(UserModel student, {bool compact = false}) {
    final name = student.fullName?.trim().isNotEmpty == true
        ? student.fullName!
        : student.username;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          name,
          style: pw.TextStyle(
            fontSize: compact ? 16 : 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        // Contact info line
        pw.Text(
          [
            student.email,
            if (student.phoneNumber?.isNotEmpty == true) student.phoneNumber,
            if (student.location?.isNotEmpty == true) student.location,
          ].where((e) => e != null && e.isNotEmpty).join(' • '),
          style: const pw.TextStyle(fontSize: 9),
        ),
        if (student.websiteUrl?.isNotEmpty == true)
          pw.Text(student.websiteUrl!, style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  // ── Section title formatting ──────────────────────────────────────────────
  pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 1)),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 3),
      ],
    );
  }

  // ── Experience entry (brief) ──────────────────────────────────────────────
  pw.Widget _buildExperienceEntry(ExperienceModel exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: exp.jobTitle,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: ' • ${exp.company}'),
              ],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Text(
            _formatDateRange(
              exp.startDate,
              exp.endDate,
              isCurrent: exp.isCurrent,
            ),
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColor(0.5, 0.5, 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Experience entry (detailed with description) ──────────────────────────
  pw.Widget _buildExperienceEntryDetailed(ExperienceModel exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: exp.jobTitle,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: ' • ${exp.company}'),
              ],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Text(
            _formatDateRange(
              exp.startDate,
              exp.endDate,
              isCurrent: exp.isCurrent,
            ),
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColor(0.5, 0.5, 0.5),
            ),
          ),
          if (exp.location?.isNotEmpty == true)
            pw.Text(
              exp.location!,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColor(0.5, 0.5, 0.5),
              ),
            ),
          if (exp.description?.isNotEmpty == true)
            pw.Text(exp.description!, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 2),
        ],
      ),
    );
  }

  // ── Education entry ──────────────────────────────────────────────────────
  pw.Widget _buildEducationEntry(EducationModel edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: edu.degree,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(
                  text:
                      ' in ${edu.fieldOfStudy} • '
                      '${edu.institution}',
                ),
              ],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Row(
            children: [
              pw.Text(
                _formatDateRange(edu.startDate, edu.endDate),
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColor(0.5, 0.5, 0.5),
                ),
              ),
              if (edu.grade != null)
                pw.Text(
                  ' • GPA: ${edu.grade}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor(0.6, 0.6, 0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Certification entry (brief) ───────────────────────────────────────────
  pw.Widget _buildCertificationEntry(CertificationModel cert) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: cert.name,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: ' • ${cert.issuingOrganization}'),
          ],
          style: const pw.TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  // ── Certification entry (detailed) ───────────────────────────────────────
  pw.Widget _buildCertificationEntryDetailed(CertificationModel cert) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: cert.name,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: ' • ${cert.issuingOrganization}'),
              ],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Text(
            _formatDate(cert.issueDate),
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColor(0.5, 0.5, 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Achievement entry ────────────────────────────────────────────────────
  pw.Widget _buildAchievementEntry(StudentAchievementModel ach) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: ach.title,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                if (ach.category.isNotEmpty == true)
                  pw.TextSpan(text: ' • ${ach.category}'),
              ],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          if (ach.description.isNotEmpty == true)
            pw.Text(ach.description, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  // ── Reflection entry ─────────────────────────────────────────────────────
  pw.Widget _buildReflectionEntry(StudentReflectionModel ref) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: ref.title,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: ' (${ref.mood})'),
              ],
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          if (ref.content.isNotEmpty == true)
            pw.Text(
              ref.content.length > 100
                  ? '${ref.content.substring(0, 100)}...'
                  : ref.content,
              style: const pw.TextStyle(fontSize: 9),
            ),
        ],
      ),
    );
  }

  // ── Format skills by category ────────────────────────────────────────────
  List<pw.Widget> _formatSkillsByCategory(List<StudentSkillsModel> skills) {
    final grouped = <String, List<StudentSkillsModel>>{};

    for (final skill in skills) {
      final category = skill.category;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(skill);
    }

    return grouped.entries.map((entry) {
      final skillNames = entry.value.map((s) => s.skillName).toList();
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '${entry.key}: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: skillNames.join(', ')),
            ],
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      );
    }).toList();
  }
}
