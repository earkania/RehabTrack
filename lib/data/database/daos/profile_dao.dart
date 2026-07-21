import 'package:drift/drift.dart';
import 'package:rehab_track/data/database/app_database.dart';
import 'package:rehab_track/data/database/tables/profile_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfileDao extends DatabaseAccessor<AppDatabase>
    with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Stream<Profile?> watchActiveProfile() {
    return (select(profiles)
      ..limit(1)).watchSingleOrNull();
  }

  Future<Profile?> getActiveProfile() {
    return (select(profiles)
      ..limit(1)).getSingleOrNull();
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
}
