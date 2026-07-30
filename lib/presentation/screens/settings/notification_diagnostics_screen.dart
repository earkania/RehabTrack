import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';

class NotificationDiagnosticsScreen extends ConsumerStatefulWidget {
  const NotificationDiagnosticsScreen({super.key});

  @override
  ConsumerState<NotificationDiagnosticsScreen> createState() =>
      _NotificationDiagnosticsScreenState();
}

class _NotificationDiagnosticsScreenState
    extends ConsumerState<NotificationDiagnosticsScreen> {
  final _log = <String>[];

  void _addLog(String msg) {
    debugPrint('[NotificationDiagnostics] $msg');
    setState(() => _log.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $msg'));
  }

  Future<void> _initCheck() async {
    final service = ref.read(notificationServiceProvider);
    _addLog('isInitialized: ${service.isInitialized}');
    _addLog('tz.local.name: ${tz.local.name}');
    final tzNow = tz.TZDateTime.now(tz.local);
    _addLog('tz.local now: $tzNow');
    _addLog('DateTime.now(): ${DateTime.now()}');
    _addLog('DateTime.now().toLocal(): ${DateTime.now().toLocal()}');
    _addLog('DateTime.now().toUtc(): ${DateTime.now().toUtc()}');

    final hasNotif = await service.hasNotificationPermission();
    _addLog('hasNotificationPermission: $hasNotif');
    final hasExact = await service.hasExactAlarmPermission();
    _addLog('hasExactAlarmPermission: $hasExact');
  }

  Future<void> _showNow({required bool isMeasurement}) async {
    final service = ref.read(notificationServiceProvider);
    final channelId = isMeasurement
        ? NotificationService.measurementChannelId
        : NotificationService.medicationChannelId;
    final id = isMeasurement ? 900002 : 900001;
    final label = isMeasurement ? 'Measurement' : 'Medication';

    _addLog('=== showNow $label ===');
    _addLog('id: $id, channelId: $channelId');
    _addLog('isInitialized: ${service.isInitialized}');

    try {
      await service.showNotification(
        id: id,
        title: 'Test $label',
        body: 'Immediate $label notification test',
        channelId: channelId,
        playSound: true,
        enableVibration: true,
      );
      _addLog('showNotification completed without exception');
    } catch (e, stack) {
      _addLog('showNotification EXCEPTION: $e');
      _addLog('stack: $stack');
    }
  }

  Future<void> _scheduleSoon({required bool isMeasurement, int seconds = 30}) async {
    final service = ref.read(notificationServiceProvider);
    final channelId = isMeasurement
        ? NotificationService.measurementChannelId
        : NotificationService.medicationChannelId;
    final id = isMeasurement ? 900004 : 900003;
    final label = isMeasurement ? 'Measurement' : 'Medication';

    final now = DateTime.now();
    final target = now.add(Duration(seconds: seconds));
    final tzTarget = tz.TZDateTime(
      tz.local,
      target.year,
      target.month,
      target.day,
      target.hour,
      target.minute,
      target.second,
    );

    _addLog('=== scheduleSoon $label (${seconds}s) ===');
    _addLog('id: $id, channelId: $channelId');
    _addLog('now (local): $now');
    _addLog('target (local): $target');
    _addLog('tzTarget: $tzTarget');
    _addLog('tz.local.name: ${tz.local.name}');
    _addLog('isInitialized: ${service.isInitialized}');

    try {
      await service.scheduleNotification(
        id: id,
        title: 'Scheduled $label',
        body: 'This $label notification was scheduled ${seconds}s ago',
        scheduledDate: tzTarget,
        channelId: channelId,
        playSound: true,
        enableVibration: true,
      );
      _addLog('scheduleNotification completed without exception');
    } catch (e, stack) {
      _addLog('scheduleNotification EXCEPTION: $e');
      _addLog('stack: $stack');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Diagnostics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _initCheck,
                child: const Text('Check Init'),
              ),
              ElevatedButton(
                onPressed: () => _showNow(isMeasurement: false),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50),
                child: const Text('Show Med Now'),
              ),
              ElevatedButton(
                onPressed: () => _showNow(isMeasurement: true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade50),
                child: const Text('Show Meas Now'),
              ),
              ElevatedButton(
                onPressed: () => _scheduleSoon(isMeasurement: false, seconds: 30),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
                child: const Text('Schedule Med 30s'),
              ),
              ElevatedButton(
                onPressed: () => _scheduleSoon(isMeasurement: true, seconds: 60),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
                child: const Text('Schedule Meas 60s'),
              ),
            ],
          ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _log.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  _log[i],
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
