import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';
import 'package:rehab_track/presentation/utils/doctor_visit_localizer.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';

enum _VisitViewMode { upcoming, history }

/// Records → Doctor Visits. Two lists backed by the same data:
///  - Upcoming: open (still scheduled) visits, including past-scheduled ones
///    that need attention until the user completes/cancels/reschedules them.
///  - History: terminal visits (completed / cancelled / missed).
class DoctorVisitsScreen extends ConsumerStatefulWidget {
  const DoctorVisitsScreen({super.key});

  @override
  ConsumerState<DoctorVisitsScreen> createState() => _DoctorVisitsScreenState();
}

class _DoctorVisitsScreenState extends ConsumerState<DoctorVisitsScreen> {
  _VisitViewMode _mode = _VisitViewMode.upcoming;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUpcoming = _mode == _VisitViewMode.upcoming;
    final visitsAsync = isUpcoming
        ? ref.watch(doctorVisitUpcomingProvider)
        : ref.watch(doctorVisitHistoryProvider);
    final lookup = ref.watch(careContactLookupProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorVisits)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.doctorVisitAdd),
        tooltip: l10n.addDoctorVisit,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_VisitViewMode>(
                segments: [
                  ButtonSegment(
                    value: _VisitViewMode.upcoming,
                    label: Text(l10n.upcomingVisits),
                  ),
                  ButtonSegment(
                    value: _VisitViewMode.history,
                    label: Text(l10n.visitHistory),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) {
                  setState(() => _mode = selection.first);
                },
              ),
            ),
          ),
          Expanded(
            child: visitsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.error)),
              data: (visits) {
                if (visits.isEmpty) {
                  return EmptyState(
                    icon: isUpcoming
                        ? Icons.event_busy_outlined
                        : Icons.history,
                    title: isUpcoming
                        ? l10n.noUpcomingVisits
                        : l10n.noVisitHistory,
                    subtitle: isUpcoming
                        ? l10n.noUpcomingVisitsDescription
                        : l10n.noVisitHistoryDescription,
                    actionLabel: isUpcoming ? l10n.addDoctorVisit : null,
                    onAction: isUpcoming
                        ? () => context.push(AppRoutes.doctorVisitAdd)
                        : null,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: visits.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final visit = visits[index];
                    return _VisitTile(
                      visit: visit,
                      doctor:
                          lookup[visit.doctorContactId]?.effectiveDisplayName,
                      clinic: lookup[visit.organizationContactId]
                          ?.effectiveDisplayName,
                      l10n: l10n,
                      now: now,
                      onTap: () => context.push(
                        AppRoutes.doctorVisitDetails(visit.id!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  final DoctorVisitRecord visit;
  final String? doctor;
  final String? clinic;
  final AppLocalizations l10n;
  final DateTime now;
  final VoidCallback onTap;

  const _VisitTile({
    required this.visit,
    required this.doctor,
    required this.clinic,
    required this.l10n,
    required this.now,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isUpcomingList = visit.isOpen;
    final needsAttention = isUpcomingList && !visit.scheduledDateTime.isAfter(now);

    final primaryName = _primaryName();
    final secondary = _secondaryName();

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: needsAttention
            ? colorScheme.errorContainer
            : colorScheme.secondaryContainer,
        foregroundColor: needsAttention
            ? colorScheme.onErrorContainer
            : colorScheme.onSecondaryContainer,
        child: Icon(
          needsAttention ? Icons.warning_amber_rounded : Icons.medical_services,
          size: 22,
        ),
      ),
      title: Text(
        primaryName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          color: needsAttention ? colorScheme.error : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (secondary != null)
            Text(secondary, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            isUpcomingList
                ? '${AppDateFormatter.of(context).formatMediumDate(visit.scheduledDateTime)}'
                    ' · ${AppDateFormatter.of(context).formatTime(visit.scheduledDateTime)}'
                : _terminalSubtitle(context),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: isUpcomingList
          ? Icon(
              needsAttention ? Icons.error_outline : Icons.chevron_right,
              color: needsAttention ? colorScheme.error : null,
            )
          : Chip(
              avatar: Icon(
                DoctorVisitLocalizer.statusIcon(visit.status),
                size: 16,
                color: _statusColor(colorScheme),
              ),
              label: Text(
                DoctorVisitLocalizer.statusLabel(l10n, visit.status),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _statusColor(colorScheme),
                ),
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
    );
  }

  String _primaryName() {
    if (doctor != null && doctor!.trim().isNotEmpty) return doctor!;
    if (clinic != null && clinic!.trim().isNotEmpty) return clinic!;
    return l10n.contactNotAvailable;
  }

  String? _secondaryName() {
    if (doctor != null &&
        doctor!.trim().isNotEmpty &&
        clinic != null &&
        clinic!.trim().isNotEmpty) {
      return clinic;
    }
    if (visit.reason != null && visit.reason!.trim().isNotEmpty) {
      return visit.reason;
    }
    return null;
  }

  String _terminalSubtitle(BuildContext context) {
    final formatter = AppDateFormatter.of(context);
    final time =
        '${formatter.formatMediumDate(visit.scheduledDateTime)} · ${formatter.formatTime(visit.scheduledDateTime)}';
    if (visit.reason != null && visit.reason!.trim().isNotEmpty) {
      return '$time · ${visit.reason!.trim()}';
    }
    return time;
  }

  Color _statusColor(ColorScheme colorScheme) {
    return switch (visit.status) {
      DoctorVisitStatus.completed => colorScheme.primary,
      DoctorVisitStatus.cancelled => colorScheme.outline,
      DoctorVisitStatus.missed => colorScheme.error,
      DoctorVisitStatus.scheduled => colorScheme.secondary,
    };
  }
}
