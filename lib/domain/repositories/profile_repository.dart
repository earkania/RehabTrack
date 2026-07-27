import 'package:rehab_track/domain/entities/profile.dart';

abstract class ProfileRepository {
  Stream<Profile?> watchActiveProfile(int profileId);
  Future<Profile?> getActiveProfile(int profileId);
  Future<int> createProfile(Profile profile);
  Future<void> updateProfile(Profile profile);
  Future<void> deleteProfile(int id);
  Stream<List<Profile>> watchAllProfiles();
  Future<List<Profile>> getAllProfiles();
  Future<void> setPrimaryProfile(int profileId);
  Future<int> getProfileCount();
}
