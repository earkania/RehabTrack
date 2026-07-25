import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final color = ReadingStatusColor.forStatus(status, colorScheme);

    return Icon(
      Icons.circle,
      size: size,
      color: color,
    );
  }
}
