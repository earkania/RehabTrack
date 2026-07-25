import 'package:flutter/material.dart';
import 'package:rehab_track/domain/entities/reading_status.dart';
import 'package:rehab_track/presentation/utils/reading_status_color.dart';

class MeasurementValuePart {
  final String label;
  final String value;
  final String unit;
  final ReadingStatus status;

  const MeasurementValuePart({
    this.label = '',
    required this.value,
    this.unit = '',
    required this.status,
  });
}

class StatusAwareMeasurementValue extends StatelessWidget {
  final List<MeasurementValuePart> parts;
  final TextStyle? style;
  final String? semanticsLabel;

  const StatusAwareMeasurementValue({
    super.key,
    required this.parts,
    this.style,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spans = <InlineSpan>[];

    for (var i = 0; i < parts.length; i++) {
      if (i > 0) {
        spans.add(const TextSpan(text: ', '));
      }
      final color = ReadingStatusColor.forStatus(
        parts[i].status,
        colorScheme,
      );

      if (parts[i].label.isNotEmpty) {
        spans.add(TextSpan(
          text: parts[i].label,
          style: style,
        ));
      }

      spans.add(TextSpan(
        text: parts[i].value,
        style: style?.copyWith(color: color) ?? TextStyle(color: color),
      ));

      if (parts[i].unit.isNotEmpty) {
        spans.add(TextSpan(
          text: parts[i].unit,
          style: style,
        ));
      }
    }

    return Semantics(
      label: semanticsLabel,
      child: RichText(text: TextSpan(children: spans)),
    );
  }
}
