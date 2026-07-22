import 'package:flutter/material.dart';
import 'package:rehab_track/l10n/app_localizations.dart';

class TimePickerField extends StatelessWidget {
  final String time;
  final ValueChanged<String> onTimeSelected;
  final VoidCallback? onRemove;

  const TimePickerField({
    super.key,
    required this.time,
    required this.onTimeSelected,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        final parts = time.split(':');
        final initialHour = int.tryParse(parts.first) ?? 8;
        final initialMinute = int.tryParse(parts.last) ?? 0;

        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
        );

        if (picked != null) {
          final normalized =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onTimeSelected(normalized);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: onRemove != null
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                  tooltip: l10n.removeTime,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              time,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
