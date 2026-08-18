import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/doctor_prescription_provider.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_medications_section.dart';
import 'package:rehab_track/presentation/widgets/medication/medication_form.dart';

/// Doctor Prescription Details Screen
class DoctorPrescriptionDetailsScreen extends ConsumerStatefulWidget {
  const DoctorPrescriptionDetailsScreen({
    super.key,
    required this.prescriptionId,
  });

  final int prescriptionId;

  @override
  ConsumerState<DoctorPrescriptionDetailsScreen> createState() =>
      _DoctorPrescriptionDetailsScreenState();
}

class _DoctorPrescriptionDetailsScreenState
    extends ConsumerState<DoctorPrescriptionDetailsScreen> {
  DoctorPrescription? _prescription;
  List<DoctorPrescriptionAttachment> _attachments = [];
  List<DoctorPrescriptionMedication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null) {
      setState(() => _isLoading = false);
      return;
    }
    final prescription = await ref
        .read(doctorPrescriptionRepositoryProvider)
        .getPrescription(widget.prescriptionId, profileId);

    if (prescription != null) {
      final dao = ref.read(doctorPrescriptionDaoProvider);
      final attachments = await dao.getAttachments(widget.prescriptionId);
      final medications = await dao.getMedications(widget.prescriptionId);

      setState(() {
        _prescription = prescription;
        _attachments = attachments
            .map(DoctorPrescriptionAttachment.fromDb)
            .toList();
        _medications =
            medications.map(DoctorPrescriptionMedication.fromDb).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doctorPrescriptionDetails),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.push(
                    AppRoutes.recordsPrescriptionsEdit(widget.prescriptionId),
                  );
                  break;
                case 'archive':
                  _archivePrescription();
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined, size: 20),
                  title:
                      Text(AppLocalizations.of(context)!.editDoctorPrescription),
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.archive_outlined, size: 20),
                  title:
                      Text(AppLocalizations.of(context)!.archivePrescription),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.deleteDoctorPrescription,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Future<void> _archivePrescription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.archivePrescription),
        content:
            Text(AppLocalizations.of(context)!.archivePrescriptionConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.archive),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final profileId = ref.read(currentActiveProfileIdProvider);
        if (profileId == null) return;
        await ref
            .read(doctorPrescriptionRepositoryProvider)
            .archivePrescription(widget.prescriptionId, profileId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.prescriptionArchived),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.error}: $e'),
            ),
          );
        }
      }
    }
  }

  void _confirmDelete() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDoctorPrescription),
        content: Text(l10n.confirmDeletePrescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePrescription();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePrescription() async {
    try {
      final profileId = ref.read(currentActiveProfileIdProvider);
      if (profileId == null) return;
      await ref
          .read(doctorPrescriptionRepositoryProvider)
          .deletePrescription(widget.prescriptionId, profileId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.prescriptionDeleted),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _createMedication() async {
    final prescription = _prescription;
    if (prescription == null) return;
    final l10n = AppLocalizations.of(context)!;

    final medicationName = prescription.title.trim();
    if (medicationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noMedicationInfoEntered)),
      );
      return;
    }

    final notes = [
      if (prescription.reason != null && prescription.reason!.trim().isNotEmpty)
        prescription.reason!.trim(),
      if (prescription.notes != null && prescription.notes!.trim().isNotEmpty)
        prescription.notes!.trim(),
    ].join('\n');

    // Open the existing medication creation screen pre-filled. No auto-save.
    context.push(
      AppRoutes.medicationAdd,
      extra: MedicationFormData(
        name: medicationName,
        notes: notes,
      ),
    );
  }

  Widget _buildContent() {
    if (_prescription == null) {
      return const Center(child: Text('Prescription not found'));
    }

    final prescription = _prescription!;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final contactLookup = ref.watch(careContactLookupProvider);
    final relatedVisit = prescription.relatedDoctorVisitId != null
        ? ref
            .watch(doctorVisitByIdProvider(prescription.relatedDoctorVisitId!))
            .valueOrNull
        : null;

    final doctorName = _contactName(contactLookup[prescription.doctorContactId]);
    final clinicName = _contactName(contactLookup[prescription.clinicContactId]);
    final visitValue = _visitLabel(relatedVisit);

    final hasMedicationInfo =
        prescription.title.trim().isNotEmpty ||
            (prescription.reason != null &&
                prescription.reason!.trim().isNotEmpty) ||
            (prescription.notes != null &&
                prescription.notes!.trim().isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prescription.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          _DetailRow(
            label: AppLocalizations.of(context)!.prescriptionDate,
            value: AppDateFormatter.of(context).formatMediumDate(
              prescription.prescriptionDate,
            ),
          ),
          const SizedBox(height: 8),

          if (prescription.doctorContactId != null) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.doctor,
              value: doctorName,
            ),
            const SizedBox(height: 8),
          ],

          if (prescription.clinicContactId != null) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.clinicOrHospital,
              value: clinicName,
            ),
            const SizedBox(height: 8),
          ],

          if (prescription.relatedDoctorVisitId != null) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.relatedDoctorVisit,
              value: visitValue,
            ),
            const SizedBox(height: 8),
          ],

          if (prescription.reason != null &&
              prescription.reason!.isNotEmpty) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.prescriptionReason,
              value: prescription.reason!,
            ),
            const SizedBox(height: 8),
          ],

          if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.notes,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              prescription.notes!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],

          if (_medications.isNotEmpty) ...[
            const SizedBox(height: 16),
            DoctorPrescriptionMedicationsList(medications: _medications),
          ],

          if (hasMedicationInfo) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _createMedication,
              icon: const Icon(Icons.medication_outlined),
              label: Text(l10n.createMedication),
            ),
          ],

          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.attachments,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._attachments.map((attachment) => _AttachmentTile(
                  attachment: attachment,
                  onOpen: () => _openAttachment(attachment),
                  onShare: () => _shareAttachment(attachment),
                  onRename: () => _renameAttachment(attachment),
                  onRemove: () => _removeAttachment(attachment),
                )),
          ],
        ],
      ),
    );
  }

  String _contactName(CareContact? contact) {
    final name = contact?.effectiveDisplayName.trim();
    if (name != null && name.isNotEmpty) return name;
    return AppLocalizations.of(context)!.contactNoLongerAvailable;
  }

  String _visitLabel(DoctorVisitRecord? visit) {
    if (visit == null) {
      return AppLocalizations.of(context)!.visitNoLongerAvailable;
    }
    if (visit.reason != null && visit.reason!.trim().isNotEmpty) {
      return visit.reason!;
    }
    final formatter = AppDateFormatter.of(context);
    final date = formatter.formatMediumDate(visit.scheduledDateTime);
    final time = formatter.formatTime(visit.scheduledDateTime);
    return '$date $time';
  }

  Future<void> _renameAttachment(
    DoctorPrescriptionAttachment attachment,
  ) async {
    final controller = TextEditingController(text: attachment.displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameAttachment),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.displayName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(context, value.isEmpty ? null : value);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );

    if (newName == null || newName == attachment.displayName) return;
    try {
      await ref
          .read(doctorPrescriptionRepositoryProvider)
          .updateAttachment(attachment.copyWith(displayName: newName));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.attachmentRenamed),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
          ),
        );
      }
    }
  }

  Future<void> _removeAttachment(
    DoctorPrescriptionAttachment attachment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.removeAttachment),
        content: Text(AppLocalizations.of(context)!.confirmRemoveAttachment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(doctorPrescriptionRepositoryProvider)
            .removeAttachment(attachment.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.attachmentRemoved),
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.error}: $e'),
            ),
          );
        }
      }
    }
  }

  Future<void> _openAttachment(
    DoctorPrescriptionAttachment attachment,
  ) async {
    try {
      final file = await _resolveFile(attachment);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.couldNotOpenAttachment),
            ),
          );
        }
        return;
      }

      if (attachment.fileType == 'image') {
        const channel = MethodChannel('com.earkania.rehabtrack/notifications');
        try {
          final openedInPhotos = await channel.invokeMethod<bool>(
            'openImageWithPhotos',
            {'path': file.path},
          );
          if (mounted && openedInPhotos != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.couldNotOpenAttachment),
              ),
            );
          }
          return;
        } on PlatformException catch (_) {
          // Fall through to default handler below.
        }
      }

      final result = await OpenFilex.open(file.path);
      if (mounted && result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.couldNotOpenAttachment),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.couldNotOpenAttachment}: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareAttachment(
    DoctorPrescriptionAttachment attachment,
  ) async {
    try {
      final file = await _resolveFile(attachment);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: attachment.displayName,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.couldNotShareAttachment,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.couldNotShareAttachment}: $e',
            ),
          ),
        );
      }
    }
  }

  Future<File> _resolveFile(
    DoctorPrescriptionAttachment attachment,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    return File(p.join(appDir.path, attachment.managedRelativePath));
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final DoctorPrescriptionAttachment attachment;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  const _AttachmentTile({
    required this.attachment,
    required this.onOpen,
    required this.onShare,
    required this.onRename,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _FileTypeIcon(fileType: attachment.fileType),
        title: Text(
          attachment.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          attachment.originalFileName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.open_in_new, color: theme.colorScheme.primary),
              onPressed: onOpen,
              tooltip: l10n.openAttachment,
            ),
            IconButton(
              icon: Icon(Icons.share, color: theme.colorScheme.primary),
              onPressed: onShare,
              tooltip: l10n.shareAttachment,
            ),
            IconButton(
              icon: Icon(Icons.drive_file_rename_outline,
                  color: theme.colorScheme.primary),
              onPressed: onRename,
              tooltip: l10n.renameAttachment,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: onRemove,
              tooltip: l10n.removeAttachment,
            ),
          ],
        ),
      ),
    );
  }
}

class _FileTypeIcon extends StatelessWidget {
  final String fileType;

  const _FileTypeIcon({required this.fileType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (fileType) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'image':
        icon = Icons.image;
        color = Colors.blue;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}