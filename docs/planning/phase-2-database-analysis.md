# Phase 2 — Database & Core Data Layer

**Status:** Complete
**Date:** 2026-07-21

## What Was Done

### Dependencies Added

| Package | Version | Purpose |
|---|---|---|
| `drift` | ^2.34.2 | Type-safe SQLite ORM |
| `sqlite3_flutter_libs` | ^0.6.0 | Native SQLite3 libraries |
| `path_provider` | ^2.1.6 | Application document directory |
| `path` | ^1.9.1 | File path utilities |
| `drift_dev` | ^2.34.0 | Drift code generation (dev) |
| `freezed` | >=3.0.0 <4.0.0 | Upgraded for drift_dev compatibility |
| `freezed_annotation` | >=3.0.0 <4.0.0 | Upgraded for drift_dev compatibility |

### Database Tables (17 total)

| Table | Module | Description |
|---|---|---|
| `Profiles` | Profile | Personal health profile (single-user initially) |
| `Medications` | Medication | Medication definitions |
| `MedicationSchedules` | Medication | When to take medications (JSON config) |
| `MedicationLogs` | Medication | Dose history (taken/missed/skipped) |
| `MeasurementTypes` | Measurement | Available measurement categories |
| `MeasurementRecords` | Measurement | Actual measurement values |
| `MeasurementSchedules` | Measurement | Measurement reminder config |
| `ExerciseTypes` | Exercise | Exercise activity types |
| `ExerciseGoals` | Exercise | Target activity levels |
| `ExerciseLogs` | Exercise | Completed activity records |
| `Doctors` | Doctor | Personal doctor contacts |
| `DoctorVisits` | Doctor | Appointment records |
| `DocumentAttachments` | Document | File attachments (lab results, etc.) |
| `DietPlans` | Diet | Diet plan headers |
| `DietItems` | Diet | Individual diet guidelines |
| `HealthTemplates` | Template | Bundled health configurations |
| `AppSettings` | Settings | Key-value configuration storage |

### Domain Entities (10 files)

All entities are pure Dart classes in `lib/domain/entities/`:
- `profile.dart` — Profile
- `medication.dart` — Medication, MedicationSchedule, MedicationLog
- `measurement.dart` — MeasurementType, MeasurementRecord, MeasurementSchedule
- `exercise.dart` — ExerciseType, ExerciseGoal, ExerciseLog
- `doctor.dart` — Doctor, DoctorVisit
- `document_attachment.dart` — DocumentAttachment
- `diet.dart` — DietPlan, DietItem
- `health_template.dart` — HealthTemplate
- `app_setting.dart` — AppSetting
- `schedule_config.dart` — ScheduleConfig sealed class

### Domain Enums (1 file)

`lib/domain/enums/enums.dart`:
- `Gender` — male, female, other
- `MedicationDoseStatus` — pending, taken, missed, skipped
- `VisitStatus` — scheduled, completed, cancelled
- `DocumentCategory` — labResult, prescription, dietPlan, other
- `DietCategory` — recommended, avoid, limit
- `MeasurementCategory` — vital, metabolic, body, custom

### ScheduleConfig Sealed Classes

Three schedule types as Dart 3 sealed classes:
- `DailySchedule` — every day at a specific time
- `FixedTimesSchedule` — multiple fixed times per day
- `IntervalDaysSchedule` — every N days at a specific time

All include manual `toJson()`/`fromJson()` for JSON serialization without code generation.

### Data Access Objects (9 DAOs)

One DAO per module in `lib/data/database/daos/`:
- `ProfileDao` — profile CRUD
- `MedicationDao` — medication, schedule, and log queries
- `MeasurementDao` — measurement type, record, and schedule queries
- `ExerciseDao` — exercise type, goal, and log queries
- `DoctorDao` — doctor and visit queries
- `DocumentDao` — document attachment queries
- `DietDao` — diet plan and item queries
- `HealthTemplateDao` — health template queries
- `AppSettingDao` — key-value settings

### Repository Interfaces (7 interfaces)

Updated with full method signatures:
- `ProfileRepository` — 5 methods
- `MedicationRepository` — 13 methods
- `MeasurementRepository` — 12 methods
- `ExerciseRepository` — 12 methods
- `DoctorRepository` — 10 methods
- `DocumentRepository` — 6 methods
- `SettingsRepository` — 5 methods

### Repository Implementations (7 classes)

All in `lib/data/repositories/`:
- `ProfileRepositoryImpl`
- `MedicationRepositoryImpl`
- `MeasurementRepositoryImpl`
- `ExerciseRepositoryImpl`
- `DoctorRepositoryImpl`
- `DocumentRepositoryImpl`
- `SettingsRepositoryImpl`

Each implementation maps between Drift data classes and domain entities.

### Migration Strategy

- Schema version: 1
- `onCreate`: Creates all tables, then seeds initial data
- Future migrations will use `schemaVersion` increments and `beforeOpen`/`MigrationStrategy`

### Seed Data

**Built-in Measurement Types** (5):
- Blood Pressure (mmHg, vital)
- Heart Rate (bpm, vital)
- Weight (kg, body)
- Blood Glucose (mg/dL, metabolic)
- Temperature (°C, vital)

**Health Templates** (3):
- Cardiac Recovery — BP, HR, weight, walking exercise
- Diabetes Management — glucose, weight, diet
- General Wellness — weight, exercise

### Riverpod Providers

`lib/presentation/providers/database_provider.dart`:
- `databaseProvider` — singleton AppDatabase instance
- `profileRepositoryProvider`
- `medicationRepositoryProvider`
- `measurementRepositoryProvider`
- `exerciseRepositoryProvider`
- `doctorRepositoryProvider`
- `documentRepositoryProvider`
- `settingsRepositoryProvider`

## Column Naming Notes

Some Drift table column names were renamed to avoid conflicts with `Table` base class methods:
- `DietItems.text` → `DietItems.itemText` (conflicts with `Table.text`)
- `DoctorVisits.dateTime` → `DoctorVisits.visitDate` (conflicts with `Table.dateTime`)
- `ExerciseLogs.dateTime` → `ExerciseLogs.logDate` (conflicts with `Table.dateTime`)

## File Structure

```
lib/
├── data/
│   ├── database/
│   │   ├── app_database.dart          # Drift database class + DAO getters
│   │   ├── app_database.g.dart        # Generated
│   │   ├── seed_data.dart             # Initial measurement types + templates
│   │   ├── tables/                    # 9 table definition files
│   │   ├── daos/                      # 9 DAO files + generated mixins
│   │   └── migrations/                # Ready for future migrations
│   ├── models/                        # (empty, entities are in domain)
│   └── repositories/                  # 7 repository implementations
├── domain/
│   ├── entities/                      # 10 entity files
│   ├── enums/
│   │   └── enums.dart                 # All domain enums
│   └── repositories/                  # 7 repository interfaces
└── presentation/
    └── providers/
        └── database_provider.dart     # Riverpod providers
```

## Verification

- `flutter analyze` — passes (0 issues)
- `flutter build apk --debug` — succeeds
- `dart run build_runner build` — generates all Drift + freezed code

## Not Yet Implemented

- UI screens (Phase 3+)
- Notification infrastructure (Phase 3)
- Profile creation flow
- Medication management UI
- Measurement entry and charts
- Exercise tracking UI
- Doctor directory UI
- Document management UI
- Diet plan UI
- Reports and export
- Backup and restore
- Security features

## Next Phase

Phase 3 — Notification Infrastructure and Core Screens.
