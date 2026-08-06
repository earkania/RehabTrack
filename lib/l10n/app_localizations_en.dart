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
  String get appSettings => 'App Settings';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get backupRestoreComingSoon =>
      'Backup and restore functionality will be available soon.';

  @override
  String get createBackup => 'Create backup';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get backupInformation => 'Backup information';

  @override
  String get backupScreenDescription =>
      'Create a copy of all your data and save it as a file you control. Your photos and app settings are included.';

  @override
  String get backupIncludes => 'What\'s included';

  @override
  String get backupIncludesDatabase => 'All your health records and history';

  @override
  String get backupIncludesPhotos => 'Profile and care contact photos';

  @override
  String get backupIncludesSettings => 'App settings and preferences';

  @override
  String get backupRestoreNotAvailable =>
      'Restore will be available in a future update.';

  @override
  String backupLastSuccessful(Object time) {
    return 'Last successful backup: $time';
  }

  @override
  String get backupLastNever => 'No backup created yet';

  @override
  String get backupInProgress => 'Creating backup…';

  @override
  String get backupSuccessTitle => 'Backup created';

  @override
  String get backupSuccessMessage =>
      'Your backup file has been saved to the chosen location.';

  @override
  String get backupMissingFilesMessage =>
      'Some photos referenced by your data were missing and are not included in this backup.';

  @override
  String get backupCancelledTitle => 'Backup cancelled';

  @override
  String get backupCancelledMessage => 'No backup was created.';

  @override
  String get backupFailedTitle => 'Backup failed';

  @override
  String get backupStorageFailure =>
      'Could not write the backup to the selected location. Try again or choose a different location.';

  @override
  String get backupDatabaseFailure =>
      'Could not read the app database. Try again.';

  @override
  String get backupArchiveFailure =>
      'Could not create the backup file. Try again.';

  @override
  String get backupPermissionDenied =>
      'Permission to save the backup was denied.';

  @override
  String get backupNotEnoughStorage =>
      'Not enough free space on the selected location.';

  @override
  String get backupOperationInProgress =>
      'A backup is already in progress. Please wait.';

  @override
  String get backupUnexpectedFailure =>
      'Something went wrong. Please try again.';

  @override
  String get selectBackupFile => 'Select backup file';

  @override
  String get selectingBackup => 'Selecting backup…';

  @override
  String get readingBackup => 'Reading backup…';

  @override
  String get validatingBackup => 'Validating backup…';

  @override
  String get verifyingChecksums => 'Verifying checksums…';

  @override
  String get checkingCompatibility => 'Checking compatibility…';

  @override
  String get backupPreview => 'Backup preview';

  @override
  String get backupDetails => 'Backup details';

  @override
  String backupDate(String date) {
    return 'Backup date: $date';
  }

  @override
  String backupAppVersion(String version) {
    return 'App version: $version';
  }

  @override
  String backupFormatVersion(String version) {
    return 'Backup format version: $version';
  }

  @override
  String databaseVersion(String version) {
    return 'Database version: $version';
  }

  @override
  String currentDatabaseVersion(String version) {
    return 'Current database version: $version';
  }

  @override
  String profilesCount(int count) {
    return 'Profiles: $count';
  }

  @override
  String filesCount(int count) {
    return 'Managed files: $count';
  }

  @override
  String get backupSize => 'Backup size';

  @override
  String get compatibleBackup => 'Compatible';

  @override
  String get compatibleMigrationRequired => 'Compatible, migration required';

  @override
  String get incompatibleBackup => 'Incompatible';

  @override
  String get migrationRequired => 'Migration will be required before restore.';

  @override
  String get restoreWillReplaceData =>
      'Restoring this backup will replace the current RehabTrack data on this device with the backup contents. Photos, settings and all records will be overwritten.';

  @override
  String get continueRestore => 'Continue';

  @override
  String get cancelRestore => 'Cancel';

  @override
  String get restoreNotImplementedYet =>
      'Backup validation completed successfully. Restore is not available yet.';

  @override
  String get restoreCompletedTitle => 'Restore completed';

  @override
  String get restoreFailedTitle => 'Restore failed';

  @override
  String get restoreCancelledTitle => 'Restore cancelled';

  @override
  String get restoreInProgressTitle => 'Restoring your data';

  @override
  String restoreCompletedMessage(String date) {
    return 'Your data was restored from the backup from $date.';
  }

  @override
  String get originalDataRecovered => 'Your original data was recovered.';

  @override
  String criticalRestoreRecoveryRequired(String code) {
    return 'Automatic recovery could not complete. Do not close the app — contact support with this code: $code.';
  }

  @override
  String get restoreInterrupted => 'A previous restore was interrupted.';

  @override
  String get recoveringInterruptedRestore => 'Recovering your previous data…';

  @override
  String get restoreMigrationRequired => 'Migration required';

  @override
  String get restoreMigrationNotAvailableYet =>
      'This backup uses an older database format. Restoring it requires a migration that is not available yet. No data was changed.';

  @override
  String get remindersNeedRebuilding =>
      'Scheduled reminders were cancelled. They will be rebuilt in a later version.';

  @override
  String get cannotCancelRestoreNow => 'Restore cannot be cancelled now.';

  @override
  String get restoreOperationAlreadyInProgress =>
      'A restore is already in progress.';

  @override
  String get restoreSafetySnapshotFailed =>
      'A safety snapshot of your data could not be created. The restore was stopped and your data was not changed.';

  @override
  String get restoreDatabaseReplacementFailed =>
      'The database could not be replaced.';

  @override
  String get restoreFilesFailed => 'The restored files could not be placed.';

  @override
  String get restorePreferencesFailed =>
      'The restored settings could not be applied.';

  @override
  String get restoreReinitializationFailed =>
      'The application could not be reinitialized after the restore.';

  @override
  String get restoreVerificationFailed =>
      'The restored data could not be verified.';

  @override
  String get restoreFailedGeneric => 'The restore could not be completed.';

  @override
  String get restoreCancelled =>
      'The restore was cancelled. No data was changed.';

  @override
  String get preparingRestore => 'Preparing to restore';

  @override
  String get creatingSafetySnapshot => 'Creating a safety snapshot';

  @override
  String get preparingRestoredDatabase => 'Preparing the restored database';

  @override
  String get preparingRestoredFiles => 'Preparing restored files';

  @override
  String get preparingRestoredPreferences => 'Preparing restored settings';

  @override
  String get pausingApplicationServices => 'Pausing application services';

  @override
  String get replacingDatabase => 'Replacing the database';

  @override
  String get restoringFiles => 'Restoring files';

  @override
  String get restoringPreferences => 'Restoring settings';

  @override
  String get reinitializingApplication => 'Reinitializing the application';

  @override
  String get verifyingRestoredData => 'Verifying restored data';

  @override
  String get rollingBackRestore => 'Rolling back the restore';

  @override
  String get finalizingRestore => 'Finalizing the restore';

  @override
  String get migratingDatabase =>
      'Migrating the database to the current version';

  @override
  String get validatingMigratedDatabase => 'Validating the migrated database';

  @override
  String get repairingFilePaths => 'Repairing file paths';

  @override
  String get rebuildingReminders => 'Rebuilding reminders';

  @override
  String get restoreMigrationFailed =>
      'The backup database could not be migrated to the current version. No data was changed.';

  @override
  String get restorePathRepairFailed =>
      'The restored file paths could not be repaired.';

  @override
  String get restoreDatabaseVerificationFailed =>
      'The restored database could not be verified.';

  @override
  String get restoreReminderRebuildFailed =>
      'The restored reminders could not be rebuilt.';

  @override
  String get restoreCompletedRemindersPending =>
      'Data was restored. Reminders could not be fully rebuilt and will be rescheduled.';

  @override
  String get retryReminderRebuild => 'Retry reminder rebuild';

  @override
  String get someOptionalFilesMissing =>
      'Some optional files (such as photos) referenced by the backup are missing and were cleared.';

  @override
  String get invalidBackupFile => 'This file is not a valid RehabTrack backup.';

  @override
  String get corruptedBackup =>
      'The backup archive is corrupted and could not be read.';

  @override
  String get missingBackupManifest => 'The backup is missing its manifest.';

  @override
  String get invalidBackupManifest => 'The backup manifest is invalid.';

  @override
  String get missingBackupDatabase => 'The backup is missing its database.';

  @override
  String get missingBackupPreferences =>
      'The backup is missing its preferences.';

  @override
  String get checksumMismatch =>
      'The backup failed checksum validation and may be damaged.';

  @override
  String get unsafeBackupArchive =>
      'The backup contains unsafe file paths and cannot be restored.';

  @override
  String get backupTooLarge => 'The backup is too large to validate safely.';

  @override
  String get newerBackupVersion =>
      'The backup was created by a newer, unsupported version of RehabTrack.';

  @override
  String get newerDatabaseVersion =>
      'The backup database is newer than this app supports.';

  @override
  String get unsupportedOldDatabaseVersion =>
      'The backup database is too old and cannot be migrated.';

  @override
  String get invalidBackupDatabase => 'The backup database is invalid.';

  @override
  String get invalidBackupPreferences => 'The backup preferences are invalid.';

  @override
  String get backupValidationFailed => 'Backup validation failed';

  @override
  String get operationAlreadyInProgress =>
      'Another operation is already in progress. Please wait.';

  @override
  String get backupWarningOlderAppVersion =>
      'Backup created with an older app version.';

  @override
  String get backupWarningMigrationRequired =>
      'Migration will be required before restore.';

  @override
  String get profile => 'Profile';

  @override
  String get diet => 'Diet';

  @override
  String get labAnalyses => 'Lab Analyses';

  @override
  String get doctorVisits => 'Doctor Visits';

  @override
  String get reports => 'Reports';

  @override
  String get doctors => 'Doctors';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get medicalNotes => 'Medical Notes';

  @override
  String get moduleNotAvailableYet => 'This module is not available yet';

  @override
  String get comingSoon => 'Coming soon';

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
  String get measurementReminders => 'Measurement reminders';

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

  @override
  String get patientProfile => 'Patient Profile';

  @override
  String get editPatientProfile => 'Edit Patient Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get heightCm => 'Height';

  @override
  String get weightKg => 'Weight';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get allergies => 'Allergies';

  @override
  String get gender => 'Gender';

  @override
  String get relationship => 'Relationship';

  @override
  String get selectDate => 'Select date';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get self_ => 'Self';

  @override
  String get child_ => 'Child';

  @override
  String get spouse_ => 'Spouse';

  @override
  String get parent_ => 'Parent';

  @override
  String get sibling_ => 'Sibling';

  @override
  String get grandparent_ => 'Grandparent';

  @override
  String get grandchild_ => 'Grandchild';

  @override
  String get other_ => 'Other';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get failedToSaveProfile => 'Failed to save profile';

  @override
  String get switchProfile => 'Switch Profile';

  @override
  String get noProfiles => 'No profiles yet';

  @override
  String get createFirstProfile => 'Create your first patient profile';

  @override
  String get profileSummary => 'Profile Summary';

  @override
  String get age => 'Age';

  @override
  String yearsOld(int years) {
    return '$years years old';
  }

  @override
  String get activeProfile => 'Active Profile';

  @override
  String get birthDateLabel => 'Birth Date';

  @override
  String get heightLabel => 'Height';

  @override
  String get weightLabel => 'Weight';

  @override
  String get nameLabel => 'Name';

  @override
  String get emergencyContactNameLabel => 'Contact Name';

  @override
  String get emergencyContactPhoneLabel => 'Contact Phone';

  @override
  String get profileNotSetUp => 'Profile not set up';

  @override
  String get profileNotSetUpDescription =>
      'Create a patient profile to get started.\nYour profile information will be used across the app.';

  @override
  String get addProfileInformation => 'Add Profile Information';

  @override
  String get profileInformationNotEntered =>
      'Profile information has not been entered yet.';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get removeProfilePhoto => 'Remove photo';

  @override
  String get photoSelectionCancelled => 'Photo selection was cancelled';

  @override
  String get failedToLoadPhoto => 'Failed to load photo';

  @override
  String get failedToSavePhoto => 'Failed to save photo';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to take photos';

  @override
  String get nextItemGracePeriod => 'Next item grace period';

  @override
  String get nextItemGracePeriodDescription =>
      'Keep an unfinished item in Next for this long after its scheduled time.';

  @override
  String minutesValue(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get fiveMinutes => '5 minutes';

  @override
  String get tenMinutes => '10 minutes';

  @override
  String get fifteenMinutes => '15 minutes';

  @override
  String get thirtyMinutes => '30 minutes';

  @override
  String get sixtyMinutes => '60 minutes';

  @override
  String get reminders => 'Reminders';

  @override
  String get medicationReminders => 'Medication reminders';

  @override
  String get reminderSound => 'Sound';

  @override
  String get reminderVibration => 'Vibration';

  @override
  String get defaultSnoozeDuration => 'Default snooze duration';

  @override
  String get notificationPermission => 'Notification permission';

  @override
  String get exactAlarmAccess => 'Exact alarm access';

  @override
  String get permissionGranted => 'Granted';

  @override
  String get permissionDenied => 'Denied';

  @override
  String get permissionRequired => 'Required';

  @override
  String get openNotificationSettings => 'Open notification settings';

  @override
  String get openAlarmSettings => 'Open alarm settings';

  @override
  String get androidNotificationSettings => 'Android notification settings';

  @override
  String get androidNotificationSettingsDescription =>
      'Manage system notification categories, sounds, and alerts';

  @override
  String get systemControls => 'System controls';

  @override
  String get androidMayHideUnusedCategories =>
      'Android may hide notification categories until they have been used.';

  @override
  String get testMedicationReminder => 'Test medication reminder';

  @override
  String get testMeasurementReminder => 'Test measurement reminder';

  @override
  String get testReminder => 'Test reminder';

  @override
  String get testReminderTitle => 'Test Reminder';

  @override
  String get testReminderBody =>
      'This is a test reminder to verify notification sound, vibration, and presentation.';

  @override
  String get medicationReminder => 'Medication Reminder';

  @override
  String get markAsTaken => 'Mark as Taken';

  @override
  String get snooze => 'Snooze';

  @override
  String get scheduleSavedReminderFailed =>
      'Schedule saved, but reminder could not be scheduled';

  @override
  String get reminderSchedulingFailed => 'Could not schedule reminder';

  @override
  String get reminderDetails => 'Reminder Details';

  @override
  String get reminderPermissionExplanation =>
      'RehabTrack needs notification permission to show reminders for medications and measurements.';

  @override
  String get exactAlarmExplanation =>
      'Exact alarm permission allows reminders to appear at the precise scheduled time. Without it, reminder timing may be less precise.';

  @override
  String get alarmStyleReminders => 'Alarm-style presentation';

  @override
  String get lockScreenReminderDetails =>
      'Show full reminder details on lock screen';

  @override
  String get noPermission => 'No permission';

  @override
  String get channelDisabled => 'Channel disabled';

  @override
  String get scheduleSaved => 'Schedule saved';

  @override
  String get notGranted => 'Not granted';

  @override
  String get notRequired => 'Not required';

  @override
  String get requestPermission => 'Request permission';

  @override
  String get reminderWarningNoPermission =>
      'Reminders cannot be displayed because notification permission is denied.';

  @override
  String get reminderWarningNoExactAlarm =>
      'Reminder timing may be less precise without exact alarm access.';

  @override
  String snoozeMinutes(Object minutes) {
    return 'Snooze for $minutes minutes';
  }

  @override
  String get healthReminder => 'Health reminder';

  @override
  String get healthReminderLockScreen => 'Open RehabTrack for details';

  @override
  String get remindersNotAvailable => 'Reminders not available';

  @override
  String get testReminderSent =>
      'Test reminder sent! Check your notifications.';

  @override
  String get request => 'Request';

  @override
  String get inactiveMedications => 'Inactive';

  @override
  String get showDeactivated => 'Show deactivated';

  @override
  String get reactivate => 'Reactivate';

  @override
  String get confirmReactivate =>
      'This medication will be reactivated. Its history will be preserved.';

  @override
  String get noInactiveMedications => 'No inactive medications';

  @override
  String get careContacts => 'Care Contacts';

  @override
  String get addCareContact => 'Add Care Contact';

  @override
  String get editCareContact => 'Edit Care Contact';

  @override
  String get careContactDetails => 'Contact Details';

  @override
  String get contactType => 'Contact Type';

  @override
  String get doctorOrSpecialist => 'Doctor or Specialist';

  @override
  String get clinicOrHospital => 'Clinic or Hospital';

  @override
  String get laboratory => 'Laboratory';

  @override
  String get pharmacy => 'Pharmacy';

  @override
  String get insuranceCompany => 'Insurance Company';

  @override
  String get allContacts => 'All Contacts';

  @override
  String get organizations => 'Organizations';

  @override
  String get insurance => 'Insurance';

  @override
  String get favorites => 'Favorites';

  @override
  String get archivedContacts => 'Archived Contacts';

  @override
  String get noCareContacts => 'No care contacts yet';

  @override
  String get noCareContactsDescription =>
      'Add doctors, clinics, laboratories, pharmacies, or insurance contacts.';

  @override
  String get noArchivedContacts => 'No archived contacts';

  @override
  String get noArchivedContactsDescription =>
      'Archived contacts will appear here and can be restored.';

  @override
  String get displayName => 'Display Name';

  @override
  String get specialty => 'Specialty';

  @override
  String get organization => 'Organization';

  @override
  String get organizationName => 'Organization Name';

  @override
  String get department => 'Department';

  @override
  String get contactPerson => 'Contact Person';

  @override
  String get primaryPhone => 'Primary Phone';

  @override
  String get secondaryPhone => 'Secondary Phone';

  @override
  String get website => 'Website';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get policyNumber => 'Policy Number';

  @override
  String get memberNumber => 'Member or Customer Number';

  @override
  String get policyNotes => 'Policy Notes';

  @override
  String get favorite => 'Favorite';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get call => 'Call';

  @override
  String get sendEmail => 'Send email';

  @override
  String get openWebsite => 'Open website';

  @override
  String get openAddress => 'Open address';

  @override
  String get selectContactType => 'Select Contact Type';

  @override
  String get contactSaved => 'Contact saved';

  @override
  String get contactUpdated => 'Contact updated';

  @override
  String get contactArchived => 'Contact archived';

  @override
  String get contactRestored => 'Contact restored';

  @override
  String get contactDeleted => 'Contact deleted';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get invalidWebsite => 'Enter a valid website URL';

  @override
  String get confirmArchiveContact =>
      'Archive this contact? It will be hidden from the active list but kept safely.';

  @override
  String get confirmDeleteContact =>
      'Delete this contact permanently? This cannot be undone.';

  @override
  String get confirmRestoreContact =>
      'Restore this contact to the active list?';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get failedToSaveContactPhoto => 'Failed to save photo';

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String get noContactsFoundDescription =>
      'Try adjusting your search or filters.';

  @override
  String get searchContacts => 'Search contacts';

  @override
  String get all => 'All';

  @override
  String get showArchived => 'Show archived';

  @override
  String get showActive => 'Show active';

  @override
  String get editCareContactFailed => 'Could not save contact';

  @override
  String get deleteContactFailed => 'Could not delete contact';

  @override
  String get policyAndMemberDetails => 'Policy Details';

  @override
  String get professionalInformation => 'Professional Information';

  @override
  String get organizationInformation => 'Organization Information';

  @override
  String get personalInformationLabel => 'Personal Information';

  @override
  String get careContactsSubtitle =>
      'Doctors, clinics, laboratories, pharmacies, and insurance companies';

  @override
  String get contactNotAvailable => 'Contact not found';

  @override
  String get enabled => 'Enabled';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get doctor => 'Doctor';

  @override
  String get plannedVisit => 'Planned';

  @override
  String get onDemandVisit => 'On demand';

  @override
  String get oneWeekBefore => '1 week before';

  @override
  String get twoDaysBefore => '2 days before';

  @override
  String get oneDayBefore => '1 day before';

  @override
  String get twoHoursBefore => '2 hours before';

  @override
  String get oneHourBefore => '1 hour before';

  @override
  String get thirtyMinutesBefore => '30 minutes before';

  @override
  String get fifteenMinutesBefore => '15 minutes before';

  @override
  String get addDoctorVisit => 'Add Doctor Visit';

  @override
  String get editDoctorVisit => 'Edit Doctor Visit';

  @override
  String get upcomingVisits => 'Upcoming';

  @override
  String doctorVisitsUpcomingBadgeSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count upcoming visits',
      one: '1 upcoming visit',
    );
    return 'Doctor Visits, $_temp0';
  }

  @override
  String get visitHistory => 'History';

  @override
  String get noUpcomingVisits => 'No upcoming visits';

  @override
  String get noVisitHistory => 'No visit history';

  @override
  String get noUpcomingVisitsDescription => 'Planned visits will appear here.';

  @override
  String get noVisitHistoryDescription =>
      'Completed, cancelled, and missed visits will appear here.';

  @override
  String get contactNotSelected => 'Not selected';

  @override
  String get visitReason => 'Reason for visit';

  @override
  String get remindMe => 'Remind me';

  @override
  String get remindBefore => 'Remind before';

  @override
  String get saveVisitFailed => 'Could not save visit';

  @override
  String get visitUpdated => 'Visit updated';

  @override
  String get visitSaved => 'Visit saved';

  @override
  String get doctorVisitDetails => 'Visit Details';

  @override
  String get visitNeedsAttention =>
      'This visit is past due — mark it completed, cancelled, or missed.';

  @override
  String get markCompleted => 'Mark completed';

  @override
  String get markMissed => 'Mark missed';

  @override
  String get reschedule => 'Reschedule';

  @override
  String get cancelVisit => 'Cancel visit';

  @override
  String get visitCompleted => 'Visit marked as completed';

  @override
  String get visitCancelled => 'Visit cancelled';

  @override
  String get visitMissed => 'Visit marked as missed';

  @override
  String get confirmDeleteVisit =>
      'Delete this visit permanently? This cannot be undone.';

  @override
  String get visitDeleted => 'Visit deleted';

  @override
  String get saveAsScheduledLater => 'Save as scheduled later';

  @override
  String get onDemandRecordedCompleted =>
      'On-demand visits are recorded as completed right away. Enable this to schedule it in the future instead.';

  @override
  String get scheduledDateTime => 'Scheduled date and time';

  @override
  String get visitType => 'Visit type';

  @override
  String get selectDoctor => 'Select doctor';

  @override
  String get selectClinicOrHospital => 'Select clinic or hospital';

  @override
  String get noEligibleContacts =>
      'No eligible contacts. Add a care contact first.';

  @override
  String get contactReferencedByVisits =>
      'This contact is used by a doctor visit and cannot be permanently deleted.';

  @override
  String backupLastCreated(Object time) {
    return 'Last backup created: $time';
  }

  @override
  String restoreLastCompleted(Object time) {
    return 'Last restore completed: $time';
  }

  @override
  String get restoreCancellationUnavailable =>
      'Restoring is in progress and cannot be cancelled right now.';

  @override
  String get restoreNotEnoughStorage =>
      'There is not enough free storage space to run the restore. No data was changed.';

  @override
  String backupStoredAs(Object name) {
    return 'Stored as: $name';
  }
}
