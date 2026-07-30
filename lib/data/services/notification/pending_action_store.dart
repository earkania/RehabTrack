import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'notification_action_handler.dart';

class PendingActionEntry {
  const PendingActionEntry({
    required this.actionType,
    required this.notificationId,
    required this.actionId,
    this.payload,
    required this.timestamp,
  });

  final NotificationActionType actionType;
  final int notificationId;
  final String actionId;
  final String? payload;
  final int timestamp;

  Map<String, dynamic> toJson() => {
        'actionType': actionType.name,
        'notificationId': notificationId,
        'actionId': actionId,
        'payload': payload,
        'timestamp': timestamp,
      };

  static PendingActionEntry? fromJson(Map<String, dynamic> json) {
    final actionTypeName = json['actionType'] as String?;
    final notificationId = json['notificationId'] as int?;
    final actionId = json['actionId'] as String?;
    final timestamp = json['timestamp'] as int?;
    if (actionTypeName == null ||
        notificationId == null ||
        actionId == null ||
        timestamp == null) {
      return null;
    }
    final actionType = NotificationActionType.values
        .where((t) => t.name == actionTypeName)
        .firstOrNull;
    if (actionType == null) return null;
    return PendingActionEntry(
      actionType: actionType,
      notificationId: notificationId,
      actionId: actionId,
      payload: json['payload'] as String?,
      timestamp: timestamp,
    );
  }

  NotificationActionResponse toResponse() => NotificationActionResponse(
        notificationId: notificationId,
        actionId: actionId,
        actionType: actionType,
        payload: payload,
      );
}

class PendingActionStore {
  static const _filename = 'rehabtrack_pending_actions.json';

  static final PendingActionStore _instance = PendingActionStore._();
  static PendingActionStore get instance => _instance;

  PendingActionStore._();

  File _file(String basePath) => File('$basePath/$_filename');

  String get _basePath => Directory.systemTemp.path;

  Future<void> addPendingAction(PendingActionEntry entry) async {
    try {
      final file = _file(_basePath);
      final existing = await _readAll(file);
      existing.add(entry);
      await _writeAll(file, existing);
      debugPrint('[PendingActionStore] stored action: ${entry.actionType.name} '
          'notif=${entry.notificationId}');
    } catch (e) {
      debugPrint('[PendingActionStore] failed to store action: $e');
    }
  }

  Future<List<PendingActionEntry>> consumeAll() async {
    try {
      final file = _file(_basePath);
      final entries = await _readAll(file);
      if (entries.isNotEmpty) {
        await file.delete();
        debugPrint('[PendingActionStore] consumed ${entries.length} '
            'pending action(s)');
      }
      return entries;
    } catch (e) {
      debugPrint('[PendingActionStore] failed to consume actions: $e');
      return [];
    }
  }

  Future<int> pendingCount() async {
    try {
      final file = _file(_basePath);
      final entries = await _readAll(file);
      return entries.length;
    } catch (_) {
      return 0;
    }
  }

  Future<List<PendingActionEntry>> _readAll(File file) async {
    try {
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final list = jsonDecode(content) as List<dynamic>;
      return list
          .map((e) => PendingActionEntry.fromJson(e as Map<String, dynamic>))
          .whereType<PendingActionEntry>()
          .toList();
    } catch (e) {
      debugPrint('[PendingActionStore] failed to read: $e');
      try {
        await file.delete();
      } catch (_) {}
      return [];
    }
  }

  Future<void> _writeAll(
    File file,
    List<PendingActionEntry> entries,
  ) async {
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await file.writeAsString(json);
  }
}
