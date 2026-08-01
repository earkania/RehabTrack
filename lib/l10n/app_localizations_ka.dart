// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Georgian (`ka`).
class AppLocalizationsKa extends AppLocalizations {
  AppLocalizationsKa([String locale = 'ka']) : super(locale);

  @override
  String get appTitle => 'RehabTrack';

  @override
  String get welcomeMessage => 'მოგესალმებით RehabTrack-ში';

  @override
  String get today => 'დღეს';

  @override
  String get health => 'ჯანმრთელობა';

  @override
  String get activities => 'აქტივობები';

  @override
  String get records => 'ჩანაწერები';

  @override
  String get settings => 'პარამეტრები';

  @override
  String get profile => 'პროფილი';

  @override
  String get diet => 'დიეტა';

  @override
  String get labAnalyses => 'ლაბორატორიული ანალიზები';

  @override
  String get doctorVisits => 'ექიმთან ვიზიტები';

  @override
  String get reports => 'ანგარიშები';

  @override
  String get doctors => 'ექიმები';

  @override
  String get emergencyContacts => 'საგანგებო კონტაქტები';

  @override
  String get medicalNotes => 'სამედიცინო ჩანაწერები';

  @override
  String get moduleNotAvailableYet => 'ეს მოდული ჯერ არ არის ხელმისაწვდომი';

  @override
  String get comingSoon => 'მალე იქნება';

  @override
  String get language => 'ენა';

  @override
  String get theme => 'თემა';

  @override
  String get systemDefault => 'სისტემის ნაგულისხმევი';

  @override
  String get notifications => 'შეტყობინებები';

  @override
  String get enableNotifications => 'შეტყობინებების ჩართვა';

  @override
  String get security => 'უსაფრთხოება';

  @override
  String get appLock => 'აპლიკაციის დაბლოკვა';

  @override
  String get disabled => 'გამორთული';

  @override
  String get noDataYet => 'მონაცემები ჯერ არ არის';

  @override
  String get addFirstItem => 'დაამატეთ პირველი ელემენტი';

  @override
  String get save => 'შენახვა';

  @override
  String get cancel => 'გაუქმება';

  @override
  String get delete => 'წაშლა';

  @override
  String get edit => 'რედაქტირება';

  @override
  String get confirm => 'დადასტურება';

  @override
  String get back => 'უკან';

  @override
  String get loading => 'ჩატვირთვა...';

  @override
  String get error => 'შეცდომა';

  @override
  String get actionFailed => 'მოქმედების შესრულება ვერ მოხერხდა';

  @override
  String get retry => 'ხელახლა';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'დიახ';

  @override
  String get no => 'არა';

  @override
  String get medications => 'მედიკამენტები';

  @override
  String get addMedication => 'მედიკამენტის დამატება';

  @override
  String get editMedication => 'მედიკამენტის რედაქტირება';

  @override
  String get medicationName => 'მედიკამენტის სახელი';

  @override
  String get description => 'აღწერა';

  @override
  String get doseAmount => 'დოზა';

  @override
  String get doseUnit => 'დოზის ერთეული';

  @override
  String get active => 'აქტიური';

  @override
  String get startDate => 'დაწყების თარიღი';

  @override
  String get endDate => 'დასრულების თარიღი';

  @override
  String get notes => 'შენიშვნები';

  @override
  String get scheduleType => 'გრაფიკის ტიპი';

  @override
  String get dailySchedule => 'ყოველდღიური';

  @override
  String get dailyScheduleDescription => 'მიიღეთ მითითებულ დროს ყოველდღიურად';

  @override
  String get everyNDaysSchedule => 'ყოველ N დღეში';

  @override
  String get everyNDaysScheduleDescription =>
      'მიიღეთ მითითებულ დროს ყოველ N დღეში';

  @override
  String get intervalSchedule => 'ინტერვალი დღეებში';

  @override
  String get instructions => 'ინსტრუქციები';

  @override
  String get alternatives => 'ალტერნატივები';

  @override
  String get addAlternative => 'ალტერნატივის დამატება';

  @override
  String get doctorApproved => 'ექიმის მიერ დამტკიცებული';

  @override
  String get history => 'ისტორია';

  @override
  String get adherence => 'მიყოლა';

  @override
  String get taken => 'მიღებული';

  @override
  String get missed => 'გამოტოვილი';

  @override
  String get skipped => 'გამოტოვებული';

  @override
  String get pending => 'მოლოდინში';

  @override
  String get noMedicationsYet => 'მედიკამენტები ჯერ არ არის';

  @override
  String get addFirstMedication => 'დაამატეთ თქვენი პირველი მედიკამენტი';

  @override
  String get scheduleAdded => 'გრაფიკი დაემატა';

  @override
  String get scheduleDeleted => 'გრაფიკი წაიშალა';

  @override
  String get confirmDelete => 'დარწმუნებული ხართ?';

  @override
  String get nextDose => 'შემდეგი დოზა';

  @override
  String get logDose => 'დოზის აღრიცხვა';

  @override
  String get medicationAdded => 'მედიკამენტი დაემატა';

  @override
  String get medicationUpdated => 'მედიკამენტი განახლდა';

  @override
  String get medicationDeleted => 'მედიკამენტი წაიშალა';

  @override
  String get addSchedule => 'გრაფიკის დამატება';

  @override
  String get editSchedule => 'გრაფიკის რედაქტირება';

  @override
  String dailyAt(String times) {
    return 'ყოველდღიურად $times';
  }

  @override
  String everyNDays(int count, String times) {
    return 'ყოველ $count დღეში $times';
  }

  @override
  String get intakeQuantity => 'მიღების რაოდენობა';

  @override
  String get perIntake => 'მიღებაზე';

  @override
  String get dosageForm => 'დოზის ფორმა';

  @override
  String get tablet => 'აბი';

  @override
  String get capsule => 'კაფსულა';

  @override
  String get drop => 'წვეთი';

  @override
  String get ml => 'მლ';

  @override
  String get puff => 'შესხურება';

  @override
  String get unit => 'ერთეული';

  @override
  String get sachet => 'პაკეტი';

  @override
  String get spoon => 'კოვზი';

  @override
  String get injection => 'ინექცია';

  @override
  String get topical => 'წასმა';

  @override
  String get other => 'სხვა';

  @override
  String get customDosageForm => 'მორგებული დოზის ფორმის სახელი';

  @override
  String get customDosageFormRequired =>
      'მორგებული დოზის ფორმის სახელი საჭიროა';

  @override
  String get invalidIntakeQuantity => 'შეიყვანეთ სწორი მიღების რაოდენობა';

  @override
  String get beforeMeal => 'ჭამამდე';

  @override
  String get afterMeal => 'ჭამის შემდეგ';

  @override
  String get withMeal => 'ჭამასთან ერთად';

  @override
  String get emptyStomach => 'ცარიელ კუჭზე';

  @override
  String get beforeBedtime => 'ძილის წინ';

  @override
  String get morningOnly => 'მხოლოდ დილით';

  @override
  String get noSchedulesYet => 'გრაფიკები ჯერ არ არის';

  @override
  String get noAlternativesYet => 'ალტერნატივები ჯერ არ არის';

  @override
  String get addScheduleToMedication => 'დაამატეთ გრაფიკი ამ მედიკამენტისთვის';

  @override
  String get days => 'დღე';

  @override
  String get deactivate => 'დეაქტივაცია';

  @override
  String get confirmDeactivate =>
      'მედიკამენტი დეაქტივირდება. გრაფიკები და ისტორია შენარჩუნდება.';

  @override
  String get invalidRoute => 'არასწორი გვერდი';

  @override
  String get schedules => 'გრაფიკები';

  @override
  String get deleteSchedule => 'წაშალეთ გრაფიკი';

  @override
  String get deleteScheduleConfirmation =>
      'დარწმუნებული ხართ რომ გსურთ ამ გრაფიკის წაშლა?';

  @override
  String get selectTime => 'აირჩიეთ დრო';

  @override
  String get addTime => 'დროის დამატება';

  @override
  String get scheduledTime => 'დაგეგმილი დრო';

  @override
  String get removeTime => 'წაშლა';

  @override
  String get intervalDays => 'ინტერვალი (დღეები)';

  @override
  String get atLeastOneTimeRequired => 'სულ მცირე ერთი დრო საჭიროა';

  @override
  String get duplicateTimesNotAllowed => 'დუბლიკატი დროები არ დაიშვება';

  @override
  String get invalidInterval => 'ინტერვალი უნდა იყოს 1-დან 30-მდე';

  @override
  String get failedToSaveSchedule => 'გრაფიკის შენახვა ვერ მოხერხდა';

  @override
  String get failedToDeleteSchedule => 'გრაფიკის წაშლა ვერ მოხერხდა';

  @override
  String get schedulesSection => 'გრაფიკები';

  @override
  String get addScheduleSubtitle => 'დაამატეთ გრაფიკი შეხსენებებისთვის';

  @override
  String get editAlternative => 'ალტერნატივის რედაქტირება';

  @override
  String get deleteAlternative => 'ალტერნატივის წაშლა';

  @override
  String get deleteAlternativeConfirmation =>
      'წაშალოთ ეს ალტერნატივა? ეს არ იმოქმედებს მედიკამენტზე ან მის გრაფიკებზე.';

  @override
  String get alternativeAdded => 'ალტერნატივა დაემატა';

  @override
  String get alternativeUpdated => 'ალტერნატივა განახლდა';

  @override
  String get alternativeDeleted => 'ალტერნატივა წაიშალა';

  @override
  String get noAlternatives => 'ალტერნატივები არ არის';

  @override
  String get noAlternativesDescription =>
      'დაამატეთ ექიმის მიერ დამტკიცებული შემცვლელები ამ მედიკამენტისთვის';

  @override
  String get alternativesSection => 'ალტერნატივები';

  @override
  String get genericSubstitute => 'გენერიკული შემცვლელი';

  @override
  String get confirmDeleteAlternative =>
      'დარწმუნებული ხართ, რომ გსურთ ამ ალტერნატივის წაშლა?';

  @override
  String get historySection => 'ისტორია და მიყოლა';

  @override
  String get historyScreenTitle => 'მედიკამენტის ისტორია';

  @override
  String get last7Days => 'ბოლო 7 დღე';

  @override
  String get last30Days => 'ბოლო 30 დღე';

  @override
  String get allTime => 'ყველა დრო';

  @override
  String adherencePercentage(double percentage) {
    return '$percentage%';
  }

  @override
  String get noLogsYet => 'ჩანაწერები ჯერ არ არის';

  @override
  String get noLogsDescription =>
      'აღრიცხეთ დოზები თქვენი მედიკამენტის მიყოლის თვალყურის სანახავად';

  @override
  String get logDoseNow => 'დოზის აღრიცხვა';

  @override
  String get selectStatus => 'აირჩიეთ სტატუსი';

  @override
  String get doseNotes => 'შენიშვნები (სურვილისამებრ)';

  @override
  String get doseLogged => 'დოზა აღირიცხა';

  @override
  String get logDoseError => 'დოზის აღრიცხვა ვერ მოხერხდა';

  @override
  String get totalDoses => 'სულ დოზები';

  @override
  String get completedDoses => 'დასრულებული';

  @override
  String get adherenceRate => 'მიყოლის მაჩვენებელი';

  @override
  String get doseHistory => 'დოზების ისტორია';

  @override
  String get noHistoryYet => 'ისტორია ჯერ არ არის';

  @override
  String get noHistoryDescription =>
      'თქვენი მედიკამენტის ჩანაწერების ისტორია აქ გამოჩნდება';

  @override
  String scheduledFor(String time) {
    return 'დაგეგმილია $time';
  }

  @override
  String takenAt(String time) {
    return 'მიღებულია $time';
  }

  @override
  String get nameRequired => 'სახელი საჭიროა';

  @override
  String get invalidDose => 'არასწორი დოზის რაოდენობა';

  @override
  String get endDateBeforeStartDate =>
      'დასრულების თარიღი უნდა იყოს დაწყების თარიღის შემდეგ';

  @override
  String get scheduleUpdated => 'გრაფიკი განახლდა';

  @override
  String get noSchedulesAvailable => 'გრაფიკები არ არის დოზის აღსარიცხავად';

  @override
  String get dosageComponents => 'დოზის კომპონენტები';

  @override
  String get addComponent => 'კომპონენტის დამატება';

  @override
  String get removeComponent => 'კომპონენტის წაშლა';

  @override
  String get componentName => 'კომპონენტის სახელი';

  @override
  String get componentNameOptional => 'კომპონენტის სახელი (სურვილისამებრ)';

  @override
  String get measurements => 'გაზომვები';

  @override
  String get measurementTypes => 'გაზომვის ტიპები';

  @override
  String get addMeasurement => 'გაზომვის დამატება';

  @override
  String get editMeasurement => 'გაზომვის რედაქტირება';

  @override
  String get measurementHistory => 'გაზომვის ისტორია';

  @override
  String get measuredAt => 'გაზომილია';

  @override
  String get latestReading => 'უახლესი ჩანაწერი';

  @override
  String get noMeasurementsYet => 'გაზომვის ტიპები ჯერ არ არის';

  @override
  String get noReadingsYet => 'ჩანაწერები ჯერ არ არის';

  @override
  String get addFirstReading => 'დაამატეთ პირველი ჩანაწერი';

  @override
  String get bloodPressure => 'არტერიული წნევა';

  @override
  String get systolic => 'სისტოლური';

  @override
  String get diastolic => 'დიასტოლური';

  @override
  String get pulse => 'პულსი';

  @override
  String get weight => 'წონა';

  @override
  String get bloodGlucose => 'გლუკოზა სისხლში';

  @override
  String get spo2 => 'SpO2';

  @override
  String get temperature => 'ტემპერატურა';

  @override
  String get irregularHeartbeat => 'არარეგულარული გულისცემა';

  @override
  String get pulseLabel => 'პულსი';

  @override
  String get fieldName => 'ველის სახელი';

  @override
  String get requiredField => 'სავალდებულო';

  @override
  String get minimumValue => 'მინიმალური მნიშვნელობა';

  @override
  String get maximumValue => 'მაქსიმალური მნიშვნელობა';

  @override
  String get invalidMeasurementValue => 'არასწორი გაზომვის მნიშვნელობა';

  @override
  String get failedToSaveMeasurement => 'გაზომვის შენახვა ვერ მოხერხდა';

  @override
  String get measurementAdded => 'გაზომვა დაემატა';

  @override
  String get measurementUpdated => 'გაზომვა განახლდა';

  @override
  String get measurementDeleted => 'გაზომვა წაიშალა';

  @override
  String get confirmDeleteMeasurement =>
      'დარწმუნებული ხართ, რომ გსურთ ამ ჩანაწერის წაშლა?';

  @override
  String get readingSaved => 'ჩანაწერი შეინახა';

  @override
  String get readingUpdated => 'ჩანაწერი განახლდა';

  @override
  String get readingDeleted => 'ჩანაწერი წაიშალა';

  @override
  String get noMeasurementsHistory => 'ისტორია ჯერ არ არის';

  @override
  String get noMeasurementsHistoryDescription =>
      'თქვენი გაზომვების ისტორია აქ გამოჩნდება';

  @override
  String get measurementValue => 'მნიშვნელობა';

  @override
  String get measurementUnit => 'ერთეული';

  @override
  String get selectMeasurementType => 'აირჩიეთ გაზომვის ტიპი';

  @override
  String get addReading => 'ჩანაწერის დამატება';

  @override
  String get addReadingTooltip => 'ჩანაწერის დამატება';

  @override
  String get viewHistory => 'ისტორია';

  @override
  String get valueRequired => 'მნიშვნელობა საჭიროა';

  @override
  String get mustBePositive => 'მნიშვნელობა უნდა იყოს დადებითი';

  @override
  String get systolicGreaterThanDiastolic =>
      'სისტოლური უნდა აღემატებოდეს დიასტოლურს';

  @override
  String get withinRange => 'ნორმის ფარგლებში';

  @override
  String get aboveRange => 'ნორმაზე მაღალი';

  @override
  String get belowRange => 'ნორმაზე დაბალი';

  @override
  String get noReferenceRange => 'უცნობი';

  @override
  String get readingStatusLegend => 'ჩანაწერის სტატუსი';

  @override
  String get referenceRange => 'ცნობილი დიაპაზონი';

  @override
  String get legendWithinRangeDescription => 'კონფიგურირებულ დიაპაზონში';

  @override
  String get legendAboveRangeDescription => 'კონფიგურირებულ დიაპაზონზე მაღალი';

  @override
  String get legendBelowRangeDescription => 'კონფიგურირებულ დიაპაზონზე დაბალი';

  @override
  String get legendNoReferenceRangeDescription =>
      'დიაპაზონი არ არის კონფიგურირებული';

  @override
  String get legendIrregularHeartbeat => 'აღმოჩენილია არარეგულარული გულისცემა';

  @override
  String get referenceRanges => 'ცნობილი დიაპაზონები';

  @override
  String get applicationDefault => 'აპლიკაციის ნაგულისხმევი';

  @override
  String get lowerBound => 'ქვედა ზღვარი';

  @override
  String get upperBound => 'ზედა ზღვარი';

  @override
  String get resetToDefault => 'ნაგულისხმევზე დაბრუნება';

  @override
  String get rangeSaved => 'დიაპაზონი შეინახა';

  @override
  String get failedToSaveRange => 'დიაპაზონის შენახვა ვერ მოხერხდა';

  @override
  String get lowerBoundAboveUpperBound =>
      'ქვედა ზღვარი უნდა იყოს ზედა ზღვარზე ნაკლები';

  @override
  String referenceRangeCount(int count) {
    return '$count ცნობილი დიაპაზონი';
  }

  @override
  String get trends => 'ტრენდები';

  @override
  String get measurementTrends => 'გაზომვის ტრენდები';

  @override
  String get viewTrends => 'ტრენდები';

  @override
  String get lastSevenDays => 'ბოლო 7 დღე';

  @override
  String get lastThirtyDays => 'ბოლო 30 დღე';

  @override
  String get lastNinetyDays => 'ბოლო 90 დღე';

  @override
  String get latest => 'უახლესი';

  @override
  String get average => 'საშუალო';

  @override
  String get minimum => 'მინიმუმი';

  @override
  String get maximum => 'მაქსიმუმი';

  @override
  String get readingCount => 'გაზომვები';

  @override
  String get firstReading => 'პირველი';

  @override
  String get change => 'ცვლილება';

  @override
  String get percentageChange => 'ცვლილება %';

  @override
  String get belowCount => 'დაბალი';

  @override
  String get withinCount => 'ნორმაში';

  @override
  String get aboveCount => 'მაღალი';

  @override
  String get unknownCount => 'უცნობი';

  @override
  String get irregularHeartbeatCount => 'არარეგულარული გულისცემა';

  @override
  String get noTrendData => 'ტრენდის მონაცემები არ არის';

  @override
  String get moreReadingsNeeded =>
      'ტრენდის ჩვენებისთვის საჭიროა მინიმუმ 2 გაზომვა';

  @override
  String get selectPeriod => 'პერიოდის არჩევა';

  @override
  String get failedToLoadTrends => 'ტრენდების ჩატვირთვა ვერ მოხერხდა';

  @override
  String get statusSummary => 'სტატუსის შეჯამება';

  @override
  String get statistics => 'სტატისტიკა';

  @override
  String get chart => 'გრაფიკი';

  @override
  String get systolicLabel => 'სისტოლური';

  @override
  String get diastolicLabel => 'დიასტოლური';

  @override
  String get pulseLabelStat => 'პულსი';

  @override
  String get systolicShort => 'სისტ.';

  @override
  String get diastolicShort => 'დიასტ.';

  @override
  String get pulseShort => 'პულსი';

  @override
  String get unavailable => 'მიუწვდომელი';

  @override
  String get withinConfiguredRange => 'კონფიგურირებულ დიაპაზონში';

  @override
  String get belowConfiguredRange => 'კონფიგურირებულ დიაპაზონზე დაბალი';

  @override
  String get aboveConfiguredRange => 'კონფიგურირებულ დიაპაზონზე მაღალი';

  @override
  String get noReferenceRangeConfigured => 'დიაპაზონი არ არის კონფიგურირებული';

  @override
  String componentStatusSystolic(String status) {
    return 'სისტოლური $status';
  }

  @override
  String componentStatusDiastolic(String status) {
    return 'დიასტოლური $status';
  }

  @override
  String componentStatusPulse(String status) {
    return 'პულსი $status';
  }

  @override
  String get measurementSchedules => 'გაზომვების გრაფიკი';

  @override
  String get addMeasurementSchedule => 'დაამატეთ გაზომვის გრაფიკი';

  @override
  String get editMeasurementSchedule => 'შეცვალეთ გაზომვის გრაფიკი';

  @override
  String get noMeasurementSchedules => 'გაზომვების გრაფიკი არ არსებობს';

  @override
  String get noMeasurementSchedulesDescription =>
      'დაამატეთ გრაფიკი შეხსენებებისთვის';

  @override
  String get daily => 'ყოველდღიური';

  @override
  String get everyNDaysLabel => 'ყოველ N დღეში';

  @override
  String get everyNDaysRequiresStartDate =>
      'ყოველ N დღეში საჭიროებს დაწყების თარიღს';

  @override
  String get recordNow => 'ჩაწერე ახლა';

  @override
  String get measurementReminder => 'გაზომვის შეხსენება';

  @override
  String get measurementReminders => 'გაზომვების შეხსენებები';

  @override
  String timeToRecordMeasurement(String name) {
    return 'დროა ჩაწეროთ $name';
  }

  @override
  String get reminderScheduled => 'შეხსენება დაგეგმილია';

  @override
  String get reminderUpdated => 'შეხსენება განახლდა';

  @override
  String get reminderDeleted => 'შეხსენება წაიშალა';

  @override
  String get scheduleRecovered => 'გრაფიკი აღდგენილია';

  @override
  String get measurementsDueToday => 'დღეს გასაკეთებელი გაზომვები';

  @override
  String get noRemindersToday => 'დღეს შეხსენებები არ არის დაგეგმილი';

  @override
  String get upcoming => 'მომდევნო';

  @override
  String get overdue => 'ვადაგასული';

  @override
  String get completed => 'დასრულებული';

  @override
  String get snoozed => 'გადადებული';

  @override
  String get todaysProgress => 'დღევანდელი პროგრესი';

  @override
  String get todaysPlan => 'დღევანდელი გეგმა';

  @override
  String get nothingScheduledToday => 'დღეს არაფერია დაგეგმილი';

  @override
  String get nextItem => 'შემდეგი';

  @override
  String get medicationsToday => 'მედიკამენტები';

  @override
  String get measurementsToday => 'გაზომვები';

  @override
  String get completedAndSkipped => 'დასრულებული და გამოტოვებული';

  @override
  String get markTaken => 'მიღებულია';

  @override
  String get snooze10min => 'გადადე 10 წუთით';

  @override
  String get due => 'დროა';

  @override
  String get dueSoon => 'მალე დროა';

  @override
  String takeMedication(Object name) {
    return 'მიიღე $name';
  }

  @override
  String completedAt(Object time) {
    return 'დასრულდა $time';
  }

  @override
  String overdueSince(Object time) {
    return 'ვადაგასულია $time-დან';
  }

  @override
  String get noMedicationsToday => 'დღეს მედიკამენტების გრაფიკი არ არის';

  @override
  String get noMeasurementsToday => 'დღეს გაზომვების გრაფიკი არ არის';

  @override
  String get agenda => 'დღის განრიგი';

  @override
  String get moreActions => 'დამატებითი მოქმედებები';

  @override
  String get skip => 'გამოტოვება';

  @override
  String get openDetails => 'დეტალები';

  @override
  String get failedToUpdateItem => 'ელემენტის განახლება ვერ მოხერხდა';

  @override
  String get changeToSkipped => 'შეცვალეთ გამოტოვებულზე';

  @override
  String get changeToTaken => 'შეცვალეთ მიღებულზე';

  @override
  String get resetToPending => 'დააბრუნეთ მოლოდინში';

  @override
  String get editReading => 'ჩანაწერის რედაქტირება';

  @override
  String get dailyPlan => 'დღის გეგმა';

  @override
  String get previousDay => 'წინა დღე';

  @override
  String get nextDay => 'მომდევნო დღე';

  @override
  String get returnToToday => 'დღეს';

  @override
  String get nothingScheduledForThisDay => 'ამ დღისთვის არაფერია დაგეგმილი';

  @override
  String get firstPlannedItem => 'პირველი დაგეგმილი ელემენტი';

  @override
  String scheduledAt(Object time) {
    return 'დაგეგმილია $time';
  }

  @override
  String get medicationsMissed => 'გამოტოვებული მედიკამენტები';

  @override
  String get measurementsMissed => 'გამოტოვებული გაზომვები';

  @override
  String get dailySummary => 'დღის შეჯამება';

  @override
  String get patientProfile => 'პაციენტის პროფილი';

  @override
  String get editPatientProfile => 'პაციენტის პროფილის რედაქტირება';

  @override
  String get personalInformation => 'პირადი ინფორმაცია';

  @override
  String get contactInformation => 'საკონტაქტო ინფორმაცია';

  @override
  String get emergencyContact => 'საგანგებო კონტაქტი';

  @override
  String get additionalInformation => 'დამატებითი ინფორმაცია';

  @override
  String get firstName => 'სახელი';

  @override
  String get lastName => 'გვარი';

  @override
  String get phone => 'ტელეფონი';

  @override
  String get email => 'ელ. ფოსტა';

  @override
  String get address => 'მისამართი';

  @override
  String get heightCm => 'სიმაღლე';

  @override
  String get weightKg => 'წონა';

  @override
  String get bloodType => 'სისხლის ჯგუფი';

  @override
  String get allergies => 'ალერგიები';

  @override
  String get gender => 'სქესი';

  @override
  String get relationship => 'ურთიერთობა';

  @override
  String get selectDate => 'აირჩიეთ თარიღი';

  @override
  String get male => 'მამრობითი';

  @override
  String get female => 'მდედრობითი';

  @override
  String get self_ => 'თავად';

  @override
  String get child_ => 'შვილი';

  @override
  String get spouse_ => 'მეუღლე';

  @override
  String get parent_ => 'მშობელი';

  @override
  String get sibling_ => 'და-ძმა';

  @override
  String get grandparent_ => 'პაპა-ბებია';

  @override
  String get grandchild_ => 'შვილიშვილი';

  @override
  String get other_ => 'სხვა';

  @override
  String get profileUpdated => 'პროფილი განახლდა';

  @override
  String get failedToSaveProfile => 'პროფილის შენახვა ვერ მოხერხდა';

  @override
  String get switchProfile => 'პროფილის შეცვლა';

  @override
  String get noProfiles => 'პროფილები ჯერ არ არის';

  @override
  String get createFirstProfile => 'შექმენით თქვენი პირველი პაციენტის პროფილი';

  @override
  String get profileSummary => 'პროფილის შეჯამება';

  @override
  String get age => 'ასაკი';

  @override
  String yearsOld(int years) {
    return '$years წლის';
  }

  @override
  String get activeProfile => 'აქტიური პროფილი';

  @override
  String get birthDateLabel => 'დაბადების თარიღი';

  @override
  String get heightLabel => 'სიმაღლე';

  @override
  String get weightLabel => 'წონა';

  @override
  String get nameLabel => 'სახელი';

  @override
  String get emergencyContactNameLabel => 'კონტაქტის სახელი';

  @override
  String get emergencyContactPhoneLabel => 'კონტაქტის ტელეფონი';

  @override
  String get profileNotSetUp => 'პროფილი არ არის დაყენებული';

  @override
  String get profileNotSetUpDescription =>
      'შექმენით პაციენტის პროფილი დასაწყებად.\nთქვენი პროფილის ინფორმაცია გამოყენებული იქნება აპლიკაციაში.';

  @override
  String get addProfileInformation => 'პროფილის ინფორმაციის დამატება';

  @override
  String get profileInformationNotEntered =>
      'პროფილის ინფორმაცია ჯერ არ არის შეყვანილი.';

  @override
  String get profilePhoto => 'პროფილის ფოტო';

  @override
  String get changeProfilePhoto => 'პროფილის ფოტოს შეცვლა';

  @override
  String get chooseFromGallery => 'აირჩიეთ გალერეიდან';

  @override
  String get takePhoto => 'გადაიღეთ ფოტო';

  @override
  String get removeProfilePhoto => 'ფოტოს წაშლა';

  @override
  String get photoSelectionCancelled => 'ფოტოს არჩევა გაუქმდა';

  @override
  String get failedToLoadPhoto => 'ფოტოს ჩატვირთვა ვერ მოხერხდა';

  @override
  String get failedToSavePhoto => 'ფოტოს შენახვა ვერ მოხერხდა';

  @override
  String get cameraPermissionRequired =>
      'ფოტოს გადასაღებად საჭიროა კამერის ნებართვა';

  @override
  String get nextItemGracePeriod => 'შემდეგი ჩანაწერის დაყოვნების პერიოდი';

  @override
  String get nextItemGracePeriodDescription =>
      'დაუსრულებელი ელემენტი რჩება შემდეგი ჩანაწერის ბარათში არჩეული პერიოდის განმავლობაში მისი დაგეგმილი დროიდან.';

  @override
  String minutesValue(int minutes) {
    return '$minutes წუთი';
  }

  @override
  String get fiveMinutes => '5 წუთი';

  @override
  String get tenMinutes => '10 წუთი';

  @override
  String get fifteenMinutes => '15 წუთი';

  @override
  String get thirtyMinutes => '30 წუთი';

  @override
  String get sixtyMinutes => '60 წუთი';

  @override
  String get reminders => 'შეხსენებები';

  @override
  String get medicationReminders => 'მედიკამენტების შეხსენებები';

  @override
  String get reminderSound => 'ხმა';

  @override
  String get reminderVibration => 'ვიბრაცია';

  @override
  String get defaultSnoozeDuration => 'გადადების ხანგრძლივობა';

  @override
  String get notificationPermission => 'შეტყობინების ნებართვა';

  @override
  String get exactAlarmAccess => 'ზუსტი მაღვიძარას წვდომა';

  @override
  String get permissionGranted => 'ნებადართულია';

  @override
  String get permissionDenied => 'აკრძალულია';

  @override
  String get permissionRequired => 'საჭიროა';

  @override
  String get openNotificationSettings => 'შეტყობინებების პარამეტრები';

  @override
  String get openAlarmSettings => 'მაღვიძარას პარამეტრები';

  @override
  String get androidNotificationSettings =>
      'Android შეტყობინებების პარამეტრები';

  @override
  String get androidNotificationSettingsDescription =>
      'მართეთ სისტემური შეტყობინებების კატეგორიები, ხმები და გაფრთხილებები';

  @override
  String get systemControls => 'სისტემური კონტროლი';

  @override
  String get androidMayHideUnusedCategories =>
      'Android-მა შეიძლება დამალოს კატეგორიები, სანამ ისინი არ გამოიყენება.';

  @override
  String get testMedicationReminder => 'მედიკამენტის ტესტური შეხსენება';

  @override
  String get testMeasurementReminder => 'გაზომვის ტესტური შეხსენება';

  @override
  String get testReminder => 'ტესტური შეხსენება';

  @override
  String get testReminderTitle => 'ტესტური შეხსენება';

  @override
  String get testReminderBody =>
      'ეს არის ტესტური შეხსენება შეტყობინების ხმის, ვიბრაციის და გამოჩენის შესამოწმებლად.';

  @override
  String get medicationReminder => 'მედიკამენტის შეხსენება';

  @override
  String get markAsTaken => 'მიღებულია';

  @override
  String get snooze => 'გადადება';

  @override
  String get scheduleSavedReminderFailed =>
      'გრაფიკი შენახულია, მაგრამ შეხსენების დაგეგმვა ვერ მოხერხდა';

  @override
  String get reminderSchedulingFailed => 'შეხსენების დაგეგმვა ვერ მოხერხდა';

  @override
  String get reminderDetails => 'შეხსენების დეტალები';

  @override
  String get reminderPermissionExplanation =>
      'RehabTrack-ს სჭირდება შეტყობინების ნებართვა მედიკამენტების და გაზომვების შეხსენებების ჩვენებისთვის.';

  @override
  String get exactAlarmExplanation =>
      'ზუსტი მაღვიძარას ნებართვა საშუალებას აძლევს შეხსენებებს გამოჩნდეს ზუსტად დაგეგმილ დროს. მის გარეშე, შეხსენების დრო შეიძლება იყოს ნაკლებად ზუსტი.';

  @override
  String get alarmStyleReminders => 'მაღვიძარას სტილის პრეზენტაცია';

  @override
  String get lockScreenReminderDetails =>
      'სრული შეხსენების დეტალების ჩვენება ჩაკეტილ ეკრანზე';

  @override
  String get noPermission => 'ნებართვა არ არის';

  @override
  String get channelDisabled => 'არხი გამორთულია';

  @override
  String get scheduleSaved => 'გრაფიკი შენახულია';

  @override
  String get notGranted => 'მინიჭებული არ არის';

  @override
  String get notRequired => 'არ არის საჭირო';

  @override
  String get requestPermission => 'ნებართვის მოთხოვნა';

  @override
  String get reminderWarningNoPermission =>
      'შეხსენებების ჩვენება შეუძლებელია, რადგან შეტყობინების ნებართვა აკრძალულია.';

  @override
  String get reminderWarningNoExactAlarm =>
      'შეხსენების დრო შეიძლება იყოს ნაკლებად ზუსტი ზუსტი მაღვიძარას წვდომის გარეშე.';

  @override
  String snoozeMinutes(Object minutes) {
    return 'გადადება $minutes წუთით';
  }

  @override
  String get healthReminder => 'ჯანმრთელობის შეხსენება';

  @override
  String get healthReminderLockScreen => 'გახსენით RehabTrack დეტალებისთვის';

  @override
  String get remindersNotAvailable => 'შეხსენებები მიუწვდომელია';

  @override
  String get testReminderSent =>
      'ტესტური შეხსენება გაიგზავნა! შეამოწმეთ შეტყობინებები.';

  @override
  String get request => 'მოთხოვნა';

  @override
  String get inactiveMedications => 'არააქტიური';

  @override
  String get showDeactivated => 'დეაქტივირებულების ჩვენება';

  @override
  String get reactivate => 'ხელახლა გააქტიურება';

  @override
  String get confirmReactivate =>
      'მედიკამენტი ხელახლა გააქტიურდება. მისი ისტორია შენარჩუნდება.';

  @override
  String get noInactiveMedications => 'არააქტიური მედიკამენტები არ არის';
}
