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
  String get actionFailed => 'Could not complete action';

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
  String get dailyScheduleDescription => 'Take at specified times every day';

  @override
  String get everyNDaysSchedule => 'Every N Days';

  @override
  String get everyNDaysScheduleDescription =>
      'Take at specified times every N days';

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
  String dailyAt(String times) {
    return 'Daily at $times';
  }

  @override
  String everyNDays(int count, String times) {
    return 'Every $count days at $times';
  }

  @override
  String get intakeQuantity => 'Intake Quantity';

  @override
  String get perIntake => 'per intake';

  @override
  String get dosageForm => 'Dosage Form';

  @override
  String get tablet => 'tablet';

  @override
  String get capsule => 'capsule';

  @override
  String get drop => 'drop';

  @override
  String get ml => 'ml';

  @override
  String get puff => 'puff';

  @override
  String get unit => 'Unit';

  @override
  String get sachet => 'sachet';

  @override
  String get spoon => 'spoon';

  @override
  String get injection => 'injection';

  @override
  String get topical => 'Apply';

  @override
  String get other => 'Other';

  @override
  String get customDosageForm => 'Custom dosage form name';

  @override
  String get customDosageFormRequired => 'Custom dosage form name is required';

  @override
  String get invalidIntakeQuantity => 'Enter a valid intake quantity';

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
      'Are you sure you want to delete this schedule?';

  @override
  String get selectTime => 'Select Time';

  @override
  String get addTime => 'Add Time';

  @override
  String get scheduledTime => 'Scheduled Time';

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
  String get addScheduleSubtitle => 'Add a schedule to get reminders';

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

  @override
  String get historySection => 'History & Adherence';

  @override
  String get historyScreenTitle => 'Medication History';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get allTime => 'All Time';

  @override
  String adherencePercentage(double percentage) {
    return '$percentage%';
  }

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get noLogsDescription =>
      'Log doses to track your medication adherence';

  @override
  String get logDoseNow => 'Log Dose';

  @override
  String get selectStatus => 'Select Status';

  @override
  String get doseNotes => 'Notes (optional)';

  @override
  String get doseLogged => 'Dose logged';

  @override
  String get logDoseError => 'Failed to log dose';

  @override
  String get totalDoses => 'Total Doses';

  @override
  String get completedDoses => 'Completed';

  @override
  String get adherenceRate => 'Adherence Rate';

  @override
  String get doseHistory => 'Dose History';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noHistoryDescription =>
      'Your medication log history will appear here';

  @override
  String scheduledFor(String time) {
    return 'Scheduled for $time';
  }

  @override
  String takenAt(String time) {
    return 'Taken at $time';
  }

  @override
  String get nameRequired => 'Name is required';

  @override
  String get invalidDose => 'Invalid dose amount';

  @override
  String get endDateBeforeStartDate =>
      'End date must be on or after start date';

  @override
  String get scheduleUpdated => 'Schedule updated';

  @override
  String get noSchedulesAvailable => 'No schedules available to log a dose';

  @override
  String get dosageComponents => 'Dosage Components';

  @override
  String get addComponent => 'Add Component';

  @override
  String get removeComponent => 'Remove component';

  @override
  String get componentName => 'Component Name';

  @override
  String get componentNameOptional => 'Component Name (optional)';

  @override
  String get measurements => 'Measurements';

  @override
  String get measurementTypes => 'Measurement Types';

  @override
  String get addMeasurement => 'Add Measurement';

  @override
  String get editMeasurement => 'Edit Measurement';

  @override
  String get measurementHistory => 'Measurement History';

  @override
  String get measuredAt => 'Measured at';

  @override
  String get latestReading => 'Latest reading';

  @override
  String get noMeasurementsYet => 'No measurement types available';

  @override
  String get noReadingsYet => 'No readings yet';

  @override
  String get addFirstReading => 'Add your first reading';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get systolic => 'Systolic';

  @override
  String get diastolic => 'Diastolic';

  @override
  String get pulse => 'Pulse';

  @override
  String get weight => 'Weight';

  @override
  String get bloodGlucose => 'Blood Glucose';

  @override
  String get spo2 => 'SpO2';

  @override
  String get temperature => 'Temperature';

  @override
  String get irregularHeartbeat => 'Irregular heartbeat';

  @override
  String get pulseLabel => 'pulse';

  @override
  String get fieldName => 'Field Name';

  @override
  String get requiredField => 'Required';

  @override
  String get minimumValue => 'Minimum Value';

  @override
  String get maximumValue => 'Maximum Value';

  @override
  String get invalidMeasurementValue => 'Invalid measurement value';

  @override
  String get failedToSaveMeasurement => 'Failed to save measurement';

  @override
  String get measurementAdded => 'Measurement added';

  @override
  String get measurementUpdated => 'Measurement updated';

  @override
  String get measurementDeleted => 'Measurement deleted';

  @override
  String get confirmDeleteMeasurement =>
      'Are you sure you want to delete this reading?';

  @override
  String get readingSaved => 'Reading saved';

  @override
  String get readingUpdated => 'Reading updated';

  @override
  String get readingDeleted => 'Reading deleted';

  @override
  String get noMeasurementsHistory => 'No history yet';

  @override
  String get noMeasurementsHistoryDescription =>
      'Your measurement history will appear here';

  @override
  String get measurementValue => 'Value';

  @override
  String get measurementUnit => 'Unit';

  @override
  String get selectMeasurementType => 'Select measurement type';

  @override
  String get addReading => 'Add Reading';

  @override
  String get addReadingTooltip => 'Add Reading';

  @override
  String get viewHistory => 'History';

  @override
  String get valueRequired => 'Value is required';

  @override
  String get mustBePositive => 'Value must be positive';

  @override
  String get systolicGreaterThanDiastolic =>
      'Systolic should be greater than diastolic';

  @override
  String get withinRange => 'Within range';

  @override
  String get aboveRange => 'Above range';

  @override
  String get belowRange => 'Below range';

  @override
  String get noReferenceRange => 'No reference range';

  @override
  String get readingStatusLegend => 'Reading Status';

  @override
  String get referenceRange => 'Reference Range';

  @override
  String get legendWithinRangeDescription => 'Within configured range';

  @override
  String get legendAboveRangeDescription => 'Above configured range';

  @override
  String get legendBelowRangeDescription => 'Below configured range';

  @override
  String get legendNoReferenceRangeDescription =>
      'No reference range configured';

  @override
  String get legendIrregularHeartbeat => 'Irregular heartbeat detected';

  @override
  String get referenceRanges => 'Reference Ranges';

  @override
  String get applicationDefault => 'Application default';

  @override
  String get lowerBound => 'Lower Bound';

  @override
  String get upperBound => 'Upper Bound';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get rangeSaved => 'Range saved';

  @override
  String get failedToSaveRange => 'Failed to save range';

  @override
  String get lowerBoundAboveUpperBound =>
      'Lower bound must be less than upper bound';

  @override
  String referenceRangeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reference ranges',
      one: '1 reference range',
      zero: '0 reference ranges',
    );
    return '$_temp0';
  }

  @override
  String get trends => 'Trends';

  @override
  String get measurementTrends => 'Measurement Trends';

  @override
  String get viewTrends => 'Trends';

  @override
  String get lastSevenDays => 'Last 7 Days';

  @override
  String get lastThirtyDays => 'Last 30 Days';

  @override
  String get lastNinetyDays => 'Last 90 Days';

  @override
  String get latest => 'Latest';

  @override
  String get average => 'Average';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get readingCount => 'Readings';

  @override
  String get firstReading => 'First';

  @override
  String get change => 'Change';

  @override
  String get percentageChange => 'Change %';

  @override
  String get belowCount => 'Below';

  @override
  String get withinCount => 'Within';

  @override
  String get aboveCount => 'Above';

  @override
  String get unknownCount => 'Unknown';

  @override
  String get irregularHeartbeatCount => 'Irregular Heartbeat';

  @override
  String get noTrendData => 'No trend data';

  @override
  String get moreReadingsNeeded =>
      'At least 2 readings are needed to show a trend';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get failedToLoadTrends => 'Failed to load trends';

  @override
  String get statusSummary => 'Status Summary';

  @override
  String get statistics => 'Statistics';

  @override
  String get chart => 'Chart';

  @override
  String get systolicLabel => 'Systolic';

  @override
  String get diastolicLabel => 'Diastolic';

  @override
  String get pulseLabelStat => 'Pulse';

  @override
  String get systolicShort => 'Systolic';

  @override
  String get diastolicShort => 'Diastolic';

  @override
  String get pulseShort => 'Pulse';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get withinConfiguredRange => 'within configured range';

  @override
  String get belowConfiguredRange => 'below configured range';

  @override
  String get aboveConfiguredRange => 'above configured range';

  @override
  String get noReferenceRangeConfigured => 'no reference range configured';

  @override
  String componentStatusSystolic(String status) {
    return 'Systolic $status';
  }

  @override
  String componentStatusDiastolic(String status) {
    return 'Diastolic $status';
  }

  @override
  String componentStatusPulse(String status) {
    return 'Pulse $status';
  }

  @override
  String get measurementSchedules => 'Measurement Schedules';

  @override
  String get addMeasurementSchedule => 'Add Measurement Schedule';

  @override
  String get editMeasurementSchedule => 'Edit Measurement Schedule';

  @override
  String get noMeasurementSchedules => 'No measurement schedules';

  @override
  String get noMeasurementSchedulesDescription =>
      'Add a schedule to get reminders for this measurement';

  @override
  String get daily => 'Daily';

  @override
  String get everyNDaysLabel => 'Every N Days';

  @override
  String get everyNDaysRequiresStartDate =>
      'Every N Days requires a start date';

  @override
  String get recordNow => 'Record Now';

  @override
  String get measurementReminder => 'Measurement Reminder';

  @override
  String get measurementReminders => 'Measurement Reminders';

  @override
  String timeToRecordMeasurement(String name) {
    return 'Time to record $name';
  }

  @override
  String get reminderScheduled => 'Reminder scheduled';

  @override
  String get reminderUpdated => 'Reminder updated';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String get scheduleRecovered => 'Schedule recovered';

  @override
  String get measurementsDueToday => 'Measurements Due Today';

  @override
  String get noRemindersToday => 'No reminders scheduled for today';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get overdue => 'Overdue';

  @override
  String get completed => 'Completed';

  @override
  String get snoozed => 'Snoozed';

  @override
  String get todaysProgress => 'Today\'s Progress';

  @override
  String get todaysPlan => 'Today\'s Plan';

  @override
  String get nothingScheduledToday => 'Nothing scheduled for today';

  @override
  String get nextItem => 'Next';

  @override
  String get medicationsToday => 'Medications';

  @override
  String get measurementsToday => 'Measurements';

  @override
  String get completedAndSkipped => 'Completed & Skipped';

  @override
  String get markTaken => 'Mark as Taken';

  @override
  String get snooze10min => 'Snooze 10 min';

  @override
  String get due => 'Due';

  @override
  String get dueSoon => 'Due soon';

  @override
  String takeMedication(Object name) {
    return 'Take $name';
  }

  @override
  String completedAt(Object time) {
    return 'Completed at $time';
  }

  @override
  String overdueSince(Object time) {
    return 'Overdue since $time';
  }

  @override
  String get noMedicationsToday => 'No medication schedules for today';

  @override
  String get noMeasurementsToday => 'No measurement schedules for today';

  @override
  String get agenda => 'Agenda';

  @override
  String get moreActions => 'More actions';

  @override
  String get skip => 'Skip';

  @override
  String get openDetails => 'Details';

  @override
  String get failedToUpdateItem => 'Failed to update item';

  @override
  String get changeToSkipped => 'Change to Skipped';

  @override
  String get changeToTaken => 'Change to Taken';

  @override
  String get resetToPending => 'Reset to Pending';

  @override
  String get editReading => 'Edit Reading';

  @override
  String get dailyPlan => 'Daily Plan';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get returnToToday => 'Today';

  @override
  String get nothingScheduledForThisDay => 'Nothing scheduled for this day';

  @override
  String get firstPlannedItem => 'First planned item';

  @override
  String scheduledAt(Object time) {
    return 'Scheduled at $time';
  }

  @override
  String get medicationsMissed => 'Missed medications';

  @override
  String get measurementsMissed => 'Missed measurements';

  @override
  String get dailySummary => 'Daily Summary';
}
