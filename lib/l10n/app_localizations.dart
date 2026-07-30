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
  /// **'Measurement Reminders'**
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
