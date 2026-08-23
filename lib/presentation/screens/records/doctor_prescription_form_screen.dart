import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:rehab_track/core/router/app_routes.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';
import 'package:rehab_track/domain/services/app_date_formatter.dart';
import 'package:rehab_track/l10n/app_localizations.dart';
import 'package:rehab_track/presentation/providers/database_provider.dart';
import 'package:rehab_track/presentation/providers/doctor_prescription_provider.dart';
import 'package:rehab_track/presentation/providers/profile_provider.dart';
import 'package:rehab_track/presentation/widgets/care_contact_selector.dart';
import 'package:rehab_track/presentation/widgets/doctor_visit_selector.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_attachments_section.dart';
import 'package:rehab_track/presentation/screens/records/doctor_prescription_medications_section.dart';

/// Add/Edit Doctor Prescription screen
class DoctorPrescriptionFormScreen extends ConsumerStatefulWidget {
  const DoctorPrescriptionFormScreen({super.key, this.prescriptionId});

  final int? prescriptionId;

  @override
  ConsumerState<DoctorPrescriptionFormScreen> createState() =>
      _DoctorPrescriptionFormScreenState();
}

class _DoctorPrescriptionFormScreenState
    extends ConsumerState<DoctorPrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _prescriptionDate = DateTime.now();
  int? _doctorContactId;
  int? _clinicContactId;
  int? _relatedDoctorVisitId;
  final List<File> _newAttachments = [];
  final List<int> _removedAttachmentIds = [];
  List<DoctorPrescriptionAttachment> _existingAttachments = [];
  List<DoctorPrescriptionMedication> _medications = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.prescriptionId != null;
    if (_isEditing) {
      _loadExistingPrescription();
    }
  }

  Future<void> _loadExistingPrescription() async {
    final profileId = ref.read(currentActiveProfileIdProvider);
    if (profileId == null || widget.prescriptionId == null) return;
    final prescription = await ref
        .read(doctorPrescriptionRepositoryProvider)
        .getPrescription(widget.prescriptionId!, profileId);

    if (prescription != null && mounted) {
      setState(() {
        _titleController.text = prescription.title;
        _prescriptionDate = prescription.prescriptionDate;
        _doctorContactId = prescription.doctorContactId;
        _clinicContactId = prescription.clinicContactId;
        _relatedDoctorVisitId = prescription.relatedDoctorVisitId;
        _reasonController.text = prescription.reason ?? '';
        _notesController.text = prescription.notes ?? '';
        _isEditing = true;
      });

      // Load existing attachments
      final dao = ref.read(doctorPrescriptionDaoProvider);
      final attachments = await dao.getAttachments(widget.prescriptionId!);
      final medications = await dao.getMedications(widget.prescriptionId!);
      if (mounted) {
        setState(() {
          _existingAttachments = attachments
              .map(DoctorPrescriptionAttachment.fromDb)
              .toList();
          _medications =
              medications.map(DoctorPrescriptionMedication.fromDb).toList();
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.prescriptionId == null
              ? l10n.addDoctorPrescription
              : l10n.editDoctorPrescription,
        ),
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
                labelText: l10n.prescriptionName,
                hintText: l10n.prescriptionNameHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.prescriptionNameRequired;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Prescription Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.prescriptionDate),
              subtitle: Text(
                AppDateFormatter.of(context).formatMediumDate(
                  _prescriptionDate,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _prescriptionDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _prescriptionDate = date;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Doctor
            CareContactSelector(
              label: l10n.doctor,
              selectedContactId: _doctorContactId,
              allowedTypes: ['doctor'],
              onChanged: (id) => setState(() => _doctorContactId = id),
            ),

            const SizedBox(height: 16),

            // Clinic / Hospital
            CareContactSelector(
              label: l10n.clinicOrHospital,
              selectedContactId: _clinicContactId,
              allowedTypes: ['clinic', 'hospital'],
              onChanged: (id) => setState(() => _clinicContactId = id),
            ),

            const SizedBox(height: 16),

            // Related Doctor Visit
            DoctorVisitSelector(
              label: l10n.relatedDoctorVisit,
              selectedVisitId: _relatedDoctorVisitId,
              onChanged: (id) => setState(() => _relatedDoctorVisitId = id),
            ),

            const SizedBox(height: 16),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: l10n.prescriptionReason,
                hintText: l10n.prescriptionReasonHint,
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.prescriptionNotes,
                hintText: l10n.prescriptionNotesHint,
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // Medications Section
            DoctorPrescriptionMedicationsEditor(
              initialMedications: _medications,
              prescriptionId: widget.prescriptionId,
              profileId: ref.read(currentActiveProfileIdProvider),
              medicationRepository:
                  ref.read(medicationRepositoryProvider),
              onChanged: (medications) {
                _medications = medications;
              },
            ),

            const SizedBox(height: 24),

            // Attachments Section
            PrescriptionAttachmentsSection(
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
                    : Text(
                        _isEditing
                            ? l10n.updateDoctorPrescription
                            : l10n.saveDoctorPrescription,
                      ),
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

    setState(() => _isLoading = true);

    try {
      final profileId = ref.read(currentActiveProfileIdProvider);
      if (profileId == null) {
        setState(() => _isLoading = false);
        return;
      }
      final repo = ref.read(doctorPrescriptionRepositoryProvider);

      final prescription = DoctorPrescription(
        id: widget.prescriptionId,
        profileId: profileId,
        title: _titleController.text.trim(),
        prescriptionDate: _prescriptionDate,
        doctorContactId: _doctorContactId,
        clinicContactId: _clinicContactId,
        relatedDoctorVisitId: _relatedDoctorVisitId,
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.prescriptionId == null) {
        await repo.createPrescription(
          prescription,
          _newAttachments.toList(),
          medications: List.of(_medications),
        );
      } else {
        for (final attachmentId in _removedAttachmentIds) {
          await repo.removeAttachment(attachmentId);
        }
        await repo.updatePrescription(
          prescription,
          medications: List.of(_medications),
        );
        if (_newAttachments.isNotEmpty) {
          final saved = await ref
              .read(doctorPrescriptionRepositoryProvider)
              .getPrescription(prescription.id!, profileId);
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
        // Capture lookups before popping: the form's context is deactivated
        // by the pop below.
        final messenger = ScaffoldMessenger.of(context);
        final savedMessage = AppLocalizations.of(context)!.prescriptionSaved;
        if (context.canPop()) {
          // Return to wherever the form was pushed from (list after add,
          // details after edit) so the existing navigation stack survives.
          // The list refreshes itself through repository watch streams.
          context.pop(true);
        } else {
          // Deep-linked form with nothing beneath it: fall back to the list.
          context.go(AppRoutes.recordsPrescriptions);
        }
        messenger.showSnackBar(
          SnackBar(content: Text(savedMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.error}: $e',
            ),
          ),
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