import 'dart:convert';

sealed class ScheduleConfig {
  const ScheduleConfig();

  Map<String, dynamic> toJson();

  String toJsonString() => jsonEncode(toJson());

  factory ScheduleConfig.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'daily' => DailySchedule.fromJson(json),
      'fixed_times' => FixedTimesSchedule.fromJson(json),
      'interval_days' => IntervalDaysSchedule.fromJson(json),
      _ => throw ArgumentError('Unknown schedule type: ${json["type"]}'),
    };
  }

  factory ScheduleConfig.fromJsonString(String jsonString) {
    return ScheduleConfig.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
}

class DailySchedule extends ScheduleConfig {
  final String time;

  const DailySchedule({required this.time});

  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    return DailySchedule(time: json['time'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'daily', 'time': time};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySchedule &&
          runtimeType == other.runtimeType &&
          time == other.time;

  @override
  int get hashCode => time.hashCode;
}

class FixedTimesSchedule extends ScheduleConfig {
  final List<String> times;

  const FixedTimesSchedule({required this.times});

  factory FixedTimesSchedule.fromJson(Map<String, dynamic> json) {
    return FixedTimesSchedule(
      times: (json['times'] as List<dynamic>).cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'fixed_times', 'times': times};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FixedTimesSchedule &&
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
  final int interval;
  final String time;

  const IntervalDaysSchedule({required this.interval, required this.time});

  factory IntervalDaysSchedule.fromJson(Map<String, dynamic> json) {
    return IntervalDaysSchedule(
      interval: json['interval'] as int,
      time: json['time'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'interval_days',
    'interval': interval,
    'time': time,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalDaysSchedule &&
          runtimeType == other.runtimeType &&
          interval == other.interval &&
          time == other.time;

  @override
  int get hashCode => Object.hash(interval, time);
}
