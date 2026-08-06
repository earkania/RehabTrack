# Database Schema History

This document tracks every SQLite schema version of RehabTrack's app database
(`rehabtrack.sqlite`, maintained by Drift in `lib/data/database/app_database.dart`).

The current `schemaVersion` is **14**. Migrations run in `AppDatabase.migration.onUpgrade`
using cumulative `if (from < N)` blocks, so upgrading from any older version applies
exactly the steps needed. The initial `onCreate` creates all tables and seeds defaults.

## Version map

| Version | Commit | Phase | Changes |
|---|---|---|---|
| **1** | `aa2afec` | Phase 2 | Initial schema and data layer: profiles, medications, measurement types/records, exercises, doctors, documents, diet, health templates, app settings. |
| **2** | `e7dbdca` | Phase 4A | `medications.doseAmount`, `medications.doseUnit`; new `medication_alternatives` table. |
| **3** | `60a6f1b` | Phase 4B | New `medication_components` and `medication_alternative_components` tables; backfills components from `doseAmount`/`doseUnit`. |
| **4** | `66678b7` | Phase 5A | `measurement_types` gains `key`, `default_unit`, `display_order`; `measurement_records.updatedAt`; new `measurement_type_fields` and `measurement_record_values` tables; seeds the six system measurement types. |
| **5** | `66678b7` | Phase 5A | `cleanupDuplicateMeasurementTypes` — deduplicates measurement types left over from earlier seeding. |
| **6** | `233be88` | Phase 4E | Schedule redesign: drops `medication_schedules` and `medication_logs` and recreates them with `intakeQuantity`, `dosageForm`, `customDosageForm`. Destructive (test data only). |
| **7** | `0ce637a` | Phase 5A.1 | `measurement_records.irregularHeartbeatDetected`. |
| **8** | `fac2746` | Phase 5A.1 | New `profile_reference_ranges` table (profile-specific reference ranges). |
| **9** | `022269a` | Phase 5C | `measurement_schedules` gains `instructions`, `createdAt`, `updatedAt` (with backfill); new `measurement_reminder_logs` table. |
| **10** | `3d2e91b` | Phase 5C | One time per schedule: drops and recreates `measurement_schedules` and `measurement_reminder_logs`. Destructive. |
| **11** | `33556eb` | Phase 6D | `measurement_reminder_logs.measurementRecordId` links reminder logs to measurement records. |
| **12** | `56fccc5` | Phase 7A | `profiles` gains `phone`, `email`, `address`, `relationshipToOwner`, `isPrimary`, `isActive`, `photoPath`. |
| **13** | `f4d5e26` | Phase 8A | New `care_contacts` table (shared table for medical professionals and organizations). |
| **14** | `f230fa3` | Phase 8C | New `doctor_visit_records` table (records backed by optional care-contact references). |

> Note: versions 4–5 landed together in `66678b7`; version 3's `60a6f1b` also
> appears in the `-S "schemaVersion => 3"` history alongside `66678b7`. The
> mapping above is the earliest commit that introduced each `schemaVersion`.

## Restore compatibility

Backup/restore uses the same cumulative migration strategy (`onUpgrade`) to bring
an older backup's database up to the current schema **before** it replaces the
live database. The single source of truth for the versioning policy is
`lib/domain/backup/backup_version_policy.dart`:

- Current schema: **14** (`AppDatabase.currentSchemaVersion`).
- Oldest restore-compatible schema: **1** (`minSupportedDatabaseSchemaVersion`).
  Because Migrations 2→14 are cumulative `if (from < N)` steps, every backup at
  `>= 1` has a supported migration path.
- Backup-format version: **1** (`BackupManifest.currentFormatVersion`).

Restore rules:

- A backup **newer than the current schema** (schema `> 14`) is rejected as
  `newerDatabaseVersion` and cannot be restored.
- A backup **older than 1** is rejected as `unsupportedOldDatabaseVersion`.
- A backup at schema `1..13` is restored via `RestoreSqliteMigrator`, which opens
  a temporary copy with `AppDatabase.forTesting(...)` and lets Drift run the same
  `onUpgrade` blocks to reach 14, then validates schema version, core tables,
  sample queries and `foreign_key_check`. The live database is never migrated in
  place; migration runs strictly on the prepared temporary copy in the restore
  workspace.
- A backup at schema **14** is restored directly (no migration).

> The full 1→→14 path is exercised by Drift's own migration strategy; automated
> coverage currently validates a faithful v13 fixture migrating to 14 (the
> last step, which adds `doctor_visit_records`). Historical pre-v12 fixtures are
> marked a known limitation of the automated tests, not of the migration itself —
> the production path reuses the exact same cumulative `onUpgrade` logic the app
> has run on every upgrade since these versions existed.

## Related

- Migration logic: `lib/data/database/app_database.dart` → `MigrationStrategy.onUpgrade`.
- Restore migration service: `lib/data/services/restore/restore_sqlite_migrator.dart`.
- Version policy: `lib/domain/backup/backup_version_policy.dart`.
- Migration coverage: `test/care_contact_migration_test.dart` asserts the schema
  version is 14 and that care-contact/doctor-visit tables and indexes exist;
  `test/restore_sqlite_migrator_test.dart` asserts v13→v14 restore migration.
- `docs/design/design-notes.md` documents the v13→v14 additive migration and the
  Phase 4 restore decisions.
- Backup archives record `databaseSchemaVersion` in `manifest.json`; the preview
  validator checks it and the restore engine migrates supported older values.
