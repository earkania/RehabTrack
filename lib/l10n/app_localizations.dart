import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ka.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ka'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'RehabTrack'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to RehabTrack'**
  String get welcomeMessage;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @backupRestoreComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore functionality will be available soon.'**
  String get backupRestoreComingSoon;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @backupInformation.
  ///
  /// In en, this message translates to:
  /// **'Backup information'**
  String get backupInformation;

  /// No description provided for @backupScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a copy of all your data and save it as a file you control. Your photos and app settings are included.'**
  String get backupScreenDescription;

  /// No description provided for @backupIncludes.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get backupIncludes;

  /// No description provided for @backupIncludesDatabase.
  ///
  /// In en, this message translates to:
  /// **'All your health records and history'**
  String get backupIncludesDatabase;

  /// No description provided for @backupIncludesPhotos.
  ///
  /// In en, this message translates to:
  /// **'Profile and care contact photos'**
  String get backupIncludesPhotos;

  /// No description provided for @backupIncludesSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings and preferences'**
  String get backupIncludesSettings;

  /// No description provided for @backupRestoreNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Restore will be available in a future update.'**
  String get backupRestoreNotAvailable;

  /// No description provided for @backupLastSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Last successful backup: {time}'**
  String backupLastSuccessful(Object time);

  /// No description provided for @backupLastNever.
  ///
  /// In en, this message translates to:
  /// **'No backup created yet'**
  String get backupLastNever;

  /// No description provided for @backupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Creating backup…'**
  String get backupInProgress;

  /// No description provided for @backupSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup created'**
  String get backupSuccessTitle;

  /// No description provided for @backupSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your backup file has been saved to the chosen location.'**
  String get backupSuccessMessage;

  /// No description provided for @backupMissingFilesMessage.
  ///
  /// In en, this message translates to:
  /// **'Some photos referenced by your data were missing and are not included in this backup.'**
  String get backupMissingFilesMessage;

  /// No description provided for @backupCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled'**
  String get backupCancelledTitle;

  /// No description provided for @backupCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'No backup was created.'**
  String get backupCancelledMessage;

  /// No description provided for @backupFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailedTitle;

  /// No description provided for @backupStorageFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not write the backup to the selected location. Try again or choose a different location.'**
  String get backupStorageFailure;

  /// No description provided for @backupDatabaseFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not read the app database. Try again.'**
  String get backupDatabaseFailure;

  /// No description provided for @backupArchiveFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not create the backup file. Try again.'**
  String get backupArchiveFailure;

  /// No description provided for @backupPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission to save the backup was denied.'**
  String get backupPermissionDenied;

  /// No description provided for @backupNotEnoughStorage.
  ///
  /// In en, this message translates to:
  /// **'Not enough free space on the selected location.'**
  String get backupNotEnoughStorage;

  /// No description provided for @backupOperationInProgress.
  ///
  /// In en, this message translates to:
  /// **'A backup is already in progress. Please wait.'**
  String get backupOperationInProgress;

  /// No description provided for @backupUnexpectedFailure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get backupUnexpectedFailure;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select backup file'**
  String get selectBackupFile;

  /// No description provided for @selectingBackup.
  ///
  /// In en, this message translates to:
  /// **'Selecting backup…'**
  String get selectingBackup;

  /// No description provided for @readingBackup.
  ///
  /// In en, this message translates to:
  /// **'Reading backup…'**
  String get readingBackup;

  /// No description provided for @validatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Validating backup…'**
  String get validatingBackup;

  /// No description provided for @verifyingChecksums.
  ///
  /// In en, this message translates to:
  /// **'Verifying checksums…'**
  String get verifyingChecksums;

  /// No description provided for @checkingCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Checking compatibility…'**
  String get checkingCompatibility;

  /// No description provided for @backupPreview.
  ///
  /// In en, this message translates to:
  /// **'Backup preview'**
  String get backupPreview;

  /// No description provided for @backupDetails.
  ///
  /// In en, this message translates to:
  /// **'Backup details'**
  String get backupDetails;

  /// No description provided for @backupDate.
  ///
  /// In en, this message translates to:
  /// **'Backup date: {date}'**
  String backupDate(String date);

  /// No description provided for @backupAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version: {version}'**
  String backupAppVersion(String version);

  /// No description provided for @backupFormatVersion.
  ///
  /// In en, this message translates to:
  /// **'Backup format version: {version}'**
  String backupFormatVersion(String version);

  /// No description provided for @databaseVersion.
  ///
  /// In en, this message translates to:
  /// **'Database version: {version}'**
  String databaseVersion(String version);

  /// No description provided for @currentDatabaseVersion.
  ///
  /// In en, this message translates to:
  /// **'Current database version: {version}'**
  String currentDatabaseVersion(String version);

  /// No description provided for @profilesCount.
  ///
  /// In en, this message translates to:
  /// **'Profiles: {count}'**
  String profilesCount(int count);

  /// No description provided for @filesCount.
  ///
  /// In en, this message translates to:
  /// **'Managed files: {count}'**
  String filesCount(int count);

  /// No description provided for @backupSize.
  ///
  /// In en, this message translates to:
  /// **'Backup size'**
  String get backupSize;

  /// No description provided for @compatibleBackup.
  ///
  /// In en, this message translates to:
  /// **'Compatible'**
  String get compatibleBackup;

  /// No description provided for @compatibleMigrationRequired.
  ///
  /// In en, this message translates to:
  /// **'Compatible, migration required'**
  String get compatibleMigrationRequired;

  /// No description provided for @incompatibleBackup.
  ///
  /// In en, this message translates to:
  /// **'Incompatible'**
  String get incompatibleBackup;

  /// No description provided for @migrationRequired.
  ///
  /// In en, this message translates to:
  /// **'Migration will be required before restore.'**
  String get migrationRequired;

  /// No description provided for @restoreWillReplaceData.
  ///
  /// In en, this message translates to:
  /// **'Restoring this backup will replace the current RehabTrack data on this device with the backup contents. Photos, settings and all records will be overwritten.'**
  String get restoreWillReplaceData;

  /// No description provided for @continueRestore.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueRestore;

  /// No description provided for @cancelRestore.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelRestore;

  /// No description provided for @restoreNotImplementedYet.
  ///
  /// In en, this message translates to:
  /// **'Backup validation completed successfully. Restore is not available yet.'**
  String get restoreNotImplementedYet;

  /// No description provided for @restoreCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore completed'**
  String get restoreCompletedTitle;

  /// No description provided for @restoreFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailedTitle;

  /// No description provided for @restoreCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore cancelled'**
  String get restoreCancelledTitle;

  /// No description provided for @restoreInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Restoring your data'**
  String get restoreInProgressTitle;

  /// No description provided for @restoreCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data was restored from the backup from {date}.'**
  String restoreCompletedMessage(String date);

  /// No description provided for @originalDataRecovered.
  ///
  /// In en, this message translates to:
  /// **'Your original data was recovered.'**
  String get originalDataRecovered;

  /// No description provided for @criticalRestoreRecoveryRequired.
  ///
  /// In en, this message translates to:
  /// **'Automatic recovery could not complete. Do not close the app — contact support with this code: {code}.'**
  String criticalRestoreRecoveryRequired(String code);

  /// No description provided for @restoreInterrupted.
  ///
  /// In en, this message translates to:
  /// **'A previous restore was interrupted.'**
  String get restoreInterrupted;

  /// No description provided for @recoveringInterruptedRestore.
  ///
  /// In en, this message translates to:
  /// **'Recovering your previous data…'**
  String get recoveringInterruptedRestore;

  /// No description provided for @restoreMigrationRequired.
  ///
  /// In en, this message translates to:
  /// **'Migration required'**
  String get restoreMigrationRequired;

  /// No description provided for @restoreMigrationNotAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'This backup uses an older database format. Restoring it requires a migration that is not available yet. No data was changed.'**
  String get restoreMigrationNotAvailableYet;

  /// No description provided for @remindersNeedRebuilding.
  ///
  /// In en, this message translates to:
  /// **'Scheduled reminders were cancelled. They will be rebuilt in a later version.'**
  String get remindersNeedRebuilding;

  /// No description provided for @cannotCancelRestoreNow.
  ///
  /// In en, this message translates to:
  /// **'Restore cannot be cancelled now.'**
  String get cannotCancelRestoreNow;

  /// No description provided for @restoreOperationAlreadyInProgress.
  ///
  /// In en, this message translates to:
  /// **'A restore is already in progress.'**
  String get restoreOperationAlreadyInProgress;

  /// No description provided for @restoreSafetySnapshotFailed.
  ///
  /// In en, this message translates to:
  /// **'A safety snapshot of your data could not be created. The restore was stopped and your data was not changed.'**
  String get restoreSafetySnapshotFailed;

  /// No description provided for @restoreDatabaseReplacementFailed.
  ///
  /// In en, this message translates to:
  /// **'The database could not be replaced.'**
  String get restoreDatabaseReplacementFailed;

  /// No description provided for @restoreFilesFailed.
  ///
  /// In en, this message translates to:
  /// **'The restored files could not be placed.'**
  String get restoreFilesFailed;

  /// No description provided for @restorePreferencesFailed.
  ///
  /// In en, this message translates to:
  /// **'The restored settings could not be applied.'**
  String get restorePreferencesFailed;

  /// No description provided for @restoreReinitializationFailed.
  ///
  /// In en, this message translates to:
  /// **'The application could not be reinitialized after the restore.'**
  String get restoreReinitializationFailed;

  /// No description provided for @restoreVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'The restored data could not be verified.'**
  String get restoreVerificationFailed;

  /// No description provided for @restoreFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'The restore could not be completed.'**
  String get restoreFailedGeneric;

  /// No description provided for @restoreCancelled.
  ///
  /// In en, this message translates to:
  /// **'The restore was cancelled. No data was changed.'**
  String get restoreCancelled;

  /// No description provided for @preparingRestore.
  ///
  /// In en, this message translates to:
  /// **'Preparing to restore'**
  String get preparingRestore;

  /// No description provided for @creatingSafetySnapshot.
  ///
  /// In en, this message translates to:
  /// **'Creating a safety snapshot'**
  String get creatingSafetySnapshot;

  /// No description provided for @preparingRestoredDatabase.
  ///
  /// In en, this message translates to:
  /// **'Preparing the restored database'**
  String get preparingRestoredDatabase;

  /// No description provided for @preparingRestoredFiles.
  ///
  /// In en, this message translates to:
  /// **'Preparing restored files'**
  String get preparingRestoredFiles;

  /// No description provided for @preparingRestoredPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preparing restored settings'**
  String get preparingRestoredPreferences;

  /// No description provided for @pausingApplicationServices.
  ///
  /// In en, this message translates to:
  /// **'Pausing application services'**
  String get pausingApplicationServices;

  /// No description provided for @replacingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Replacing the database'**
  String get replacingDatabase;

  /// No description provided for @restoringFiles.
  ///
  /// In en, this message translates to:
  /// **'Restoring files'**
  String get restoringFiles;

  /// No description provided for @restoringPreferences.
  ///
  /// In en, this message translates to:
  /// **'Restoring settings'**
  String get restoringPreferences;

  /// No description provided for @reinitializingApplication.
  ///
  /// In en, this message translates to:
  /// **'Reinitializing the application'**
  String get reinitializingApplication;

  /// No description provided for @verifyingRestoredData.
  ///
  /// In en, this message translates to:
  /// **'Verifying restored data'**
  String get verifyingRestoredData;

  /// No description provided for @rollingBackRestore.
  ///
  /// In en, this message translates to:
  /// **'Rolling back the restore'**
  String get rollingBackRestore;

  /// No description provided for @finalizingRestore.
  ///
  /// In en, this message translates to:
  /// **'Finalizing the restore'**
  String get finalizingRestore;

  /// No description provided for @migratingDatabase.
  ///
  /// In en, this message translates to:
  /// **'Migrating the database to the current version'**
  String get migratingDatabase;

  /// No description provided for @validatingMigratedDatabase.
  ///
  /// In en, this message translates to:
  /// **'Validating the migrated database'**
  String get validatingMigratedDatabase;

  /// No description provided for @repairingFilePaths.
  ///
  /// In en, this message translates to:
  /// **'Repairing file paths'**
  String get repairingFilePaths;

  /// No description provided for @rebuildingReminders.
  ///
  /// In en, this message translates to:
  /// **'Rebuilding reminders'**
  String get rebuildingReminders;

  /// No description provided for @restoreMigrationFailed.
  ///
  /// In en, this message translates to:
  /// **'The backup database could not be migrated to the current version. No data was changed.'**
  String get restoreMigrationFailed;

  /// No description provided for @restorePathRepairFailed.
  ///
  /// In en, this message translates to:
  /// **'The restored file paths could not be repaired.'**
  String get restorePathRepairFailed;

  /// No description provided for @restoreDatabaseVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'The restored database could not be verified.'**
  String get restoreDatabaseVerificationFailed;

  /// No description provided for @restoreReminderRebuildFailed.
  ///
  /// In en, this message translates to:
  /// **'The restored reminders could not be rebuilt.'**
  String get restoreReminderRebuildFailed;

  /// No description provided for @restoreCompletedRemindersPending.
  ///
  /// In en, this message translates to:
  /// **'Data was restored. Reminders could not be fully rebuilt and will be rescheduled.'**
  String get restoreCompletedRemindersPending;

  /// No description provided for @retryReminderRebuild.
  ///
  /// In en, this message translates to:
  /// **'Retry reminder rebuild'**
  String get retryReminderRebuild;

  /// No description provided for @someOptionalFilesMissing.
  ///
  /// In en, this message translates to:
  /// **'Some optional files (such as photos) referenced by the backup are missing and were cleared.'**
  String get someOptionalFilesMissing;

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid RehabTrack backup.'**
  String get invalidBackupFile;

  /// No description provided for @corruptedBackup.
  ///
  /// In en, this message translates to:
  /// **'The backup archive is corrupted and could not be read.'**
  String get corruptedBackup;

  /// No description provided for @missingBackupManifest.
  ///
  /// In en, this message translates to:
  /// **'The backup is missing its manifest.'**
  String get missingBackupManifest;

  /// No description provided for @invalidBackupManifest.
  ///
  /// In en, this message translates to:
  /// **'The backup manifest is invalid.'**
  String get invalidBackupManifest;

  /// No description provided for @missingBackupDatabase.
  ///
  /// In en, this message translates to:
  /// **'The backup is missing its database.'**
  String get missingBackupDatabase;

  /// No description provided for @missingBackupPreferences.
  ///
  /// In en, this message translates to:
  /// **'The backup is missing its preferences.'**
  String get missingBackupPreferences;

  /// No description provided for @checksumMismatch.
  ///
  /// In en, this message translates to:
  /// **'The backup failed checksum validation and may be damaged.'**
  String get checksumMismatch;

  /// No description provided for @unsafeBackupArchive.
  ///
  /// In en, this message translates to:
  /// **'The backup contains unsafe file paths and cannot be restored.'**
  String get unsafeBackupArchive;

  /// No description provided for @backupTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The backup is too large to validate safely.'**
  String get backupTooLarge;

  /// No description provided for @newerBackupVersion.
  ///
  /// In en, this message translates to:
  /// **'The backup was created by a newer, unsupported version of RehabTrack.'**
  String get newerBackupVersion;

  /// No description provided for @newerDatabaseVersion.
  ///
  /// In en, this message translates to:
  /// **'The backup database is newer than this app supports.'**
  String get newerDatabaseVersion;

  /// No description provided for @unsupportedOldDatabaseVersion.
  ///
  /// In en, this message translates to:
  /// **'The backup database is too old and cannot be migrated.'**
  String get unsupportedOldDatabaseVersion;

  /// No description provided for @invalidBackupDatabase.
  ///
  /// In en, this message translates to:
  /// **'The backup database is invalid.'**
  String get invalidBackupDatabase;

  /// No description provided for @invalidBackupPreferences.
  ///
  /// In en, this message translates to:
  /// **'The backup preferences are invalid.'**
  String get invalidBackupPreferences;

  /// No description provided for @backupValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup validation failed'**
  String get backupValidationFailed;

  /// No description provided for @operationAlreadyInProgress.
  ///
  /// In en, this message translates to:
  /// **'Another operation is already in progress. Please wait.'**
  String get operationAlreadyInProgress;

  /// No description provided for @backupWarningOlderAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Backup created with an older app version.'**
  String get backupWarningOlderAppVersion;

  /// No description provided for @backupWarningMigrationRequired.
  ///
  /// In en, this message translates to:
  /// **'Migration will be required before restore.'**
  String get backupWarningMigrationRequired;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @labAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Lab Analyses'**
  String get labAnalyses;

  /// No description provided for @doctorVisits.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visits'**
  String get doctorVisits;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @medicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical Notes'**
  String get medicalNotes;

  /// No description provided for @moduleNotAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'This module is not available yet'**
  String get moduleNotAvailableYet;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add your first item to get started'**
  String get addFirstItem;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete action'**
  String get actionFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @removeMedication.
  ///
  /// In en, this message translates to:
  /// **'Remove Medication'**
  String get removeMedication;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @medicationNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Amoxicillin'**
  String get medicationNameHint;

  /// No description provided for @medicationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Medication name is required'**
  String get medicationNameRequired;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @doseAmount.
  ///
  /// In en, this message translates to:
  /// **'Dose Amount'**
  String get doseAmount;

  /// No description provided for @doseUnit.
  ///
  /// In en, this message translates to:
  /// **'Dose Unit'**
  String get doseUnit;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @scheduleType.
  ///
  /// In en, this message translates to:
  /// **'Schedule Type'**
  String get scheduleType;

  /// No description provided for @dailySchedule.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailySchedule;

  /// No description provided for @dailyScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Take at specified times every day'**
  String get dailyScheduleDescription;

  /// No description provided for @everyNDaysSchedule.
  ///
  /// In en, this message translates to:
  /// **'Every N Days'**
  String get everyNDaysSchedule;

  /// No description provided for @everyNDaysScheduleDescription.
  ///
  /// In en, this message translates to:
  /// **'Take at specified times every N days'**
  String get everyNDaysScheduleDescription;

  /// No description provided for @intervalSchedule.
  ///
  /// In en, this message translates to:
  /// **'Interval Days'**
  String get intervalSchedule;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @alternatives.
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// No description provided for @addAlternative.
  ///
  /// In en, this message translates to:
  /// **'Add Alternative'**
  String get addAlternative;

  /// No description provided for @doctorApproved.
  ///
  /// In en, this message translates to:
  /// **'Doctor Approved'**
  String get doctorApproved;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @noMedicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet'**
  String get noMedicationsYet;

  /// No description provided for @addFirstMedication.
  ///
  /// In en, this message translates to:
  /// **'Add your first medication'**
  String get addFirstMedication;

  /// No description provided for @scheduleAdded.
  ///
  /// In en, this message translates to:
  /// **'Schedule added'**
  String get scheduleAdded;

  /// No description provided for @scheduleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Schedule deleted'**
  String get scheduleDeleted;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get confirmDelete;

  /// No description provided for @nextDose.
  ///
  /// In en, this message translates to:
  /// **'Next dose'**
  String get nextDose;

  /// No description provided for @logDose.
  ///
  /// In en, this message translates to:
  /// **'Log a dose'**
  String get logDose;

  /// No description provided for @medicationAdded.
  ///
  /// In en, this message translates to:
  /// **'Medication added'**
  String get medicationAdded;

  /// No description provided for @medicationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Medication updated'**
  String get medicationUpdated;

  /// No description provided for @medicationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Medication deleted'**
  String get medicationDeleted;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @dailyAt.
  ///
  /// In en, this message translates to:
  /// **'Daily at {times}'**
  String dailyAt(String times);

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {count} days at {times}'**
  String everyNDays(int count, String times);

  /// No description provided for @intakeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Intake Quantity'**
  String get intakeQuantity;

  /// No description provided for @perIntake.
  ///
  /// In en, this message translates to:
  /// **'per intake'**
  String get perIntake;

  /// No description provided for @dosageForm.
  ///
  /// In en, this message translates to:
  /// **'Dosage Form'**
  String get dosageForm;

  /// No description provided for @tablet.
  ///
  /// In en, this message translates to:
  /// **'tablet'**
  String get tablet;

  /// No description provided for @capsule.
  ///
  /// In en, this message translates to:
  /// **'capsule'**
  String get capsule;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'drop'**
  String get drop;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @puff.
  ///
  /// In en, this message translates to:
  /// **'puff'**
  String get puff;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @sachet.
  ///
  /// In en, this message translates to:
  /// **'sachet'**
  String get sachet;

  /// No description provided for @spoon.
  ///
  /// In en, this message translates to:
  /// **'spoon'**
  String get spoon;

  /// No description provided for @injection.
  ///
  /// In en, this message translates to:
  /// **'injection'**
  String get injection;

  /// No description provided for @topical.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get topical;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @customDosageForm.
  ///
  /// In en, this message translates to:
  /// **'Custom dosage form name'**
  String get customDosageForm;

  /// No description provided for @customDosageFormRequired.
  ///
  /// In en, this message translates to:
  /// **'Custom dosage form name is required'**
  String get customDosageFormRequired;

  /// No description provided for @invalidIntakeQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid intake quantity'**
  String get invalidIntakeQuantity;

  /// No description provided for @beforeMeal.
  ///
  /// In en, this message translates to:
  /// **'Before meal'**
  String get beforeMeal;

  /// No description provided for @afterMeal.
  ///
  /// In en, this message translates to:
  /// **'After meal'**
  String get afterMeal;

  /// No description provided for @withMeal.
  ///
  /// In en, this message translates to:
  /// **'With meal'**
  String get withMeal;

  /// No description provided for @emptyStomach.
  ///
  /// In en, this message translates to:
  /// **'On empty stomach'**
  String get emptyStomach;

  /// No description provided for @beforeBedtime.
  ///
  /// In en, this message translates to:
  /// **'Before bedtime'**
  String get beforeBedtime;

  /// No description provided for @morningOnly.
  ///
  /// In en, this message translates to:
  /// **'Morning only'**
  String get morningOnly;

  /// No description provided for @noSchedulesYet.
  ///
  /// In en, this message translates to:
  /// **'No schedules yet'**
  String get noSchedulesYet;

  /// No description provided for @noAlternativesYet.
  ///
  /// In en, this message translates to:
  /// **'No alternatives yet'**
  String get noAlternativesYet;

  /// No description provided for @addScheduleToMedication.
  ///
  /// In en, this message translates to:
  /// **'Add a schedule for this medication'**
  String get addScheduleToMedication;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @confirmDeactivate.
  ///
  /// In en, this message translates to:
  /// **'This medication will be deactivated. Schedules and history will be preserved.'**
  String get confirmDeactivate;

  /// No description provided for @invalidRoute.
  ///
  /// In en, this message translates to:
  /// **'Invalid page'**
  String get invalidRoute;

  /// No description provided for @schedules.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedules;

  /// No description provided for @deleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get deleteSchedule;

  /// No description provided for @deleteScheduleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this schedule?'**
  String get deleteScheduleConfirmation;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get addTime;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get scheduledTime;

  /// No description provided for @removeTime.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTime;

  /// No description provided for @intervalDays.
  ///
  /// In en, this message translates to:
  /// **'Interval (days)'**
  String get intervalDays;

  /// No description provided for @atLeastOneTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one time is required'**
  String get atLeastOneTimeRequired;

  /// No description provided for @duplicateTimesNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Duplicate times are not allowed'**
  String get duplicateTimesNotAllowed;

  /// No description provided for @invalidInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval must be between 1 and 30'**
  String get invalidInterval;

  /// No description provided for @failedToSaveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Failed to save schedule'**
  String get failedToSaveSchedule;

  /// No description provided for @failedToDeleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete schedule'**
  String get failedToDeleteSchedule;

  /// No description provided for @schedulesSection.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedulesSection;

  /// No description provided for @addScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a schedule to get reminders'**
  String get addScheduleSubtitle;

  /// No description provided for @editAlternative.
  ///
  /// In en, this message translates to:
  /// **'Edit Alternative'**
  String get editAlternative;

  /// No description provided for @deleteAlternative.
  ///
  /// In en, this message translates to:
  /// **'Delete Alternative'**
  String get deleteAlternative;

  /// No description provided for @deleteAlternativeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove this alternative? This will not affect the medication or its schedules.'**
  String get deleteAlternativeConfirmation;

  /// No description provided for @alternativeAdded.
  ///
  /// In en, this message translates to:
  /// **'Alternative added'**
  String get alternativeAdded;

  /// No description provided for @alternativeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Alternative updated'**
  String get alternativeUpdated;

  /// No description provided for @alternativeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Alternative deleted'**
  String get alternativeDeleted;

  /// No description provided for @noAlternatives.
  ///
  /// In en, this message translates to:
  /// **'No alternatives'**
  String get noAlternatives;

  /// No description provided for @noAlternativesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add doctor-approved substitutes for this medication'**
  String get noAlternativesDescription;

  /// No description provided for @alternativesSection.
  ///
  /// In en, this message translates to:
  /// **'Alternatives'**
  String get alternativesSection;

  /// No description provided for @genericSubstitute.
  ///
  /// In en, this message translates to:
  /// **'Generic substitute'**
  String get genericSubstitute;

  /// No description provided for @confirmDeleteAlternative.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this alternative?'**
  String get confirmDeleteAlternative;

  /// No description provided for @historySection.
  ///
  /// In en, this message translates to:
  /// **'History & Adherence'**
  String get historySection;

  /// No description provided for @historyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication History'**
  String get historyScreenTitle;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @adherencePercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}%'**
  String adherencePercentage(double percentage);

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No logs yet'**
  String get noLogsYet;

  /// No description provided for @noLogsDescription.
  ///
  /// In en, this message translates to:
  /// **'Log doses to track your medication adherence'**
  String get noLogsDescription;

  /// No description provided for @logDoseNow.
  ///
  /// In en, this message translates to:
  /// **'Log Dose'**
  String get logDoseNow;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @doseNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get doseNotes;

  /// No description provided for @doseLogged.
  ///
  /// In en, this message translates to:
  /// **'Dose logged'**
  String get doseLogged;

  /// No description provided for @logDoseError.
  ///
  /// In en, this message translates to:
  /// **'Failed to log dose'**
  String get logDoseError;

  /// No description provided for @totalDoses.
  ///
  /// In en, this message translates to:
  /// **'Total Doses'**
  String get totalDoses;

  /// No description provided for @completedDoses.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedDoses;

  /// No description provided for @adherenceRate.
  ///
  /// In en, this message translates to:
  /// **'Adherence Rate'**
  String get adherenceRate;

  /// No description provided for @doseHistory.
  ///
  /// In en, this message translates to:
  /// **'Dose History'**
  String get doseHistory;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @noHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your medication log history will appear here'**
  String get noHistoryDescription;

  /// No description provided for @scheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String scheduledFor(String time);

  /// No description provided for @takenAt.
  ///
  /// In en, this message translates to:
  /// **'Taken at {time}'**
  String takenAt(String time);

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @invalidDose.
  ///
  /// In en, this message translates to:
  /// **'Invalid dose amount'**
  String get invalidDose;

  /// No description provided for @endDateBeforeStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date must be on or after start date'**
  String get endDateBeforeStartDate;

  /// No description provided for @scheduleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Schedule updated'**
  String get scheduleUpdated;

  /// No description provided for @noSchedulesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schedules available to log a dose'**
  String get noSchedulesAvailable;

  /// No description provided for @dosageComponents.
  ///
  /// In en, this message translates to:
  /// **'Dosage Components'**
  String get dosageComponents;

  /// No description provided for @addComponent.
  ///
  /// In en, this message translates to:
  /// **'Add Component'**
  String get addComponent;

  /// No description provided for @removeComponent.
  ///
  /// In en, this message translates to:
  /// **'Remove component'**
  String get removeComponent;

  /// No description provided for @componentName.
  ///
  /// In en, this message translates to:
  /// **'Component Name'**
  String get componentName;

  /// No description provided for @componentNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Component Name (optional)'**
  String get componentNameOptional;

  /// No description provided for @measurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// No description provided for @measurementTypes.
  ///
  /// In en, this message translates to:
  /// **'Measurement Types'**
  String get measurementTypes;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @editMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit Measurement'**
  String get editMeasurement;

  /// No description provided for @measurementHistory.
  ///
  /// In en, this message translates to:
  /// **'Measurement History'**
  String get measurementHistory;

  /// No description provided for @measuredAt.
  ///
  /// In en, this message translates to:
  /// **'Measured at'**
  String get measuredAt;

  /// No description provided for @latestReading.
  ///
  /// In en, this message translates to:
  /// **'Latest reading'**
  String get latestReading;

  /// No description provided for @noMeasurementsYet.
  ///
  /// In en, this message translates to:
  /// **'No measurement types available'**
  String get noMeasurementsYet;

  /// No description provided for @noReadingsYet.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get noReadingsYet;

  /// No description provided for @addFirstReading.
  ///
  /// In en, this message translates to:
  /// **'Add your first reading'**
  String get addFirstReading;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @pulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get pulse;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @bloodGlucose.
  ///
  /// In en, this message translates to:
  /// **'Blood Glucose'**
  String get bloodGlucose;

  /// No description provided for @spo2.
  ///
  /// In en, this message translates to:
  /// **'SpO2'**
  String get spo2;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @irregularHeartbeat.
  ///
  /// In en, this message translates to:
  /// **'Irregular heartbeat'**
  String get irregularHeartbeat;

  /// No description provided for @pulseLabel.
  ///
  /// In en, this message translates to:
  /// **'pulse'**
  String get pulseLabel;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Field Name'**
  String get fieldName;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @minimumValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum Value'**
  String get minimumValue;

  /// No description provided for @maximumValue.
  ///
  /// In en, this message translates to:
  /// **'Maximum Value'**
  String get maximumValue;

  /// No description provided for @invalidMeasurementValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid measurement value'**
  String get invalidMeasurementValue;

  /// No description provided for @failedToSaveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Failed to save measurement'**
  String get failedToSaveMeasurement;

  /// No description provided for @measurementAdded.
  ///
  /// In en, this message translates to:
  /// **'Measurement added'**
  String get measurementAdded;

  /// No description provided for @measurementUpdated.
  ///
  /// In en, this message translates to:
  /// **'Measurement updated'**
  String get measurementUpdated;

  /// No description provided for @measurementDeleted.
  ///
  /// In en, this message translates to:
  /// **'Measurement deleted'**
  String get measurementDeleted;

  /// No description provided for @confirmDeleteMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reading?'**
  String get confirmDeleteMeasurement;

  /// No description provided for @readingSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading saved'**
  String get readingSaved;

  /// No description provided for @readingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reading updated'**
  String get readingUpdated;

  /// No description provided for @readingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reading deleted'**
  String get readingDeleted;

  /// No description provided for @noMeasurementsHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noMeasurementsHistory;

  /// No description provided for @noMeasurementsHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your measurement history will appear here'**
  String get noMeasurementsHistoryDescription;

  /// No description provided for @measurementValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get measurementValue;

  /// No description provided for @measurementUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get measurementUnit;

  /// No description provided for @selectMeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Select measurement type'**
  String get selectMeasurementType;

  /// No description provided for @addReading.
  ///
  /// In en, this message translates to:
  /// **'Add Reading'**
  String get addReading;

  /// No description provided for @addReadingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Reading'**
  String get addReadingTooltip;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get viewHistory;

  /// No description provided for @valueRequired.
  ///
  /// In en, this message translates to:
  /// **'Value is required'**
  String get valueRequired;

  /// No description provided for @mustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Value must be positive'**
  String get mustBePositive;

  /// No description provided for @systolicGreaterThanDiastolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic should be greater than diastolic'**
  String get systolicGreaterThanDiastolic;

  /// No description provided for @withinRange.
  ///
  /// In en, this message translates to:
  /// **'Within range'**
  String get withinRange;

  /// No description provided for @aboveRange.
  ///
  /// In en, this message translates to:
  /// **'Above range'**
  String get aboveRange;

  /// No description provided for @belowRange.
  ///
  /// In en, this message translates to:
  /// **'Below range'**
  String get belowRange;

  /// No description provided for @noReferenceRange.
  ///
  /// In en, this message translates to:
  /// **'No reference range'**
  String get noReferenceRange;

  /// No description provided for @readingStatusLegend.
  ///
  /// In en, this message translates to:
  /// **'Reading Status'**
  String get readingStatusLegend;

  /// No description provided for @referenceRange.
  ///
  /// In en, this message translates to:
  /// **'Reference Range'**
  String get referenceRange;

  /// No description provided for @legendWithinRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Within configured range'**
  String get legendWithinRangeDescription;

  /// No description provided for @legendAboveRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Above configured range'**
  String get legendAboveRangeDescription;

  /// No description provided for @legendBelowRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Below configured range'**
  String get legendBelowRangeDescription;

  /// No description provided for @legendNoReferenceRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'No reference range configured'**
  String get legendNoReferenceRangeDescription;

  /// No description provided for @legendIrregularHeartbeat.
  ///
  /// In en, this message translates to:
  /// **'Irregular heartbeat detected'**
  String get legendIrregularHeartbeat;

  /// No description provided for @referenceRanges.
  ///
  /// In en, this message translates to:
  /// **'Reference Ranges'**
  String get referenceRanges;

  /// No description provided for @applicationDefault.
  ///
  /// In en, this message translates to:
  /// **'Application default'**
  String get applicationDefault;

  /// No description provided for @lowerBound.
  ///
  /// In en, this message translates to:
  /// **'Lower Bound'**
  String get lowerBound;

  /// No description provided for @upperBound.
  ///
  /// In en, this message translates to:
  /// **'Upper Bound'**
  String get upperBound;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @rangeSaved.
  ///
  /// In en, this message translates to:
  /// **'Range saved'**
  String get rangeSaved;

  /// No description provided for @failedToSaveRange.
  ///
  /// In en, this message translates to:
  /// **'Failed to save range'**
  String get failedToSaveRange;

  /// No description provided for @lowerBoundAboveUpperBound.
  ///
  /// In en, this message translates to:
  /// **'Lower bound must be less than upper bound'**
  String get lowerBoundAboveUpperBound;

  /// No description provided for @referenceRangeCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{0 reference ranges} =1{1 reference range} other{{count} reference ranges}}'**
  String referenceRangeCount(int count);

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @measurementTrends.
  ///
  /// In en, this message translates to:
  /// **'Measurement Trends'**
  String get measurementTrends;

  /// No description provided for @viewTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get viewTrends;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get lastSevenDays;

  /// No description provided for @lastThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get lastThirtyDays;

  /// No description provided for @lastNinetyDays.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get lastNinetyDays;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @readingCount.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get readingCount;

  /// No description provided for @firstReading.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get firstReading;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @percentageChange.
  ///
  /// In en, this message translates to:
  /// **'Change %'**
  String get percentageChange;

  /// No description provided for @belowCount.
  ///
  /// In en, this message translates to:
  /// **'Below'**
  String get belowCount;

  /// No description provided for @withinCount.
  ///
  /// In en, this message translates to:
  /// **'Within'**
  String get withinCount;

  /// No description provided for @aboveCount.
  ///
  /// In en, this message translates to:
  /// **'Above'**
  String get aboveCount;

  /// No description provided for @unknownCount.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownCount;

  /// No description provided for @irregularHeartbeatCount.
  ///
  /// In en, this message translates to:
  /// **'Irregular Heartbeat'**
  String get irregularHeartbeatCount;

  /// No description provided for @noTrendData.
  ///
  /// In en, this message translates to:
  /// **'No trend data'**
  String get noTrendData;

  /// No description provided for @moreReadingsNeeded.
  ///
  /// In en, this message translates to:
  /// **'At least 2 readings are needed to show a trend'**
  String get moreReadingsNeeded;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectPeriod;

  /// No description provided for @failedToLoadTrends.
  ///
  /// In en, this message translates to:
  /// **'Failed to load trends'**
  String get failedToLoadTrends;

  /// No description provided for @timeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Time of day'**
  String get timeOfDay;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @allReadings.
  ///
  /// In en, this message translates to:
  /// **'All readings'**
  String get allReadings;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @morningReadings.
  ///
  /// In en, this message translates to:
  /// **'Morning readings'**
  String get morningReadings;

  /// No description provided for @midday.
  ///
  /// In en, this message translates to:
  /// **'Midday'**
  String get midday;

  /// No description provided for @middayReadings.
  ///
  /// In en, this message translates to:
  /// **'Midday readings'**
  String get middayReadings;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @eveningReadings.
  ///
  /// In en, this message translates to:
  /// **'Evening readings'**
  String get eveningReadings;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @nightReadings.
  ///
  /// In en, this message translates to:
  /// **'Night readings'**
  String get nightReadings;

  /// No description provided for @noMorningReadings.
  ///
  /// In en, this message translates to:
  /// **'No morning readings in the selected period'**
  String get noMorningReadings;

  /// No description provided for @noMiddayReadings.
  ///
  /// In en, this message translates to:
  /// **'No midday readings in the selected period'**
  String get noMiddayReadings;

  /// No description provided for @noEveningReadings.
  ///
  /// In en, this message translates to:
  /// **'No evening readings in the selected period'**
  String get noEveningReadings;

  /// No description provided for @noNightReadings.
  ///
  /// In en, this message translates to:
  /// **'No night readings in the selected period'**
  String get noNightReadings;

  /// No description provided for @adjustTrendFilters.
  ///
  /// In en, this message translates to:
  /// **'Try a different date range or time of day'**
  String get adjustTrendFilters;

  /// No description provided for @statusSummary.
  ///
  /// In en, this message translates to:
  /// **'Status Summary'**
  String get statusSummary;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @systolicLabel.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolicLabel;

  /// No description provided for @diastolicLabel.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolicLabel;

  /// No description provided for @pulseLabelStat.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get pulseLabelStat;

  /// No description provided for @systolicShort.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolicShort;

  /// No description provided for @diastolicShort.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolicShort;

  /// No description provided for @pulseShort.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get pulseShort;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @withinConfiguredRange.
  ///
  /// In en, this message translates to:
  /// **'within configured range'**
  String get withinConfiguredRange;

  /// No description provided for @belowConfiguredRange.
  ///
  /// In en, this message translates to:
  /// **'below configured range'**
  String get belowConfiguredRange;

  /// No description provided for @aboveConfiguredRange.
  ///
  /// In en, this message translates to:
  /// **'above configured range'**
  String get aboveConfiguredRange;

  /// No description provided for @noReferenceRangeConfigured.
  ///
  /// In en, this message translates to:
  /// **'no reference range configured'**
  String get noReferenceRangeConfigured;

  /// No description provided for @componentStatusSystolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic {status}'**
  String componentStatusSystolic(String status);

  /// No description provided for @componentStatusDiastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic {status}'**
  String componentStatusDiastolic(String status);

  /// No description provided for @componentStatusPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse {status}'**
  String componentStatusPulse(String status);

  /// No description provided for @measurementSchedules.
  ///
  /// In en, this message translates to:
  /// **'Measurement Schedules'**
  String get measurementSchedules;

  /// No description provided for @addMeasurementSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement Schedule'**
  String get addMeasurementSchedule;

  /// No description provided for @editMeasurementSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Measurement Schedule'**
  String get editMeasurementSchedule;

  /// No description provided for @noMeasurementSchedules.
  ///
  /// In en, this message translates to:
  /// **'No measurement schedules'**
  String get noMeasurementSchedules;

  /// No description provided for @noMeasurementSchedulesDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a schedule to get reminders for this measurement'**
  String get noMeasurementSchedulesDescription;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @everyNDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Every N Days'**
  String get everyNDaysLabel;

  /// No description provided for @everyNDaysRequiresStartDate.
  ///
  /// In en, this message translates to:
  /// **'Every N Days requires a start date'**
  String get everyNDaysRequiresStartDate;

  /// No description provided for @recordNow.
  ///
  /// In en, this message translates to:
  /// **'Record Now'**
  String get recordNow;

  /// No description provided for @measurementReminder.
  ///
  /// In en, this message translates to:
  /// **'Measurement Reminder'**
  String get measurementReminder;

  /// No description provided for @measurementReminders.
  ///
  /// In en, this message translates to:
  /// **'Measurement reminders'**
  String get measurementReminders;

  /// No description provided for @timeToRecordMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Time to record {name}'**
  String timeToRecordMeasurement(String name);

  /// No description provided for @reminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled'**
  String get reminderScheduled;

  /// No description provided for @reminderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated'**
  String get reminderUpdated;

  /// No description provided for @reminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get reminderDeleted;

  /// No description provided for @scheduleRecovered.
  ///
  /// In en, this message translates to:
  /// **'Schedule recovered'**
  String get scheduleRecovered;

  /// No description provided for @measurementsDueToday.
  ///
  /// In en, this message translates to:
  /// **'Measurements Due Today'**
  String get measurementsDueToday;

  /// No description provided for @noRemindersToday.
  ///
  /// In en, this message translates to:
  /// **'No reminders scheduled for today'**
  String get noRemindersToday;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @snoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get snoozed;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Progress'**
  String get todaysProgress;

  /// No description provided for @todaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Plan'**
  String get todaysPlan;

  /// No description provided for @nothingScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for today'**
  String get nothingScheduledToday;

  /// No description provided for @nextItem.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextItem;

  /// No description provided for @medicationsToday.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medicationsToday;

  /// No description provided for @measurementsToday.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsToday;

  /// No description provided for @completedAndSkipped.
  ///
  /// In en, this message translates to:
  /// **'Completed & Skipped'**
  String get completedAndSkipped;

  /// No description provided for @markTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as Taken'**
  String get markTaken;

  /// No description provided for @snooze10min.
  ///
  /// In en, this message translates to:
  /// **'Snooze 10 min'**
  String get snooze10min;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @dueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get dueSoon;

  /// No description provided for @takeMedication.
  ///
  /// In en, this message translates to:
  /// **'Take {name}'**
  String takeMedication(Object name);

  /// No description provided for @completedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed at {time}'**
  String completedAt(Object time);

  /// No description provided for @overdueSince.
  ///
  /// In en, this message translates to:
  /// **'Overdue since {time}'**
  String overdueSince(Object time);

  /// No description provided for @noMedicationsToday.
  ///
  /// In en, this message translates to:
  /// **'No medication schedules for today'**
  String get noMedicationsToday;

  /// No description provided for @noMeasurementsToday.
  ///
  /// In en, this message translates to:
  /// **'No measurement schedules for today'**
  String get noMeasurementsToday;

  /// No description provided for @agenda.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @openDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get openDetails;

  /// No description provided for @failedToUpdateItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to update item'**
  String get failedToUpdateItem;

  /// No description provided for @changeToSkipped.
  ///
  /// In en, this message translates to:
  /// **'Change to Skipped'**
  String get changeToSkipped;

  /// No description provided for @changeToTaken.
  ///
  /// In en, this message translates to:
  /// **'Change to Taken'**
  String get changeToTaken;

  /// No description provided for @resetToPending.
  ///
  /// In en, this message translates to:
  /// **'Reset to Pending'**
  String get resetToPending;

  /// No description provided for @editReading.
  ///
  /// In en, this message translates to:
  /// **'Edit Reading'**
  String get editReading;

  /// No description provided for @dailyPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily Plan'**
  String get dailyPlan;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @returnToToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get returnToToday;

  /// No description provided for @scheduleStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on {date}'**
  String scheduleStartsOn(String date);

  /// No description provided for @scheduleUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String scheduleUntil(String date);

  /// No description provided for @nothingScheduledForThisDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled for this day'**
  String get nothingScheduledForThisDay;

  /// No description provided for @firstPlannedItem.
  ///
  /// In en, this message translates to:
  /// **'First planned item'**
  String get firstPlannedItem;

  /// No description provided for @scheduledAt.
  ///
  /// In en, this message translates to:
  /// **'Scheduled at {time}'**
  String scheduledAt(Object time);

  /// No description provided for @medicationsMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed medications'**
  String get medicationsMissed;

  /// No description provided for @measurementsMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed measurements'**
  String get measurementsMissed;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @patientProfile.
  ///
  /// In en, this message translates to:
  /// **'Patient Profile'**
  String get patientProfile;

  /// No description provided for @editPatientProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient Profile'**
  String get editPatientProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightKg;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @self_.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get self_;

  /// No description provided for @child_.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child_;

  /// No description provided for @spouse_.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get spouse_;

  /// No description provided for @parent_.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent_;

  /// No description provided for @sibling_.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get sibling_;

  /// No description provided for @grandparent_.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get grandparent_;

  /// No description provided for @grandchild_.
  ///
  /// In en, this message translates to:
  /// **'Grandchild'**
  String get grandchild_;

  /// No description provided for @other_.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other_;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @failedToSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get failedToSaveProfile;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch Profile'**
  String get switchProfile;

  /// No description provided for @noProfiles.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet'**
  String get noProfiles;

  /// No description provided for @createFirstProfile.
  ///
  /// In en, this message translates to:
  /// **'Create your first patient profile'**
  String get createFirstProfile;

  /// No description provided for @profileSummary.
  ///
  /// In en, this message translates to:
  /// **'Profile Summary'**
  String get profileSummary;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{years} years old'**
  String yearsOld(int years);

  /// No description provided for @activeProfile.
  ///
  /// In en, this message translates to:
  /// **'Active Profile'**
  String get activeProfile;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDateLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @emergencyContactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get emergencyContactNameLabel;

  /// No description provided for @emergencyContactPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get emergencyContactPhoneLabel;

  /// No description provided for @profileNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Profile not set up'**
  String get profileNotSetUp;

  /// No description provided for @profileNotSetUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a patient profile to get started.\nYour profile information will be used across the app.'**
  String get profileNotSetUpDescription;

  /// No description provided for @addProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'Add Profile Information'**
  String get addProfileInformation;

  /// No description provided for @profileInformationNotEntered.
  ///
  /// In en, this message translates to:
  /// **'Profile information has not been entered yet.'**
  String get profileInformationNotEntered;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @removeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removeProfilePhoto;

  /// No description provided for @photoSelectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Photo selection was cancelled'**
  String get photoSelectionCancelled;

  /// No description provided for @failedToLoadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to load photo'**
  String get failedToLoadPhoto;

  /// No description provided for @failedToSavePhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to save photo'**
  String get failedToSavePhoto;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take photos'**
  String get cameraPermissionRequired;

  /// No description provided for @nextItemGracePeriod.
  ///
  /// In en, this message translates to:
  /// **'Next item grace period'**
  String get nextItemGracePeriod;

  /// No description provided for @nextItemGracePeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep an unfinished item in Next for this long after its scheduled time.'**
  String get nextItemGracePeriodDescription;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesValue(int minutes);

  /// No description provided for @fiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get fiveMinutes;

  /// No description provided for @tenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get tenMinutes;

  /// No description provided for @fifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get fifteenMinutes;

  /// No description provided for @thirtyMinutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get thirtyMinutes;

  /// No description provided for @sixtyMinutes.
  ///
  /// In en, this message translates to:
  /// **'60 minutes'**
  String get sixtyMinutes;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @medicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Medication reminders'**
  String get medicationReminders;

  /// No description provided for @reminderSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get reminderSound;

  /// No description provided for @reminderVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get reminderVibration;

  /// No description provided for @reminderStyle.
  ///
  /// In en, this message translates to:
  /// **'Reminder style'**
  String get reminderStyle;

  /// No description provided for @reminderStyleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get reminderStyleStandard;

  /// No description provided for @reminderStyleStandardDescription.
  ///
  /// In en, this message translates to:
  /// **'Balanced alerts with the usual sound and vibration'**
  String get reminderStyleStandardDescription;

  /// No description provided for @reminderStyleProminent.
  ///
  /// In en, this message translates to:
  /// **'Prominent'**
  String get reminderStyleProminent;

  /// No description provided for @reminderStyleProminentDescription.
  ///
  /// In en, this message translates to:
  /// **'High-attention alerts that interrupt more strongly'**
  String get reminderStyleProminentDescription;

  /// No description provided for @defaultSnoozeDuration.
  ///
  /// In en, this message translates to:
  /// **'Default snooze duration'**
  String get defaultSnoozeDuration;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get notificationPermission;

  /// No description provided for @exactAlarmAccess.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm access'**
  String get exactAlarmAccess;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionDenied;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get permissionRequired;

  /// No description provided for @openNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open notification settings'**
  String get openNotificationSettings;

  /// No description provided for @openAlarmSettings.
  ///
  /// In en, this message translates to:
  /// **'Open alarm settings'**
  String get openAlarmSettings;

  /// No description provided for @androidNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Android notification settings'**
  String get androidNotificationSettings;

  /// No description provided for @androidNotificationSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage system notification categories, sounds, and alerts'**
  String get androidNotificationSettingsDescription;

  /// No description provided for @systemControls.
  ///
  /// In en, this message translates to:
  /// **'System controls'**
  String get systemControls;

  /// No description provided for @androidMayHideUnusedCategories.
  ///
  /// In en, this message translates to:
  /// **'Android may hide notification categories until they have been used.'**
  String get androidMayHideUnusedCategories;

  /// No description provided for @testMedicationReminder.
  ///
  /// In en, this message translates to:
  /// **'Test medication reminder'**
  String get testMedicationReminder;

  /// No description provided for @testMeasurementReminder.
  ///
  /// In en, this message translates to:
  /// **'Test measurement reminder'**
  String get testMeasurementReminder;

  /// No description provided for @testReminder.
  ///
  /// In en, this message translates to:
  /// **'Test reminder'**
  String get testReminder;

  /// No description provided for @testReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Reminder'**
  String get testReminderTitle;

  /// No description provided for @testReminderBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test reminder to verify notification sound, vibration, and presentation.'**
  String get testReminderBody;

  /// No description provided for @medicationReminder.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get medicationReminder;

  /// No description provided for @markAsTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as Taken'**
  String get markAsTaken;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @scheduleSavedReminderFailed.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved, but reminder could not be scheduled'**
  String get scheduleSavedReminderFailed;

  /// No description provided for @reminderSchedulingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not schedule reminder'**
  String get reminderSchedulingFailed;

  /// No description provided for @reminderDetails.
  ///
  /// In en, this message translates to:
  /// **'Reminder Details'**
  String get reminderDetails;

  /// No description provided for @reminderPermissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'RehabTrack needs notification permission to show reminders for medications and measurements.'**
  String get reminderPermissionExplanation;

  /// No description provided for @exactAlarmExplanation.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm permission allows reminders to appear at the precise scheduled time. Without it, reminder timing may be less precise.'**
  String get exactAlarmExplanation;

  /// No description provided for @alarmStyleReminders.
  ///
  /// In en, this message translates to:
  /// **'Alarm-style presentation'**
  String get alarmStyleReminders;

  /// No description provided for @alarmStyle.
  ///
  /// In en, this message translates to:
  /// **'Alarm-style'**
  String get alarmStyle;

  /// No description provided for @alarmStyleDescription.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarms with the strongest sound and vibration that interrupt even on the lock screen'**
  String get alarmStyleDescription;

  /// No description provided for @alarmStyleCapabilityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarms available'**
  String get alarmStyleCapabilityAvailable;

  /// No description provided for @alarmStyleCapabilityNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Alarm-style reminders present as prominent alerts because full-screen access is not available'**
  String get alarmStyleCapabilityNotAvailable;

  /// No description provided for @alarmStyleCapabilityNotificationPermissionMissing.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to show alarm-style reminders'**
  String get alarmStyleCapabilityNotificationPermissionMissing;

  /// No description provided for @alarmStyleCapabilityExactAlarmMissing.
  ///
  /// In en, this message translates to:
  /// **'Exact alarm access is required for precise alarm timing'**
  String get alarmStyleCapabilityExactAlarmMissing;

  /// No description provided for @alarmStyleCapabilityChannelDisabled.
  ///
  /// In en, this message translates to:
  /// **'The alarm notification channel is disabled; enable it in Android notification settings'**
  String get alarmStyleCapabilityChannelDisabled;

  /// No description provided for @alarmStyleCapabilityUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alarms require Android 14 or later; alarm-style reminders use a prominent alert instead'**
  String get alarmStyleCapabilityUnsupported;

  /// No description provided for @manageAlarmStyleAccess.
  ///
  /// In en, this message translates to:
  /// **'Manage alarm-style access'**
  String get manageAlarmStyleAccess;

  /// No description provided for @manageAlarmStyleAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Open system settings to allow or deny full-screen notifications'**
  String get manageAlarmStyleAccessDescription;

  /// No description provided for @fullScreenRemindersAllowed.
  ///
  /// In en, this message translates to:
  /// **'Full-screen reminders are allowed'**
  String get fullScreenRemindersAllowed;

  /// No description provided for @fullScreenRemindersNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Full-screen reminders are not allowed'**
  String get fullScreenRemindersNotAllowed;

  /// No description provided for @testAlarmStyleTile.
  ///
  /// In en, this message translates to:
  /// **'Test alarm-style reminder'**
  String get testAlarmStyleTile;

  /// No description provided for @alarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm sound'**
  String get alarmSound;

  /// No description provided for @alarmSoundSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get alarmSoundSystemDefault;

  /// No description provided for @alarmSoundCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom sound'**
  String get alarmSoundCustom;

  /// No description provided for @alarmSoundChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose sound'**
  String get alarmSoundChoose;

  /// No description provided for @alarmSoundTest.
  ///
  /// In en, this message translates to:
  /// **'Test sound'**
  String get alarmSoundTest;

  /// No description provided for @alarmSoundStopTest.
  ///
  /// In en, this message translates to:
  /// **'Stop test'**
  String get alarmSoundStopTest;

  /// No description provided for @alarmSoundPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play the sound preview'**
  String get alarmSoundPreviewFailed;

  /// No description provided for @alarmStyleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Alarm-style reminders are not available on this device'**
  String get alarmStyleUnavailable;

  /// No description provided for @lockScreenReminderDetails.
  ///
  /// In en, this message translates to:
  /// **'Show full reminder details on lock screen'**
  String get lockScreenReminderDetails;

  /// No description provided for @alarmReminder.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarmReminder;

  /// No description provided for @alarmDismissed.
  ///
  /// In en, this message translates to:
  /// **'Alarm dismissed'**
  String get alarmDismissed;

  /// No description provided for @scheduledHealthReminder.
  ///
  /// In en, this message translates to:
  /// **'You have a scheduled health reminder'**
  String get scheduledHealthReminder;

  /// No description provided for @doctorVisitReminder.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit reminder'**
  String get doctorVisitReminder;

  /// No description provided for @measurementToRecord.
  ///
  /// In en, this message translates to:
  /// **'Record {type} at {time}'**
  String measurementToRecord(String type, String time);

  /// No description provided for @dismissTestAlarm.
  ///
  /// In en, this message translates to:
  /// **'Dismiss test alarm'**
  String get dismissTestAlarm;

  /// No description provided for @testAlarmStyleReminder.
  ///
  /// In en, this message translates to:
  /// **'Alarm-style test'**
  String get testAlarmStyleReminder;

  /// No description provided for @testAlarmStyleBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test of the alarm-style presentation. Press Dismiss to stop it.'**
  String get testAlarmStyleBody;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'No permission'**
  String get noPermission;

  /// No description provided for @channelDisabled.
  ///
  /// In en, this message translates to:
  /// **'Channel disabled'**
  String get channelDisabled;

  /// No description provided for @scheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved'**
  String get scheduleSaved;

  /// No description provided for @notGranted.
  ///
  /// In en, this message translates to:
  /// **'Not granted'**
  String get notGranted;

  /// No description provided for @notRequired.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get notRequired;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request permission'**
  String get requestPermission;

  /// No description provided for @reminderWarningNoPermission.
  ///
  /// In en, this message translates to:
  /// **'Reminders cannot be displayed because notification permission is denied.'**
  String get reminderWarningNoPermission;

  /// No description provided for @reminderWarningNoExactAlarm.
  ///
  /// In en, this message translates to:
  /// **'Reminder timing may be less precise without exact alarm access.'**
  String get reminderWarningNoExactAlarm;

  /// No description provided for @snoozeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Snooze for {minutes} minutes'**
  String snoozeMinutes(Object minutes);

  /// No description provided for @healthReminder.
  ///
  /// In en, this message translates to:
  /// **'Health reminder'**
  String get healthReminder;

  /// No description provided for @healthReminderLockScreen.
  ///
  /// In en, this message translates to:
  /// **'Open RehabTrack for details'**
  String get healthReminderLockScreen;

  /// No description provided for @remindersNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Reminders not available'**
  String get remindersNotAvailable;

  /// No description provided for @testReminderSent.
  ///
  /// In en, this message translates to:
  /// **'Test reminder sent! Check your notifications.'**
  String get testReminderSent;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @inactiveMedications.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveMedications;

  /// No description provided for @showDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Show deactivated'**
  String get showDeactivated;

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// No description provided for @confirmReactivate.
  ///
  /// In en, this message translates to:
  /// **'This medication will be reactivated. Its history will be preserved.'**
  String get confirmReactivate;

  /// No description provided for @noInactiveMedications.
  ///
  /// In en, this message translates to:
  /// **'No inactive medications'**
  String get noInactiveMedications;

  /// No description provided for @careContacts.
  ///
  /// In en, this message translates to:
  /// **'Care Contacts'**
  String get careContacts;

  /// No description provided for @addCareContact.
  ///
  /// In en, this message translates to:
  /// **'Add Care Contact'**
  String get addCareContact;

  /// No description provided for @editCareContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Care Contact'**
  String get editCareContact;

  /// No description provided for @careContactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get careContactDetails;

  /// No description provided for @contactType.
  ///
  /// In en, this message translates to:
  /// **'Contact Type'**
  String get contactType;

  /// No description provided for @doctorOrSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Doctor or Specialist'**
  String get doctorOrSpecialist;

  /// No description provided for @clinicOrHospital.
  ///
  /// In en, this message translates to:
  /// **'Clinic or Hospital'**
  String get clinicOrHospital;

  /// No description provided for @laboratory.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get laboratory;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @insuranceCompany.
  ///
  /// In en, this message translates to:
  /// **'Insurance Company'**
  String get insuranceCompany;

  /// No description provided for @allContacts.
  ///
  /// In en, this message translates to:
  /// **'All Contacts'**
  String get allContacts;

  /// No description provided for @organizations.
  ///
  /// In en, this message translates to:
  /// **'Organizations'**
  String get organizations;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @archivedContacts.
  ///
  /// In en, this message translates to:
  /// **'Archived Contacts'**
  String get archivedContacts;

  /// No description provided for @noCareContacts.
  ///
  /// In en, this message translates to:
  /// **'No care contacts yet'**
  String get noCareContacts;

  /// No description provided for @noCareContactsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add doctors, clinics, laboratories, pharmacies, or insurance contacts.'**
  String get noCareContactsDescription;

  /// No description provided for @noArchivedContacts.
  ///
  /// In en, this message translates to:
  /// **'No archived contacts'**
  String get noArchivedContacts;

  /// No description provided for @noArchivedContactsDescription.
  ///
  /// In en, this message translates to:
  /// **'Archived contacts will appear here and can be restored.'**
  String get noArchivedContactsDescription;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @organizationName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get organizationName;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPerson;

  /// No description provided for @primaryPhone.
  ///
  /// In en, this message translates to:
  /// **'Primary Phone'**
  String get primaryPhone;

  /// No description provided for @secondaryPhone.
  ///
  /// In en, this message translates to:
  /// **'Secondary Phone'**
  String get secondaryPhone;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @policyNumber.
  ///
  /// In en, this message translates to:
  /// **'Policy Number'**
  String get policyNumber;

  /// No description provided for @memberNumber.
  ///
  /// In en, this message translates to:
  /// **'Member or Customer Number'**
  String get memberNumber;

  /// No description provided for @policyNotes.
  ///
  /// In en, this message translates to:
  /// **'Policy Notes'**
  String get policyNotes;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get sendEmail;

  /// No description provided for @openWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open website'**
  String get openWebsite;

  /// No description provided for @openAddress.
  ///
  /// In en, this message translates to:
  /// **'Open address'**
  String get openAddress;

  /// No description provided for @selectContactType.
  ///
  /// In en, this message translates to:
  /// **'Select Contact Type'**
  String get selectContactType;

  /// No description provided for @contactSaved.
  ///
  /// In en, this message translates to:
  /// **'Contact saved'**
  String get contactSaved;

  /// No description provided for @contactUpdated.
  ///
  /// In en, this message translates to:
  /// **'Contact updated'**
  String get contactUpdated;

  /// No description provided for @contactArchived.
  ///
  /// In en, this message translates to:
  /// **'Contact archived'**
  String get contactArchived;

  /// No description provided for @contactRestored.
  ///
  /// In en, this message translates to:
  /// **'Contact restored'**
  String get contactRestored;

  /// No description provided for @contactDeleted.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted'**
  String get contactDeleted;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @invalidWebsite.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid website URL'**
  String get invalidWebsite;

  /// No description provided for @confirmArchiveContact.
  ///
  /// In en, this message translates to:
  /// **'Archive this contact? It will be hidden from the active list but kept safely.'**
  String get confirmArchiveContact;

  /// No description provided for @confirmDeleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete this contact permanently? This cannot be undone.'**
  String get confirmDeleteContact;

  /// No description provided for @confirmRestoreContact.
  ///
  /// In en, this message translates to:
  /// **'Restore this contact to the active list?'**
  String get confirmRestoreContact;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @failedToSaveContactPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to save photo'**
  String get failedToSaveContactPhoto;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// No description provided for @noContactsFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get noContactsFoundDescription;

  /// No description provided for @searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get searchContacts;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @showActive.
  ///
  /// In en, this message translates to:
  /// **'Show active'**
  String get showActive;

  /// No description provided for @editCareContactFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save contact'**
  String get editCareContactFailed;

  /// No description provided for @deleteContactFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete contact'**
  String get deleteContactFailed;

  /// No description provided for @policyAndMemberDetails.
  ///
  /// In en, this message translates to:
  /// **'Policy Details'**
  String get policyAndMemberDetails;

  /// No description provided for @professionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get professionalInformation;

  /// No description provided for @organizationInformation.
  ///
  /// In en, this message translates to:
  /// **'Organization Information'**
  String get organizationInformation;

  /// No description provided for @personalInformationLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformationLabel;

  /// No description provided for @careContactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Doctors, clinics, laboratories, pharmacies, and insurance companies'**
  String get careContactsSubtitle;

  /// No description provided for @contactNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Contact not found'**
  String get contactNotAvailable;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @plannedVisit.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get plannedVisit;

  /// No description provided for @onDemandVisit.
  ///
  /// In en, this message translates to:
  /// **'On demand'**
  String get onDemandVisit;

  /// No description provided for @oneWeekBefore.
  ///
  /// In en, this message translates to:
  /// **'1 week before'**
  String get oneWeekBefore;

  /// No description provided for @twoDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'2 days before'**
  String get twoDaysBefore;

  /// No description provided for @oneDayBefore.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get oneDayBefore;

  /// No description provided for @twoHoursBefore.
  ///
  /// In en, this message translates to:
  /// **'2 hours before'**
  String get twoHoursBefore;

  /// No description provided for @oneHourBefore.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get oneHourBefore;

  /// No description provided for @thirtyMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get thirtyMinutesBefore;

  /// No description provided for @fifteenMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'15 minutes before'**
  String get fifteenMinutesBefore;

  /// No description provided for @addDoctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Add Doctor Visit'**
  String get addDoctorVisit;

  /// No description provided for @editDoctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Edit Doctor Visit'**
  String get editDoctorVisit;

  /// No description provided for @upcomingVisits.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingVisits;

  /// No description provided for @doctorVisitsUpcomingBadgeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Doctor Visits, {count, plural, =1{1 upcoming visit} other{{count} upcoming visits}}'**
  String doctorVisitsUpcomingBadgeSemantics(int count);

  /// No description provided for @visitHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get visitHistory;

  /// No description provided for @noUpcomingVisits.
  ///
  /// In en, this message translates to:
  /// **'No upcoming visits'**
  String get noUpcomingVisits;

  /// No description provided for @noVisitHistory.
  ///
  /// In en, this message translates to:
  /// **'No visit history'**
  String get noVisitHistory;

  /// No description provided for @noUpcomingVisitsDescription.
  ///
  /// In en, this message translates to:
  /// **'Planned visits will appear here.'**
  String get noUpcomingVisitsDescription;

  /// No description provided for @noVisitHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Completed, cancelled, and missed visits will appear here.'**
  String get noVisitHistoryDescription;

  /// No description provided for @contactNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get contactNotSelected;

  /// No description provided for @visitReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for visit'**
  String get visitReason;

  /// No description provided for @remindMe.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get remindMe;

  /// No description provided for @remindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind before'**
  String get remindBefore;

  /// No description provided for @saveVisitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save visit'**
  String get saveVisitFailed;

  /// No description provided for @visitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Visit updated'**
  String get visitUpdated;

  /// No description provided for @visitSaved.
  ///
  /// In en, this message translates to:
  /// **'Visit saved'**
  String get visitSaved;

  /// No description provided for @doctorVisitDetails.
  ///
  /// In en, this message translates to:
  /// **'Visit Details'**
  String get doctorVisitDetails;

  /// No description provided for @visitNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'This visit is past due — mark it completed, cancelled, or missed.'**
  String get visitNeedsAttention;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get markCompleted;

  /// No description provided for @markMissed.
  ///
  /// In en, this message translates to:
  /// **'Mark missed'**
  String get markMissed;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @cancelVisit.
  ///
  /// In en, this message translates to:
  /// **'Cancel visit'**
  String get cancelVisit;

  /// No description provided for @visitCompleted.
  ///
  /// In en, this message translates to:
  /// **'Visit marked as completed'**
  String get visitCompleted;

  /// No description provided for @visitCancelled.
  ///
  /// In en, this message translates to:
  /// **'Visit cancelled'**
  String get visitCancelled;

  /// No description provided for @visitMissed.
  ///
  /// In en, this message translates to:
  /// **'Visit marked as missed'**
  String get visitMissed;

  /// No description provided for @confirmDeleteVisit.
  ///
  /// In en, this message translates to:
  /// **'Delete this visit permanently? This cannot be undone.'**
  String get confirmDeleteVisit;

  /// No description provided for @visitDeleted.
  ///
  /// In en, this message translates to:
  /// **'Visit deleted'**
  String get visitDeleted;

  /// No description provided for @saveAsScheduledLater.
  ///
  /// In en, this message translates to:
  /// **'Save as scheduled later'**
  String get saveAsScheduledLater;

  /// No description provided for @onDemandRecordedCompleted.
  ///
  /// In en, this message translates to:
  /// **'On-demand visits are recorded as completed right away. Enable this to schedule it in the future instead.'**
  String get onDemandRecordedCompleted;

  /// No description provided for @scheduledDateTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled date and time'**
  String get scheduledDateTime;

  /// No description provided for @visitType.
  ///
  /// In en, this message translates to:
  /// **'Visit type'**
  String get visitType;

  /// No description provided for @selectDoctor.
  ///
  /// In en, this message translates to:
  /// **'Select doctor'**
  String get selectDoctor;

  /// No description provided for @selectClinicOrHospital.
  ///
  /// In en, this message translates to:
  /// **'Select clinic or hospital'**
  String get selectClinicOrHospital;

  /// No description provided for @noEligibleContacts.
  ///
  /// In en, this message translates to:
  /// **'No eligible contacts. Add a care contact first.'**
  String get noEligibleContacts;

  /// No description provided for @untitledContact.
  ///
  /// In en, this message translates to:
  /// **'Untitled contact'**
  String get untitledContact;

  /// No description provided for @contactReferencedByVisits.
  ///
  /// In en, this message translates to:
  /// **'This contact is used by a doctor visit and cannot be permanently deleted.'**
  String get contactReferencedByVisits;

  /// No description provided for @backupLastCreated.
  ///
  /// In en, this message translates to:
  /// **'Last backup created: {time}'**
  String backupLastCreated(Object time);

  /// No description provided for @restoreLastCompleted.
  ///
  /// In en, this message translates to:
  /// **'Last restore completed: {time}'**
  String restoreLastCompleted(Object time);

  /// No description provided for @restoreCancellationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Restoring is in progress and cannot be cancelled right now.'**
  String get restoreCancellationUnavailable;

  /// No description provided for @restoreNotEnoughStorage.
  ///
  /// In en, this message translates to:
  /// **'There is not enough free storage space to run the restore. No data was changed.'**
  String get restoreNotEnoughStorage;

  /// No description provided for @backupStoredAs.
  ///
  /// In en, this message translates to:
  /// **'Stored as: {name}'**
  String backupStoredAs(Object name);

  /// No description provided for @manageBackups.
  ///
  /// In en, this message translates to:
  /// **'Manage Backups'**
  String get manageBackups;

  /// No description provided for @manageBackupsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No backups have been created yet'**
  String get manageBackupsEmpty;

  /// No description provided for @manageBackupsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Backups you create appear here so you can inspect, restore, share or delete them.'**
  String get manageBackupsEmptyHint;

  /// No description provided for @manageBackupsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your backups.'**
  String get manageBackupsLoadFailed;

  /// No description provided for @manageBackupsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get manageBackupsUnavailable;

  /// No description provided for @manageBackupsUnavailableDetail.
  ///
  /// In en, this message translates to:
  /// **'This file is no longer available. It may have been moved, renamed or removed.'**
  String get manageBackupsUnavailableDetail;

  /// No description provided for @manageBackupsShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get manageBackupsShare;

  /// No description provided for @manageBackupsShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share this backup.'**
  String get manageBackupsShareFailed;

  /// No description provided for @manageBackupsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get manageBackupsDelete;

  /// No description provided for @manageBackupsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete backup?'**
  String get manageBackupsDeleteTitle;

  /// No description provided for @manageBackupsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the backup file. This action cannot be undone.'**
  String get manageBackupsDeleteConfirm;

  /// No description provided for @manageBackupsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Backup deleted'**
  String get manageBackupsDeleted;

  /// No description provided for @manageBackupsDeleteUnresolved.
  ///
  /// In en, this message translates to:
  /// **'The backup file could not be resolved, so it was removed from this list.'**
  String get manageBackupsDeleteUnresolved;

  /// No description provided for @manageBackupsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get manageBackupsRestore;

  /// No description provided for @manageBackupsRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get manageBackupsRestoreTitle;

  /// No description provided for @manageBackupsRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore will replace your current data with the contents of this backup.'**
  String get manageBackupsRestoreConfirm;

  /// No description provided for @manageBackupsRestoreCancelled.
  ///
  /// In en, this message translates to:
  /// **'Restore cancelled.'**
  String get manageBackupsRestoreCancelled;

  /// No description provided for @importExistingBackups.
  ///
  /// In en, this message translates to:
  /// **'Import Existing Backups'**
  String get importExistingBackups;

  /// No description provided for @importBackups.
  ///
  /// In en, this message translates to:
  /// **'Import backups'**
  String get importBackups;

  /// No description provided for @backupsImported.
  ///
  /// In en, this message translates to:
  /// **'{count} backups imported'**
  String backupsImported(Object count);

  /// No description provided for @backupsAlreadyPresent.
  ///
  /// In en, this message translates to:
  /// **'{count} backups were already in your list and were updated'**
  String backupsAlreadyPresent(Object count);

  /// No description provided for @invalidBackupSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} files were not valid RehabTrack backups and were skipped'**
  String invalidBackupSkipped(Object count);

  /// No description provided for @backupImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import the selected files.'**
  String get backupImportFailed;

  /// No description provided for @backupImportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled.'**
  String get backupImportCancelled;

  /// No description provided for @backupUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get backupUnavailable;

  /// No description provided for @backupFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Backup file not found'**
  String get backupFileNotFound;

  /// No description provided for @removeFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove from List'**
  String get removeFromList;

  /// No description provided for @confirmRemoveBackupFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove this backup from the list? Its file is no longer available, so nothing will be deleted from storage.'**
  String get confirmRemoveBackupFromList;

  /// No description provided for @backupRemovedFromList.
  ///
  /// In en, this message translates to:
  /// **'Backup removed from list'**
  String get backupRemovedFromList;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unknownAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability unknown'**
  String get unknownAvailability;

  /// No description provided for @fileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'File unavailable'**
  String get fileUnavailable;

  /// No description provided for @refreshingBackupAvailability.
  ///
  /// In en, this message translates to:
  /// **'Refreshing backup availability'**
  String get refreshingBackupAvailability;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @addLabAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Add Lab Analysis'**
  String get addLabAnalysis;

  /// No description provided for @editLabAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Edit Lab Analysis'**
  String get editLabAnalysis;

  /// No description provided for @labAnalysisDetails.
  ///
  /// In en, this message translates to:
  /// **'Lab Analysis Details'**
  String get labAnalysisDetails;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get analysisTitle;

  /// No description provided for @analysisTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Blood test, MRI report, ECG'**
  String get analysisTitleHint;

  /// No description provided for @analysisCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get analysisCategory;

  /// No description provided for @analysisDate.
  ///
  /// In en, this message translates to:
  /// **'Analysis Date'**
  String get analysisDate;

  /// No description provided for @resultReceivedDate.
  ///
  /// In en, this message translates to:
  /// **'Result Received Date'**
  String get resultReceivedDate;

  /// No description provided for @laboratoryOrClinic.
  ///
  /// In en, this message translates to:
  /// **'Laboratory / Clinic'**
  String get laboratoryOrClinic;

  /// No description provided for @orderingDoctor.
  ///
  /// In en, this message translates to:
  /// **'Ordering Doctor'**
  String get orderingDoctor;

  /// No description provided for @relatedDoctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Related Doctor Visit'**
  String get relatedDoctorVisit;

  /// No description provided for @analysisNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get analysisNotes;

  /// No description provided for @analysisNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this analysis'**
  String get analysisNotesHint;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachment;

  /// No description provided for @addPdf.
  ///
  /// In en, this message translates to:
  /// **'Add PDF'**
  String get addPdf;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @openAttachment.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openAttachment;

  /// No description provided for @shareAttachment.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAttachment;

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAttachment;

  /// No description provided for @renameAttachment.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameAttachment;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @cardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get cardiology;

  /// No description provided for @imaging.
  ///
  /// In en, this message translates to:
  /// **'Imaging'**
  String get imaging;

  /// No description provided for @pathology.
  ///
  /// In en, this message translates to:
  /// **'Pathology'**
  String get pathology;

  /// No description provided for @allAnalyses.
  ///
  /// In en, this message translates to:
  /// **'All Analyses'**
  String get allAnalyses;

  /// No description provided for @seeArchivedAnalyses.
  ///
  /// In en, this message translates to:
  /// **'See Archived Records'**
  String get seeArchivedAnalyses;

  /// No description provided for @showArchivedAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Show archived analyses'**
  String get showArchivedAnalyses;

  /// No description provided for @showingArchivedAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Showing archived analyses'**
  String get showingArchivedAnalyses;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @archivedAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Archived Analyses'**
  String get archivedAnalyses;

  /// No description provided for @noLabAnalyses.
  ///
  /// In en, this message translates to:
  /// **'No lab analyses yet'**
  String get noLabAnalyses;

  /// No description provided for @noLabAnalysesDesc.
  ///
  /// In en, this message translates to:
  /// **'Add PDFs, scans, or photos of your medical analyses.'**
  String get noLabAnalysesDesc;

  /// No description provided for @noArchivedAnalyses.
  ///
  /// In en, this message translates to:
  /// **'No archived analyses'**
  String get noArchivedAnalyses;

  /// No description provided for @noArchivedAnalysesDesc.
  ///
  /// In en, this message translates to:
  /// **'Archived analyses will appear here.'**
  String get noArchivedAnalysesDesc;

  /// No description provided for @analysisSaved.
  ///
  /// In en, this message translates to:
  /// **'Analysis saved'**
  String get analysisSaved;

  /// No description provided for @analysisUpdated.
  ///
  /// In en, this message translates to:
  /// **'Analysis updated'**
  String get analysisUpdated;

  /// No description provided for @analysisArchived.
  ///
  /// In en, this message translates to:
  /// **'Analysis archived'**
  String get analysisArchived;

  /// No description provided for @analysisRestored.
  ///
  /// In en, this message translates to:
  /// **'Analysis restored'**
  String get analysisRestored;

  /// No description provided for @analysisDeleted.
  ///
  /// In en, this message translates to:
  /// **'Analysis deleted'**
  String get analysisDeleted;

  /// No description provided for @unsupportedFileType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type. Please select a PDF, JPG, JPEG, or PNG file.'**
  String get unsupportedFileType;

  /// No description provided for @attachmentMissing.
  ///
  /// In en, this message translates to:
  /// **'Attachment file is missing'**
  String get attachmentMissing;

  /// No description provided for @couldNotOpenAttachment.
  ///
  /// In en, this message translates to:
  /// **'Could not open attachment'**
  String get couldNotOpenAttachment;

  /// No description provided for @couldNotShareAttachment.
  ///
  /// In en, this message translates to:
  /// **'Could not share attachment'**
  String get couldNotShareAttachment;

  /// No description provided for @confirmRemoveAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove this attachment?'**
  String get confirmRemoveAttachment;

  /// No description provided for @confirmDeleteAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Delete this analysis permanently? All attachments will be removed.'**
  String get confirmDeleteAnalysis;

  /// No description provided for @deleteAnalysisAndAttachments.
  ///
  /// In en, this message translates to:
  /// **'Delete analysis and all attachments'**
  String get deleteAnalysisAndAttachments;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @titleAscending.
  ///
  /// In en, this message translates to:
  /// **'Title (A–Z)'**
  String get titleAscending;

  /// No description provided for @contactNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'Contact no longer available'**
  String get contactNoLongerAvailable;

  /// No description provided for @visitNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'Visit no longer available'**
  String get visitNoLongerAvailable;

  /// No description provided for @analysisTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get analysisTitleRequired;

  /// No description provided for @resultDateBeforeAnalysisDate.
  ///
  /// In en, this message translates to:
  /// **'Result received date cannot be before analysis date'**
  String get resultDateBeforeAnalysisDate;

  /// No description provided for @existingAttachments.
  ///
  /// In en, this message translates to:
  /// **'Existing Attachments'**
  String get existingAttachments;

  /// No description provided for @newAttachments.
  ///
  /// In en, this message translates to:
  /// **'New Attachments'**
  String get newAttachments;

  /// No description provided for @activeAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Active Analyses'**
  String get activeAnalyses;

  /// No description provided for @archiveAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Archive Analysis'**
  String get archiveAnalysis;

  /// No description provided for @archiveAnalysisConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Archive this analysis? It will be moved to the archived list but can be restored.'**
  String get archiveAnalysisConfirmation;

  /// No description provided for @restoreAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Restore Analysis'**
  String get restoreAnalysis;

  /// No description provided for @deleteLabAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Delete Lab Analysis'**
  String get deleteLabAnalysis;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// No description provided for @failedToSaveAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Failed to save analysis'**
  String get failedToSaveAnalysis;

  /// No description provided for @analysisAlreadyInProgress.
  ///
  /// In en, this message translates to:
  /// **'A restore is already in progress.'**
  String get analysisAlreadyInProgress;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// No description provided for @openImage.
  ///
  /// In en, this message translates to:
  /// **'Open Image'**
  String get openImage;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @selectContact.
  ///
  /// In en, this message translates to:
  /// **'Select contact'**
  String get selectContact;

  /// No description provided for @selectDoctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Select doctor visit'**
  String get selectDoctorVisit;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @updateLabAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Update Lab Analysis'**
  String get updateLabAnalysis;

  /// No description provided for @saveLabAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Save Lab Analysis'**
  String get saveLabAnalysis;

  /// No description provided for @noActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'No active profile'**
  String get noActiveProfile;

  /// No description provided for @createProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a patient profile first to get started.'**
  String get createProfileFirst;

  /// No description provided for @errorLoadingAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load lab analyses'**
  String get errorLoadingAnalyses;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Search lab analyses'**
  String get searchAnalyses;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @newAttachment.
  ///
  /// In en, this message translates to:
  /// **'New attachment'**
  String get newAttachment;

  /// No description provided for @doctorPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Doctor Prescriptions'**
  String get doctorPrescriptions;

  /// No description provided for @addDoctorPrescription.
  ///
  /// In en, this message translates to:
  /// **'Add Prescription'**
  String get addDoctorPrescription;

  /// No description provided for @editDoctorPrescription.
  ///
  /// In en, this message translates to:
  /// **'Edit Prescription'**
  String get editDoctorPrescription;

  /// No description provided for @doctorPrescriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Prescription Details'**
  String get doctorPrescriptionDetails;

  /// No description provided for @prescriptionName.
  ///
  /// In en, this message translates to:
  /// **'Prescription Name'**
  String get prescriptionName;

  /// No description provided for @prescriptionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Amoxicillin 500mg, Blood pressure medication'**
  String get prescriptionNameHint;

  /// No description provided for @prescriptionNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Prescription name is required'**
  String get prescriptionNameRequired;

  /// No description provided for @prescriptionDate.
  ///
  /// In en, this message translates to:
  /// **'Prescription Date'**
  String get prescriptionDate;

  /// No description provided for @prescriptionReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get prescriptionReason;

  /// No description provided for @prescriptionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Optional reason for this prescription'**
  String get prescriptionReasonHint;

  /// No description provided for @prescriptionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get prescriptionNotes;

  /// No description provided for @prescriptionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this prescription'**
  String get prescriptionNotesHint;

  /// No description provided for @updateDoctorPrescription.
  ///
  /// In en, this message translates to:
  /// **'Update Prescription'**
  String get updateDoctorPrescription;

  /// No description provided for @saveDoctorPrescription.
  ///
  /// In en, this message translates to:
  /// **'Save Prescription'**
  String get saveDoctorPrescription;

  /// No description provided for @prescriptionSaved.
  ///
  /// In en, this message translates to:
  /// **'Prescription saved'**
  String get prescriptionSaved;

  /// No description provided for @prescriptionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Prescription updated'**
  String get prescriptionUpdated;

  /// No description provided for @prescriptionArchived.
  ///
  /// In en, this message translates to:
  /// **'Prescription archived'**
  String get prescriptionArchived;

  /// No description provided for @prescriptionRestored.
  ///
  /// In en, this message translates to:
  /// **'Prescription restored'**
  String get prescriptionRestored;

  /// No description provided for @prescriptionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Prescription deleted'**
  String get prescriptionDeleted;

  /// No description provided for @archivePrescription.
  ///
  /// In en, this message translates to:
  /// **'Archive Prescription'**
  String get archivePrescription;

  /// No description provided for @archivePrescriptionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Archive this prescription? It will be moved to the archived list but can be restored.'**
  String get archivePrescriptionConfirmation;

  /// No description provided for @restorePrescription.
  ///
  /// In en, this message translates to:
  /// **'Restore Prescription'**
  String get restorePrescription;

  /// No description provided for @deleteDoctorPrescription.
  ///
  /// In en, this message translates to:
  /// **'Delete Prescription'**
  String get deleteDoctorPrescription;

  /// No description provided for @confirmDeletePrescription.
  ///
  /// In en, this message translates to:
  /// **'Delete this prescription permanently? All attachments will be removed.'**
  String get confirmDeletePrescription;

  /// No description provided for @noDoctorPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'No prescriptions yet'**
  String get noDoctorPrescriptions;

  /// No description provided for @noDoctorPrescriptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add PDFs, scans, or photos of your prescriptions.'**
  String get noDoctorPrescriptionsDesc;

  /// No description provided for @noArchivedPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'No archived prescriptions'**
  String get noArchivedPrescriptions;

  /// No description provided for @noArchivedPrescriptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Archived prescriptions will appear here.'**
  String get noArchivedPrescriptionsDesc;

  /// No description provided for @archivedPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Archived Prescriptions'**
  String get archivedPrescriptions;

  /// No description provided for @seeArchivedPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'See Archived Prescriptions'**
  String get seeArchivedPrescriptions;

  /// No description provided for @activePrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Prescriptions'**
  String get activePrescriptions;

  /// No description provided for @showArchivedPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Show archived prescriptions'**
  String get showArchivedPrescriptions;

  /// No description provided for @showingArchivedPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Showing archived prescriptions'**
  String get showingArchivedPrescriptions;

  /// No description provided for @allPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'All Prescriptions'**
  String get allPrescriptions;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @searchPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Search prescriptions'**
  String get searchPrescriptions;

  /// No description provided for @errorLoadingPrescriptions.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load prescriptions'**
  String get errorLoadingPrescriptions;

  /// No description provided for @createMedication.
  ///
  /// In en, this message translates to:
  /// **'Create Medication'**
  String get createMedication;

  /// No description provided for @noMedicationInfoEntered.
  ///
  /// In en, this message translates to:
  /// **'No medication information was entered'**
  String get noMedicationInfoEntered;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @timing.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get timing;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @medicationNotes.
  ///
  /// In en, this message translates to:
  /// **'Medication Notes'**
  String get medicationNotes;

  /// No description provided for @noMedicationsInPrescription.
  ///
  /// In en, this message translates to:
  /// **'No medications in this prescription'**
  String get noMedicationsInPrescription;

  /// No description provided for @medicationsCount.
  ///
  /// In en, this message translates to:
  /// **'Medications: {count}'**
  String medicationsCount(Object count);

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get enterManually;

  /// No description provided for @chooseFromMyMedications.
  ///
  /// In en, this message translates to:
  /// **'Choose from My Medications'**
  String get chooseFromMyMedications;

  /// No description provided for @myMedications.
  ///
  /// In en, this message translates to:
  /// **'My Medications'**
  String get myMedications;

  /// No description provided for @selectActiveMedication.
  ///
  /// In en, this message translates to:
  /// **'Select Active Medication'**
  String get selectActiveMedication;

  /// No description provided for @searchMyMedications.
  ///
  /// In en, this message translates to:
  /// **'Search My Medications'**
  String get searchMyMedications;

  /// No description provided for @noActiveMedicationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No active medications available'**
  String get noActiveMedicationsAvailable;

  /// No description provided for @noActiveMedicationsAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'Add a medication in the Medications section first, or enter the details manually.'**
  String get noActiveMedicationsAvailableHint;

  /// No description provided for @prefilledFromMedication.
  ///
  /// In en, this message translates to:
  /// **'Copied from My Medications — edit the details as needed before saving.'**
  String get prefilledFromMedication;

  /// No description provided for @attachmentRenamed.
  ///
  /// In en, this message translates to:
  /// **'Attachment renamed'**
  String get attachmentRenamed;

  /// No description provided for @attachmentRemoved.
  ///
  /// In en, this message translates to:
  /// **'Attachment removed'**
  String get attachmentRemoved;

  /// No description provided for @foods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get foods;

  /// No description provided for @generalGuidance.
  ///
  /// In en, this message translates to:
  /// **'General Guidance'**
  String get generalGuidance;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get searchFoods;

  /// No description provided for @searchGuidance.
  ///
  /// In en, this message translates to:
  /// **'Search general guidance'**
  String get searchGuidance;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @caution.
  ///
  /// In en, this message translates to:
  /// **'Caution'**
  String get caution;

  /// No description provided for @avoid.
  ///
  /// In en, this message translates to:
  /// **'Avoid'**
  String get avoid;

  /// No description provided for @allDietItems.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allDietItems;

  /// No description provided for @allGuidanceRules.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allGuidanceRules;

  /// No description provided for @dietGuidanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get dietGuidanceCategory;

  /// No description provided for @smokingGuidanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get smokingGuidanceCategory;

  /// No description provided for @hydrationGuidanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydrationGuidanceCategory;

  /// No description provided for @caffeineGuidanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Caffeine'**
  String get caffeineGuidanceCategory;

  /// No description provided for @alcoholGuidanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcoholGuidanceCategory;

  /// No description provided for @otherGuidanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherGuidanceCategory;

  /// No description provided for @alphabeticalAZ.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get alphabeticalAZ;

  /// No description provided for @alphabeticalZA.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get alphabeticalZA;

  /// No description provided for @sortByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get sortByCategory;

  /// No description provided for @noDietItems.
  ///
  /// In en, this message translates to:
  /// **'No food guidance yet'**
  String get noDietItems;

  /// No description provided for @noDietItemsDescription.
  ///
  /// In en, this message translates to:
  /// **'Track foods as allowed, caution, or avoid.'**
  String get noDietItemsDescription;

  /// No description provided for @noArchivedDietItems.
  ///
  /// In en, this message translates to:
  /// **'No archived food items'**
  String get noArchivedDietItems;

  /// No description provided for @noGuidanceRules.
  ///
  /// In en, this message translates to:
  /// **'No general guidance yet'**
  String get noGuidanceRules;

  /// No description provided for @noGuidanceRulesDescription.
  ///
  /// In en, this message translates to:
  /// **'Record diet, smoking, hydration, caffeine, and other rules.'**
  String get noGuidanceRulesDescription;

  /// No description provided for @noArchivedGuidanceRules.
  ///
  /// In en, this message translates to:
  /// **'No archived guidance rules'**
  String get noArchivedGuidanceRules;

  /// No description provided for @errorLoadingDietItems.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load food guidance'**
  String get errorLoadingDietItems;

  /// No description provided for @errorLoadingGuidanceRules.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load general guidance'**
  String get errorLoadingGuidanceRules;

  /// No description provided for @addDietItem.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addDietItem;

  /// No description provided for @editDietItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Food'**
  String get editDietItem;

  /// No description provided for @dietItemDetails.
  ///
  /// In en, this message translates to:
  /// **'Food Details'**
  String get dietItemDetails;

  /// No description provided for @dietItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Food item not found'**
  String get dietItemNotFound;

  /// No description provided for @dietItemIsArchived.
  ///
  /// In en, this message translates to:
  /// **'This food item is archived.'**
  String get dietItemIsArchived;

  /// No description provided for @archiveDietItem.
  ///
  /// In en, this message translates to:
  /// **'Archive Food'**
  String get archiveDietItem;

  /// No description provided for @archiveDietItemConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Archive this food item? It will be moved to the archived list but can be restored.'**
  String get archiveDietItemConfirmation;

  /// No description provided for @restoreDietItem.
  ///
  /// In en, this message translates to:
  /// **'Restore Food'**
  String get restoreDietItem;

  /// No description provided for @deleteDietItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Food'**
  String get deleteDietItem;

  /// No description provided for @confirmDeleteDietItem.
  ///
  /// In en, this message translates to:
  /// **'Delete this food item permanently?'**
  String get confirmDeleteDietItem;

  /// No description provided for @dietItemSaved.
  ///
  /// In en, this message translates to:
  /// **'Food saved'**
  String get dietItemSaved;

  /// No description provided for @dietItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Food updated'**
  String get dietItemUpdated;

  /// No description provided for @dietItemArchived.
  ///
  /// In en, this message translates to:
  /// **'Food archived'**
  String get dietItemArchived;

  /// No description provided for @dietItemRestored.
  ///
  /// In en, this message translates to:
  /// **'Food restored'**
  String get dietItemRestored;

  /// No description provided for @dietItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Food deleted'**
  String get dietItemDeleted;

  /// No description provided for @showArchivedDietItems.
  ///
  /// In en, this message translates to:
  /// **'Show archived foods'**
  String get showArchivedDietItems;

  /// No description provided for @showingArchivedDietItems.
  ///
  /// In en, this message translates to:
  /// **'Showing archived foods'**
  String get showingArchivedDietItems;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @foodNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Fresh fruit'**
  String get foodNameHint;

  /// No description provided for @foodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Food name is required'**
  String get foodNameRequired;

  /// No description provided for @foodCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get foodCategory;

  /// No description provided for @foodGroup.
  ///
  /// In en, this message translates to:
  /// **'Food Group'**
  String get foodGroup;

  /// No description provided for @foodGroupHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Fruits, Vegetables, Grains'**
  String get foodGroupHint;

  /// No description provided for @foodNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get foodNotes;

  /// No description provided for @foodNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional notes about this food'**
  String get foodNotesHint;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @sourceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Dietitian recommendation'**
  String get sourceHint;

  /// No description provided for @updateDietItem.
  ///
  /// In en, this message translates to:
  /// **'Update Food'**
  String get updateDietItem;

  /// No description provided for @saveDietItem.
  ///
  /// In en, this message translates to:
  /// **'Save Food'**
  String get saveDietItem;

  /// No description provided for @addGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Add Guidance'**
  String get addGuidanceRule;

  /// No description provided for @editGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Edit Guidance'**
  String get editGuidanceRule;

  /// No description provided for @guidanceRuleDetails.
  ///
  /// In en, this message translates to:
  /// **'Guidance Details'**
  String get guidanceRuleDetails;

  /// No description provided for @guidanceRuleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Guidance rule not found'**
  String get guidanceRuleNotFound;

  /// No description provided for @guidanceRuleIsArchived.
  ///
  /// In en, this message translates to:
  /// **'This guidance rule is archived.'**
  String get guidanceRuleIsArchived;

  /// No description provided for @guidanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get guidanceTitle;

  /// No description provided for @guidanceTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Drink water throughout the day'**
  String get guidanceTitleHint;

  /// No description provided for @guidanceTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get guidanceTitleRequired;

  /// No description provided for @guidanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get guidanceCategory;

  /// No description provided for @guidanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get guidanceDescription;

  /// No description provided for @guidanceDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional details about this rule'**
  String get guidanceDescriptionHint;

  /// No description provided for @updateGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Update Guidance'**
  String get updateGuidanceRule;

  /// No description provided for @saveGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Save Guidance'**
  String get saveGuidanceRule;

  /// No description provided for @archiveGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Archive Guidance'**
  String get archiveGuidanceRule;

  /// No description provided for @archiveGuidanceRuleConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Archive this guidance rule? It will be moved to the archived list but can be restored.'**
  String get archiveGuidanceRuleConfirmation;

  /// No description provided for @restoreGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Restore Guidance'**
  String get restoreGuidanceRule;

  /// No description provided for @deleteGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Delete Guidance'**
  String get deleteGuidanceRule;

  /// No description provided for @confirmDeleteGuidanceRule.
  ///
  /// In en, this message translates to:
  /// **'Delete this guidance rule permanently?'**
  String get confirmDeleteGuidanceRule;

  /// No description provided for @guidanceRuleSaved.
  ///
  /// In en, this message translates to:
  /// **'Guidance saved'**
  String get guidanceRuleSaved;

  /// No description provided for @guidanceRuleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Guidance updated'**
  String get guidanceRuleUpdated;

  /// No description provided for @guidanceRuleArchived.
  ///
  /// In en, this message translates to:
  /// **'Guidance archived'**
  String get guidanceRuleArchived;

  /// No description provided for @guidanceRuleRestored.
  ///
  /// In en, this message translates to:
  /// **'Guidance restored'**
  String get guidanceRuleRestored;

  /// No description provided for @guidanceRuleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Guidance deleted'**
  String get guidanceRuleDeleted;

  /// No description provided for @showArchivedGuidanceRules.
  ///
  /// In en, this message translates to:
  /// **'Show archived guidance'**
  String get showArchivedGuidanceRules;

  /// No description provided for @showingArchivedGuidanceRules.
  ///
  /// In en, this message translates to:
  /// **'Showing archived guidance'**
  String get showingArchivedGuidanceRules;

  /// No description provided for @inHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {hours}h {minutes}m'**
  String inHoursMinutes(int hours, int minutes);

  /// No description provided for @inHours.
  ///
  /// In en, this message translates to:
  /// **'In {hours}h'**
  String inHours(int hours);

  /// No description provided for @inMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {minutes}m'**
  String inMinutes(int minutes);

  /// No description provided for @hoursMinutesOverdue.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m overdue'**
  String hoursMinutesOverdue(int hours, int minutes);

  /// No description provided for @hoursOverdue.
  ///
  /// In en, this message translates to:
  /// **'{hours}h overdue'**
  String hoursOverdue(int hours);

  /// No description provided for @minutesOverdue.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m overdue'**
  String minutesOverdue(int minutes);

  /// No description provided for @semanticInHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {hours} hours {minutes} minutes'**
  String semanticInHoursMinutes(int hours, int minutes);

  /// No description provided for @semanticInHours.
  ///
  /// In en, this message translates to:
  /// **'in {hours} hours'**
  String semanticInHours(int hours);

  /// No description provided for @semanticInMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes} minutes'**
  String semanticInMinutes(int minutes);

  /// No description provided for @semanticHoursMinutesOverdue.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours {minutes} minutes overdue'**
  String semanticHoursMinutesOverdue(int hours, int minutes);

  /// No description provided for @semanticHoursOverdue.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours overdue'**
  String semanticHoursOverdue(int hours);

  /// No description provided for @semanticMinutesOverdue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes overdue'**
  String semanticMinutesOverdue(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ka'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ka':
      return AppLocalizationsKa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
