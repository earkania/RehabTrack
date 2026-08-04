import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/data/services/notification/doctor_visit_reminder_service.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/notification_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/reminder_settings_provider.dart';

/// Open (still scheduled) doctor visits for the active profile.
final doctorVisitUpcomingProvider =
    StreamProvider.autoDispose<List<DoctorVisitRecord>>((ref) {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  if (profileId == null) return Stream.value(const []);
  return ref
      .watch(doctorVisitRepositoryProvider)
      .watchUpcomingVisits(profileId);
});

/// Terminal (completed / cancelled / missed) doctor visits for the active
/// profile, most recent first.
final doctorVisitHistoryProvider =
    StreamProvider.autoDispose<List<DoctorVisitRecord>>((ref) {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  if (profileId == null) return Stream.value(const []);
  return ref
      .watch(doctorVisitRepositoryProvider)
      .watchVisitHistory(profileId);
});

/// Watches a single visit scoped to the active profile.
final doctorVisitByIdProvider =
    StreamProvider.autoDispose.family<DoctorVisitRecord?, int>((ref, visitId) {
  final profileId = ref.watch(currentActiveProfileIdProvider);
  if (profileId == null) return Stream.value(null);
  return ref
      .watch(doctorVisitRepositoryProvider)
      .watchVisitById(profileId, visitId);
});

/// Number of open upcoming visits — used for the Records dashboard badge.
final upcomingDoctorVisitCountProvider =
    Provider.autoDispose<int>((ref) {
  return ref.watch(doctorVisitUpcomingProvider).valueOrNull?.length ?? 0;
});

/// Combined active + archived contact lookup for the active profile, keyed by
/// contact id. Deleted contacts are simply absent from the map, letting the UI
/// show a localized "contact not available" fallback without crashing.
final careContactLookupProvider = Provider.autoDispose<Map<int, CareContact>>(
  (ref) {
    final active = ref.watch(careContactsProvider).valueOrNull ?? const [];
    final archived =
        ref.watch(archivedCareContactsProvider).valueOrNull ?? const [];
    final map = <int, CareContact>{};
    for (final c in [...active, ...archived]) {
      if (c.id != null) map[c.id!] = c;
    }
    return map;
  },
);

/// Schedules and cancels Doctor Visit reminder notifications.
final doctorVisitReminderServiceProvider =
    Provider<DoctorVisitReminderService>((ref) {
  return DoctorVisitReminderService(
    notificationService: ref.watch(notificationServiceProvider),
    notificationScheduler: ref.watch(notificationSchedulerProvider),
    careContactRepository: ref.watch(careContactRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    showProfileName: () => ref.read(showPatientNameInNotificationsProvider),
  );
});
