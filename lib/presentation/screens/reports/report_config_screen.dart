import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/report_configuration.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/providers/report_provider.dart';

/// Configuration screen for the Health Report: name, date range, and the
/// sections to include. Builds a [ReportData] on Preview and pushes the
/// preview screen.
class ReportConfigScreen extends ConsumerStatefulWidget {
  const ReportConfigScreen({super.key});

  @override
  ConsumerState<ReportConfigScreen> createState() =>
      _ReportConfigScreenState();
}

class _ReportConfigScreenState extends ConsumerState<ReportConfigScreen> {
  final TextEditingController _titleController = TextEditingController();
  ReportDateRangeType _rangeType = ReportDateRangeType.last30Days;
  DateTime? _customStart;
  DateTime? _customEnd;
  final Set<ReportSection> _sections = {...ReportSection.ordered};
  bool _building = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  ReportConfiguration get _configuration {
    return ReportConfiguration(
      title: _titleController.text.trim().isEmpty
          ? ReportConfiguration.defaultTitle
          : _titleController.text,
      dateRangeType: _rangeType,
      customStartDate: _customStart,
      customEndDate: _customEnd,
      selectedSections: _sections,
      profileId: ref.read(currentActiveProfileIdProvider) ?? 1,
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _customStart : _customEnd) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _customStart = picked;
      } else {
        _customEnd = picked;
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onPreview() async {
    final l10n = AppLocalizations.of(context)!;
    final config = _configuration;
    if (!config.hasSelectedSection) {
      _showError(l10n.reportErrorNoSections);
      return;
    }
    if (!config.hasValidTitle) {
      _showError(l10n.reportErrorInvalidTitle);
      return;
    }
    if (!config.hasValidCustomRange) {
      _showError(l10n.reportErrorInvalidRange);
      return;
    }

    setState(() => _building = true);
    try {
      final data = await ref.read(reportBuilderProvider).build(config);
      if (!mounted) return;
      context.push(AppRoutes.recordsReportsPreview, extra: data);
    } catch (_) {
      if (mounted) _showError(l10n.reportErrorGeneric);
    } finally {
      if (mounted) setState(() => _building = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rangeLabels = <ReportDateRangeType, String>{
      ReportDateRangeType.last7Days: l10n.reportRangeLastWeek,
      ReportDateRangeType.last30Days: l10n.reportRangeLastMonth,
      ReportDateRangeType.last90Days: l10n.reportRangeLast3Months,
      ReportDateRangeType.allTime: l10n.reportRangeAllTime,
      ReportDateRangeType.custom: l10n.reportRangeCustom,
    };
    final sectionLabels = <ReportSection, String>{
      ReportSection.profile: l10n.reportPatientSummary,
      ReportSection.medications: l10n.medications,
      ReportSection.measurements: l10n.measurements,
      ReportSection.doctorVisits: l10n.doctorVisits,
      ReportSection.doctorPrescriptions: l10n.doctorPrescriptions,
      ReportSection.labAnalyses: l10n.labAnalyses,
      ReportSection.diet: l10n.diet,
      ReportSection.activities: l10n.activities,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.reportNameLabel,
                  hintText: l10n.reportDefaultTitle,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.reportDateRangeLabel,
                  style: theme.textTheme.titleMedium),
              DropdownButtonFormField<ReportDateRangeType>(
                initialValue: _rangeType,
                decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (final entry in rangeLabels.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _rangeType = value ?? _rangeType),
              ),
              if (_rangeType == ReportDateRangeType.custom) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: true),
                        child: Text(
                          _customStart == null
                              ? l10n.reportCustomStartDate
                              : '${l10n.reportCustomStartDate}: ${_fmtDate(_customStart!)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(isStart: false),
                        child: Text(
                          _customEnd == null
                              ? l10n.reportCustomEndDate
                              : '${l10n.reportCustomEndDate}: ${_fmtDate(_customEnd!)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(l10n.reportSectionsLabel,
                  style: theme.textTheme.titleMedium),
              Column(
                children: [
                  for (final section in ReportSection.ordered)
                    CheckboxListTile(
                      title: Text(sectionLabels[section]!),
                      value: _sections.contains(section),
                      onChanged: (checked) => setState(() {
                        checked!
                            ? _sections.add(section)
                            : _sections.remove(section);
                      }),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: FilledButton.icon(
              onPressed: _building ? null : _onPreview,
              icon: _building
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.preview_outlined),
              label: Text(l10n.reportPreview),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';
}
