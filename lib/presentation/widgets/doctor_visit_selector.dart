import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';

/// Selector widget for picking a doctor visit
class DoctorVisitSelector extends ConsumerWidget {
  const DoctorVisitSelector({
    super.key,
    required this.label,
    this.selectedVisitId,
    this.onChanged,
    this.allowEmpty = true,
  });

  final String label;
  final int? selectedVisitId;
  final ValueChanged<int?>? onChanged;
  final bool allowEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final visitsAsync = ref.watch(doctorVisitUpcomingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        visitsAsync.when(
          data: (visits) {
            final upcoming = visits.where((v) => v.isOpen).toList()
              ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));

            final selected = selectedVisitId != null
                ? visits.firstWhereOrNull((v) => v.id == selectedVisitId)
                : null;

            return InkWell(
              onTap: () async {
                final result = await showDialog<int?>(
                  context: context,
                  builder: (context) => _VisitSelectionDialog(
                    visits: upcoming,
                    initialSelection: selectedVisitId,
                  ),
                );
                if (result != null && onChanged != null) {
                  onChanged!(result);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _visitLabel(context, selected),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: selected != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            );
          },
          loading: () => InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            child: Text(
              l10n.loading,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          error: (error, stack) => InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorText: error.toString(),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
        if (selectedVisitId != null && onChanged != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: () => onChanged!(null),
              icon: const Icon(Icons.clear),
              label: Text(l10n.clearSelection),
            ),
          ),
      ],
    );
  }
}

String _visitTitle(BuildContext context, DoctorVisitRecord visit) {
  if (visit.reason != null && visit.reason!.trim().isNotEmpty) {
    return visit.reason!;
  }
  final date = DateFormat.yMMMd().format(visit.scheduledDateTime);
  final time = DateFormat.Hm().format(visit.scheduledDateTime);
  return '$date $time';
}

String _visitLabel(BuildContext context, DoctorVisitRecord? visit) {
  final l10n = AppLocalizations.of(context)!;
  if (visit == null) return l10n.selectDoctorVisit;
  return _visitTitle(context, visit);
}

class _VisitSelectionDialog extends StatelessWidget {
  const _VisitSelectionDialog({
    required this.visits,
    required this.initialSelection,
  });

  final List<DoctorVisitRecord> visits;
  final int? initialSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.selectDoctorVisit),
      content: SizedBox(
        width: double.maxFinite,
        child: visits.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noUpcomingVisits,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.noUpcomingVisitsDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: visits.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  return ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(
                      _visitTitle(context, visit),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(visit.scheduledDateTime)} at ${DateFormat.Hm().format(visit.scheduledDateTime)}',
                    ),
trailing: Icon(
  initialSelection == visit.id
      ? Icons.check_circle
      : Icons.circle_outlined,
  color: initialSelection == visit.id
      ? Theme.of(context).colorScheme.primary
      : Theme.of(context).colorScheme.onSurfaceVariant,
),
onTap: () => Navigator.pop(context, visit.id),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(l10n.clearSelection),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}