import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rehab_track/domain/entities/today_agenda.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/today_provider.dart';
import 'package:rehab_track/presentation/widgets/empty_state.dart';
import 'package:rehab_track/presentation/widgets/today/today_agenda_item.dart';
import 'package:rehab_track/presentation/widgets/today/today_next_item_card.dart';
import 'package:rehab_track/presentation/widgets/today/today_summary_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final agenda = ref.watch(todayAgendaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayAgendaProvider);
          await ref.read(todayAgendaProvider.future);
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
                  onPressed: () => ref.invalidate(todayAgendaProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (data) {
            if (data.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.today,
                    title: l10n.nothingScheduledToday,
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
        SliverToBoxAdapter(child: TodaySummaryCard()),
        SliverToBoxAdapter(child: TodayNextItemCard()),
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
