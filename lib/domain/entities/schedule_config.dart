import 'dart:convert';

sealed class ScheduleConfig {
  const ScheduleConfig();

  List<String> get times;

  Map<String, dynamic> toJson();

  String toJsonString() => jsonEncode(toJson());

  factory ScheduleConfig.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'daily' => DailySchedule.fromJson(json),
      'interval_days' => IntervalDaysSchedule.fromJson(json),
      _ => throw ArgumentError('Unknown schedule type: ${json["type"]}'),
    };
  }

  factory ScheduleConfig.fromJsonString(String jsonString) {
    return ScheduleConfig.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  static List<String> normalizeTimes(List<String> rawTimes) {
    final trimmed = rawTimes
        .map((t) => t.trim())
        .where((t) => RegExp(r'^\d{2}:\d{2}$').hasMatch(t))
        .toSet()
        .toList()
      ..sort();
    return trimmed;
  }

  static void validateTimes(List<String> times) {
    if (times.isEmpty) {
      throw ArgumentError('At least one time is required');
    }
    final normalized = normalizeTimes(times);
    if (normalized.length != times.length) {
      throw ArgumentError('Duplicate or invalid times');
    }
  }
}

class DailySchedule extends ScheduleConfig {
  @override
  final List<String> times;

  const DailySchedule({required this.times});

  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    final times = (json['times'] as List<dynamic>).cast<String>();
    return DailySchedule(times: List<String>.from(times));
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'daily', 'times': times};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySchedule &&
          runtimeType == other.runtimeType &&
          _listEquals(times, other.times);

  @override
  int get hashCode => Object.hashAll(times);

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class IntervalDaysSchedule extends ScheduleConfig {
  final int intervalDays;
  @override
  final List<String> times;

  const IntervalDaysSchedule({required this.intervalDays, required this.times});

  factory IntervalDaysSchedule.fromJson(Map<String, dynamic> json) {
    final interval = json['interval'] as int;
    final times = (json['times'] as List<dynamic>).cast<String>();
    return IntervalDaysSchedule(
      intervalDays: interval,
      times: List<String>.from(times),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'interval_days',
        'interval': intervalDays,
        'times': times,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalDaysSchedule &&
          runtimeType == other.runtimeType &&
          intervalDays == other.intervalDays &&
          _listEquals(times, other.times);

  @override
  int get hashCode => Object.hash(intervalDays, Object.hashAll(times));

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
