import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/doctor_prescription_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

/// Archived Doctor Prescriptions screen
class ArchivedDoctorPrescriptionsScreen extends ConsumerWidget {
  const ArchivedDoctorPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeProfileId = ref.watch(currentActiveProfileIdProvider);

    final prescriptions = ref
        .watch(archivedDoctorPrescriptionsProvider(activeProfileId ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archivedPrescriptions),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.recordsPrescriptions),
        ),
      ),
      body: activeProfileId == null
          ? _buildNoProfile(context)
          : prescriptions.when(
              data: (list) => _buildList(context, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildError(context, ref, error),
            ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
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

  Widget _buildList(BuildContext context, List<DoctorPrescription> list) {
    final l10n = AppLocalizations.of(context)!;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noArchivedPrescriptions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noArchivedPrescriptionsDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final prescription = list[index];
        return _ArchivedPrescriptionTile(prescription: prescription);
      },
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
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

class _ArchivedPrescriptionTile extends ConsumerWidget {
  final DoctorPrescription prescription;

  const _ArchivedPrescriptionTile({required this.prescription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: const _PrescriptionTileIcon(),
        title: Tooltip(
          message: prescription.title,
          child: Text(
            prescription.title,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(prescription.prescriptionDate),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final profileId =
                ref.read(currentActiveProfileIdProvider);
            if (profileId == null) return;
            final repo = ref.read(doctorPrescriptionRepositoryProvider);
            final l10n = AppLocalizations.of(context)!;
            if (value == 'restore') {
              await repo.restorePrescription(prescription.id!, profileId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.prescriptionRestored)),
                );
              }
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteDoctorPrescription),
                  content: Text(l10n.confirmDeletePrescription),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                      ),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await repo.deletePrescription(prescription.id!, profileId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.prescriptionDeleted)),
                  );
                }
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'restore',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.unarchive_outlined, size: 20),
                title: Text(AppLocalizations.of(context)!.restorePrescription),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  AppLocalizations.of(context)!.deleteDoctorPrescription,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
        onTap: () => context.push(
          AppRoutes.recordsPrescriptionsDetails(prescription.id!),
        ),
      ),
    );
  }
}

class _PrescriptionTileIcon extends StatelessWidget {
  const _PrescriptionTileIcon();

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.teal.withValues(alpha: 0.1),
      child:
          const Icon(Icons.description_outlined, color: Colors.teal, size: 20),
    );
  }
}