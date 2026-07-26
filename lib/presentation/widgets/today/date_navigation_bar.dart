import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';

class DateNavigationBar extends ConsumerWidget {
  const DateNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedAgendaDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate.isAtSameMomentAs(today);

    final dateLabel = DateFormat.yMMMMd().format(selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousDay,
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              ref.read(selectedAgendaDateProvider.notifier).state = newDate;
            },
          ),
          Expanded(
            child: Center(
              child: isToday
                  ? Text(
                      l10n.today,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : GestureDetector(
                      onTap: () {
                        ref.read(selectedAgendaDateProvider.notifier).state =
                            today;
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dateLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            l10n.returnToToday,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextDay,
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              ref.read(selectedAgendaDateProvider.notifier).state = newDate;
            },
          ),
        ],
      ),
    );
  }
}
