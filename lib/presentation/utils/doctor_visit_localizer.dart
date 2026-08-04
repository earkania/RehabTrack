import 'package:flutter/material.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

/// Resolves localized labels for doctor visit types and statuses. The stable
/// enum names (`planned`, `onDemand`, `scheduled`, ...) are never persisted as
/// localized text; this is the single place where the UI maps them to strings.
class DoctorVisitLocalizer {
  DoctorVisitLocalizer._();

  static String typeLabel(AppLocalizations l10n, DoctorVisitType type) {
    return switch (type) {
      DoctorVisitType.planned => l10n.plannedVisit,
      DoctorVisitType.onDemand => l10n.onDemandVisit,
    };
  }

  static String statusLabel(AppLocalizations l10n, DoctorVisitStatus status) {
    return switch (status) {
      DoctorVisitStatus.scheduled => l10n.scheduled,
      DoctorVisitStatus.completed => l10n.completed,
      DoctorVisitStatus.cancelled => l10n.cancelled,
      DoctorVisitStatus.missed => l10n.missed,
    };
  }

  /// Formatted reminder offset ("1 day before", "2 hours before", ...).
  static String reminderOffsetLabel(
    AppLocalizations l10n,
    int minutes,
  ) {
    if (minutes >= 10080) return l10n.oneWeekBefore;
    if (minutes >= 2880) return l10n.twoDaysBefore;
    if (minutes >= 1440) return l10n.oneDayBefore;
    if (minutes >= 120) return l10n.twoHoursBefore;
    if (minutes >= 60) return l10n.oneHourBefore;
    if (minutes >= 30) return l10n.thirtyMinutesBefore;
    return l10n.fifteenMinutesBefore;
  }

  static IconData statusIcon(DoctorVisitStatus status) {
    return switch (status) {
      DoctorVisitStatus.scheduled => Icons.event_outlined,
      DoctorVisitStatus.completed => Icons.check_circle_outline,
      DoctorVisitStatus.cancelled => Icons.cancel_outlined,
      DoctorVisitStatus.missed => Icons.error_outline,
    };
  }
}
