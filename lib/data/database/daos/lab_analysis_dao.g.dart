// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lab_analysis_dao.dart';

// ignore_for_file: type=lint
mixin _$LabAnalysisDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CareContactsTable get careContacts => attachedDatabase.careContacts;
  $DoctorVisitRecordsTable get doctorVisitRecords =>
      attachedDatabase.doctorVisitRecords;
  $LabAnalysesTable get labAnalyses => attachedDatabase.labAnalyses;
  $LabAnalysisAttachmentsTable get labAnalysisAttachments =>
      attachedDatabase.labAnalysisAttachments;
  LabAnalysisDaoManager get managers => LabAnalysisDaoManager(this);
}

class LabAnalysisDaoManager {
  final _$LabAnalysisDaoMixin _db;
  LabAnalysisDaoManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CareContactsTableTableManager get careContacts =>
      $$CareContactsTableTableManager(_db.attachedDatabase, _db.careContacts);
  $$DoctorVisitRecordsTableTableManager get doctorVisitRecords =>
      $$DoctorVisitRecordsTableTableManager(
        _db.attachedDatabase,
        _db.doctorVisitRecords,
      );
  $$LabAnalysesTableTableManager get labAnalyses =>
      $$LabAnalysesTableTableManager(_db.attachedDatabase, _db.labAnalyses);
  $$LabAnalysisAttachmentsTableTableManager get labAnalysisAttachments =>
      $$LabAnalysisAttachmentsTableTableManager(
        _db.attachedDatabase,
        _db.labAnalysisAttachments,
      );
}
