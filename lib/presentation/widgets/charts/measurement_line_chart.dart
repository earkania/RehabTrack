import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';

class MeasurementLineChart extends StatelessWidget {
  final List<MeasurementChartSeries> series;
  final String typeKey;

  const MeasurementLineChart({
    super.key,
    required this.series,
    required this.typeKey,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty || series.every((s) => s.isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final allPoints = series.expand((s) => s.points).toList();
    if (allPoints.isEmpty) return const SizedBox.shrink();

    final allValues = allPoints.map((p) => p.numericValue).toList();
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;
    final adjustedMinY = (minY - padding).clamp(0.0, double.infinity);
    final adjustedMaxY = maxY + padding;

    final seriesColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];

    final lineBarsData = <LineChartBarData>[];
    for (var i = 0; i < series.length; i++) {
      final s = series[i];
      if (s.isEmpty) continue;

      final spots = <FlSpot>[];
      for (var j = 0; j < s.points.length; j++) {
        spots.add(FlSpot(j.toDouble(), s.points[j].numericValue));
      }

      final isPulse = s.fieldKey == 'pulse';
      final barColor = seriesColors[i % seriesColors.length];

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: barColor,
          barWidth: isPulse ? 1.5 : 2.5,
          isStrokeCapRound: true,
          dashArray: isPulse ? [4, 4] : null,
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              final pointIndex = spot.x.toInt();
              if (pointIndex >= s.points.length) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: barColor,
                  strokeColor: barColor,
                  strokeWidth: 1,
                );
              }
              final point = s.points[pointIndex];
              final statusColor = _statusColor(point.readingStatus, colorScheme);

              if (point.irregularHeartbeatDetected) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: statusColor.withValues(alpha: 0.3),
                  strokeColor: colorScheme.error,
                  strokeWidth: 2,
                );
              }
              return FlDotCirclePainter(
                radius: isPulse ? 3 : 4,
                color: statusColor,
                strokeColor: statusColor,
                strokeWidth: 1,
              );
            },
          ),
        ),
      );
    }

    final uniquePoints = _deduplicatePoints(allPoints);

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 16,
          top: 16,
          bottom: 8,
        ),
        child: LineChart(
          LineChartData(
            minY: adjustedMinY,
            maxY: adjustedMaxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(adjustedMinY, adjustedMaxY),
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      _formatAxisValue(value),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: _calculateDateInterval(uniquePoints.length),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= uniquePoints.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatDateAxis(
                          uniquePoints[index].measuredAt,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: lineBarsData,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    colorScheme.surfaceContainerHighest,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final seriesIndex = spot.barIndex;
                    final s = seriesIndex >= 0 && seriesIndex < series.length
                        ? series[seriesIndex]
                        : series.first;
                    final pointIndex = spot.x.toInt();
                    if (pointIndex < 0 || pointIndex >= s.points.length) {
                      return null;
                    }
                    final point = s.points[pointIndex];
                    final statusText = _statusText(point.readingStatus, l10n);

                    return LineTooltipItem(
                      '',
                      const TextStyle(),
                      children: [
                        TextSpan(
                          text: _formatFullDate(point.measuredAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '\n'),
                        TextSpan(
                          text:
                              '${s.label}: ${_formatValue(point.numericValue)} ${point.unit}',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (statusText.isNotEmpty) ...[
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _statusColor(
                                point.readingStatus,
                                colorScheme,
                              ),
                            ),
                          ),
                        ],
                        if (point.irregularHeartbeatDetected) ...[
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: l10n.irregularHeartbeat,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    );
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(ReadingStatus status, ColorScheme colorScheme) {
    return ReadingStatusColor.forStatus(status, colorScheme);
  }

  String _statusText(ReadingStatus status, AppLocalizations l10n) {
    return switch (status) {
      ReadingStatus.inRange => l10n.withinRange,
      ReadingStatus.belowRange => l10n.belowRange,
      ReadingStatus.aboveRange => l10n.aboveRange,
      ReadingStatus.unknown => '',
    };
  }

  List<MeasurementChartPoint> _deduplicatePoints(
    List<MeasurementChartPoint> allPoints,
  ) {
    final seen = <int>{};
    final result = <MeasurementChartPoint>[];
    for (final p in allPoints) {
      if (!seen.contains(p.recordId)) {
        seen.add(p.recordId);
        result.add(p);
      }
    }
    result.sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    return result;
  }

  String _formatAxisValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _formatDateAxis(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 1) {
      return DateFormat.Hm().format(date);
    }
    if (diff.inDays < 30) {
      return DateFormat('d MMM').format(date);
    }
    return DateFormat('MMM yy').format(date);
  }

  String _formatFullDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  double _calculateInterval(double min, double max) {
    final range = max - min;
    if (range <= 0) return 1;
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    if (range <= 200) return 40;
    return (range / 5).ceilToDouble();
  }

  double _calculateDateInterval(int pointCount) {
    if (pointCount <= 7) return 1;
    if (pointCount <= 30) return (pointCount / 7).ceilToDouble();
    return (pointCount / 6).ceilToDouble();
  }
}
