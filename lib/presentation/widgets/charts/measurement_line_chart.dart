import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/measurement_chart.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/utils/measurement_chart_axis.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';

class MeasurementLineChart extends StatefulWidget {
  final List<MeasurementChartSeries> series;
  final String typeKey;

  static const Key tooltipKey = Key('measurement-chart-tooltip');

  const MeasurementLineChart({
    super.key,
    required this.series,
    required this.typeKey,
  });

  @override
  State<MeasurementLineChart> createState() => _MeasurementLineChartState();
}

class _MeasurementLineChartState extends State<MeasurementLineChart> {
  static const double _tooltipMargin = 8;
  static const double _tooltipRadius = 8;
  static const EdgeInsets _tooltipPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 8);
  static const double _maxContentWidth = 200;
  static const double _itemsGap = 4;

  final GlobalKey _leafKey = GlobalKey();

  OverlayEntry? _tooltipEntry;
  List<LineBarSpot>? _tooltipSpots;
  Size _tooltipSize = Size.zero;
  Offset _tooltipPosition = Offset.zero;
  ThemeData? _tooltipTheme;
  AppLocalizations? _tooltipL10n;

  @override
  void didUpdateWidget(MeasurementLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.series, widget.series) ||
        oldWidget.typeKey != widget.typeKey) {
      _hideTooltip();
    }
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _hideTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
    _tooltipSpots = null;
  }

  void _handleTouch(FlTouchEvent event, LineTouchResponse? response) {
    if (!mounted) {
      return;
    }
    final spots = response?.lineBarSpots;
    if (!event.isInterestedForInteractions || spots == null || spots.isEmpty) {
      _hideTooltip();
      return;
    }
    _showTooltip(spots);
  }

  void _showTooltip(List<LineBarSpot> rawSpots) {
    final spots = List<LineBarSpot>.of(rawSpots)
      ..sort((a, b) => b.y.compareTo(a.y));

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    _tooltipTheme = theme;
    _tooltipL10n = l10n;
    final spans = _tooltipItemSpans(spots, theme, l10n);
    if (spans.isEmpty) {
      _hideTooltip();
      return;
    }

    final anchor = _anchorOffset(spots.first);
    final size = _measureTooltip(spans);
    final position = _clampedPosition(anchor, size);

    _tooltipSpots = spots;
    _tooltipSize = size;
    _tooltipPosition = position;

    final entry = _tooltipEntry;
    if (entry == null) {
      final overlay = Overlay.of(context);
      final newEntry = OverlayEntry(builder: _buildOverlay);
      _tooltipEntry = newEntry;
      overlay.insert(newEntry);
    } else {
      entry.markNeedsBuild();
    }
  }

  Offset _anchorOffset(LineBarSpot topSpot) {
    final box = _leafKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      return Offset.zero;
    }

    final maxPoints = widget.series.fold<int>(
      0,
      (max, s) => s.points.length > max ? s.points.length : max,
    );
    if (maxPoints <= 1) {
      return Offset.zero;
    }

    final values = widget.series
        .expand((s) => s.points.map((p) => p.numericValue))
        .toList();
    if (values.isEmpty) {
      return Offset.zero;
    }
    final axis = computeMeasurementChartAxis(values: values);

    final deltaX = (maxPoints - 1).toDouble();
    final deltaY = axis.maxY - axis.minY;

    final x = deltaX == 0 ? 0.0 : topSpot.x / deltaX * box.size.width;
    final y = deltaY == 0
        ? box.size.height
        : box.size.height -
            (topSpot.y - axis.minY) / deltaY * box.size.height;

    return box.localToGlobal(Offset(x, y));
  }

  Size _measureTooltip(List<TextSpan> spans) {
    if (spans.isEmpty) {
      return Size(_tooltipPadding.horizontal, _tooltipPadding.vertical);
    }
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    var width = 0.0;
    var height = 0.0;
    for (var i = 0; i < spans.length; i++) {
      final tp = TextPainter(
        text: spans[i],
        textDirection: direction,
        textScaler: textScaler,
      )..layout(maxWidth: _maxContentWidth);
      width = math.max(width, tp.width);
      height += tp.height;
    }
    height += (spans.length - 1) * _itemsGap;

    return Size(
      width + _tooltipPadding.horizontal,
      height + _tooltipPadding.vertical,
    );
  }

  Offset _clampedPosition(Offset anchor, Size size) {
    final screen = MediaQuery.of(context).size;
    final maxLeft = math.max(0.0, screen.width - size.width);
    final maxTop = math.max(0.0, screen.height - size.height);

    var left = anchor.dx - size.width / 2;
    var top = anchor.dy - size.height - _tooltipMargin;

    left = left.clamp(0.0, maxLeft);
    if (top < 0) {
      top = anchor.dy + _tooltipMargin;
    }
    top = top.clamp(0.0, maxTop);

    return Offset(left, top);
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final spots = _tooltipSpots;
    if (spots == null) {
      return const SizedBox.shrink();
    }
    final theme = _tooltipTheme;
    final l10n = _tooltipL10n;
    if (theme == null || l10n == null) {
      return const SizedBox.shrink();
    }
    final spans = _tooltipItemSpans(spots, theme, l10n);

    return Positioned(
      left: _tooltipPosition.dx,
      top: _tooltipPosition.dy,
      child: IgnorePointer(
        child: Semantics(
          label: spans.map((s) => s.toPlainText()).join('\n'),
          container: true,
          excludeSemantics: true,
          child: Material(
            key: MeasurementLineChart.tooltipKey,
            color: theme.colorScheme.surfaceContainerHighest,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_tooltipRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: _tooltipSize.width,
              height: _tooltipSize.height,
              child: Padding(
                padding: _tooltipPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < spans.length; i++) ...[
                      if (i > 0) const SizedBox(height: _itemsGap),
                      Text.rich(spans[i]),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _tooltipItemSpans(
    List<LineBarSpot> spots,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    // Component rows follow each measurement type's canonical component
    // order, which is the order of [widget.series] (blood pressure:
    // systolic, diastolic, pulse; other types: field displayOrder). The
    // touched spots arrive in Y-value order and must not drive row order.
    final componentRank = <String, int>{
      for (var i = 0; i < widget.series.length; i++) widget.series[i].fieldKey: i,
    };

    final readings = <int, _TooltipReading>{};
    final readingOrder = <int>[];

    for (final spot in spots) {
      final s = spot.barIndex >= 0 && spot.barIndex < widget.series.length
          ? widget.series[spot.barIndex]
          : widget.series.first;
      final pointIndex = spot.x.toInt();
      if (pointIndex < 0 || pointIndex >= s.points.length) {
        continue;
      }
      final point = s.points[pointIndex];
      final reading = readings.putIfAbsent(point.recordId, () {
        readingOrder.add(point.recordId);
        return _TooltipReading(measuredAt: point.measuredAt);
      });
      reading.components.add(
        _TooltipComponent(
          label: s.label,
          value: point.numericValue,
          unit: point.unit,
          status: point.effectiveStatus,
          irregularHeartbeatDetected: point.irregularHeartbeatDetected,
          fieldKey: s.fieldKey,
          sequence: reading.components.length,
        ),
      );
    }

    // Sort by stable component identity (series field key), with the arrival
    // sequence as a deterministic tie-breaker for repeated keys.
    for (final reading in readings.values) {
      reading.components.sort((a, b) {
        final ra = componentRank[a.fieldKey] ?? componentRank.length;
        final rb = componentRank[b.fieldKey] ?? componentRank.length;
        if (ra != rb) return ra.compareTo(rb);
        return a.sequence.compareTo(b.sequence);
      });
    }

    return [
      for (final key in readingOrder)
        _buildReadingSpan(readings[key]!, theme, l10n),
    ];
  }

  /// Renders one measurement reading as a single block: one date/time header
  /// followed by its component entries. With a single component the header
  /// stays directly above the value; with multiple components the groups are
  /// separated so the timestamp is not repeated for every component.
  TextSpan _buildReadingSpan(
    _TooltipReading reading,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final colorScheme = theme.colorScheme;
    final bodyStyle = theme.textTheme.bodySmall;
    final components = reading.components;

    final children = <InlineSpan>[
      TextSpan(
        text: _formatFullDate(reading.measuredAt),
        style: bodyStyle?.copyWith(fontWeight: FontWeight.w600),
      ),
    ];

    final afterHeader = components.length > 1 ? '\n\n' : '\n';
    for (var i = 0; i < components.length; i++) {
      final component = components[i];
      children.add(TextSpan(text: i == 0 ? afterHeader : '\n\n'));
      children.add(
        TextSpan(
          children: [
            TextSpan(
              text: '${component.label}: ',
              style: bodyStyle?.copyWith(fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: '${_formatValue(component.value)} ${component.unit}',
            ),
          ],
        ),
      );

      final statusText = _statusText(component.status, l10n);
      if (statusText.isNotEmpty) {
        children.add(
          TextSpan(
            text: '\n$statusText',
            style: bodyStyle?.copyWith(
              color: _statusColor(component.status, colorScheme),
            ),
          ),
        );
      }
      if (component.irregularHeartbeatDetected) {
        children.add(
          TextSpan(
            text: '\n${l10n.irregularHeartbeat}',
            style: bodyStyle?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }
    }

    return TextSpan(style: bodyStyle, children: children);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.series.isEmpty ||
        widget.series.every((s) => s.isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final allPoints = widget.series.expand((s) => s.points).toList();
    if (allPoints.isEmpty) return const SizedBox.shrink();

    final allValues = allPoints.map((p) => p.numericValue).toList();
    final axis = computeMeasurementChartAxis(values: allValues);

    final seriesColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];

    final lineBarsData = <LineChartBarData>[];
    for (var i = 0; i < widget.series.length; i++) {
      final s = widget.series[i];
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
              final statusColor = _statusColor(point.effectiveStatus, colorScheme);

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
            minY: axis.minY,
            maxY: axis.maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: axis.interval,
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
                  interval: axis.interval,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      axis.format(value),
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
                getTooltipColor: (_) => colorScheme.surfaceContainerHighest,
                tooltipRoundedRadius: _tooltipRadius,
                tooltipMargin: _tooltipMargin,
                tooltipPadding: _tooltipPadding,
                getTooltipItems: (touchedSpots) =>
                    List<LineTooltipItem?>.filled(touchedSpots.length, null),
              ),
              handleBuiltInTouches: true,
              touchCallback: _handleTouch,
            ),
          ),
          chartRendererKey: _leafKey,
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

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  String _formatDateAxis(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final formatter = AppDateFormatter.of(context);
    if (diff.inDays < 1) {
      return formatter.formatTime(date);
    }
    if (diff.inDays < 30) {
      return formatter.formatMonthDay(date);
    }
    return formatter.formatMonthYear(date);
  }

  String _formatFullDate(DateTime date) {
    return AppDateFormatter.of(context).formatShortDateTime(date);
  }

  double _calculateDateInterval(int pointCount) {
    if (pointCount <= 7) return 1;
    if (pointCount <= 30) return (pointCount / 7).ceilToDouble();
    return (pointCount / 6).ceilToDouble();
  }
}

class _TooltipReading {
  _TooltipReading({required this.measuredAt});

  final DateTime measuredAt;
  final List<_TooltipComponent> components = [];
}

class _TooltipComponent {
  const _TooltipComponent({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.irregularHeartbeatDetected,
    required this.fieldKey,
    required this.sequence,
  });

  final String label;
  final double value;
  final String unit;
  final ReadingStatus status;
  final bool irregularHeartbeatDetected;

  /// Stable component identity used for canonical row ordering.
  final String fieldKey;

  /// Arrival order, used only as a deterministic tie-breaker.
  final int sequence;
}
