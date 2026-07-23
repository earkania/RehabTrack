import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const Widget xsH = SizedBox(height: xs);
  static const Widget smH = SizedBox(height: sm);
  static const Widget mdH = SizedBox(height: md);
  static const Widget lgH = SizedBox(height: lg);
  static const Widget xlH = SizedBox(height: xl);

  static const Widget xsW = SizedBox(width: xs);
  static const Widget smW = SizedBox(width: sm);
  static const Widget mdW = SizedBox(width: md);
  static const Widget lgW = SizedBox(width: lg);
  static const Widget xlW = SizedBox(width: xl);
}
