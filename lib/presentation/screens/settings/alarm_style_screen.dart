import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

import 'package:rehab_track/core/router/app_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/data/services/notification/alarm_presentation.dart';
import 'package:rehab_track/data/services/notification/notification_action_bridge.dart';
import 'package:rehab_track/data/services/notification/notification_action_handler.dart';
import 'package:rehab_track/data/services/notification/notification_service.dart';
import 'package:rehab_track/data/services/notification/reminder_payload.dart';
import 'package:rehab_track/domain/entities/medication.dart';
import 'package:rehab_track/domain/entities/scheduled_measurement.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';
import 'package:rehab_track/presentation/utils/dosage_form_localizer.dart';

/// The dedicated full-screen Alarm-style presentation.
///
/// Renders the active alarm from [activeAlarmPresentationProvider] (set when an
/// alarm notification is opened via tap, full-screen intent, or cold start) and
/// routes every user action through the canonical notification action bridge so
/// exactly one occurrence is acknowledged with no medical duplication.
///
/// Dismissing an alarm stops its sound/vibration (cancelling the active
/// notification) but leaves the occurrence unresolved (Pending/Overdue). Back
/// navigation behaves like Dismiss and never completes a dose; the screen never
/// traps the user.
class AlarmStyleScreen extends ConsumerStatefulWidget {
  const AlarmStyleScreen({super.key});

  @override
  ConsumerState<AlarmStyleScreen> createState() => _AlarmStyleScreenState();
}

class _AlarmStyleScreenState extends ConsumerState<AlarmStyleScreen>
    with WidgetsBindingObserver {
  AlarmPresentation? _active;
  AlarmPresentation? _lastActive;
  ReminderPayload? _reminder;
  NotificationService? _service;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _active = ref.read(activeAlarmPresentationProvider);
    _reminder = _active?.reminder;
    _lastActive = _active;
    // Do not read `ref` in dispose (riverpod forbids it once the element
    // starts unmounting), so capture the service up front.
    _service = ref.read(notificationServiceProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Leaving the screen without acknowledging (e.g. back navigation) must not
    // leave the alarm sound playing.
    if (_lastActive != null) {
      _service?.stopAlarmSound();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding the app must not leave the alarm sound playing.
    if (state == AppLifecycleState.paused) {
      _service?.stopAlarmSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeAlarmPresentationProvider);
    _lastActive = active;

    // An acknowledgment already submitted: show the confirmation without
    // scheduling any fallback navigation, so the app's own post-frame
    // `context.go(home)` below never races with the action's router
    // navigation (e.g. Details -> visit details).
    if (_submitted) {
      return const _AcknowledgedScreen();
    }

    // No alarm is active: either a stale route was reached or the presentation
    // was acknowledged elsewhere. Fall back to Today without trapping the user.
    if (active == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.home);
      });
      return const Scaffold(body: SizedBox());
    }

    if (active.isTestAlarm) {
      return _TestAlarmView(
        active: active,
        onDismiss: () => _dismissTestAlarm(active),
        onClose: () => _closeOnly(active),
      );
    }

    final reminder = _reminder;
    if (reminder == null) {
      // Unrecognized payload: safe generic dismiss-only presentation.
      return _TestAlarmView(
        active: active,
        onDismiss: () => _dismissInvalid(active),
        onClose: () => _closeOnly(active),
      );
    }

    switch (reminder.type) {
      case ReminderType.medication:
        return _AlarmScaffold(
          active: active,
          scheduledAt: reminder.occurrenceDateTime,
          actions: [
            FilledButton.icon(
              onPressed: () => _runAction(
                active,
                NotificationActionType.medicationMarkTaken,
              ),
              icon: const Icon(Icons.check),
              label: Text(l10n.markAsTaken),
            ),
            OutlinedButton.icon(
              onPressed: () => _runAction(active,
                  NotificationActionType.medicationSnooze),
              icon: const Icon(Icons.snooze_outlined),
              label: Text(l10n.snooze),
            ),
            TextButton.icon(
              onPressed: () => _runAction(
                active,
                NotificationActionType.medicationSkip,
              ),
              icon: const Icon(Icons.skip_next_outlined),
              label: Text(l10n.skip),
            ),
            OutlinedButton.icon(
              onPressed: () => _runDismiss(active),
              icon: const Icon(Icons.notifications_off_outlined),
              label: Text(l10n.dismissAlarm),
            ),
          ],
        );
      case ReminderType.measurement:
        final typeId = reminder.measurementTypeId;
        return _AlarmScaffold(
          active: active,
          scheduledAt: reminder.occurrenceDateTime,
          actions: [
            FilledButton.icon(
              onPressed: typeId == null
                  ? null
                  : () => _runMeasurementRecordNow(active, typeId),
              icon: const Icon(Icons.edit_note_outlined),
              label: Text(l10n.recordNow),
            ),
            OutlinedButton.icon(
              onPressed: () => _runAction(
                active,
                NotificationActionType.measurementSnooze,
              ),
              icon: const Icon(Icons.snooze_outlined),
              label: Text(l10n.snooze),
            ),
            TextButton.icon(
              onPressed: () => _runAction(active, NotificationActionType.measurementSkip),
              icon: const Icon(Icons.skip_next_outlined),
              label: Text(l10n.skip),
            ),
            OutlinedButton.icon(
              onPressed: () => _runDismiss(active),
              icon: const Icon(Icons.notifications_off_outlined),
              label: Text(l10n.dismissAlarm),
            ),
          ],
        );
      case ReminderType.doctorVisit:
        final visitId = reminder.visitId ?? reminder.scheduleId;
        return _AlarmScaffold(
          active: active,
          scheduledAt: reminder.occurrenceDateTime,
          actions: [
            FilledButton.icon(
              onPressed: visitId > 0
                  ? () => _runDoctorVisitOpen(active, visitId)
                  : null,
              icon: const Icon(Icons.open_in_new),
              label: Text(l10n.openDetails),
            ),
            OutlinedButton.icon(
              onPressed: () => _runDoctoVisitSnooze(active),
              icon: const Icon(Icons.snooze_outlined),
              label: Text(l10n.snooze),
            ),
            OutlinedButton.icon(
              onPressed: () => _runDismiss(active),
              icon: const Icon(Icons.notifications_off_outlined),
              label: Text(l10n.dismissAlarm),
            ),
          ],
        );
    }
  }

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  Future<void> _runAction(
    AlarmPresentation active,
    NotificationActionType actionType,
  ) async {
    final reminder = _reminder;
    if (reminder == null) return;
    final result = await ref
        .read(notificationActionBridgeProvider)
        .executeUiAction(
          actionType: actionType,
          payload: reminder,
          notificationId: active.notificationId,
        );
    if (!mounted) return;
    if (result == ActionResult.success ||
        result == ActionResult.alreadyCompleted) {
      _finish(active);
    } else {
      _showError(l10n.actionFailed);
    }
  }

  Future<void> _runDismiss(AlarmPresentation active) async {
    final reminder = _reminder;
    if (reminder == null) {
      await ref
          .read(notificationServiceProvider)
          .cancelNotification(active.notificationId);
      if (!mounted) return;
      _finish(active);
      return;
    }
    final result = await ref
        .read(notificationActionBridgeProvider)
        .executeUiAction(
          actionType: NotificationActionType.dismiss,
          payload: reminder,
          notificationId: active.notificationId,
        );
    if (!mounted) return;
    if (result == ActionResult.success) {
      _finish(active);
    } else {
      _showError(l10n.dismissFailed);
    }
  }

  Future<void> _dismissTestAlarm(AlarmPresentation active) async {
    await ref
        .read(notificationServiceProvider)
        .cancelNotification(active.notificationId);
    if (!mounted) return;
    _finish(active);
  }

  Future<void> _dismissInvalid(AlarmPresentation active) async {
    await ref
        .read(notificationServiceProvider)
        .cancelNotification(active.notificationId);
    if (!mounted) return;
    _finish(active);
  }

  /// Navigation-only close: dismisses the presentation without cancelling the
  /// active notification (used by the top-right X on a test alarm).
  void _closeOnly(AlarmPresentation active) {
    ref.read(activeAlarmPresentationProvider.notifier).state = null;
    context.go(AppRoutes.home);
  }

  Future<void> _runMeasurementRecordNow(
    AlarmPresentation active,
    int typeId,
  ) async {
    final reminder = _reminder;
    if (reminder == null) return;
    final result = await ref
        .read(notificationActionBridgeProvider)
        .executeUiAction(
          actionType: NotificationActionType.measurementRecordNow,
          payload: reminder,
          notificationId: active.notificationId,
        );
    if (!mounted) return;
    if (result == ActionResult.success) {
      final scheduledTime = reminder.occurrenceDateTime ?? DateTime.now();
      final extra = RecordNowExtra(
        scheduledOccurrenceTime: MeasurementOccurrenceTime.normalize(scheduledTime),
        reminderScheduleId: reminder.scheduleId,
      );
      ref.read(activeAlarmPresentationProvider.notifier).state = null;
      context.go(AppRoutes.home);
      context.push(AppRoutes.measurementAdd(typeId), extra: extra);
    } else {
      _showError(l10n.actionFailed);
    }
  }

  Future<void> _runDoctorVisitOpen(
    AlarmPresentation active,
    int visitId,
  ) async {
    final reminder = _reminder;
    if (reminder == null) return;
    final result = await ref
        .read(notificationActionBridgeProvider)
        .executeUiAction(
          actionType: NotificationActionType.doctorVisitOpen,
          payload: reminder,
          notificationId: active.notificationId,
        );
    if (!mounted) return;
    if (result == ActionResult.success) {
      _finishToDetails(visitId);
    } else {
      _showError(l10n.actionFailed);
    }
  }

  /// Acknowledges the alarm and lands on the visit details in the next frame.
  /// Navigation is deferred so the alarm route finishes unmounting first, and
  /// uses the router directly to avoid acting on a disposed context.
  void _finishToDetails(int visitId) {
    setState(() => _submitted = true);
    ref.read(activeAlarmPresentationProvider.notifier).state = null;
    final router = ref.read(routerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go(AppRoutes.home);
      router.push(AppRoutes.doctorVisitDetails(visitId));
    });
  }

  Future<void> _runDoctoVisitSnooze(AlarmPresentation active) async {
    final reminder = _reminder;
    if (reminder == null) return;
    final result = await ref
        .read(notificationActionBridgeProvider)
        .executeUiAction(
          actionType: NotificationActionType.doctorVisitSnooze,
          payload: reminder,
          notificationId: active.notificationId,
        );
    if (!mounted) return;
    if (result == ActionResult.success) {
      _finish(active);
    } else {
      _showError(l10n.actionFailed);
    }
  }

  /// Marks the acknowledgment as submitted (brief confirmation replaces the
  /// live alarm) and navigates home in the next frame.
  void _finish(AlarmPresentation active) {
    setState(() => _submitted = true);
    ref.read(activeAlarmPresentationProvider.notifier).state = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Displays the recognized reminder content for the active alarm.
class _AlarmScaffold extends ConsumerWidget {
  const _AlarmScaffold({
    required this.active,
    required this.scheduledAt,
    required this.actions,
  });

  final AlarmPresentation active;
  final DateTime? scheduledAt;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Privacy: when the user chose to hide details on the lock screen, show a
    // generic alarm instead of the medication/measurement/visit specifics.
    final detailsHidden = !ref.watch(showDetailsOnLockScreenProvider);

    final reminder = active.reminder;
    final Future<_AlarmContent> contentFuture = reminder == null
        ? Future.value(const _AlarmContent.empty())
        : _loadContent(ref, reminder, l10n);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: FutureBuilder<_AlarmContent>(
            future: contentFuture,
            builder: (context, snapshot) {
              final content = snapshot.data ?? const _AlarmContent.empty();
              final title = detailsHidden
                  ? l10n.alarmReminder
                  : content.title;
              final item = detailsHidden
                  ? l10n.healthReminderLockScreen
                  : content.item;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.alarmReminder,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.close,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref
                              .read(activeAlarmPresentationProvider.notifier)
                              .state = null;
                          context.go(AppRoutes.home);
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.notifications_active,
                    size: 72,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (item.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (!detailsHidden && scheduledAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.scheduledAt(_formatTime(scheduledAt!)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 48),
                  ...actions,
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<_AlarmContent> _loadContent(
    WidgetRef ref,
    ReminderPayload reminder,
    AppLocalizations l10n,
  ) async {
    switch (reminder.type) {
      case ReminderType.medication:
        return _loadMedication(ref, reminder, l10n);
      case ReminderType.measurement:
        return _loadMeasurement(ref, reminder, l10n);
      case ReminderType.doctorVisit:
        return _loadDoctorVisit(ref, reminder, l10n);
    }
  }

  Future<_AlarmContent> _loadMedication(
    WidgetRef ref,
    ReminderPayload reminder,
    AppLocalizations l10n,
  ) async {
    final medicationId = reminder.medicationId;
    final scheduleId = reminder.scheduleId;
    if (medicationId == null) return const _AlarmContent.empty();
    final repo = ref.read(medicationRepositoryProvider);
    final medication = await repo.getMedication(medicationId);
    final schedule = await repo.getSchedule(scheduleId);
    if (medication == null) {
      return _AlarmContent(title: l10n.medicationReminder, item: '');
    }
    final title = _medicationTitle(medication);
    final item = _medicationBody(medication, schedule, l10n);
    return _AlarmContent(title: title, item: item);
  }

  Future<_AlarmContent> _loadMeasurement(
    WidgetRef ref,
    ReminderPayload reminder,
    AppLocalizations l10n,
  ) async {
    final typeId = reminder.measurementTypeId;
    if (typeId == null) return const _AlarmContent.empty();
    final repo = ref.read(measurementRepositoryProvider);
    final type = await repo.getMeasurementType(typeId);
    if (type == null) {
      return _AlarmContent(title: l10n.measurementReminder, item: '');
    }
    return _AlarmContent(
      title: type.name,
      item: l10n.measurementToRecord(
        type.name,
        _formatTime(reminder.occurrenceDateTime ?? DateTime.now()),
      ),
    );
  }

  Future<_AlarmContent> _loadDoctorVisit(
    WidgetRef ref,
    ReminderPayload reminder,
    AppLocalizations l10n,
  ) async {
    final visitId = reminder.visitId ?? reminder.scheduleId;
    final repo = ref.read(doctorVisitRepositoryProvider);
    final visit = await repo.getVisitById(reminder.profileId, visitId);
    if (visit == null) {
      return _AlarmContent(title: l10n.doctorVisitReminder, item: '');
    }
    final contacts = ref.read(careContactRepositoryProvider);
    final doctor = visit.doctorContactId != null
        ? await contacts.getContactById(visit.profileId, visit.doctorContactId!)
        : null;
    final organization = visit.organizationContactId != null
        ? await contacts.getContactById(visit.profileId, visit.organizationContactId!)
        : null;
    final title = doctor?.effectiveDisplayName ??
        organization?.effectiveDisplayName ??
        l10n.doctorVisitReminder;
    final item = organization != null && doctor != null
        ? '${doctor.effectiveDisplayName} \u2014 ${organization.effectiveDisplayName}'
        : (organization?.effectiveDisplayName ?? '');
    return _AlarmContent(title: title, item: item);
  }

  String _medicationTitle(Medication medication) {
    final name = medication.name;
    final dose = medication.doseAmount;
    if (dose != null && dose.isNotEmpty) {
      final unit = medication.doseUnit != null && medication.doseUnit!.isNotEmpty
          ? ' ${medication.doseUnit}'
          : '';
      return '$name $dose$unit';
    }
    return name;
  }

  String _medicationBody(
    Medication medication,
    MedicationSchedule? schedule,
    AppLocalizations l10n,
  ) {
    if (schedule == null) return '';
    final quantity = schedule.intakeQuantity;
    final intake = DosageFormLocalizer.localizeWithQuantity(
      quantity,
      schedule.dosageForm,
      l10n,
      customForm: schedule.customDosageForm,
    );
    final parts = <String>[intake];
    if (schedule.instructions != null && schedule.instructions!.isNotEmpty) {
      parts.add(schedule.instructions!);
    }
    return parts.join(' \u2014 ');
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AlarmContent {
  const _AlarmContent({required this.title, required this.item});
  const _AlarmContent.empty() : title = '', item = '';

  final String title;
  final String item;
}

/// Dismiss-only view used by the manual Alarm-style test and for unrecognized
/// payloads. Never offers medical actions and never touches medical data.
class _TestAlarmView extends StatelessWidget {
  const _TestAlarmView({
    required this.active,
    required this.onDismiss,
    required this.onClose,
  });

  final AlarmPresentation active;
  final VoidCallback onDismiss;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.alarmReminder,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.notifications_active,
                size: 72,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.testAlarmStyleReminder,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.testAlarmStyleBody,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              OutlinedButton.icon(
                onPressed: onDismiss,
                icon: const Icon(Icons.notifications_off_outlined),
                label: Text(l10n.dismissTestAlarm),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcknowledgedScreen extends StatelessWidget {
  const _AcknowledgedScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.alarmDismissed,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}