class AppRoutes {
  AppRoutes._();

  // Bottom-navigation destinations
  static const home = '/';
  static const health = '/health';
  static const records = '/records';
  static const profile = '/profile';
  static const settings = '/settings';

  // Settings
  static const settingsApp = '/settings/app';
  static const settingsBackupRestore = '/settings/backup-restore';

  // Health
  static const healthMedications = '/health/medications';
  static const healthMeasurements = '/health/measurements';
  static const healthActivities = '/health/activities';
  static const healthDiet = '/health/diet';

  // Records
  static const recordsLabAnalyses = '/records/lab-analyses';
  static const recordsLabAnalysesAdd = '/records/lab-analyses/new';
  static const recordsLabAnalysesArchived = '/records/lab-analyses/archived';
  static String recordsLabAnalysesDetails(int id) => '/records/lab-analyses/$id';
  static String recordsLabAnalysesEdit(int id) => '/records/lab-analyses/$id/edit';
  static const recordsDoctorVisits = '/records/doctor-visits';
  static const recordsReports = '/records/reports';

  // Doctor Visits
  static const doctorVisitAdd = '/records/doctor-visits/add';
  static String doctorVisitDetails(int id) => '/records/doctor-visits/$id';
  static String doctorVisitEdit(int id) => '/records/doctor-visits/$id/edit';

  // Profile
  static const patientProfile = '/profile/patient';
  static const patientProfileEdit = '/profile/patient/edit';
  static const profileDoctors = '/profile/doctors';
  static const profileEmergencyContacts = '/profile/emergency-contacts';
  static const profileMedicalNotes = '/profile/medical-notes';

  // Care Contacts
  static const profileCareContacts = '/profile/contacts';
  static const careContactArchived = '/profile/contacts/archived';
  static const careContactAdd = '/profile/contacts/new';
  static String careContactDetails(int id) => '/profile/contacts/$id';
  static String careContactEdit(int id) => '/profile/contacts/$id/edit';

  // Measurements (deep links)
  static String measurementAdd(int typeId) => '/measurements/measurement/$typeId/add';
  static String measurementHistory(int typeId) => '/measurements/measurement/$typeId/history';
  static String measurementEdit(int recordId) =>
      '/measurements/measurement/record/$recordId/edit';
  static String measurementTrends(int typeId) =>
      '/measurements/measurement/$typeId/trends';
  static const measurementRanges = '/measurements/ranges';
  static String measurementScheduleAdd(int typeId) =>
      '/measurements/measurement/$typeId/schedule/add';
  static String measurementScheduleList(int typeId) =>
      '/measurements/measurement/$typeId/schedules';
  static String measurementScheduleEdit(int typeId, int scheduleId) =>
      '/measurements/measurement/$typeId/schedule/$scheduleId/edit';
  // Medications (deep links)
  static const medicationAdd = '/medications/medication/add';
  static String medicationDetail(int id) => '/medications/medication/$id';
  static String medicationEdit(int id) => '/medications/medication/$id/edit';
  static String medicationHistory(int id) => '/medications/medication/$id/history';
  static String scheduleAdd(int medicationId) => '/medications/medication/$medicationId/schedule/add';
  static String scheduleEdit(int medicationId, int scheduleId) =>
      '/medications/medication/$medicationId/schedule/$scheduleId/edit';
  static String alternativeAdd(int medicationId) => '/medications/medication/$medicationId/alternative/add';
  static String alternativeEdit(int medicationId, int alternativeId) =>
      '/medications/medication/$medicationId/alternative/$alternativeId/edit';
}

class RecordNowExtra {
  final DateTime scheduledOccurrenceTime;
  final int reminderScheduleId;

  const RecordNowExtra({
    required this.scheduledOccurrenceTime,
    required this.reminderScheduleId,
  });
}

class _OldRoutes {
  static const measurements = '/measurements';
  static const medications = '/medications';
  static const activities = '/activities';
  static const patientProfile = '/settings/patient-profile';
  static const patientProfileEdit = '/settings/patient-profile/edit';

  static bool isTabPath(String location, String path) =>
      location == path || location == '$path/';
}

class RouteRedirector {
  static String? redirect(String location) {
    // Legacy bottom-navigation tab paths → new canonical destinations.
    if (_OldRoutes.isTabPath(location, _OldRoutes.measurements)) {
      return AppRoutes.healthMeasurements;
    }
    if (_OldRoutes.isTabPath(location, _OldRoutes.medications)) {
      return AppRoutes.healthMedications;
    }
    if (_OldRoutes.isTabPath(location, _OldRoutes.activities)) {
      return AppRoutes.healthMedications;
    }
    // Legacy patient-profile paths → Profile dashboard.
    if (_OldRoutes.isTabPath(location, _OldRoutes.patientProfile)) {
      return AppRoutes.patientProfile;
    }
    if (_OldRoutes.isTabPath(location, _OldRoutes.patientProfileEdit)) {
      return AppRoutes.patientProfileEdit;
    }
    return null;
  }
}
