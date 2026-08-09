import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rehab_track/data/database/app_database.dart' as db;
import 'package:rehab_track/data/repositories/doctor_prescription_repository_impl.dart';
import 'package:rehab_track/domain/entities/doctor_prescription.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.AppDatabase database;
  late DoctorPrescriptionRepositoryImpl repository;
  late Directory tempDir;
  late Directory mockAppDir;

  const methodChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() async {
    database = db.AppDatabase.test();
    repository = DoctorPrescriptionRepositoryImpl(database);

    tempDir = Directory.systemTemp.createTempSync('prescription_repo_test_');
    mockAppDir = Directory(p.join(tempDir.path, 'app_docs'))
      ..createSync(recursive: true);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return mockAppDir.path;
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
    await database.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<int> insertProfile({bool isPrimary = true}) {
    return database.into(database.profiles).insert(
      db.ProfilesCompanion.insert(
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        isPrimary: Value(isPrimary),
        isActive: const Value(true),
      ),
    );
  }

  Future<int> insertContact({
    required int profileId,
    String type = 'doctor',
    String displayName = 'Dr. Smith',
  }) {
    return database.careContactDao.insertContact(
      db.CareContactsCompanion.insert(
        profileId: profileId,
        contactType: type,
        displayName: displayName,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  }

  DoctorPrescription makePrescription({
    int? id,
    required int profileId,
    String title = 'Amoxicillin 500mg',
    DateTime? prescriptionDate,
    int? doctorContactId,
    int? clinicContactId,
    int? relatedDoctorVisitId,
    String? reason,
    String? notes,
    bool isArchived = false,
  }) {
    return DoctorPrescription(
      id: id,
      profileId: profileId,
      title: title,
      prescriptionDate: prescriptionDate ?? DateTime(2026, 8, 1),
      doctorContactId: doctorContactId,
      clinicContactId: clinicContactId,
      relatedDoctorVisitId: relatedDoctorVisitId,
      reason: reason,
      notes: notes,
      isArchived: isArchived,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  File makeTempFile({
    String name = 'prescription.pdf',
    List<int> content = const [1, 2, 3],
  }) {
    final file = File(p.join(tempDir.path, name));
    file.writeAsBytesSync(content);
    return file;
  }

  group('createPrescription / getPrescription', () {
    test('persists a prescription with no attachments', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId, reason: 'Bacterial infection'),
        [],
      );

      expect(created.id, greaterThan(0));
      final saved = await repository.getPrescription(created.id!, profileId);
      expect(saved, isNotNull);
      expect(saved!.title, 'Amoxicillin 500mg');
      expect(saved.reason, 'Bacterial infection');
      expect(saved.doctorContactId, isNull);
      expect(saved.isArchived, isFalse);
    });

    test('stores files under managed storage and records attachments',
        () async {
      final profileId = await insertProfile();
      final doctorId = await insertContact(profileId: profileId);
      final file = makeTempFile(name: 'rx.pdf', content: [1, 2, 3, 4]);

      final created = await repository.createPrescription(
        makePrescription(
          profileId: profileId,
          doctorContactId: doctorId,
          reason: 'Ear infection',
        ),
        [file],
      );

      final attachments =
          await database.doctorPrescriptionDao.getAttachments(created.id!);
      expect(attachments, hasLength(1));
      final attachment = attachments.single;
      expect(attachment.fileType, 'pdf');
      expect(attachment.mimeType, 'application/pdf');
      expect(attachment.originalFileName, 'rx.pdf');
      expect(attachment.displayName, 'rx');
      expect(attachment.fileSize, 4);
      expect(attachment.managedRelativePath, startsWith(
          'doctor_prescriptions/$profileId/${created.id}/'));
      expect(attachment.managedRelativePath, endsWith('.pdf'));

      // The file was copied into the app documents directory.
      final stored = File(p.join(mockAppDir.path, attachment.managedRelativePath));
      expect(stored.existsSync(), isTrue);
      expect(stored.readAsBytesSync(), [1, 2, 3, 4]);
    });

    test('categorizes image attachments', () async {
      final profileId = await insertProfile();
      final file = makeTempFile(name: 'photo.jpg');

      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [file],
      );

      final attachments =
          await database.doctorPrescriptionDao.getAttachments(created.id!);
      expect(attachments.single.fileType, 'image');
      expect(attachments.single.mimeType, 'image/jpeg');
    });
  });

  group('updatePrescription', () {
    test('updates fields in place without duplicating the row', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId, title: 'Original'),
        [],
      );

      final updated = created.copyWith(
        title: 'Updated drug',
        notes: 'Twice daily',
      );
      await repository.updatePrescription(updated);

      final saved = await repository.getPrescription(created.id!, profileId);
      expect(saved!.title, 'Updated drug');
      expect(saved.notes, 'Twice daily');

      final all = await database.doctorPrescriptionDao
          .customSelect('SELECT COUNT(*) FROM doctor_prescriptions')
          .get();
      expect(all.single.read<int>('COUNT(*)'), 1);
    });
  });

  group('archive / restore / delete', () {
    test('archived prescription leaves the active watch and enters archived',
        () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
      );

      expect(
        await repository.watchActivePrescriptions(profileId).first,
        hasLength(1),
      );
      await repository.archivePrescription(created.id!, profileId);

      expect(await repository.watchActivePrescriptions(profileId).first,
          isEmpty);
      final archived =
          await repository.watchArchivedPrescriptions(profileId).first;
      expect(archived.map((p) => p.id), [created.id!]);
    });

    test('restore moves a prescription back to active', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
      );
      await repository.archivePrescription(created.id!, profileId);
      expect(await repository.watchActivePrescriptions(profileId).first,
          isEmpty);

      await repository.restorePrescription(created.id!, profileId);
      expect(
        await repository.watchActivePrescriptions(profileId).first,
        hasLength(1),
      );
    });

    test('delete removes the row and the managed files', () async {
      final profileId = await insertProfile();
      final file = makeTempFile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [file],
      );
      final attachments =
          await database.doctorPrescriptionDao.getAttachments(created.id!);
      final storedPath =
          p.join(mockAppDir.path, attachments.single.managedRelativePath);
      expect(File(storedPath).existsSync(), isTrue);

      await repository.deletePrescription(created.id!, profileId);

      expect(await repository.getPrescription(created.id!, profileId), isNull);
      expect(File(storedPath).existsSync(), isFalse);
      expect(
        await database.doctorPrescriptionDao.getAttachments(created.id!),
        isEmpty,
      );
    });
  });

  group('searchPrescriptions', () {
    test('filters by query on title, reason and notes', () async {
      final profileId = await insertProfile();
      await repository.createPrescription(
        makePrescription(profileId: profileId, title: 'Amoxicillin'),
        [],
      );
      await repository.createPrescription(
        makePrescription(
          profileId: profileId,
          title: 'Ibuprofen',
          reason: 'Pain relief',
        ),
        [],
      );

      final titleMatch =
          await repository.searchPrescriptions(profileId, query: 'amox').first;
      expect(titleMatch.map((p) => p.title), ['Amoxicillin']);

      final reasonMatch =
          await repository.searchPrescriptions(profileId, query: 'pain').first;
      expect(reasonMatch.map((p) => p.title), ['Ibuprofen']);
    });

    test('excludes archived unless includeArchived is set', () async {
      final profileId = await insertProfile();
      final active = await repository.createPrescription(
        makePrescription(profileId: profileId, title: 'Active rx'),
        [],
      );
      final archived = await repository.createPrescription(
        makePrescription(profileId: profileId, title: 'Archived rx'),
        [],
      );
      await repository.archivePrescription(archived.id!, profileId);

      final activeOnly =
          await repository.searchPrescriptions(profileId).first;
      expect(activeOnly.map((p) => p.id), [active.id!]);

      final withArchived = await repository
          .searchPrescriptions(profileId, includeArchived: true)
          .first;
      expect(withArchived.map((p) => p.id).toSet(),
          {active.id!, archived.id!});
    });

    test('filters by date range', () async {
      final profileId = await insertProfile();
      final old = await repository.createPrescription(
        makePrescription(
          profileId: profileId,
          title: 'Old rx',
          prescriptionDate: DateTime(2026, 1, 1),
        ),
        [],
      );
      await repository.createPrescription(
        makePrescription(
          profileId: profileId,
          title: 'New rx',
          prescriptionDate: DateTime(2026, 8, 1),
        ),
        [],
      );

      final filtered = await repository
          .searchPrescriptions(
            profileId,
            startDate: DateTime(2026, 6, 1),
          )
          .first;
      expect(filtered.map((p) => p.id), isNot(contains(old.id!)));
    });
  });

  group('attachments', () {
    test('addAttachment appends a file to an existing prescription', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
      );
      final file = makeTempFile(name: 'scan.png');

      final attachment = await repository.addAttachment(
        created.id!,
        profileId,
        file,
        'image',
        'scan',
        'image/png',
      );

      expect(attachment.sortOrder, 0);
      final stored =
          File(p.join(mockAppDir.path, attachment.managedRelativePath));
      expect(stored.existsSync(), isTrue);
      expect(
        (await database.doctorPrescriptionDao.getAttachments(created.id!))
            .map((a) => a.id),
        [attachment.id],
      );
    });

    test('addAttachment throws when the prescription does not exist',
        () async {
      final file = makeTempFile();
      expect(
        repository.addAttachment(999, 1, file, 'pdf', 'x', 'application/pdf'),
        throwsArgumentError,
      );
    });

    test('removeAttachment deletes the record and its managed file', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
      );
      final attachment = await repository.addAttachment(
        created.id!,
        profileId,
        makeTempFile(),
        'pdf',
        'rx',
        'application/pdf',
      );
      final storedPath =
          File(p.join(mockAppDir.path, attachment.managedRelativePath));
      expect(storedPath.existsSync(), isTrue);

      await repository.removeAttachment(attachment.id!);

      expect(storedPath.existsSync(), isFalse);
      expect(
        await database.doctorPrescriptionDao.getAttachments(created.id!),
        isEmpty,
      );
    });

    test('updateAttachment updates display metadata', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
      );
      final attachment = await repository.addAttachment(
        created.id!,
        profileId,
        makeTempFile(name: 'renamed_doc.pdf'),
        'pdf',
        'old name',
        'application/pdf',
      );

      await repository.updateAttachment(
        attachment.copyWith(displayName: 'new name'),
      );

      final saved =
          await database.doctorPrescriptionDao.getAttachment(attachment.id!);
      expect(saved!.displayName, 'new name');
      expect(saved.originalFileName, 'renamed_doc.pdf');
    });
  });

  group('medications', () {
    DoctorPrescriptionMedication makeMedication({
      int? id,
      required int prescriptionId,
      required int profileId,
      String medicationName = 'Clopidogrel 75 mg',
      String? doseAmount,
      String? doseUnit,
      String? frequency,
      String? timing,
      String? duration,
      String? instructions,
      String? notes,
      int sortOrder = 0,
    }) {
      return DoctorPrescriptionMedication(
        id: id,
        prescriptionId: prescriptionId,
        profileId: profileId,
        medicationName: medicationName,
        doseAmount: doseAmount,
        doseUnit: doseUnit,
        frequency: frequency,
        timing: timing,
        duration: duration,
        instructions: instructions,
        notes: notes,
        sortOrder: sortOrder,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
    }

    test('createPrescription persists medications in order', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId, title: 'Cardiology'),
        [],
        medications: [
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'Clopidogrel 75 mg',
            doseAmount: '75',
            doseUnit: 'mg',
          ),
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'Bisoprolol 5 mg',
            doseAmount: '5',
            doseUnit: 'mg',
          ),
        ],
      );

      final meds = await repository.getMedications(created.id!);
      expect(meds, hasLength(2));
      expect(meds.map((m) => m.medicationName),
          ['Clopidogrel 75 mg', 'Bisoprolol 5 mg']);
      expect(meds[0].prescriptionId, created.id);
      expect(meds[0].profileId, profileId);
      expect(meds.map((m) => m.sortOrder), [0, 1]);
    });

    test('createPrescription with no medications persists none', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
      );
      expect(await repository.getMedications(created.id!), isEmpty);
    });

    test('updatePrescription replaces, keeps and adds medications by diff',
        () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
        medications: [
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'Keep me',
          ),
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'Remove me',
          ),
        ],
      );

      final existing = await repository.getMedications(created.id!);
      final keep = existing.firstWhere((m) => m.medicationName == 'Keep me');
      final remove = existing.firstWhere((m) => m.medicationName == 'Remove me');

      await repository.updatePrescription(
        created.copyWith(title: 'Updated'),
        medications: [
          keep.copyWith(doseAmount: '10', doseUnit: 'mg'),
          makeMedication(
            prescriptionId: created.id!,
            profileId: profileId,
            medicationName: 'New one',
          ),
        ],
      );

      final meds = await repository.getMedications(created.id!);
      expect(meds.map((m) => m.medicationName), ['Keep me', 'New one']);
      expect(meds.first.doseAmount, '10');
      expect(meds.map((m) => m.sortOrder), [0, 1]);
      expect(meds.map((m) => m.id), isNot(contains(remove.id)));
    });

    test('getPrescriptionWithMedications bundles both', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId, title: 'Bundled'),
        [],
        medications: [
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'A drug',
          ),
        ],
      );

      final bundled = await repository.getPrescriptionWithMedications(
        created.id!,
        profileId,
      );
      expect(bundled, isNotNull);
      expect(bundled!.prescription.title, 'Bundled');
      expect(bundled.medications.map((m) => m.medicationName), ['A drug']);
    });

    test('archive preserves medications; restore brings them back', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
        medications: [
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'Preserved',
          ),
        ],
      );

      await repository.archivePrescription(created.id!, profileId);
      expect(
        (await repository.getPrescriptionWithMedications(
                created.id!, profileId))!
            .medications
            .map((m) => m.medicationName),
        ['Preserved'],
      );

      await repository.restorePrescription(created.id!, profileId);
      expect(
        (await repository.getPrescriptionWithMedications(
                created.id!, profileId))!
            .medications
            .map((m) => m.medicationName),
        ['Preserved'],
      );
    });

    test('delete removes the prescription and its medications', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
        medications: [
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'Gone',
          ),
        ],
      );

      await repository.deletePrescription(created.id!, profileId);
      expect(await repository.getMedications(created.id!), isEmpty);
    });

    test('medications are isolated per profile', () async {
      final profileA = await insertProfile(isPrimary: true);
      final profileB = await insertProfile(isPrimary: false);
      final created = await repository.createPrescription(
        makePrescription(profileId: profileA),
        [],
        medications: [
          makeMedication(
            prescriptionId: 0,
            profileId: profileA,
            medicationName: 'Profile A drug',
          ),
        ],
      );

      final meds = await (database.select(database.doctorPrescriptionMedications)
            ..where((t) => t.profileId.equals(profileB)))
          .get();
      expect(meds, isEmpty);

      final bundled = await repository.getPrescriptionWithMedications(
        created.id!,
        profileB,
      );
      expect(bundled, isNull);
    });

    test('searchPrescriptions matches by medication name', () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId, title: 'Rx'),
        [],
        medications: [
          makeMedication(
            prescriptionId: 0,
            profileId: profileId,
            medicationName: 'Clopidogrel 75 mg',
          ),
        ],
      );

      final match = await repository
          .searchPrescriptions(profileId, query: 'clopidogrel')
          .first;
      expect(match.map((p) => p.id), [created.id!]);
    });

    test('addMedication / updateMedication / removeMedication / reorder',
        () async {
      final profileId = await insertProfile();
      final created = await repository.createPrescription(
        makePrescription(profileId: profileId),
        [],
      );

      final first = await repository.addMedication(
        created.id!,
        makeMedication(
          prescriptionId: created.id!,
          profileId: profileId,
          medicationName: 'First',
        ),
      );
      final second = await repository.addMedication(
        created.id!,
        makeMedication(
          prescriptionId: created.id!,
          profileId: profileId,
          medicationName: 'Second',
        ),
      );
      expect(first.sortOrder, 0);
      expect(second.sortOrder, 1);

      final updated = await repository.updateMedication(
        second.copyWith(doseAmount: '20', doseUnit: 'mg'),
      );
      expect(updated.doseAmount, '20');
      expect(updated.medicationName, 'Second');

      await repository.reorderMedications(created.id!, [second.id!, first.id!]);
      final afterReorder = await repository.getMedications(created.id!);
      expect(afterReorder.map((m) => m.medicationName), ['Second', 'First']);
      expect(afterReorder.map((m) => m.sortOrder), [0, 1]);

      await repository.removeMedication(first.id!);
      expect(
        (await repository.getMedications(created.id!))
            .map((m) => m.medicationName),
        ['Second'],
      );
    });
  });
}