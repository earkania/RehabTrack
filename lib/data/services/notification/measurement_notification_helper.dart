import 'dart:convert';

import 'package:rehab_track/domain/entities/schedule_config.dart';

class MeasurementNotificationHelper {
  MeasurementNotificationHelper._();

  static const int _namespaceOffset = 100000;

  static List<int> computeNotificationIds({
    required int scheduleId,
    required ScheduleConfig config,
  }) {
    return List.generate(
      config.times.length,
      (i) => _namespaceOffset + scheduleId + i,
    );
  }

  static int baseNotificationId(int scheduleId) {
    return _namespaceOffset + scheduleId;
  }

  static MeasurementNotificationPayload? parsePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      if (json['type'] != 'measurement') return null;

      final scheduleId = json['scheduleId'] as int?;
      final measurementTypeId = json['measurementTypeId'] as int?;
      final profileId = json['profileId'] as int?;
      final scheduledTime = json['scheduledTime'] as String?;

      if (scheduleId == null || measurementTypeId == null) return null;

      return MeasurementNotificationPayload(
        scheduleId: scheduleId,
        measurementTypeId: measurementTypeId,
        profileId: profileId ?? 1,
        scheduledTime: scheduledTime,
      );
    } catch (_) {
      return null;
    }
  }

  static String buildPayload({
    required int scheduleId,
    required int measurementTypeId,
    required int profileId,
    String? scheduledTime,
  }) {
    return jsonEncode({
      'type': 'measurement',
      'scheduleId': scheduleId,
      'measurementTypeId': measurementTypeId,
      'profileId': profileId,
      'scheduledTime': scheduledTime,
    });
  }
}

class MeasurementNotificationPayload {
  const MeasurementNotificationPayload({
    required this.scheduleId,
    required this.measurementTypeId,
    required this.profileId,
    this.scheduledTime,
  });

  final int scheduleId;
  final int measurementTypeId;
  final int profileId;
  final String? scheduledTime;

  bool get isValid => scheduleId > 0 && measurementTypeId > 0;
}
