// lib/core/constants/app_constants.dart
// ─────────────────────────────────────────────────────────────────────────────
// Central repository for every literal value used across the app.
// RULE: Zero magic numbers/strings outside this file.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:portfolioph/core/styling/design_tokens.dart';

abstract final class AppConstants {
  // ── App metadata ────────────────────────────────────────────────────────────
  static const String appName = 'PortFolioPH';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Build your portfolio, own your future.';

  // ── Database ────────────────────────────────────────────────────────────────
  static const String dbName = 'portfolioph.db';
  static const int dbVersion = 5;

  // ── SharedPreferences keys ──────────────────────────────────────────────────
  static const String prefUserId = 'userId';
  static const String prefThemeMode = 'themeMode';
  static const String prefOnboardingDone = 'onboardingDone';

  // ── Local development admin seed account ──────────────────────────────────
  static const String localAdminUsername = 'portfolioph_admin';
  static const String localAdminEmail = 'admin@portfolioph.local';
  static const String localAdminPassword = 'Admin12345';
  static const String localAdminFullName = 'PortFolioPH Admin';

  // ── Roles ─────────────────────────────────────────────────────────────────
  static const String roleStudent = 'student';
  static const String roleUser = 'user';
  static const String roleTeacher = 'teacher';
  static const String roleCoordinator = 'coordinator';
  static const String roleAdmin = 'admin';
  static const String roleRecruiter = 'recruiter';
  static const String roleSeeker = 'job_seeker';

  // ── Local development academic accounts (teacher/coordinator) ────────────
  static const String localTeacherUsername = 'portfolioph_teacher';
  static const String localTeacherEmail = 'teacher@portfolioph.local';
  static const String localTeacherPassword = 'Teacher12345';
  static const String localTeacherFullName = 'PortFolioPH Teacher';

  static const String localCoordinatorUsername = 'portfolioph_coordinator';
  static const String localCoordinatorEmail = 'coordinator@portfolioph.local';
  static const String localCoordinatorPassword = 'Coordinator12345';
  static const String localCoordinatorFullName = 'PortFolioPH Coordinator';

  // ── Brand colours (raw ARGB – used by AppTheme) ─────────────────────────────
  static const Color primaryColor = DesignTokens.accentBlue;
  static const Color accentColor = DesignTokens.accentPurple;
  static const Color errorColor = DesignTokens.accentPhilippineRed;
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color surfaceColor = DesignTokens.lightBase;
  static const Color onPrimaryColor = Color(0xFFFFFFFF);
  static const Color textPrimary = DesignTokens.darkBaseA;
  static const Color textSecondary = Color(0xFF64748B);

  // ── Typography scale (sp) ────────────────────────────────────────────────────
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;
  static const double fontSizeDisplay = 32.0;

  // ── Spacing / padding (dp) ───────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Border radii ─────────────────────────────────────────────────────────────
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 12.0; // Additional: Card content
  static const double radiusXxl = 14.0; // Additional: Dialog content
  static const double radiusHero = 20.0; // Additional: Hero/premium sections
  static const double radiusGlass = 24.0; // Additional: Glass containers
  static const double radiusFull = 999.0;

  // ── Elevation ────────────────────────────────────────────────────────────────
  static const double elevationLow = 2.0;
  static const double elevationMid = 4.0;
  static const double elevationHigh = 8.0;

  // ── Animation durations ──────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 3);

  // ── Bottom navigation ────────────────────────────────────────────────────────
  static const int navIndexHome = 0;
  static const int navIndexPortfolio = 1;
  static const int navIndexResume = 2;
  static const int navIndexSkills = 3;
  static const int navIndexProfile = 4;

  // ── Theme Background Colors (Dark Mode) ──────────────────────────────────────
  static const Color darkBg1 = DesignTokens.darkBaseA;
  static const Color darkBg2 = DesignTokens.darkSurface;
  static const Color darkBg3 = DesignTokens.darkBaseC;

  // ── Theme Background Colors (Light Mode) ─────────────────────────────────────
  static const Color lightBg1 = DesignTokens.lightBase;
  static const Color lightBg2 = DesignTokens.lightSurfaceSoft;
  static const Color lightBg3 = DesignTokens.lightSurfaceTint;

  // ── Glassmorphism Colors ─────────────────────────────────────────────────────
  static const Color glassBorderDark = Color(
    0xFFFFFFFF,
  ); // White border for dark mode
  static const Color glassBorderLight = Color(
    0xFF000000,
  ); // Black border for light mode

  // ── Image/asset paths ────────────────────────────────────────────────────────
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderAvatarPath =
      'assets/images/avatar_placeholder.png';

  // ── Validation limits ────────────────────────────────────────────────────────
  static const int maxUsernameLength = 50;
  static const int minPasswordLength = 8;
  static const int maxBioLength = 500;
  static const int maxProjectDescriptionLength = 1000;
  static const int maxProjectImages = 5;
  static const int maxProjectImageBytes = 500000;
  static const int maxCertificateImageBytes = 500000;
}
