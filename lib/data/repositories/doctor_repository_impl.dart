import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/doctor.dart';
import 'package:rehab_track/domain/repositories/doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final db.AppDatabase _database;

  DoctorRepositoryImpl(this._database);

  @override
  Stream<List<Doctor>> watchDoctors(int profileId) {
    return _database.doctorDao
        .watchDoctors(profileId)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Doctor>> getDoctors(int profileId) async {
    final rows =
        await _database.doctorDao.getDoctors(profileId);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<Doctor?> getDoctor(int id) async {
    final row = await _database.doctorDao.getDoctor(id);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<int> createDoctor(Doctor doctor) async {
    return _database.doctorDao.insertDoctor(
      db.DoctorsCompanion.insert(
        profileId: doctor.profileId,
        firstName: doctor.firstName,
        lastName: doctor.lastName,
        specialty: Value(doctor.specialty),
        phone: Value(doctor.phone),
        email: Value(doctor.email),
        clinic: Value(doctor.clinic),
        notes: Value(doctor.notes),
      ),
    );
  }

  @override
  Future<void> updateDoctor(Doctor doctor) async {
    await _database.doctorDao.updateDoctor(
      db.DoctorsCompanion(
        id: Value(doctor.id!),
        profileId: Value(doctor.profileId),
        firstName: Value(doctor.firstName),
        lastName: Value(doctor.lastName),
        specialty: Value(doctor.specialty),
        phone: Value(doctor.phone),
        email: Value(doctor.email),
        clinic: Value(doctor.clinic),
        notes: Value(doctor.notes),
      ),
    );
  }

  @override
  Future<void> deleteDoctor(int id) async {
    await _database.doctorDao.deleteDoctor(id);
  }

  @override
  Stream<List<DoctorVisit>> watchVisits(
    int profileId, {
    bool upcomingOnly = false,
  }) {
    return _database.doctorDao
        .watchVisits(profileId, upcomingOnly: upcomingOnly)
        .map((rows) => rows.map(_visitToDomain).toList());
  }

  @override
  Future<List<DoctorVisit>> getVisits(
    int profileId, {
    bool upcomingOnly = false,
  }) async {
    final rows = await _database.doctorDao.getVisits(
      profileId,
      upcomingOnly: upcomingOnly,
    );
    return rows.map(_visitToDomain).toList();
  }

  @override
  Future<int> createVisit(DoctorVisit visit) async {
    return _database.doctorDao.insertVisit(
      db.DoctorVisitsCompanion.insert(
        profileId: visit.profileId,
        doctorId: visit.doctorId,
        visitDate: visit.visitDate,
        status: visit.status,
        reason: Value(visit.reason),
        notes: Value(visit.notes),
        reminderEnabled: Value(visit.reminderEnabled),
        reminderMinutesBefore:
            Value(visit.reminderMinutesBefore),
      ),
    );
  }

  @override
  Future<void> updateVisit(DoctorVisit visit) async {
    await _database.doctorDao.updateVisit(
      db.DoctorVisitsCompanion(
        id: Value(visit.id!),
        profileId: Value(visit.profileId),
        doctorId: Value(visit.doctorId),
        visitDate: Value(visit.visitDate),
        status: Value(visit.status),
        reason: Value(visit.reason),
        notes: Value(visit.notes),
        reminderEnabled: Value(visit.reminderEnabled),
        reminderMinutesBefore:
            Value(visit.reminderMinutesBefore),
      ),
    );
  }

  @override
  Future<void> deleteVisit(int id) async {
    await _database.doctorDao.deleteVisit(id);
  }

  Doctor _toDomain(db.Doctor row) {
    return Doctor(
      id: row.id,
      profileId: row.profileId,
      firstName: row.firstName,
      lastName: row.lastName,
      specialty: row.specialty,
      phone: row.phone,
      email: row.email,
      clinic: row.clinic,
      notes: row.notes,
    );
  }

  DoctorVisit _visitToDomain(db.DoctorVisit row) {
    return DoctorVisit(
      id: row.id,
      profileId: row.profileId,
      doctorId: row.doctorId,
      visitDate: row.visitDate,
      status: row.status,
      reason: row.reason,
      notes: row.notes,
      reminderEnabled: row.reminderEnabled,
      reminderMinutesBefore: row.reminderMinutesBefore,
    );
  }
}
