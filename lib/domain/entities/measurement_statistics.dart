class MeasurementStatistics {
  final int count;
  final double? latest;
  final double? minimum;
  final double? maximum;
  final double? average;
  final double? first;
  final double? change;
  final double? percentageChange;

  const MeasurementStatistics({
    required this.count,
    this.latest,
    this.minimum,
    this.maximum,
    this.average,
    this.first,
    this.change,
    this.percentageChange,
  });

  static const empty = MeasurementStatistics(count: 0);

  static MeasurementStatistics compute(List<double> values) {
    if (values.isEmpty) return empty;
    if (values.length == 1) {
      final v = values.first;
      return MeasurementStatistics(
        count: 1,
        latest: v,
        minimum: v,
        maximum: v,
        average: v,
        first: v,
      );
    }

    final sorted = List<double>.from(values);
    sorted.sort();

    final first = values.first;
    final latest = values.last;
    final min = sorted.first;
    final max = sorted.last;
    final sum = values.reduce((a, b) => a + b);
    final avg = sum / values.length;
    final change = latest - first;
    final pctChange = first != 0 ? (change / first) * 100 : null;

    return MeasurementStatistics(
      count: values.length,
      latest: latest,
      minimum: min,
      maximum: max,
      average: avg,
      first: first,
      change: change,
      percentageChange: pctChange,
    );
  }
}
