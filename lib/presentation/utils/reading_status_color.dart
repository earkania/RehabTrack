import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';

class ReadingStatusColor {
  ReadingStatusColor._();

  static Color forStatus(ReadingStatus status, ColorScheme colorScheme) {
    return switch (status) {
      ReadingStatus.inRange => Colors.green,
      ReadingStatus.belowRange => Colors.blue,
      ReadingStatus.aboveRange => colorScheme.error,
      ReadingStatus.unknown => colorScheme.outline,
    };
  }
}
