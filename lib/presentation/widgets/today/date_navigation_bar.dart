import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/utils/localized_date_format.dart';

class DateNavigationBar extends ConsumerWidget {
  const DateNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedAgendaDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate.isAtSameMomentAs(today);

    final dateLabel = LocalizedDateFormat.fullMonthDayYear(context, selectedDate);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous day',
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              ref.read(selectedAgendaDateProvider.notifier).state = newDate;
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  ref.read(selectedAgendaDateProvider.notifier).state = picked;
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  dateLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: !isToday,
            child: IconButton(
              icon: const Icon(Icons.today),
              tooltip: 'Return to today',
              onPressed: () {
                ref.read(selectedAgendaDateProvider.notifier).state = today;
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isToday
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                  : null,
            ),
            tooltip: 'Next day',
            onPressed: isToday
                ? null
                : () {
                    final newDate = selectedDate.add(const Duration(days: 1));
                    ref.read(selectedAgendaDateProvider.notifier).state =
                        newDate;
                  },
          ),
        ],
      ),
    );
  }
}
