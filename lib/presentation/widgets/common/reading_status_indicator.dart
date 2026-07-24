import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';

class ReadingStatusIndicator extends StatelessWidget {
  final ReadingStatus status;
  final double size;

  const ReadingStatusIndicator({
    super.key,
    required this.status,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ReadingStatus.inRange => Colors.green,
      ReadingStatus.belowRange => Colors.blue,
      ReadingStatus.aboveRange => Theme.of(context).colorScheme.error,
      ReadingStatus.unknown => Theme.of(context).colorScheme.outline,
    };

    return Icon(
      Icons.circle,
      size: size,
      color: color,
    );
  }
}
