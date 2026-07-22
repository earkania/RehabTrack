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
  String get fixedTimesSchedule => 'ფიქსირებული დრო';

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
  String get skipped => 'გაცდენილი';

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
  String dailyAt(String time) {
    return 'ყოველდღიურად $time';
  }

  @override
  String fixedTimes(String times) {
    return 'ფიქსირებული დრო: $times';
  }

  @override
  String everyNDays(int count, String time) {
    return 'ყოველ $count დღეში $time';
  }

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
  String get noSchedulesYet =>
      'გრაფიკები ჯერ არ არის. დაამატეთ შეხსენებებისთვის.';

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
  String get deleteSchedule => 'გრაფიკის წაშლა';

  @override
  String get deleteScheduleConfirmation =>
      'წაშალოთ ეს გრაფიკი? შეტყობინებები გაუქმდება.';

  @override
  String get selectTime => 'აირჩიეთ დრო';

  @override
  String get addTime => 'დროის დამატება';

  @override
  String get removeTime => 'წაშლა';

  @override
  String get intervalDays => 'ინტერვალი (დღე)';

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
  String get addScheduleSubtitle => 'დააყენეთ შეხსენებები ამ მედიკამენტისთვის';
}
