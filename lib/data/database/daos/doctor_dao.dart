import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/doctor_tables.dart';

part 'doctor_dao.g.dart';

@DriftAccessor(tables: [Doctors, DoctorVisits])
class DoctorDao extends DatabaseAccessor<AppDatabase>
    with _$DoctorDaoMixin {
  DoctorDao(super.db);

  Stream<List<Doctor>> watchDoctors(int profileId) {
    return (select(doctors)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.lastName),
        (t) => OrderingTerm.asc(t.firstName),
      ])).watch();
  }

  Future<List<Doctor>> getDoctors(int profileId) {
    return (select(doctors)
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.lastName),
      ])).get();
  }

  Future<Doctor?> getDoctor(int id) {
    return (select(doctors)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertDoctor(DoctorsCompanion entry) {
    return into(doctors).insert(entry);
  }

  Future<bool> updateDoctor(DoctorsCompanion entry) {
    return update(doctors).replace(entry);
  }

  Future<int> deleteDoctor(int id) {
    return (delete(doctors)
      ..where((t) => t.id.equals(id))).go();
  }

  Stream<List<DoctorVisit>> watchVisits(
    int profileId, {
    bool upcomingOnly = false,
  }) {
    final query = select(doctorVisits)
      ..where((t) => t.profileId.equals(profileId));
    if (upcomingOnly) {
      query.where(
        (t) =>
            t.visitDate.isBiggerOrEqualValue(DateTime.now()),
      );
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.visitDate),
    ]);
    return query.watch();
  }

  Future<List<DoctorVisit>> getVisits(
    int profileId, {
    bool upcomingOnly = false,
  }) {
    final query = select(doctorVisits)
      ..where((t) => t.profileId.equals(profileId));
    if (upcomingOnly) {
      query.where(
        (t) =>
            t.visitDate.isBiggerOrEqualValue(DateTime.now()),
      );
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.visitDate),
    ]);
    return query.get();
  }

  Future<int> insertVisit(DoctorVisitsCompanion entry) {
    return into(doctorVisits).insert(entry);
  }

  Future<bool> updateVisit(DoctorVisitsCompanion entry) {
    return update(doctorVisits).replace(entry);
  }

  Future<int> deleteVisit(int id) {
    return (delete(doctorVisits)
      ..where((t) => t.id.equals(id))).go();
  }
}
