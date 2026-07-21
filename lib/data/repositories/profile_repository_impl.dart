import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/domain/entities/profile.dart';

import 'package:rehab_track/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final db.AppDatabase _database;

  ProfileRepositoryImpl(this._database);

  @override
  Stream<Profile?> watchActiveProfile() {
    return _database.profileDao.watchActiveProfile().map(
      (row) => row != null ? _toDomain(row) : null,
    );
  }

  @override
  Future<Profile?> getActiveProfile() async {
    final row = await _database.profileDao.getActiveProfile();
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<int> createProfile(Profile profile) async {
    return _database.profileDao.insertProfile(
      db.ProfilesCompanion.insert(
        firstName: profile.firstName,
        lastName: profile.lastName,
        birthDate: Value(profile.birthDate),
        gender: Value(profile.gender),
        heightCm: Value(profile.heightCm),
        weightKg: Value(profile.weightKg),
        bloodType: Value(profile.bloodType),
        allergies: Value(profile.allergies),
        emergencyContactName: Value(profile.emergencyContactName),
        emergencyContactPhone: Value(profile.emergencyContactPhone),
        notes: Value(profile.notes),
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      ),
    );
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    await _database.profileDao.updateProfile(
      db.ProfilesCompanion(
        id: Value(profile.id!),
        firstName: Value(profile.firstName),
        lastName: Value(profile.lastName),
        birthDate: Value(profile.birthDate),
        gender: Value(profile.gender),
        heightCm: Value(profile.heightCm),
        weightKg: Value(profile.weightKg),
        bloodType: Value(profile.bloodType),
        allergies: Value(profile.allergies),
        emergencyContactName: Value(profile.emergencyContactName),
        emergencyContactPhone: Value(profile.emergencyContactPhone),
        notes: Value(profile.notes),
        createdAt: Value(profile.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteProfile(int id) async {
    await _database.profileDao.deleteProfile(id);
  }

  Profile _toDomain(db.Profile row) {
    return Profile(
      id: row.id,
      firstName: row.firstName,
      lastName: row.lastName,
      birthDate: row.birthDate,
      gender: row.gender,
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      bloodType: row.bloodType,
      allergies: row.allergies,
      emergencyContactName: row.emergencyContactName,
      emergencyContactPhone: row.emergencyContactPhone,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
