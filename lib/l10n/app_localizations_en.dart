// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RehabTrack';

  @override
  String get welcomeMessage => 'Welcome to RehabTrack';

  @override
  String get today => 'Today';

  @override
  String get health => 'Health';

  @override
  String get activities => 'Activities';

  @override
  String get records => 'Records';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get systemDefault => 'System default';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get security => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get disabled => 'Disabled';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get addFirstItem => 'Add your first item to get started';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get medications => 'Medications';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get description => 'Description';

  @override
  String get doseAmount => 'Dose Amount';

  @override
  String get doseUnit => 'Dose Unit';

  @override
  String get active => 'Active';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get notes => 'Notes';

  @override
  String get scheduleType => 'Schedule Type';

  @override
  String get dailySchedule => 'Daily';

  @override
  String get fixedTimesSchedule => 'Fixed Times';

  @override
  String get intervalSchedule => 'Interval Days';

  @override
  String get instructions => 'Instructions';

  @override
  String get alternatives => 'Alternatives';

  @override
  String get addAlternative => 'Add Alternative';

  @override
  String get doctorApproved => 'Doctor Approved';

  @override
  String get history => 'History';

  @override
  String get adherence => 'Adherence';

  @override
  String get taken => 'Taken';

  @override
  String get missed => 'Missed';

  @override
  String get skipped => 'Skipped';

  @override
  String get pending => 'Pending';

  @override
  String get noMedicationsYet => 'No medications yet';

  @override
  String get addFirstMedication => 'Add your first medication';

  @override
  String get scheduleAdded => 'Schedule added';

  @override
  String get scheduleDeleted => 'Schedule deleted';

  @override
  String get confirmDelete => 'Are you sure?';

  @override
  String get nextDose => 'Next dose';

  @override
  String get logDose => 'Log a dose';

  @override
  String get medicationAdded => 'Medication added';

  @override
  String get medicationUpdated => 'Medication updated';

  @override
  String get medicationDeleted => 'Medication deleted';

  @override
  String get addSchedule => 'Add Schedule';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String dailyAt(String time) {
    return 'Daily at $time';
  }

  @override
  String fixedTimes(String times) {
    return 'Fixed times: $times';
  }

  @override
  String everyNDays(int count, String time) {
    return 'Every $count days at $time';
  }

  @override
  String get beforeMeal => 'Before meal';

  @override
  String get afterMeal => 'After meal';

  @override
  String get withMeal => 'With meal';

  @override
  String get emptyStomach => 'On empty stomach';

  @override
  String get beforeBedtime => 'Before bedtime';

  @override
  String get morningOnly => 'Morning only';

  @override
  String get noSchedulesYet => 'No schedules yet';

  @override
  String get noAlternativesYet => 'No alternatives yet';

  @override
  String get addScheduleToMedication => 'Add a schedule for this medication';

  @override
  String get days => 'days';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get confirmDeactivate =>
      'This medication will be deactivated. Schedules and history will be preserved.';

  @override
  String get invalidRoute => 'Invalid page';

  @override
  String get schedules => 'Schedules';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get deleteScheduleConfirmation =>
      'Remove this schedule? Notifications will be cancelled.';

  @override
  String get selectTime => 'Select Time';

  @override
  String get addTime => 'Add Time';

  @override
  String get removeTime => 'Remove';

  @override
  String get intervalDays => 'Interval (days)';

  @override
  String get atLeastOneTimeRequired => 'At least one time is required';

  @override
  String get duplicateTimesNotAllowed => 'Duplicate times are not allowed';

  @override
  String get invalidInterval => 'Interval must be between 1 and 30';

  @override
  String get failedToSaveSchedule => 'Failed to save schedule';

  @override
  String get failedToDeleteSchedule => 'Failed to delete schedule';

  @override
  String get schedulesSection => 'Schedules';

  @override
  String get addScheduleSubtitle => 'Set up reminders for this medication';

  @override
  String get editAlternative => 'Edit Alternative';

  @override
  String get deleteAlternative => 'Delete Alternative';

  @override
  String get deleteAlternativeConfirmation =>
      'Remove this alternative? This will not affect the medication or its schedules.';

  @override
  String get alternativeAdded => 'Alternative added';

  @override
  String get alternativeUpdated => 'Alternative updated';

  @override
  String get alternativeDeleted => 'Alternative deleted';

  @override
  String get noAlternatives => 'No alternatives';

  @override
  String get noAlternativesDescription =>
      'Add doctor-approved substitutes for this medication';

  @override
  String get alternativesSection => 'Alternatives';

  @override
  String get genericSubstitute => 'Generic substitute';

  @override
  String get confirmDeleteAlternative =>
      'Are you sure you want to delete this alternative?';
}
