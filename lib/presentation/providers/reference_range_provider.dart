import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/profile_reference_range.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

final profileReferenceRangesProvider = StreamProvider.autoDispose
    .family<List<ProfileReferenceRange>, int>((ref, profileId) {
  final repo = ref.watch(referenceRangeRepositoryProvider);
  return repo.watchProfileRanges(profileId);
});

final effectiveRangesProvider = FutureProvider.autoDispose
    .family<MeasurementRanges?, ({int profileId, String typeKey})>(
      (ref, params) async {
        final repo = ref.watch(referenceRangeRepositoryProvider);
        return repo.getEffectiveRanges(params.profileId, params.typeKey);
      },
    );

final effectiveRangesForCurrentProfileProvider = FutureProvider.autoDispose
    .family<MeasurementRanges?, String>((ref, typeKey) async {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return null;
  final repo = ref.watch(referenceRangeRepositoryProvider);
  return repo.getEffectiveRanges(profileId, typeKey);
});
