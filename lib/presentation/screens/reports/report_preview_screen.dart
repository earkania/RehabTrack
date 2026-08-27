import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/data/services/report/report_storage_service.dart';
import 'package:rehab_track/data/services/report/saved_report_file.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/entities/report_data.dart';
import 'package:rehab_track/domain/entities/report_date_range.dart';
import 'package:rehab_track/domain/entities/report_section.dart';
import 'package:rehab_track/domain/enums/enums.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/domain/services/bmi.dart';
import 'package:rehab_track/presentation/providers/care_contact_provider.dart';
import 'package:rehab_track/presentation/providers/report_provider.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/domain/services/report_localization.dart';

/// Read-only preview of the prepared [ReportData], mirroring the section
/// order and content of the generated PDF. The generate action renders the
/// PDF bytes via [ReportPdfGenerator], persists them through
/// [ReportStorageService] (Downloads/RehabTrack) and offers Open / Share /
/// Done on the saved file.
class ReportPreviewScreen extends ConsumerStatefulWidget {
  const ReportPreviewScreen({super.key, required this.data});

  final ReportData data;

  @override
  ConsumerState<ReportPreviewScreen> createState() =>
      _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends ConsumerState<ReportPreviewScreen> {
  bool _generating = false;

  Future<void> _generateAndSavePdf() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final loc = ReportLocalization.of(context);
    setState(() => _generating = true);
    try {
      final fonts = await ref.read(reportPdfFontsProvider.future);
      final generator = ref.read(reportPdfGeneratorProvider);
      final storage = ref.read(reportStorageServiceProvider);
      final bytes = await generator.build(data: widget.data, loc: loc, fonts: fonts);
      final saved = await storage.savePdf(
        bytes: bytes,
        displayName: generator.buildFileName(widget.data),
      );
      if (!mounted) return;
      await _showSuccessSheet(saved, l10n, loc, storage);
    } on ReportStorageException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(e.code == 'STORAGE_UNAVAILABLE'
            ? l10n.reportStorageUnavailable
            : l10n.couldNotSaveReport),
      ));
    } on PlatformException {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.couldNotSaveReport)));
    } catch (_) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.couldNotSaveReport)));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _showSuccessSheet(
    SavedReportFile saved,
    AppLocalizations l10n,
    ReportLocalization loc,
    ReportStorageService storage,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Theme.of(sheetContext).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l10n.reportGeneratedSuccessfully,
                        style: Theme.of(sheetContext).textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('${l10n.savedTo}: ${saved.logicalLocation}',
                  style: Theme.of(sheetContext).textTheme.bodyMedium),
              Text(saved.displayName,
                  style: Theme.of(sheetContext).textTheme.bodySmall),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  final sheetMessenger = ScaffoldMessenger.of(sheetContext);
                  try {
                    await storage.open(saved);
                  } on ReportStorageException catch (_) {
                    sheetMessenger.showSnackBar(SnackBar(
                        content: Text(l10n.couldNotOpenReport)));
                  } catch (_) {
                    sheetMessenger.showSnackBar(SnackBar(
                        content: Text(l10n.couldNotOpenReport)));
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.openReport),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showContactPicker(
                  saved: saved,
                  loc: loc,
                  l10n: l10n,
                  storage: storage,
                ),
                icon: const Icon(Icons.email_outlined),
                label: Text(l10n.sendToDoctorOrClinic),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final sheetMessenger = ScaffoldMessenger.of(sheetContext);
                  try {
                    await storage.share(saved);
                  } catch (_) {
                    sheetMessenger.showSnackBar(SnackBar(
                        content: Text(l10n.couldNotShareReport)));
                  }
                },
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.shareReport),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(l10n.doneAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a bottom sheet listing Care Contacts with email addresses.
  /// When a contact is selected, opens the email composer.
  Future<void> _showContactPicker({
    required SavedReportFile saved,
    required ReportLocalization loc,
    required AppLocalizations l10n,
    required ReportStorageService storage,
  }) async {
    List<CareContact> contactsWithEmail = const [];
    try {
      final contacts = await ref.read(careContactsProvider.future);
      contactsWithEmail = contacts
          .where((c) => c.email != null && c.email!.trim().isNotEmpty)
          .toList();
    } on Exception {
      contactsWithEmail = const [];
    }

    if (!mounted) return;

    if (contactsWithEmail.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(l10n.noCareContactsWithEmail),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(AppRoutes.profileCareContacts);
              },
              child: Text(l10n.manageCareContacts),
            ),
          ],
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.selectCareContact,
                  style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contactsWithEmail.length,
                  itemBuilder: (context, index) {
                    final c = contactsWithEmail[index];
                    return ListTile(
                      title: Text(c.effectiveDisplayName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _contactTypeLabel(c.contactType, l10n),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            c.email!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _sendReportByEmail(
                          saved: saved,
                          contact: c,
                          loc: loc,
                          l10n: l10n,
                          storage: storage,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the email subject, body, and opens the email composer.
  Future<void> _sendReportByEmail({
    required SavedReportFile saved,
    required CareContact contact,
    required ReportLocalization loc,
    required AppLocalizations l10n,
    required ReportStorageService storage,
  }) async {
    final data = widget.data;
    final config = data.configuration;
    final patientName = data.profileSummary?.fullName ?? '';
    final reportTitle = loc.titleFor(config);

    // Period text: use actual dates for custom range, label for presets.
    final String period;
    if (config.dateRangeType == ReportDateRangeType.custom &&
        config.customStartDate != null &&
        config.customEndDate != null) {
      final formatter = AppDateFormatter.of(context);
      period =
          '${formatter.formatShortDate(config.customStartDate!)} – ${formatter.formatShortDate(config.customEndDate!)}';
    } else {
      period = loc.rangeLabels[config.dateRangeType] ?? '';
    }

    final subject = l10n.reportEmailSubject(reportTitle, patientName);
    final body = l10n.reportEmailBody(reportTitle, period, patientName);

    try {
      await storage.composeEmail(
        file: saved,
        recipient: contact.email!,
        subject: subject,
        body: body,
      );
    } on ReportStorageException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'NO_EMAIL_APP'
          ? l10n.noEmailAppAvailable
          : l10n.couldNotOpenEmailComposer;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenEmailComposer)),
      );
    }
  }

  String _contactTypeLabel(CareContactType type, AppLocalizations l10n) {
    return switch (type) {
      CareContactType.doctor => l10n.doctor,
      CareContactType.clinic => l10n.clinicOrHospital,
      CareContactType.laboratory => l10n.laboratory,
      CareContactType.pharmacy => l10n.pharmacy,
      CareContactType.insurance => l10n.insurance,
      CareContactType.other => l10n.otherGuidanceCategory,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final loc = ReportLocalization.of(context);
    final data = widget.data;
    final periodLine =
        loc.rangeLabels[data.configuration.dateRangeType] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportPreviewTitle),
        actions: [
          IconButton(
            tooltip: l10n.generatePdf,
            onPressed: _generating ? null : _generateAndSavePdf,
            icon: _generating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(loc.titleFor(data.configuration),
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(loc.formatGeneratedAt(data.generatedAt),
              style: theme.textTheme.bodySmall),
          Text('${loc.periodLabel}: $periodLine',
              style: theme.textTheme.bodySmall),
          const Divider(height: 24),
          for (final section in data.configuration.orderedSections)
            if (!data.isEmptySection(section)) ..._sectionWidgets(section, loc),
        ],
      ),
    );
  }

  List<Widget> _sectionWidgets(ReportSection section, ReportLocalization loc) {
    final data = widget.data;
    final theme = Theme.of(context);
    final heading = Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child:
          Text(loc.sectionTitles[section]!, style: theme.textTheme.titleLarge),
    );
    final muted = theme.textTheme.bodySmall;

    switch (section) {
      case ReportSection.profile:
        final p = data.profileSummary!;
        return [
          heading,
          Text(p.fullName, style: theme.textTheme.titleMedium),
          if (p.birthDate != null) _kv(loc.birthDateLabel, loc.formatDate(p.birthDate!)),
          if (loc.genderLabelFor(p.gender) != null)
            _kv(loc.genderLabel, loc.genderLabelFor(p.gender)!),
          if (p.bloodType != null) _kv(loc.bloodTypeLabel, p.bloodType!),
          if (p.heightCm != null)
            _kv(loc.heightLabel, p.heightCm!.toStringAsFixed(0)),
          if (p.weightKg != null)
            _kv(loc.weightLabel, p.weightKg!.toStringAsFixed(0)),
          if (p.bmi != null) _kv(loc.bmiLabel, formatBmi(p.bmi!)),
          if (p.allergies != null) _kv(loc.allergiesLabel, p.allergies!),
          if (p.emergencyContactName != null ||
              p.emergencyContactPhone != null)
            _kv(
              loc.emergencyContactLabel,
              [p.emergencyContactName, p.emergencyContactPhone]
                  .whereType<String>()
                  .join(' · '),
            ),
        ];
      case ReportSection.medications:
        return [
          heading,
          for (final med in data.medications)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      med.name,
                      [med.doseAmount, med.doseUnit]
                          .whereType<String>()
                          .join(' ')
                          .trim(),
                    ].where((s) => s.isNotEmpty).join(' — '),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (med.scheduleSummary != null)
                    Text(med.scheduleSummary!, style: muted),
                  if (med.instructions != null)
                    Text(med.instructions!, style: muted),
                ],
              ),
            ),
        ];
      case ReportSection.measurements:
        return [
          heading,
          for (final type in data.measurements)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.typeName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  for (final c in type.components)
                    _kv(
                      c.label,
                      '${loc.statMin} ${_num(c.minimum)} · '
                      '${loc.statMax} ${_num(c.maximum)} · '
                      '${loc.statAvg} ${_num(c.average)} ${c.unit}',
                    ),
                  if (type.isTruncated)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        loc.showingLatest(
                            type.includedReadingCount, type.totalReadingCount),
                        style: muted,
                      ),
                    ),
                  ...type.readings.take(20).map(
                        (row) => Text(
                          '${loc.formatDateTime(row.measuredAt)}  '
                          '${row.values.map((v) => '${_num(v.value)} ${v.unit}').join(' / ')}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                ],
              ),
            ),
        ];
      case ReportSection.doctorVisits:
        return [
          heading,
          for (final v in data.doctorVisits)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${loc.formatDateTime(v.scheduledAt)} · '
                      '${loc.visitStatusLabels[v.status] ?? v.status}'),
                  if (v.doctorName != null || v.organizationName != null)
                    Text([v.doctorName, v.organizationName]
                        .whereType<String>()
                        .where((s) => s.isNotEmpty)
                        .join(' · '), style: muted),
                  if (v.reason != null) Text(v.reason!, style: muted),
                ],
              ),
            ),
        ];
      case ReportSection.doctorPrescriptions:
        return [
          heading,
          for (final rx in data.doctorPrescriptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(loc.formatDateTime(rx.prescriptionDate), style: muted),
                  if (rx.doctorName != null || rx.clinicName != null)
                    Text([rx.doctorName, rx.clinicName]
                        .whereType<String>()
                        .where((s) => s.isNotEmpty)
                        .join(' · '), style: muted),
                  for (final med in rx.medications)
                    Text('• ${med.name}', style: theme.textTheme.bodySmall),
                  if (rx.attachmentNames.isNotEmpty)
                    Text(
                      '${loc.attachmentsLabel(rx.attachmentNames.length)}: '
                      '${rx.attachmentNames.join(', ')}',
                      style: muted,
                    ),
                ],
              ),
            ),
        ];
      case ReportSection.labAnalyses:
        return [
          heading,
          for (final lab in data.labAnalyses)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lab.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(loc.formatDateTime(lab.analysisDate), style: muted),
                  if (lab.laboratoryName != null)
                    Text(lab.laboratoryName!, style: muted),
                  if (lab.attachmentNames.isNotEmpty)
                    Text(
                      '${loc.attachmentsLabel(lab.attachmentNames.length)}: '
                      '${lab.attachmentNames.join(', ')}',
                      style: muted,
                    ),
                ],
              ),
            ),
        ];
      case ReportSection.diet:
        final diet = data.diet!;
        return [
          heading,
          for (final entry in diet.guidanceByCategory.entries) ...[
            Text(loc.guidanceCategoryLabels[entry.key] ?? entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            for (final rule in entry.value) Text('• ${rule.title}', style: muted),
          ],
          for (final entry in diet.foodsByCategory.entries) ...[
            const SizedBox(height: 6),
            Text(loc.foodCategoryLabels[entry.key] ?? entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            for (final food in entry.value) Text('• ${food.name}', style: muted),
          ],
        ];
      case ReportSection.activities:
        final stats = data.activityStats;
        return [
          heading,
          if (stats != null) ...[
            Text(loc.activitySummary(
                stats.sessionCount, stats.completedCount, stats.cancelledCount)),
            Text(
              '${loc.totalActiveTimeLabel}: '
              '${loc.formatDuration(stats.totalActiveDuration)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
          ],
          for (final s in data.activitySessions)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${loc.formatDateTime(s.startedAt)} · ${s.activityName} · '
                '${loc.formatDuration(s.activeDuration)} · '
                '${loc.sessionStatusLabels[s.status] ?? s.status}',
                style: muted,
              ),
            ),
        ];
    }
  }

  Widget _kv(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _num(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    final s = value.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }
}
