import 'package:rehab_track/domain/entities/medication.dart';

class AdherenceStats {
  final int taken;
  final int missed;
  final int skipped;
  final int pending;
  final int total;
  final double percentage;

  const AdherenceStats({
    required this.taken,
    required this.missed,
    required this.skipped,
    required this.pending,
    required this.total,
    required this.percentage,
  });

  factory AdherenceStats.fromLogs(List<MedicationLog> logs) {
    final taken = logs.where((l) => l.status == 'taken').length;
    final missed = logs.where((l) => l.status == 'missed').length;
    final skipped = logs.where((l) => l.status == 'skipped').length;
    final pending = logs.where((l) => l.status == 'pending').length;
    final total = logs.length;
    final completed = taken + missed + skipped;
    final percentage = completed > 0 ? (taken / completed) * 100 : 0.0;

    return AdherenceStats(
      taken: taken,
      missed: missed,
      skipped: skipped,
      pending: pending,
      total: total,
      percentage: percentage,
    );
  }

  static const empty = AdherenceStats(
    taken: 0,
    missed: 0,
    skipped: 0,
    pending: 0,
    total: 0,
    percentage: 0.0,
  );
}
