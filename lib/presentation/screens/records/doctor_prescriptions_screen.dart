import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/doctor_prescription_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/common/archived_toggle_button.dart';
import 'package:rehab_track/presentation/widgets/common/list_toolbar_icons.dart';

/// Doctor Prescriptions list screen
class DoctorPrescriptionsScreen extends ConsumerStatefulWidget {
  const DoctorPrescriptionsScreen({super.key});

  @override
  ConsumerState<DoctorPrescriptionsScreen> createState() =>
      _DoctorPrescriptionsScreenState();
}

class _DoctorPrescriptionsScreenState
    extends ConsumerState<DoctorPrescriptionsScreen> {
  bool _showArchived = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(doctorPrescriptionSearchQueryProvider.notifier).state =
          _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeProfileId = ref.watch(currentActiveProfileIdProvider);

    final prescriptions = _showArchived
        ? ref.watch(archivedDoctorPrescriptionsProvider(activeProfileId ?? 0))
        : ref.watch(sortedDoctorPrescriptionsProvider(activeProfileId ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doctorPrescriptions),
        actions: [
          ArchivedToggleButton(
            isArchived: _showArchived,
            showTooltip: l10n.showArchivedPrescriptions,
            showingTooltip: l10n.showingArchivedPrescriptions,
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
          ),
        ],
      ),
      floatingActionButton: _showArchived
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutes.recordsPrescriptionsAdd),
              child: const Icon(Icons.add),
            ),
      body: activeProfileId == null
          ? _buildNoProfile()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.searchPrescriptions,
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CircleMenuButton<DoctorPrescriptionFilter>(
                        icon: toolbarCategoryFilterIcon,
                        tooltip: l10n.filter,
                        selected: ref.watch(doctorPrescriptionFilterProvider) !=
                            DoctorPrescriptionFilter.all,
                        onSelected: (value) {
                          ref
                              .read(doctorPrescriptionFilterProvider.notifier)
                              .state = value;
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: DoctorPrescriptionFilter.all,
                            child: Text(l10n.allPrescriptions),
                          ),
                          PopupMenuItem(
                            value: DoctorPrescriptionFilter.doctor,
                            child: Text(l10n.doctor),
                          ),
                          PopupMenuItem(
                            value: DoctorPrescriptionFilter.hospital,
                            child: Text(l10n.hospital),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      _CircleMenuButton<DoctorPrescriptionSort>(
                        icon: toolbarSortIcon,
                        tooltip: l10n.sort,
                        selected: ref.watch(doctorPrescriptionSortProvider) !=
                            DoctorPrescriptionSort.newestFirst,
                        onSelected: (value) {
                          ref
                              .read(doctorPrescriptionSortProvider.notifier)
                              .state = value;
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: DoctorPrescriptionSort.newestFirst,
                            child: Text(l10n.newestFirst),
                          ),
                          PopupMenuItem(
                            value: DoctorPrescriptionSort.oldestFirst,
                            child: Text(l10n.oldestFirst),
                          ),
                          PopupMenuItem(
                            value: DoctorPrescriptionSort.titleAscending,
                            child: Text(l10n.titleAscending),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: prescriptions.when(
                    data: (list) => _buildList(list),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => _buildError(error),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNoProfile() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActiveProfile,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createProfileFirst,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<DoctorPrescription> prescriptions) {
    final l10n = AppLocalizations.of(context)!;

    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _showArchived
                  ? l10n.noArchivedPrescriptions
                  : l10n.noDoctorPrescriptions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _showArchived
                  ? l10n.noArchivedPrescriptionsDesc
                  : l10n.noDoctorPrescriptionsDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!_showArchived) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.recordsPrescriptionsAdd),
                icon: const Icon(Icons.add),
                label: Text(l10n.addDoctorPrescription),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return _PrescriptionListTile(prescription: prescription);
      },
    );
  }

  Widget _buildError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoadingPrescriptions,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ref.invalidate(doctorPrescriptionSearchQueryProvider);
              ref.invalidate(doctorPrescriptionFilterProvider);
              ref.invalidate(doctorPrescriptionSortProvider);
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _CircleMenuButton<T> extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final ValueChanged<T> onSelected;
  final List<PopupMenuEntry<T>> Function(BuildContext context) itemBuilder;

  const _CircleMenuButton({
    required this.icon,
    required this.tooltip,
    this.selected = false,
    required this.onSelected,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      child: Semantics(
        label: tooltip,
        button: true,
        selected: selected,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? colorScheme.secondaryContainer
                  : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: selected ? colorScheme.secondary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: selected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionListTile extends StatelessWidget {
  final DoctorPrescription prescription;

  const _PrescriptionListTile({required this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: const _PrescriptionIcon(),
        title: Tooltip(
          message: prescription.title,
          child: Text(
            prescription.title,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDate(context, prescription.prescriptionDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (prescription.reason != null &&
                prescription.reason!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                prescription.reason!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prescription.doctorContactId != null ||
                prescription.clinicContactId != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.local_hospital_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        onTap: () => context.push(
          AppRoutes.recordsPrescriptionsDetails(prescription.id!),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final formatter = AppDateFormatter.of(context);
    final now = DateTime.now();
    final diff = date.difference(now).inDays.abs();

    if (diff == 0) {
      return l10n.today;
    } else if (diff == 1) {
      return l10n.tomorrow;
    } else if (diff < 7) {
      return formatter.formatWeekday(date);
    } else {
      return formatter.formatMediumDate(date);
    }
  }
}

class _PrescriptionIcon extends StatelessWidget {
  const _PrescriptionIcon();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.teal.withValues(alpha: 0.1),
      child: const Icon(Icons.description_outlined, color: Colors.teal, size: 20),
    );
  }
}