import 'dart:convert';

enum ReminderType { medication, measurement, doctorVisit }

class ReminderPayload {
  ReminderPayload({
    required this.type,
    required this.profileId,
    required this.scheduleId,
    required this.occurrenceTime,
    this.medicationId,
    this.measurementTypeId,
    this.medicationLogId,
    this.measurementReminderLogId,
    this.measurementRecordId,
    this.visitId,
    this.snoozeSourceOccurrence,
    this.notificationId,
    this.version = _currentVersion,
  });

  static const _currentVersion = 2;

  final int version;
  final ReminderType type;
  final int profileId;
  final int scheduleId;
  final String occurrenceTime;
  final int? medicationId;
  final int? measurementTypeId;
  final int? medicationLogId;
  final int? measurementReminderLogId;
  final int? measurementRecordId;
  final int? visitId;
  final String? snoozeSourceOccurrence;
  final int? notificationId;

  DateTime? get occurrenceDateTime => DateTime.tryParse(occurrenceTime);

  ReminderPayload copyWith({int? notificationId}) {
    return ReminderPayload(
      type: type,
      profileId: profileId,
      scheduleId: scheduleId,
      occurrenceTime: occurrenceTime,
      medicationId: medicationId,
      measurementTypeId: measurementTypeId,
      medicationLogId: medicationLogId,
      measurementReminderLogId: measurementReminderLogId,
      measurementRecordId: measurementRecordId,
      visitId: visitId,
      snoozeSourceOccurrence: snoozeSourceOccurrence,
      notificationId: notificationId ?? this.notificationId,
      version: version,
    );
  }

  Map<String, dynamic> toJson() => {
        'v': version,
        't': type.name,
        'p': profileId,
        's': scheduleId,
        'o': occurrenceTime,
        if (medicationId != null) 'm': medicationId,
        if (measurementTypeId != null) 'mt': measurementTypeId,
        if (medicationLogId != null) 'ml': medicationLogId,
        if (measurementReminderLogId != null) 'rl': measurementReminderLogId,
        if (measurementRecordId != null) 'rr': measurementRecordId,
        if (visitId != null) 'vi': visitId,
        if (snoozeSourceOccurrence != null) 'so': snoozeSourceOccurrence,
        if (notificationId != null) 'ni': notificationId,
      };

  String toJsonString() => jsonEncode(toJson());

  static ReminderPayload? parse(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static ReminderPayload? fromJson(Map<String, dynamic> json) {
    final typeStr = json['t'] as String?;
    if (typeStr == null) return null;

    final type = ReminderType.values.where((e) => e.name == typeStr).firstOrNull;
    if (type == null) return null;

    final profileId = json['p'] as int?;
    final scheduleId = json['s'] as int?;
    final occurrenceTime = json['o'] as String?;
    if (profileId == null || scheduleId == null || occurrenceTime == null) {
      return null;
    }

    return ReminderPayload(
      version: (json['v'] as int?) ?? 2,
      type: type,
      profileId: profileId,
      scheduleId: scheduleId,
      occurrenceTime: occurrenceTime,
      medicationId: json['m'] as int?,
      measurementTypeId: json['mt'] as int?,
      medicationLogId: json['ml'] as int?,
      measurementReminderLogId: json['rl'] as int?,
      measurementRecordId: json['rr'] as int?,
      visitId: json['vi'] as int?,
      snoozeSourceOccurrence: json['so'] as String?,
      notificationId: json['ni'] as int?,
    );
  }
}
