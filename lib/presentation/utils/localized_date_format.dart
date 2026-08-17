import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocalizedDateFormat {
  LocalizedDateFormat._();

  static String _localeCode(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  static String fullMonthDayYear(BuildContext context, DateTime date) {
    return DateFormat.yMMMMd(_localeCode(context)).format(date);
  }

  static String shortMonthDayYear(BuildContext context, DateTime date) {
    return DateFormat.yMMMd(_localeCode(context)).format(date);
  }

  /// "4 Aug" — day followed by the localized abbreviated month.
  static String dayShortMonth(BuildContext context, DateTime date) {
    return DateFormat('d MMM', _localeCode(context)).format(date);
  }

  /// "Aug 26" — localized abbreviated month followed by the two-digit year.
  static String shortMonthYear(BuildContext context, DateTime date) {
    return DateFormat('MMM yy', _localeCode(context)).format(date);
  }

  /// "04.07.2026 09:00" — numeric date and time in the app locale.
  static String numericFullDateTime(BuildContext context, DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm', _localeCode(context)).format(date);
  }

  static String hourMinute(BuildContext context, DateTime date) {
    return DateFormat.Hm(_localeCode(context)).format(date);
  }
}
