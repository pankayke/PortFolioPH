// lib/core/utils/date_formatter.dart
// ─────────────────────────────────────────────────────────────────────────────
// Date / time formatting utilities – Sprint 2.
//
// Wraps [intl.DateFormat] behind stable named functions so format strings are
// never scattered across the codebase.
//
// Rule: Pure static functions — no state, no Flutter dependencies.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:intl/intl.dart';

abstract final class AppDateFormatter {
  // ── Patterns ──────────────────────────────────────────────────────────────────
  static const String _patternDisplay = 'MMM d, yyyy'; // Mar 5, 2026
  static const String _patternShort = 'MM/dd/yyyy'; // 03/05/2026
  static const String _patternMonthYear = 'MMM yyyy'; // Mar 2026
  static const String _patternFull = 'MMMM d, yyyy'; // March 5, 2026
  static const String _patternTime = 'h:mm a'; // 2:08 AM
  static const String _patternDateTime =
      'MMM d, yyyy h:mm a'; // Mar 5, 2026 2:08 AM

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Formats an ISO-8601 string as "Mar 5, 2026". Returns "—" on null/error.
  static String formatDate(String? isoDate) =>
      _format(isoDate, _patternDisplay);

  /// Formats as "03/05/2026". Returns "—" on null/error.
  static String formatShort(String? isoDate) => _format(isoDate, _patternShort);

  /// Formats as "Mar 2026". Useful for education/experience periods.
  static String formatMonthYear(String? isoDate) =>
      _format(isoDate, _patternMonthYear);

  /// Formats as "March 5, 2026".
  static String formatFull(String? isoDate) => _format(isoDate, _patternFull);

  /// Formats only the time portion as "2:08 AM".
  static String formatTime(String? isoDate) => _format(isoDate, _patternTime);

  /// Formats as "Mar 5, 2026 2:08 AM".
  static String formatDateTime(String? isoDate) =>
      _format(isoDate, _patternDateTime);

  /// Returns a "Start – End (or Present)" range string.
  ///
  /// Example: "Jan 2023 – Mar 2026" or "Jan 2023 – Present"
  static String formatDateRange(String? startIso, String? endIso) {
    final start = formatMonthYear(startIso);
    if (start == '—') return '—';
    final end = endIso == null || endIso.isEmpty
        ? 'Present'
        : formatMonthYear(endIso);
    return '$start – $end';
  }

  /// Returns a human-readable relative time (e.g. "2 days ago", "just now").
  static String formatRelative(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(dt);

      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (_) {
      return '—';
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────────
  static String _format(String? isoDate, String pattern) {
    if (isoDate == null || isoDate.isEmpty) return '—';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat(pattern).format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
