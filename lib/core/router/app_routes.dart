class AppRoutes {
  AppRoutes._();

  static const home = '/';
  static const measurements = '/measurements';
  static const medications = '/medications';
  static const records = '/records';
  static const settings = '/settings';

  // Measurements
  static String measurementAdd(int typeId) => '/measurements/measurement/$typeId/add';
  static String measurementHistory(int typeId) => '/measurements/measurement/$typeId/history';
  static String measurementEdit(int recordId) => '/measurements/measurement/record/$recordId/edit';
  static const measurementRanges = '/measurements/ranges';

  // Medications
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

class _OldRoutes {
  static const health = '/health';
  static const activities = '/activities';

  static bool isHealthRoute(String location) => location.startsWith(health);
  static bool isActivitiesRoute(String location) => location.startsWith(activities);
}

class RouteRedirector {
  static String? redirect(String location) {
    // /health → /measurements
    if (_OldRoutes.isHealthRoute(location)) {
      return location.replaceFirst(_OldRoutes.health, AppRoutes.measurements);
    }
    // /activities → /medications
    if (_OldRoutes.isActivitiesRoute(location)) {
      return location.replaceFirst(_OldRoutes.activities, AppRoutes.medications);
    }
    return null;
  }
}
