import 'package:rehab_track/domain/entities/profile.dart';

abstract class ProfileRepository {
  Stream<Profile?> watchActiveProfile();
  Future<Profile?> getActiveProfile();
  Future<int> createProfile(Profile profile);
  Future<void> updateProfile(Profile profile);
  Future<void> deleteProfile(int id);
}
