import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';

/// Attachments section for the Lab Analysis form
class AttachmentsSection extends ConsumerStatefulWidget {
  final List<File> newAttachments;
  final List<LabAnalysisAttachment> existingAttachments;
  final VoidCallback onAddPdf;
  final VoidCallback onAddImage;
  final VoidCallback onTakePhoto;
  final void Function(int) onRemoveAttachment;

  const AttachmentsSection({
    super.key,
    required this.newAttachments,
    required this.existingAttachments,
    required this.onAddPdf,
    required this.onAddImage,
    required this.onTakePhoto,
    required this.onRemoveAttachment,
  });

  @override
  ConsumerState<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends ConsumerState<AttachmentsSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attachments,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        // Add attachment buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _AddAttachmentButton(
              icon: Icons.picture_as_pdf_outlined,
              label: l10n.addPdf,
              onPressed: widget.onAddPdf,
              color: Colors.red,
            ),
            _AddAttachmentButton(
              icon: Icons.photo_library_outlined,
              label: l10n.addImage,
              onPressed: widget.onAddImage,
              color: Colors.blue,
            ),
            _AddAttachmentButton(
              icon: Icons.camera_alt_outlined,
              label: l10n.takePhoto,
              onPressed: widget.onTakePhoto,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Existing attachments list
        if (widget.existingAttachments.isNotEmpty) ...[
          Text(l10n.existingAttachments, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.existingAttachments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final attachment = widget.existingAttachments[index];
              return _ExistingAttachmentTile(
                attachment: attachment,
                onRemove: () => widget.onRemoveAttachment(index),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        // New attachments list
        if (widget.newAttachments.isNotEmpty) ...[
          Text(l10n.newAttachments, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.newAttachments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final file = widget.newAttachments[index];
              return _NewAttachmentTile(
                file: file,
                index: index,
                onRemove: () {
                  widget.onRemoveAttachment(widget.existingAttachments.length + index);
                },
              );
            },
          ),
        ],
      ],
    );
  }
}

class _AddAttachmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _AddAttachmentButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: color),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _ExistingAttachmentTile extends StatelessWidget {
  final LabAnalysisAttachment attachment;
  final VoidCallback onRemove;

  const _ExistingAttachmentTile({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
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
              onPressed: () {
                // TODO: Open attachment
              },
              tooltip: l10n.openAttachment,
            ),
            IconButton(
              icon: Icon(Icons.share, color: theme.colorScheme.primary),
              onPressed: () {
                // TODO: Share attachment
              },
              tooltip: l10n.shareAttachment,
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

class _NewAttachmentTile extends StatelessWidget {
  final File file;
  final int index;
  final VoidCallback onRemove;

  const _NewAttachmentTile({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: _FileTypeIcon(fileType: _getFileType(file.path)),
        title: Text(
          file.path.split('/').last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          l10n.newAttachment,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.error),
          onPressed: onRemove,
          tooltip: l10n.removeAttachment,
        ),
      ),
    );
  }

  String _getFileType(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.pdf') return 'pdf';
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') return 'image';
    return 'other';
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