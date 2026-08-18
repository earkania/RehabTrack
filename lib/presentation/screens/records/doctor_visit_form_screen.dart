import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/utils/doctor_visit_localizer.dart';

/// Shared Doctor Visit create/edit form. Used by the add and edit routes.
class DoctorVisitFormScreen extends ConsumerStatefulWidget {
  /// When null the form creates a new visit; otherwise it edits [visitId].
  final int? visitId;

  const DoctorVisitFormScreen({super.key, this.visitId});

  @override
  ConsumerState<DoctorVisitFormScreen> createState() =>
      _DoctorVisitFormScreenState();
}

class _DoctorVisitFormScreenState extends ConsumerState<DoctorVisitFormScreen> {
  static const _reminderOptions = [15, 30, 60, 120, 1440, 2880, 10080];

  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loaded = false;

  DoctorVisitType _visitType = DoctorVisitType.planned;
  DoctorVisitStatus _status = DoctorVisitStatus.scheduled;
  DateTime _scheduledDateTime = DateTime.now().add(const Duration(days: 7));
  int? _doctorContactId;
  int? _organizationContactId;
  bool _reminderEnabled = true;
  int _reminderMinutes = 1440;
  bool _saveAsScheduledLater = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.visitId == null) {
      return _buildForm(context, l10n, isEditing: false, existing: null);
    }

    final visitAsync = ref.watch(doctorVisitByIdProvider(widget.visitId!));
    return visitAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editDoctorVisit)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.editDoctorVisit)),
        body: Center(child: Text(l10n.error)),
      ),
      data: (existing) {
        if (existing == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editDoctorVisit)),
            body: Center(child: Text(l10n.error)),
          );
        }
        if (!_loaded) {
          _populate(existing);
          _loaded = true;
        }
        return _buildForm(context, l10n,
            isEditing: true, existing: existing);
      },
    );
  }

  void _populate(DoctorVisitRecord visit) {
    _visitType = visit.visitType;
    _status = visit.status;
    _scheduledDateTime = visit.scheduledDateTime;
    _doctorContactId = visit.doctorContactId;
    _organizationContactId = visit.organizationContactId;
    _reminderEnabled = visit.reminderEnabled;
    _reminderMinutes = visit.reminderMinutesBefore;
    _reasonController.text = visit.reason ?? '';
    _notesController.text = visit.notes ?? '';
    _saveAsScheduledLater = visit.status == DoctorVisitStatus.scheduled;
  }

  bool get _willBeScheduled =>
      _visitType == DoctorVisitType.planned || _saveAsScheduledLater;

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isEditing,
    required DoctorVisitRecord? existing,
  }) {
    final theme = Theme.of(context);

    // For a new on-demand visit the record is completed immediately unless the
    // user opts to save it as a scheduled-for-later visit.
    final effectiveStatus = isEditing
        ? _status
        : (_willBeScheduled
            ? DoctorVisitStatus.scheduled
            : DoctorVisitStatus.completed);

    final showReminder = effectiveStatus == DoctorVisitStatus.scheduled;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editDoctorVisit : l10n.addDoctorVisit),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.visitType, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<DoctorVisitType>(
            segments: [
              ButtonSegment(
                value: DoctorVisitType.planned,
                icon: const Icon(Icons.event_outlined),
                label: Text(l10n.plannedVisit),
              ),
              ButtonSegment(
                value: DoctorVisitType.onDemand,
                icon: const Icon(Icons.flash_on_outlined),
                label: Text(l10n.onDemandVisit),
              ),
            ],
            selected: {_visitType},
            onSelectionChanged: (selection) {
              setState(() => _visitType = selection.first);
            },
          ),
          if (_visitType == DoctorVisitType.onDemand) ...[
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.saveAsScheduledLater),
              subtitle: Text(l10n.onDemandRecordedCompleted),
              value: _saveAsScheduledLater,
              onChanged: (value) => setState(() => _saveAsScheduledLater = value),
            ),
          ],
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(l10n.scheduledDateTime),
            subtitle: Text(
              '${AppDateFormatter.of(context).formatLongDate(_scheduledDateTime)}'
              ' · ${AppDateFormatter.of(context).formatTime(_scheduledDateTime)}',
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _pickDateTime(context, l10n),
          ),
          const SizedBox(height: 8),
          _buildContactTile(
            context,
            l10n,
            icon: Icons.person_outline,
            label: l10n.doctor,
            value: _doctorContactId,
            eligible: _isDoctorContact,
            onTap: () => _pickContact(context, l10n, isDoctor: true),
          ),
          _buildContactTile(
            context,
            l10n,
            icon: Icons.local_hospital_outlined,
            label: l10n.clinicOrHospital,
            value: _organizationContactId,
            eligible: _isOrganizationContact,
            onTap: () => _pickContact(context, l10n, isDoctor: false),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: l10n.visitReason,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.notes,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          if (showReminder) ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.remindMe),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
            ),
            if (_reminderEnabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_active_outlined),
                title: Text(l10n.remindBefore),
                trailing: DropdownButton<int>(
                  value: _reminderMinutes,
                  items: _reminderOptions
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              DoctorVisitLocalizer.reminderOffsetLabel(l10n, m),
                            ),
                          ))
                      .toList(),
                  onChanged: (m) {
                    if (m != null) setState(() => _reminderMinutes = m);
                  },
                ),
              ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _save(context, l10n, isEditing),
            icon: const Icon(Icons.check),
            label: Text(l10n.save),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String label,
    required int? value,
    required bool Function(CareContact) eligible,
    required VoidCallback onTap,
  }) {
    final lookup = ref.watch(careContactLookupProvider);
    final contact = value != null ? lookup[value] : null;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        contact?.effectiveDisplayName ?? l10n.contactNotSelected,
        style: contact == null
            ? theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )
            : null,
      ),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: onTap,
    );
  }

  bool _isDoctorContact(CareContact c) =>
      c.contactType == CareContactType.doctor;

  bool _isOrganizationContact(CareContact c) =>
      c.contactType.isOrganization &&
      c.contactType != CareContactType.insurance;

  Future<void> _pickDateTime(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDateTime,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDateTime),
    );
    if (time == null) return;
    setState(() {
      _scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickContact(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isDoctor,
  }) async {
    final contacts = ref
        .read(careContactsProvider)
        .valueOrNull
        ?.where(isDoctor ? _isDoctorContact : _isOrganizationContact)
        .toList() ?? const <CareContact>[];

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noEligibleContacts)),
      );
      return;
    }

    final selected = await showModalBottomSheet<CareContact>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                isDoctor ? l10n.selectDoctor : l10n.selectClinicOrHospital,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final contact in contacts)
              ListTile(
                leading: CircleAvatar(
                  child: Text(
                    contact.initials,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                title: Text(contact.effectiveDisplayName),
                onTap: () => Navigator.pop(ctx, contact),
              ),
          ],
        ),
      ),
    );

    if (selected == null || selected.id == null) return;
    setState(() {
      if (isDoctor) {
        _doctorContactId = selected.id;
      } else {
        _organizationContactId = selected.id;
      }
    });
  }

  Future<void> _save(
    BuildContext context,
    AppLocalizations l10n,
    bool isEditing,
  ) async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) {
      _showSnack(l10n.saveVisitFailed);
      return;
    }

    final status = isEditing
        ? _status
        : (_willBeScheduled
            ? DoctorVisitStatus.scheduled
            : DoctorVisitStatus.completed);
    final now = DateTime.now();
    final existing = isEditing
        ? ref.read(doctorVisitByIdProvider(widget.visitId!)).valueOrNull
        : null;

    final visit = DoctorVisitRecord(
      id: isEditing ? widget.visitId : null,
      profileId: profileId,
      doctorContactId: _doctorContactId,
      organizationContactId: _organizationContactId,
      visitType: _visitType,
      status: status,
      scheduledDateTime: _scheduledDateTime,
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      reminderEnabled: status == DoctorVisitStatus.scheduled && _reminderEnabled,
      reminderMinutesBefore: _reminderMinutes,
      isArchived: existing?.isArchived ?? false,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final repo = ref.read(doctorVisitRepositoryProvider);
    final reminderService = ref.read(doctorVisitReminderServiceProvider);
    int? visitId;

    try {
      if (isEditing) {
        await repo.updateVisit(visit);
        visitId = visit.id;
      } else {
        visitId = await repo.createVisit(visit);
      }
    } catch (_) {
      if (context.mounted) _showSnack(l10n.saveVisitFailed);
      return;
    }

    // Refresh reminders: cancel the old one, then schedule the new state.
    final oldReminderEnabled = existing?.reminderEnabled ?? false;
    final oldStatus = existing?.status;
    if (isEditing &&
        (oldReminderEnabled || oldStatus == DoctorVisitStatus.scheduled)) {
      await reminderService.cancelReminder(visitId!);
    }
    if (visit.reminderEnabled && visitId != null) {
      try {
        await reminderService.scheduleReminder(visit.copyWith(id: visitId));
      } catch (_) {
        if (context.mounted) _showSnack(l10n.reminderSchedulingFailed);
      }
    }

    if (context.mounted) {
      _showSnack(isEditing ? l10n.visitUpdated : l10n.visitSaved);
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
