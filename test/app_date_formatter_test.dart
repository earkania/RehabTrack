import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting();
  });

  final date = DateTime(2026, 8, 12, 22, 57);

  group('AppDateFormatter SHORT DATE', () {
    test('AUGUST 1 zero-pads day and month in both locales', () {
      for (final locale in [const Locale('en'), const Locale('ka')]) {
        expect(
          AppDateFormatter(locale).formatShortDate(DateTime(2026, 8, 1)),
          '01.08.2026',
          reason: '${locale.languageCode} must use the fixed dd.MM.yyyy',
        );
      }
    });

    test('AUGUST 9 zero-pads day and month in both locales', () {
      for (final locale in [const Locale('en'), const Locale('ka')]) {
        expect(
          AppDateFormatter(locale).formatShortDate(DateTime(2026, 8, 9)),
          '09.08.2026',
        );
      }
    });

    test('DECEMBER 1 zero-pads day and month in both locales', () {
      for (final locale in [const Locale('en'), const Locale('ka')]) {
        expect(
          AppDateFormatter(locale).formatShortDate(DateTime(2026, 12, 1)),
          '01.12.2026',
        );
      }
    });

    test('DECEMBER 31 zero-pads day and month in both locales', () {
      for (final locale in [const Locale('en'), const Locale('ka')]) {
        expect(
          AppDateFormatter(locale).formatShortDate(DateTime(2026, 12, 31)),
          '31.12.2026',
        );
      }
    });

    test('uses the canonical dd.MM.yyyy for every day and month width', () {
      for (final locale in [const Locale('en'), const Locale('ka')]) {
        expect(AppDateFormatter(locale).formatShortDate(date), '12.08.2026');
      }
    });

    test('does not use locale-dependent numeric ordering', () {
      final en = AppDateFormatter(const Locale('en')).formatShortDate(date);
      final ka = AppDateFormatter(const Locale('ka')).formatShortDate(date);
      expect(en, '12.08.2026');
      expect(ka, '12.08.2026');
    });
  });

  group('AppDateFormatter MEDIUM DATE', () {
    test('English shows an English month abbreviation', () {
      expect(
        AppDateFormatter(const Locale('en')).formatMediumDate(date),
        'Aug 12, 2026',
      );
    });

    test('Georgian shows a Georgian month abbreviation, not an English one',
        () {
      final ka = AppDateFormatter(const Locale('ka')).formatMediumDate(date);
      expect(ka, contains('აგვ'));
      expect(ka, isNot(contains('Aug')));
      expect(ka, isNot(contains('August')));
      expect(ka, isNot(contains('Mar')));
      expect(ka, isNot(contains('March')));
    });
  });

  group('AppDateFormatter DATE + TIME', () {
    test('Short Date plus 24-hour time uses the canonical dd.MM.yyyy', () {
      expect(
        AppDateFormatter(const Locale('en')).formatShortDateTime(date),
        '12.08.2026 22:57',
      );
      expect(
        AppDateFormatter(const Locale('ka')).formatShortDateTime(date),
        '12.08.2026 22:57',
      );
    });

    test('zero-pads the date component of the one-digit month/day example', () {
      final first = DateTime(2026, 8, 1, 22, 57);
      for (final locale in [const Locale('en'), const Locale('ka')]) {
        expect(
          AppDateFormatter(locale).formatShortDateTime(first),
          '01.08.2026 22:57',
        );
      }
    });

    test('no timezone shift is applied', () {
      final local = DateTime.now();
      expect(
        AppDateFormatter(const Locale('en')).formatShortDateTime(local),
        '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}',
      );
    });
  });

  group('AppDateFormatter TIME', () {
    test('is a 24-hour localized time', () {
      expect(AppDateFormatter(const Locale('en')).formatTime(date), '22:57');
      expect(AppDateFormatter(const Locale('ka')).formatTime(date), '22:57');
    });
  });

  group('AppDateFormatter chart roles', () {
    test('MONTH DAY keeps the Trends "day abbrMonth" shape', () {
      expect(
        AppDateFormatter(const Locale('en')).formatMonthDay(date),
        '12 Aug',
      );
      expect(
        AppDateFormatter(const Locale('ka')).formatMonthDay(date),
        '12 აგვ',
      );
    });

    test('MONTH YEAR uses the localized abbreviated month', () {
      expect(
        AppDateFormatter(const Locale('en')).formatMonthYear(date),
        'Aug 26',
      );
      expect(
        AppDateFormatter(const Locale('ka')).formatMonthYear(date),
        'აგვ 26',
      );
    });
  });

  group('AppDateFormatter WEEKDAY', () {
    test('weekday names are localized', () {
      expect(
        AppDateFormatter(const Locale('en')).formatWeekday(date),
        'Wednesday',
      );
      expect(
        AppDateFormatter(const Locale('ka')).formatWeekday(date),
        'ოთხშაბათი',
      );
    });
  });
}