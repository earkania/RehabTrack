import 'dart:math' as math;

/// A self-contained Y-axis scale for the measurement line chart.
///
/// The chart bounds ([minY]/[maxY]) always fall on clean tick boundaries that
/// belong to the generated [ticks] sequence, so the visible axis shows one
/// consistent set of human-friendly labels instead of arbitrary padded
/// boundaries. [interval] is the constant spacing between consecutive ticks
/// and [decimals] is the number of decimal places tick labels should show.
class MeasurementChartAxis {
  const MeasurementChartAxis({
    required this.minY,
    required this.maxY,
    required this.interval,
    required this.ticks,
    required this.decimals,
  });

  final double minY;
  final double maxY;
  final double interval;
  final List<double> ticks;
  final int decimals;

  /// Formats an axis value without floating-point artifacts such as
  /// `139.999999` or `36.499999`.
  String format(double value) => value.toStringAsFixed(decimals);
}

/// Small padding so data that sits exactly on a tick boundary (e.g. a maximum
/// recorded exactly at 140) does not touch the chart edges.
const double _paddingFraction = 0.05;

const int _defaultPreferredTickCount = 5;

/// Computes the Y-axis scale for a set of measurement values.
///
/// The visible range is aligned outward to the clean [1, 2, 5, 10, 20, 50,
/// 100, ...] tick interval selected for the data, keeping approximately
/// [preferredTickCount] labels while never clipping the lowest or highest
/// value. Degenerate inputs (a single value, or a constant series) are
/// expanded into a sensible non-zero range around that value.
MeasurementChartAxis computeMeasurementChartAxis({
  required List<double> values,
  int preferredTickCount = _defaultPreferredTickCount,
}) {
  var min = values.reduce(math.min);
  var max = values.reduce(math.max);

  if (max == min) {
    // Give a single/constant value a useful range around it. A zero value
    // gets a symmetric -10..10 room so ticks stay meaningful.
    final magnitude = math.max(max.abs(), 20.0);
    final span = _niceCeilNumber(magnitude * 0.5);
    min = max - span;
    max = max + span;
  }

  final range = max - min;
  final interval = _niceCeilNumber(range / preferredTickCount);
  final decimals = _decimalsForInterval(interval);
  final pad = range * _paddingFraction;

  final niceMin = _alignDown(min - pad, interval, decimals);
  final niceMax = _alignUp(max + pad, interval, decimals);

  final tickStart = (niceMin / interval).round();
  final tickEnd = (niceMax / interval).round();
  final ticks = <double>[
    for (var i = tickStart; i <= tickEnd; i++) _clean(i * interval, decimals),
  ];

  return MeasurementChartAxis(
    minY: ticks.first,
    maxY: ticks.last,
    interval: interval,
    ticks: ticks,
    decimals: decimals,
  );
}

/// Rounds [value] down to the nearest multiple of [interval] and removes any
/// floating-point noise.
double _alignDown(double value, double interval, int decimals) =>
    _clean((value / interval).floor() * interval, decimals);

/// Rounds [value] up to the nearest multiple of [interval] and removes any
/// floating-point noise.
double _alignUp(double value, double interval, int decimals) =>
    _clean((value / interval).ceil() * interval, decimals);

/// Returns the smallest ["nice"] number (1, 2, 5, or a power-of-ten multiple
/// of them) that is greater than or equal to [value]. Rounding upward like
/// this caps the visible tick count at roughly [preferredTickCount].
double _niceCeilNumber(double value) {
  if (value <= 0) {
    return 1.0;
  }
  final exponent = (math.log(value) / math.ln10).floor();
  final fraction = value / math.pow(10, exponent).toDouble();

  final double niceFraction;
  if (fraction <= 1) {
    niceFraction = 1;
  } else if (fraction <= 2) {
    niceFraction = 2;
  } else if (fraction <= 5) {
    niceFraction = 5;
  } else {
    niceFraction = 10;
  }
  return niceFraction * math.pow(10, exponent).toDouble();
}

/// Number of decimal places needed to represent every tick produced by
/// [interval] exactly (0 for 1/2/5/10/20/..., 1 for 0.5/0.2/0.1, ...).
int _decimalsForInterval(double interval) {
  for (var d = 0; d <= 6; d++) {
    final scaled = interval * math.pow(10, d).toDouble();
    if ((scaled - scaled.round()).abs() < 1e-9) {
      return d;
    }
  }
  return 0;
}

/// Rounds [value] to [decimals] decimal places, removing artifacts such as
/// `59.999999`.
double _clean(double value, int decimals) {
  if (decimals == 0) {
    return value.roundToDouble();
  }
  final factor = math.pow(10, decimals).toDouble();
  return (value * factor).roundToDouble() / factor;
}