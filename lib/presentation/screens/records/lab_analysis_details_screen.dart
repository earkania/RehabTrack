import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/care_contact.dart';
import 'package:rehab_track/domain/entities/doctor_visit_record.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/lab_analysis_provider.dart';
import 'package:rehab_track/presentation/providers/doctor_visit_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';

/// Lab Analysis Details Screen
class LabAnalysisDetailsScreen extends ConsumerStatefulWidget {
  const LabAnalysisDetailsScreen({super.key, required this.analysisId});

  final int analysisId;

  @override
  ConsumerState<LabAnalysisDetailsScreen> createState() => _LabAnalysisDetailsScreenState();
}

class _LabAnalysisDetailsScreenState extends ConsumerState<LabAnalysisDetailsScreen> {
  LabAnalysis? _analysis;
  List<LabAnalysisAttachment> _attachments = [];
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
    final analysis = await ref
        .read(labAnalysisRepositoryProvider)
        .getAnalysis(widget.analysisId, profileId);

    if (analysis != null) {
      final dao = ref.read(labAnalysisDaoProvider);
      final attachments = await dao.getAttachments(widget.analysisId);

      setState(() {
        _analysis = analysis;
        _attachments = attachments.map(LabAnalysisAttachment.fromDb).toList();
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
        title: Text(l10n.labAnalysisDetails),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.push(AppRoutes.recordsLabAnalysesEdit(widget.analysisId));
                  break;
                case 'archive':
                  _archiveAnalysis();
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
                  title: Text(AppLocalizations.of(context)!.editLabAnalysis),
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.archive_outlined, size: 20),
                  title: Text(AppLocalizations.of(context)!.archiveAnalysis),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outlined, size: 20, color: Theme.of(context).colorScheme.error),
                  title: Text(
                    AppLocalizations.of(context)!.deleteLabAnalysis,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
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

  Future<void> _archiveAnalysis() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.archiveAnalysis),
        content: Text(AppLocalizations.of(context)!.archiveAnalysisConfirmation),
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
        await ref.read(labAnalysisRepositoryProvider).archiveAnalysis(widget.analysisId, profileId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.analysisArchived)),
          );
          context.pop(); // Go back to list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
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
        title: Text(l10n.deleteLabAnalysis),
        content: Text(l10n.confirmDeleteAnalysis),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAnalysis();
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

  Future<void> _deleteAnalysis() async {
    try {
      final profileId = ref.read(currentActiveProfileIdProvider);
      if (profileId == null) return;
      await ref.read(labAnalysisRepositoryProvider).deleteAnalysis(widget.analysisId, profileId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.analysisDeleted)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }


  Widget _buildContent() {
    if (_analysis == null) {
      return const Center(child: Text('Analysis not found'));
    }

    final analysis = _analysis!;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final contactLookup = ref.watch(careContactLookupProvider);
    final relatedVisit = analysis.relatedDoctorVisitId != null
        ? ref.watch(doctorVisitByIdProvider(analysis.relatedDoctorVisitId!)).valueOrNull
        : null;

    final labName = _contactName(contactLookup[analysis.laboratoryContactId]);
    final doctorName = _contactName(contactLookup[analysis.orderingDoctorContactId]);
    final visitValue = _visitLabel(relatedVisit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            analysis.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Category
          Row(
            children: [
              _CategoryIcon(category: analysis.category),
              const SizedBox(width: 12),
              _CategoryChip(category: analysis.category),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          _DetailRow(
            label: AppLocalizations.of(context)!.analysisDate,
            value: _formatDate(context, analysis.analysisDate),
          ),
          const SizedBox(height: 8),

          if (analysis.resultReceivedDate != null) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.resultReceivedDate,
              value: _formatDate(context, analysis.resultReceivedDate!),
            ),
            const SizedBox(height: 8),
          ],

          if (analysis.laboratoryContactId != null) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.laboratoryOrClinic,
              value: labName,
            ),
            const SizedBox(height: 8),
          ],

          if (analysis.orderingDoctorContactId != null) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.orderingDoctor,
              value: doctorName,
            ),
            const SizedBox(height: 8),
          ],

          if (analysis.relatedDoctorVisitId != null) ...[
            _DetailRow(
              label: AppLocalizations.of(context)!.relatedDoctorVisit,
              value: visitValue,
            ),
            const SizedBox(height: 8),
          ],

          if (analysis.notes != null && analysis.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              l10n.notes,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              analysis.notes!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],

          // Attachments
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
            )),
          ],
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String _contactName(CareContact? contact) {
    final name = contact?.effectiveDisplayName.trim();
    if (name != null && name.isNotEmpty) return name;
    return AppLocalizations.of(context)!.contactNotAvailable;
  }

  String _visitLabel(DoctorVisitRecord? visit) {
    if (visit == null) {
      return AppLocalizations.of(context)!.contactNotAvailable;
    }
    if (visit.reason != null && visit.reason!.trim().isNotEmpty) {
      return visit.reason!;
    }
    final date = DateFormat.yMMMd().format(visit.scheduledDateTime);
    final time = DateFormat.Hm().format(visit.scheduledDateTime);
    return '$date $time';
  }

  Future<void> _openAttachment(LabAnalysisAttachment attachment) async {
    try {
      final file = await _resolveFile(attachment);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenAttachment)),
          );
        }
        return;
      }

      if (attachment.fileType == 'image') {
        const channel = MethodChannel('com.earkania.rehabtrack/notifications');
        try {
          final openedInPhotos = await channel.invokeMethod<bool>('openImageWithPhotos', {
            'path': file.path,
          });
          if (mounted && openedInPhotos != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenAttachment)),
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
            content: Text(
              AppLocalizations.of(context)!.couldNotOpenAttachment,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.couldNotOpenAttachment}: $e')),
        );
      }
    }
  }

  Future<void> _shareAttachment(LabAnalysisAttachment attachment) async {
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
            SnackBar(content: Text(AppLocalizations.of(context)!.couldNotShareAttachment)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.couldNotShareAttachment}: $e')),
        );
      }
    }
  }

  Future<File> _resolveFile(LabAnalysisAttachment attachment) async {
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
            width: 120,
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
  final LabAnalysisAttachment attachment;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  const _AttachmentTile({
    required this.attachment,
    required this.onOpen,
    required this.onShare,
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

class _CategoryIcon extends StatelessWidget {
  final String category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (category) {
      case 'laboratory':
        icon = Icons.biotech_outlined;
        color = Colors.blue;
        break;
      case 'cardiology':
        icon = Icons.favorite_outlined;
        color = Colors.red;
        break;
      case 'imaging':
        icon = Icons.image_outlined;
        color = Colors.purple;
        break;
      case 'pathology':
        icon = Icons.science_outlined;
        color = Colors.green;
        break;
      default:
        icon = Icons.folder_outlined;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String label;

    switch (category) {
      case 'laboratory':
        label = l10n.laboratory;
        break;
      case 'cardiology':
        label = l10n.cardiology;
        break;
      case 'imaging':
        label = l10n.imaging;
        break;
      case 'pathology':
        label = l10n.pathology;
        break;
      default:
        label = l10n.other;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}