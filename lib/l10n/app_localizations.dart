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

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

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

  /// No description provided for @fixedTimesSchedule.
  ///
  /// In en, this message translates to:
  /// **'Fixed Times'**
  String get fixedTimesSchedule;

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
  /// **'Daily at {time}'**
  String dailyAt(String time);

  /// No description provided for @fixedTimes.
  ///
  /// In en, this message translates to:
  /// **'Fixed times: {times}'**
  String fixedTimes(String times);

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {count} days at {time}'**
  String everyNDays(int count, String time);

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
  /// **'Remove this schedule? Notifications will be cancelled.'**
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
  /// **'Set up reminders for this medication'**
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

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

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
  /// **'View History'**
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
