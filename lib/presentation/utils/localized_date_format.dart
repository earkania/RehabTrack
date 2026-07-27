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

  static String hourMinute(BuildContext context, DateTime date) {
    return DateFormat.Hm(_localeCode(context)).format(date);
  }
}
