import 'package:rehab_track/domain/entities/doctor.dart';

abstract class DoctorRepository {
  Stream<List<Doctor>> watchDoctors(int profileId);
  Future<List<Doctor>> getDoctors(int profileId);
  Future<Doctor?> getDoctor(int id);
  Future<int> createDoctor(Doctor doctor);
  Future<void> updateDoctor(Doctor doctor);
  Future<void> deleteDoctor(int id);

  Stream<List<DoctorVisit>> watchVisits(
    int profileId, {
    bool upcomingOnly = false,
  });
  Future<List<DoctorVisit>> getVisits(
    int profileId, {
    bool upcomingOnly = false,
  });
  Future<int> createVisit(DoctorVisit visit);
  Future<void> updateVisit(DoctorVisit visit);
  Future<void> deleteVisit(int id);
}
