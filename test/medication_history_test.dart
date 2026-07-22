import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_track/domain/entities/adherence_stats.dart';
import 'package:rehab_track/domain/entities/history_period.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/widgets/medication/status_chip.dart';

Widget _wrapWithL10n(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('HistoryPeriod', () {
    test('last7Days returns a date 7 days ago', () {
      final from = HistoryPeriod.last7Days.from!;
      final expected = DateTime.now().subtract(const Duration(days: 7));
      expect(from.year, expected.year);
      expect(from.month, expected.month);
      expect(from.day, expected.day);
    });

    test('last30Days returns a date 30 days ago', () {
      final from = HistoryPeriod.last30Days.from!;
      final expected = DateTime.now().subtract(const Duration(days: 30));
      expect(from.year, expected.year);
      expect(from.month, expected.month);
      expect(from.day, expected.day);
    });

    test('allTime returns null', () {
      expect(HistoryPeriod.allTime.from, isNull);
    });
  });

  group('AdherenceStats.fromLogs', () {
    test('computes stats correctly', () {
      final now = DateTime.now();
      final logs = [
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'taken',
          createdAt: now,
        ),
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'taken',
          createdAt: now,
        ),
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'missed',
          createdAt: now,
        ),
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'skipped',
          createdAt: now,
        ),
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'pending',
          createdAt: now,
        ),
      ];

      final stats = AdherenceStats.fromLogs(logs);

      expect(stats.taken, 2);
      expect(stats.missed, 1);
      expect(stats.skipped, 1);
      expect(stats.pending, 1);
      expect(stats.total, 5);
      // completed = 2 + 1 + 1 = 4, percentage = 2/4 * 100 = 50
      expect(stats.percentage, 50.0);
    });

    test('returns empty stats for empty list', () {
      final stats = AdherenceStats.fromLogs([]);
      expect(stats.total, 0);
      expect(stats.percentage, 0.0);
    });

    test('returns zero percentage when all are pending', () {
      final now = DateTime.now();
      final logs = [
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'pending',
          createdAt: now,
        ),
      ];

      final stats = AdherenceStats.fromLogs(logs);
      expect(stats.percentage, 0.0);
    });

    test('returns 100% when all taken', () {
      final now = DateTime.now();
      final logs = [
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'taken',
          createdAt: now,
        ),
        MedicationLog(
          medicationScheduleId: 1,
          scheduledTime: now,
          status: 'taken',
          createdAt: now,
        ),
      ];

      final stats = AdherenceStats.fromLogs(logs);
      expect(stats.percentage, 100.0);
    });
  });

  group('AdherenceStats.empty', () {
    test('has zero values', () {
      expect(AdherenceStats.empty.taken, 0);
      expect(AdherenceStats.empty.missed, 0);
      expect(AdherenceStats.empty.skipped, 0);
      expect(AdherenceStats.empty.pending, 0);
      expect(AdherenceStats.empty.total, 0);
      expect(AdherenceStats.empty.percentage, 0.0);
    });
  });

  group('StatusChip', () {
    testWidgets('renders taken status with green color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(const StatusChip(status: 'taken')),
      );

      expect(find.text('Taken'), findsOneWidget);
    });

    testWidgets('renders missed status', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(const StatusChip(status: 'missed')),
      );

      expect(find.text('Missed'), findsOneWidget);
    });

    testWidgets('renders skipped status', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(const StatusChip(status: 'skipped')),
      );

      expect(find.text('Skipped'), findsOneWidget);
    });

    testWidgets('renders pending as default', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(const StatusChip(status: 'unknown')),
      );

      expect(find.text('Pending'), findsOneWidget);
    });
  });
}
