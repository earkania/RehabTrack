import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfileDao extends DatabaseAccessor<AppDatabase>
    with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Stream<Profile?> watchActiveProfile(int profileId) {
    return (select(profiles)
      ..where((t) => t.id.equals(profileId))
      ..limit(1)).watchSingleOrNull();
  }

  Future<Profile?> getActiveProfile(int profileId) {
    return (select(profiles)
      ..where((t) => t.id.equals(profileId))
      ..limit(1)).getSingleOrNull();
  }

  Stream<List<Profile>> watchAllProfiles() {
    return (select(profiles)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.isPrimary), (t) => OrderingTerm.asc(t.firstName)])
    ).watch();
  }

  Future<List<Profile>> getAllProfiles() {
    return (select(profiles)
      ..where((t) => t.isActive.equals(true))
      ..orderBy([(t) => OrderingTerm.desc(t.isPrimary), (t) => OrderingTerm.asc(t.firstName)])
    ).get();
  }

  Future<int> insertProfile(ProfilesCompanion entry) {
    return into(profiles).insert(entry);
  }

  Future<bool> updateProfile(ProfilesCompanion entry) {
    return update(profiles).replace(entry);
  }

  Future<int> deleteProfile(int id) {
    return (delete(profiles)
      ..where((t) => t.id.equals(id))).go();
  }

  Future<void> setPrimaryProfile(int profileId) async {
    await transaction(() async {
      await (update(profiles)..where((t) => t.isPrimary.equals(true)))
          .write(const ProfilesCompanion(isPrimary: Value(false)));
      await (update(profiles)..where((t) => t.id.equals(profileId)))
          .write(const ProfilesCompanion(isPrimary: Value(true)));
    });
  }

  Future<int> getProfileCount() async {
    final query = selectOnly(profiles)
      ..addColumns([profiles.id.count()]);
    final result = await query.getSingle();
    return result.read(profiles.id.count()) ?? 0;
  }
}
