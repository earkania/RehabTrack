import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';
import 'package:rehab_track/presentation/widgets/today/date_navigation_bar.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';
import 'package:rehab_track/presentation/widgets/today/today_next_item_card.dart';
import 'package:rehab_track/presentation/widgets/today/today_summary_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final agenda = ref.watch(dailyAgendaProvider);
    final selectedDate = ref.watch(selectedAgendaDateProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate.isAtSameMomentAs(today);

    final appBarTitle = isToday
        ? l10n.today
        : '${l10n.dailyPlan} · ${DateFormat.yMMMd().format(selectedDate)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyAgendaProvider);
          await ref.read(dailyAgendaProvider.future);
        },
        child: agenda.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.error),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(dailyAgendaProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (data) {
            if (data.isEmpty) {
              return ListView(
                children: [
                  const DateNavigationBar(),
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.today,
                    title: isToday
                        ? l10n.nothingScheduledToday
                        : l10n.nothingScheduledForThisDay,
                    subtitle: '',
                  ),
                ],
              );
            }

            return _TodayBody(data: data);
          },
        ),
      ),
    );
  }
}

class _TodayBody extends StatelessWidget {
  final TodayAgenda data;

  const _TodayBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: DateNavigationBar()),
        SliverToBoxAdapter(child: TodaySummaryCard(agenda: data)),
        if (data.isToday) const SliverToBoxAdapter(child: TodayNextItemCard()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.agenda,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 24),
          sliver: SliverList.builder(
            itemCount: data.items.length,
            itemBuilder: (context, index) =>
                TodayAgendaItemWidget(item: data.items[index]),
          ),
        ),
      ],
    );
  }
}
