import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/medication_provider.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_card.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final medicationsAsync = ref.watch(medicationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medications),
      ),
      body: medicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(l10n.error, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(medicationListProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (medications) {
          if (medications.isEmpty) {
            return EmptyState(
              icon: Icons.medication_outlined,
              title: l10n.noMedicationsYet,
              subtitle: l10n.addFirstMedication,
              actionLabel: l10n.addMedication,
              onAction: () => context.push('/activities/medication/add'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return MedicationCard(
                medication: medication,
                onTap: () => context.push(
                  '/activities/medication/${medication.id}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/activities/medication/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
