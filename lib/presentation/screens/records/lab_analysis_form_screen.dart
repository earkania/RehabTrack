import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/lab_analysis.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/lab_analysis_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/care_contact_selector.dart';
import 'package:rehab_track/presentation/widgets/doctor_visit_selector.dart';
import 'package:rehab_track/presentation/screens/records/lab_analysis_attachments_section.dart';

/// Add/Edit Lab Analysis screen
class LabAnalysisFormScreen extends ConsumerStatefulWidget {
  const LabAnalysisFormScreen({super.key, this.analysisId});

  final int? analysisId;

  @override
  ConsumerState<LabAnalysisFormScreen> createState() => _LabAnalysisFormScreenState();
}

class _LabAnalysisFormScreenState extends ConsumerState<LabAnalysisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'laboratory';
  DateTime _analysisDate = DateTime.now();
  DateTime? _resultReceivedDate;
  int? _laboratoryContactId;
  int? _orderingDoctorContactId;
  int? _relatedDoctorVisitId;
  final List<File> _newAttachments = [];
  final List<int> _removedAttachmentIds = [];
  List<LabAnalysisAttachment> _existingAttachments = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.analysisId != null;
    if (_isEditing) {
      _loadExistingAnalysis();
    }
  }

  Future<void> _loadExistingAnalysis() async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null || widget.analysisId == null) return;
    final analysis = await ref
        .read(labAnalysisRepositoryProvider)
        .getAnalysis(widget.analysisId!, profileId);

    if (analysis != null && mounted) {
      setState(() {
        _titleController.text = analysis.title;
        _selectedCategory = analysis.category;
        _analysisDate = analysis.analysisDate;
        _resultReceivedDate = analysis.resultReceivedDate;
        _laboratoryContactId = analysis.laboratoryContactId;
        _orderingDoctorContactId = analysis.orderingDoctorContactId;
        _relatedDoctorVisitId = analysis.relatedDoctorVisitId;
        _notesController.text = analysis.notes ?? '';
        _isEditing = true;
      });

      // Load existing attachments
      final dao = ref.read(labAnalysisDaoProvider);
      final attachments = await dao.getAttachments(widget.analysisId!);
      if (mounted) {
        setState(() {
          _existingAttachments = attachments.map(LabAnalysisAttachment.fromDb).toList();
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.analysisId == null ? l10n.addLabAnalysis : l10n.editLabAnalysis),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.analysisTitle,
                hintText: l10n.analysisTitleHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.analysisTitleRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.analysisCategory,
              ),
              items: [
                DropdownMenuItem(value: 'laboratory', child: Text(l10n.laboratory)),
                DropdownMenuItem(value: 'cardiology', child: Text(l10n.cardiology)),
                DropdownMenuItem(value: 'imaging', child: Text(l10n.imaging)),
                DropdownMenuItem(value: 'pathology', child: Text(l10n.pathology)),
                DropdownMenuItem(value: 'other', child: Text(l10n.other)),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Analysis Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.analysisDate),
              subtitle: Text(
                AppDateFormatter.of(context).formatMediumDate(_analysisDate),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _analysisDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _analysisDate = date;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Result Received Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.resultReceivedDate),
              subtitle: Text(
                _resultReceivedDate != null
                    ? AppDateFormatter.of(context)
                        .formatMediumDate(_resultReceivedDate!)
                    : l10n.notSet,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_resultReceivedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _resultReceivedDate = null;
                        });
                      },
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _resultReceivedDate ?? _analysisDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _resultReceivedDate = date;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Laboratory/Clinic
            CareContactSelector(
              label: l10n.laboratoryOrClinic,
              selectedContactId: _laboratoryContactId,
              allowedTypes: ['laboratory', 'clinic', 'hospital'],
              onChanged: (id) => setState(() => _laboratoryContactId = id),
            ),

            const SizedBox(height: 16),

            // Ordering Doctor
            CareContactSelector(
              label: l10n.orderingDoctor,
              selectedContactId: _orderingDoctorContactId,
              allowedTypes: ['doctor'],
              onChanged: (id) => setState(() => _orderingDoctorContactId = id),
            ),

            const SizedBox(height: 16),

            // Related Doctor Visit
            DoctorVisitSelector(
              label: l10n.relatedDoctorVisit,
              selectedVisitId: _relatedDoctorVisitId,
              onChanged: (id) => setState(() => _relatedDoctorVisitId = id),
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.analysisNotes,
                hintText: l10n.analysisNotesHint,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // Attachments Section
            AttachmentsSection(
              newAttachments: _newAttachments,
              existingAttachments: _existingAttachments,
              onAddPdf: _pickPdf,
              onAddImage: _pickImage,
              onTakePhoto: _takePhoto,
              onRemoveAttachment: _removeAttachment,
            ),

            const SizedBox(height: 24),

            // Save Button
            FilledButton(
              onPressed: _isLoading ? null : _save,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? l10n.updateLabAnalysis : l10n.saveLabAnalysis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      setState(() {
        _newAttachments.add(file);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newAttachments.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _newAttachments.add(File(pickedFile.path));
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      if (index < _existingAttachments.length) {
        _removedAttachmentIds.add(_existingAttachments[index].id!);
        _existingAttachments.removeAt(index);
      } else {
        _newAttachments.removeAt(index - _existingAttachments.length);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate dates
    if (_resultReceivedDate != null &&
        _resultReceivedDate!.isBefore(_analysisDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.resultDateBeforeAnalysisDate)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profileId = ref.read(currentActiveProfileIdProvider);
      if (profileId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final repo = ref.read(labAnalysisRepositoryProvider);

      final analysis = LabAnalysis(
        id: widget.analysisId,
        profileId: profileId,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        analysisDate: _analysisDate,
        resultReceivedDate: _resultReceivedDate,
        laboratoryContactId: _laboratoryContactId,
        orderingDoctorContactId: _orderingDoctorContactId,
        relatedDoctorVisitId: _relatedDoctorVisitId,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.analysisId == null) {
        await repo.createAnalysis(analysis, _newAttachments.toList());
      } else {
        for (final attachmentId in _removedAttachmentIds) {
          await repo.removeAttachment(attachmentId);
        }
        await repo.updateAnalysis(analysis);
        if (_newAttachments.isNotEmpty) {
          final saved = await ref
              .read(labAnalysisRepositoryProvider)
              .getAnalysis(analysis.id!, profileId);
          if (saved != null) {
            for (final file in _newAttachments) {
              await repo.addAttachment(
                saved.id!,
                profileId,
                file,
                _fileType(file.path),
                file.path.split('/').last,
                _mimeType(file.path),
              );
            }
          }
        }
      }

      if (mounted) {
        if (context.mounted) {
          context.go(AppRoutes.recordsLabAnalyses);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.analysisSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fileType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return 'pdf';
    }
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png')) {
      return 'image';
    }
    return 'other';
  }

  String _mimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return 'application/pdf';
    }
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }
}