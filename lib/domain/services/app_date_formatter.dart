import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Centralized, locale-aware date and time formatting for RehabTrack.
///
/// The application-selected locale — not the device locale — is authoritative
/// for every user-visible date. All presentation code must format dates through
/// this service instead of hand-building [DateFormat] patterns or concatenating
/// day/month/year manually.
///
/// Role guide (single source of truth):
/// * [formatShortDate] — SHORT DATE: fixed canonical numeric `dd.MM.yyyy`
///   (schedules, list rows, compact fields, filters), identical for every
///   supported language.
/// * [formatMediumDate] — MEDIUM DATE: month-name dates (edit screens, detail
///   screens, prominent record metadata).
/// * [formatLongDate] — LONG DATE: full month-name dates (prominent headers).
/// * [formatTime] — TIME: 24-hour local time (app-wide policy, see
///   docs/design/design-notes.md).
/// * [formatShortDateTime] — compact date + time (record list entries).
/// * [formatMediumDateTime] — prominent date + time (detail timestamps).
/// * [formatMonthDay] — chart axis labels ("4 Aug" / "4 აგვ").
/// * [formatMonthYear] — chart axis labels for long spans ("Aug 26").
class AppDateFormatter {
  AppDateFormatter(Locale locale) : _localeCode = locale.languageCode;

  /// Resolves the formatter for the currently active application locale.
  factory AppDateFormatter.of(BuildContext context) {
    return AppDateFormatter(Localizations.localeOf(context));
  }

  final String _localeCode;

  /// SHORT DATE — canonical fixed `dd.MM.yyyy` (e.g. `01.08.2026`).
  ///
  /// Zero-padded day/month for every supported language. This is an intentional
  /// RehabTrack UI convention, not a locale default — do not revert to
  /// locale-dependent numeric ordering. See docs/design/design-notes.md.
  String formatShortDate(DateTime value) {
    return DateFormat('dd.MM.yyyy', _localeCode).format(value);
  }

  /// MEDIUM DATE — locale-aware textual month names, e.g. `Aug 12, 2026` (en),
  /// `12 აგვ. 2026` (ka).
  String formatMediumDate(DateTime value) {
    return DateFormat.yMMMd(_localeCode).format(value);
  }

  /// LONG DATE — e.g. `August 12, 2026` (en), `12 აგვისტო, 2026` (ka).
  String formatLongDate(DateTime value) {
    return DateFormat.yMMMMd(_localeCode).format(value);
  }

  /// TIME (24-hour) — e.g. `22:57`.
  String formatTime(DateTime value) {
    return DateFormat.Hm(_localeCode).format(value);
  }

  /// SHORT DATE + TIME — record-list timestamps.
  String formatShortDateTime(DateTime value) {
    return '${formatShortDate(value)} ${formatTime(value)}';
  }

  /// MEDIUM DATE + TIME — prominent detail timestamps.
  String formatMediumDateTime(DateTime value) {
    return '${formatMediumDate(value)}, ${formatTime(value)}';
  }

  /// Localized weekday name (used by relative-date fallbacks such as
  /// "Monday" for the current week).
  String formatWeekday(DateTime value) {
    return DateFormat.EEEE(_localeCode).format(value);
  }

  /// Chart axis: day followed by the localized abbreviated month.
  String formatMonthDay(DateTime value) {
    return DateFormat('d MMM', _localeCode).format(value);
  }

  /// Chart axis: localized abbreviated month followed by the two-digit year.
  String formatMonthYear(DateTime value) {
    return DateFormat('MMM yy', _localeCode).format(value);
  }
}