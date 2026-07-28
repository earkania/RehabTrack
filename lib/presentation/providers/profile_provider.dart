import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/patient_profile_summary.dart';
import 'package:rehab_track/domain/entities/profile.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';

const _activeProfileIdKey = 'active_profile_id';
const _tag = 'ActiveProfile';

final activeProfileIdProvider =
    AsyncNotifierProvider<ActiveProfileIdNotifier, int?>(
  ActiveProfileIdNotifier.new,
);

class ActiveProfileIdNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async {
    final settings = ref.watch(settingsRepositoryProvider);
    final profiles = ref.watch(profileRepositoryProvider);

    // 1. Check existing setting
    final value = await settings.getValue(_activeProfileIdKey);
    if (value != null) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        developer.log('Using existing active profile ID: $parsed', name: _tag);
        return parsed;
      }
    }

    // 2. Find existing profiles
    final all = await profiles.getAllProfiles();
    developer.log('Found ${all.length} existing profile(s)', name: _tag);

    if (all.isNotEmpty) {
      // Prefer primary, then first alphabetically
      final primary = all.where((p) => p.isPrimary).toList();
      final selected = primary.isNotEmpty ? primary.first : all.first;
      final selectedId = selected.id!;
      await settings.setValue(_activeProfileIdKey, selectedId.toString());
      if (primary.isEmpty) {
        await profiles.setPrimaryProfile(selectedId);
      }
      developer.log(
        'Selected profile ID: $selectedId '
        '(isPrimary: ${selected.isPrimary})',
        name: _tag,
      );
      return selectedId;
    }

    // 3. No profiles exist — create default profile
    developer.log('No profiles found — creating default profile', name: _tag);
    try {
      final now = DateTime.now();
      final newId = await profiles.createProfile(
        Profile(
          firstName: '',
          lastName: '',
          createdAt: now,
          updatedAt: now,
          isPrimary: true,
          isActive: true,
        ),
      );
      await profiles.setPrimaryProfile(newId);
      await settings.setValue(_activeProfileIdKey, newId.toString());
      developer.log('Created default profile with ID: $newId', name: _tag);
      return newId;
    } catch (e, st) {
      developer.log(
        'Failed to create default profile: $e',
        name: _tag,
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<void> setActiveProfileId(int profileId) async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.setValue(_activeProfileIdKey, profileId.toString());
    ref.invalidateSelf();
  }
}

/// Watches a single profile by ID, emitting null when the row is absent.
final watchProfileByIdProvider = StreamProvider.family<Profile?, int>(
  (ref, profileId) {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.watchActiveProfile(profileId);
  },
);

/// Synchronous convenience provider that extracts the int? from the AsyncValue.
final currentActiveProfileIdProvider = Provider<int?>((ref) {
  final asyncValue = ref.watch(activeProfileIdProvider);
  return asyncValue.valueOrNull;
});

/// Builds a PatientProfileSummary for the currently active profile.
final patientProfileSummaryProvider =
    FutureProvider.autoDispose<PatientProfileSummary?>((ref) async {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  if (profileId == null) return null;

  final profileRepo = ref.watch(profileRepositoryProvider);
  final profile = await profileRepo.getActiveProfile(profileId);
  if (profile == null) return null;

  final medRepo = ref.watch(medicationRepositoryProvider);
  final measRepo = ref.watch(measurementRepositoryProvider);

  final activeMeds = await medRepo.watchActiveMedications(profileId).first;
  final activeSchedules =
      await measRepo.watchActiveSchedules(profileId).first;

  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  final recentRecords = await measRepo.getRecords(
    profileId,
    from: thirtyDaysAgo,
  );

  return PatientProfileSummary(
    profile: profile,
    activeMedicationCount: activeMeds.length,
    activeMeasurementScheduleCount: activeSchedules.length,
    totalMeasurementsLast30Days: recentRecords.length,
  );
});
