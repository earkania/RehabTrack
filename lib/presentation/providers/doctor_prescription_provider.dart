import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rehab_track/data/database/daos/doctor_prescription_dao.dart';
import 'package:rehab_track/data/repositories/doctor_prescription_repository_impl.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/repositories/doctor_prescription_repository.dart';

import 'database_provider.dart';

/// Provider for DoctorPrescriptionDao
final doctorPrescriptionDaoProvider = Provider<DoctorPrescriptionDao>((ref) {
  final database = ref.watch(databaseProvider);
  return database.doctorPrescriptionDao;
});

/// Provider for DoctorPrescriptionRepository
final doctorPrescriptionRepositoryProvider =
    Provider<DoctorPrescriptionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DoctorPrescriptionRepositoryImpl(database);
});

/// Active prescriptions for the current profile
final activeDoctorPrescriptionsProvider = StreamProvider.autoDispose
    .family<List<DoctorPrescription>, int>((ref, profileId) {
  final repository = ref.watch(doctorPrescriptionRepositoryProvider);
  return repository.watchActivePrescriptions(profileId);
});

/// Archived prescriptions for the current profile
final archivedDoctorPrescriptionsProvider = StreamProvider.autoDispose
    .family<List<DoctorPrescription>, int>((ref, profileId) {
  final repository = ref.watch(doctorPrescriptionRepositoryProvider);
  return repository.watchArchivedPrescriptions(profileId);
});

/// Search query for prescriptions
final doctorPrescriptionSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Filter for prescriptions: all / doctor / hospital / archived is handled
/// at the screen level (archived toggles the archived list). This holds the
/// type-wide filter for the active list.
enum DoctorPrescriptionFilter {
  all,
  doctor,
  hospital,
}

final doctorPrescriptionFilterProvider =
    StateProvider.autoDispose<DoctorPrescriptionFilter>(
  (ref) => DoctorPrescriptionFilter.all,
);

/// Search and filtered prescriptions for the current profile
final doctorPrescriptionSearchProvider = StreamProvider.autoDispose
    .family<List<DoctorPrescription>, int>((ref, profileId) {
  final repository = ref.watch(doctorPrescriptionRepositoryProvider);
  final query = ref.watch(doctorPrescriptionSearchQueryProvider);
  final filter = ref.watch(doctorPrescriptionFilterProvider);

  final base = repository.searchPrescriptions(
    profileId,
    query: query.isEmpty ? null : query,
  );

  return base.map((list) {
    switch (filter) {
      case DoctorPrescriptionFilter.all:
        return list;
      case DoctorPrescriptionFilter.doctor:
        return list.where((p) => p.doctorContactId != null).toList();
      case DoctorPrescriptionFilter.hospital:
        return list.where((p) => p.clinicContactId != null).toList();
    }
  });
});

/// Sort order for prescriptions
enum DoctorPrescriptionSort {
  newestFirst,
  oldestFirst,
  titleAscending,
}

/// Sort order provider
final doctorPrescriptionSortProvider =
    StateProvider.autoDispose<DoctorPrescriptionSort>(
  (ref) => DoctorPrescriptionSort.newestFirst,
);

/// Sorted prescriptions provider
final sortedDoctorPrescriptionsProvider =
    StreamProvider.autoDispose.family<List<DoctorPrescription>, int>(
        (ref, profileId) {
  final prescriptions = ref.watch(doctorPrescriptionSearchProvider(profileId));
  final sort = ref.watch(doctorPrescriptionSortProvider);

  return prescriptions.when(
    data: (list) {
      final sorted = List<DoctorPrescription>.from(list);
      switch (sort) {
        case DoctorPrescriptionSort.newestFirst:
          sorted.sort(
            (a, b) => b.prescriptionDate.compareTo(a.prescriptionDate),
          );
          break;
        case DoctorPrescriptionSort.oldestFirst:
          sorted.sort(
            (a, b) => a.prescriptionDate.compareTo(b.prescriptionDate),
          );
          break;
        case DoctorPrescriptionSort.titleAscending:
          sorted.sort((a, b) => a.title.compareTo(b.title));
          break;
      }
      return Stream.value(sorted);
    },
    loading: () => const Stream.empty(),
    error: (error, stack) => Stream.error(error),
  );
});

/// Single prescription by ID
final doctorPrescriptionByIdProvider = FutureProvider.autoDispose
    .family<DoctorPrescription?, ({int id, int profileId})>((ref, params) {
  final repository = ref.watch(doctorPrescriptionRepositoryProvider);
  return repository.getPrescription(params.id, params.profileId);
});

/// Attachments for a specific prescription
final doctorPrescriptionAttachmentsProvider = StreamProvider.autoDispose
    .family<List<DoctorPrescriptionAttachment>, int>((ref, prescriptionId) {
  final dao = ref.watch(doctorPrescriptionDaoProvider);
  return dao.watchAttachments(prescriptionId).map(
    (list) => list.map(DoctorPrescriptionAttachment.fromDb).toList(),
  );
});

/// Medications belonging to a specific prescription
final doctorPrescriptionMedicationsProvider = StreamProvider.autoDispose
    .family<List<DoctorPrescriptionMedication>, int>((ref, prescriptionId) {
  final repository = ref.watch(doctorPrescriptionRepositoryProvider);
  return repository.watchMedications(prescriptionId);
});