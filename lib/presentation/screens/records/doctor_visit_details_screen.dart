import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';
import 'package:rehab_track/presentation/utils/doctor_visit_localizer.dart';
import 'package:rehab_track/presentation/utils/localized_date_format.dart';

/// Visit details with status transitions. Terminal states (completed,
/// cancelled, missed) are preserved in History and never auto-reopened; only
/// an open visit can be completed/cancelled/marked missed or rescheduled.
class DoctorVisitDetailsScreen extends ConsumerWidget {
  final int visitId;

  const DoctorVisitDetailsScreen({super.key, required this.visitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final visitAsync = ref.watch(doctorVisitByIdProvider(visitId));

    return visitAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.doctorVisitDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.doctorVisitDetails)),
        body: Center(child: Text(l10n.error)),
      ),
      data: (visit) {
        if (visit == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.doctorVisitDetails)),
            body: Center(child: Text(l10n.contactNotAvailable)),
          );
        }
        return _VisitDetailsView(visit: visit);
      },
    );
  }
}

class _VisitDetailsView extends ConsumerWidget {
  final DoctorVisitRecord visit;

  const _VisitDetailsView({required this.visit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lookup = ref.watch(careContactLookupProvider);
    final now = DateTime.now();

    final doctor = lookup[visit.doctorContactId];
    final clinic = lookup[visit.organizationContactId];
    final isPastScheduled =
        visit.isOpen && !visit.scheduledDateTime.isAfter(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doctorVisitDetails),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  context.push(AppRoutes.doctorVisitEdit(visit.id!));
                case 'delete':
                  await _confirmDelete(context, ref, l10n);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.edit),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline, color: colorScheme.error),
                  title: Text(
                    l10n.delete,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Chip(
              avatar: Icon(
                DoctorVisitLocalizer.statusIcon(visit.status),
                size: 18,
                color: _statusColor(colorScheme),
              ),
              label: Text(
                DoctorVisitLocalizer.statusLabel(l10n, visit.status),
                style: TextStyle(color: _statusColor(colorScheme)),
              ),
            ),
          ),
          if (isPastScheduled) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.visitNeedsAttention,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '${LocalizedDateFormat.fullMonthDayYear(context, visit.scheduledDateTime)}'
            ' · ${LocalizedDateFormat.hourMinute(context, visit.scheduledDateTime)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${DoctorVisitLocalizer.typeLabel(l10n, visit.visitType)}'
              ' · ${visit.isOpen ? l10n.upcoming : l10n.visitHistory}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _section(context, l10n.doctor, [
            _contactTile(context, l10n, doctor),
          ]),
          _section(context, l10n.clinicOrHospital, [
            _contactTile(context, l10n, clinic),
          ]),
          if (visit.reason?.trim().isNotEmpty == true)
            _section(context, l10n.visitReason, [
              _textTile(visit.reason!.trim()),
            ]),
          if (visit.notes?.trim().isNotEmpty == true)
            _section(context, l10n.notes, [
              _textTile(visit.notes!.trim()),
            ]),
          _section(context, l10n.reminders, [
            ListTile(
              leading: const Icon(Icons.notifications_outlined, size: 20),
              title: Text(visit.reminderEnabled ? l10n.enabled : l10n.disabled),
              subtitle: visit.reminderEnabled
                  ? Text(DoctorVisitLocalizer.reminderOffsetLabel(
                      l10n,
                      visit.reminderMinutesBefore,
                    ))
                  : null,
              dense: true,
            ),
          ]),
          const SizedBox(height: 16),
          if (visit.isOpen) ...[
            _actionButton(
              context,
              icon: Icons.check_circle_outline,
              label: l10n.markCompleted,
              onPressed: () => _setStatus(
                context,
                ref,
                l10n,
                DoctorVisitStatus.completed,
              ),
            ),
            if (isPastScheduled)
              _actionButton(
                context,
                icon: Icons.error_outline,
                label: l10n.markMissed,
                onPressed: () => _setStatus(
                  context,
                  ref,
                  l10n,
                  DoctorVisitStatus.missed,
                ),
              ),
            _actionButton(
              context,
              icon: Icons.edit_calendar_outlined,
              label: l10n.reschedule,
              onPressed: () =>
                  context.push(AppRoutes.doctorVisitEdit(visit.id!)),
            ),
            _actionButton(
              context,
              icon: Icons.cancel_outlined,
              label: l10n.cancelVisit,
              destructive: true,
              onPressed: () => _setStatus(
                context,
                ref,
                l10n,
                DoctorVisitStatus.cancelled,
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _contactTile(BuildContext context, AppLocalizations l10n, Object? contact) {
    // `contact` is a CareContact when resolved.
    final name = _contactName(contact, l10n);
    return ListTile(
      leading: const Icon(Icons.person_outline, size: 20),
      title: Text(name),
      dense: true,
    );
  }

  String _contactName(Object? contact, AppLocalizations l10n) {
    if (contact == null) return l10n.contactNotAvailable;
    final c = contact as dynamic;
    final name = c.effectiveDisplayName as String?;
    if (name != null && name.trim().isNotEmpty) return name;
    return l10n.contactNotAvailable;
  }

  Widget _textTile(String value) {
    return ListTile(
      title: Text(value),
      dense: true,
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: OutlinedButton.icon(
        style: destructive
            ? OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              )
            : null,
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    return switch (visit.status) {
      DoctorVisitStatus.completed => colorScheme.primary,
      DoctorVisitStatus.cancelled => colorScheme.outline,
      DoctorVisitStatus.missed => colorScheme.error,
      DoctorVisitStatus.scheduled => colorScheme.secondary,
    };
  }

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DoctorVisitStatus status,
  ) async {
    final repo = ref.read(doctorVisitRepositoryProvider);
    final reminderService = ref.read(doctorVisitReminderServiceProvider);
    await repo.setVisitStatus(visit.profileId, visit.id!, status);
    await reminderService.cancelReminder(visit.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusMessage(l10n, status))),
      );
    }
  }

  String _statusMessage(AppLocalizations l10n, DoctorVisitStatus status) {
    return switch (status) {
      DoctorVisitStatus.completed => l10n.visitCompleted,
      DoctorVisitStatus.cancelled => l10n.visitCancelled,
      DoctorVisitStatus.missed => l10n.visitMissed,
      DoctorVisitStatus.scheduled => l10n.visitUpdated,
    };
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDeleteVisit),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(doctorVisitRepositoryProvider);
    final reminderService = ref.read(doctorVisitReminderServiceProvider);
    await reminderService.cancelReminder(visit.id!);
    await repo.deleteVisit(visit.profileId, visit.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.visitDeleted)),
      );
      context.pop();
    }
  }
}
