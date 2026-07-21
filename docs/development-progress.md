# RehabTrack Development Progress

## Project Overview

RehabTrack is a personal health companion Flutter application designed for tracking medications, health measurements, exercise, and doctor visits. The app targets offline-first usage on Android (Pixel 7) with planned future support for multiple user profiles.

**Architecture:** Clean Architecture — `core/`, `data/`, `domain/`, `presentation/` layer separation.

**Technology Stack:**

| Layer | Technology |
|---|---|
| Framework | Flutter (SDK ^3.12.2) |
| Language | Dart |
| State Management | Riverpod |
| Navigation | GoRouter |
| Database | Drift (SQLite ORM) |
| Serialization | Freezed, JSON Serializable |
| Theming | Material 3 |
| Localization | Flutter l10n (ARB files) |

## Completed Phases

### Phase 1 — Project Foundation

**Status:** Completed

**What was done:**

- Flutter project initialized with `com.earkania.rehabtrack` applicationId
- `pubspec.yaml` configured with foundation dependencies
- Material 3 theme system with teal seed color (`#2E7D6F`), light and dark modes, system theme following
- GoRouter navigation with `ShellRoute` providing bottom `NavigationBar`
- 5-tab navigation structure: Today, Health, Activities, Records, Settings
- Localization setup: English and Georgian (`ka`) with 29 translation keys
- Android build configured: `compileSdk`/`minSdk`/`targetSdk` delegated to Flutter, Java 17 compatibility
- Release signing prepared (placeholder debug keys)
- `ProviderScope` wrapping entire app for Riverpod

### Phase 2 — Database and Data Layer

**Status:** Completed

**What was done:**

**Drift Database Setup:**
- Schema version: `1`
- Database file: `rehabtrack.sqlite` in application documents directory
- Migration strategy: `onCreate` creates all tables then seeds initial data
- 17 tables registered in `@DriftDatabase` annotation

**Tables (17):**

| Table | Module |
|---|---|
| Profiles | Profile |
| Medications | Medication |
| MedicationSchedules | Medication |
| MedicationLogs | Medication |
| MeasurementTypes | Measurement |
| MeasurementRecords | Measurement |
| MeasurementSchedules | Measurement |
| ExerciseTypes | Exercise |
| ExerciseGoals | Exercise |
| ExerciseLogs | Exercise |
| Doctors | Doctor |
| DoctorVisits | Doctor |
| DocumentAttachments | Document |
| DietPlans | Diet |
| DietItems | Diet |
| HealthTemplates | Template |
| AppSettings | Settings |

**Domain Entities (10 files):**

- `profile.dart` — Profile
- `medication.dart` — Medication, MedicationSchedule, MedicationLog
- `measurement.dart` — MeasurementType, MeasurementRecord, MeasurementSchedule
- `exercise.dart` — ExerciseType, ExerciseGoal, ExerciseLog
- `doctor.dart` — Doctor, DoctorVisit
- `document_attachment.dart` — DocumentAttachment
- `diet.dart` — DietPlan, DietItem
- `health_template.dart` — HealthTemplate
- `app_setting.dart` — AppSetting
- `schedule_config.dart` — ScheduleConfig sealed class (DailySchedule, FixedTimesSchedule, IntervalDaysSchedule)

**Domain Enums (6):**

- `Gender` — male, female, other
- `MedicationDoseStatus` — pending, taken, missed, skipped
- `VisitStatus` — scheduled, completed, cancelled
- `DocumentCategory` — labResult, prescription, dietPlan, other
- `DietCategory` — recommended, avoid, limit
- `MeasurementCategory` — vital, metabolic, body, custom

**Data Access Objects (9):**

- `ProfileDao`, `MedicationDao`, `MeasurementDao`, `ExerciseDao`, `DoctorDao`, `DocumentDao`, `DietDao`, `HealthTemplateDao`, `AppSettingDao`

**Repository Structure:**

| Layer | Count | Files |
|---|---|---|
| Interfaces (domain) | 7 | profile, medication, measurement, exercise, doctor, document, settings |
| Implementations (data) | 7 | profile, medication, measurement, exercise, doctor, document, settings |

Note: Diet module has a DAO but no dedicated repository yet.

**Providers (9 total):**

- `databaseProvider` — singleton AppDatabase
- `profileRepositoryProvider`
- `medicationRepositoryProvider`
- `measurementRepositoryProvider`
- `exerciseRepositoryProvider`
- `doctorRepositoryProvider`
- `documentRepositoryProvider`
- `settingsRepositoryProvider`
- `localeProvider` — locale management (separate file)

**Seed Data:**
- 5 built-in measurement types: Blood Pressure, Heart Rate, Weight, Blood Glucose, Temperature
- 3 health templates: Cardiac Recovery, Diabetes Management, General Wellness

## Current Application State

**App launches successfully on Pixel 7.**

**Bottom navigation — 5 tabs:**

| Tab | Route | Screen | State |
|---|---|---|---|
| Today | `/` | TodayScreen | Placeholder — icon + "No data yet" |
| Health | `/health` | HealthScreen | Placeholder — icon + "No data yet" |
| Activities | `/activities` | ActivitiesScreen | Placeholder — icon + "No data yet" |
| Records | `/records` | RecordsScreen | Placeholder — icon + "No data yet" |
| Settings | `/settings` | SettingsScreen | Functional — language switching works |

**Settings screen working features:**
- Language switching (System / English / Georgian)
- Theme toggle placeholder (no-op)
- Notifications toggle placeholder (hardcoded on)
- Security toggle placeholder (hardcoded off)

**Database:** Initializes on first provider access. Schema v1 created with all 17 tables and seed data. Ready for UI integration.

## Current Technical Decisions

| Decision | Rationale |
|---|---|
| Offline-first local database | No backend dependency; data stays on device |
| No backend server | User privacy; no cloud sync in initial scope |
| Clean Architecture | Clear separation of concerns; testable layers |
| Riverpod state management | Modern, compile-safe, testable providers |
| Drift for SQLite | Type-safe, reactive database with code generation |
| GoRouter navigation | Declarative routing with ShellRoute for tab navigation |
| Localization from day one | English + Georgian from initial commit |
| Freezed for entities | Immutable data classes with copyWith, equality |
| Multi-profile architecture | Schema supports multiple profiles; UI starts with single user |

## Important Future Requirements

### Medication Management

- Flexible medication schedules (daily, fixed times, interval days)
- Meal timing instructions: before meal, after meal, with meal, any time
- Medication adherence tracking with dose status history
- Conditional dose logic:
  - Skip dose if measurement is outside threshold (e.g., skip Concor if pulse < 55 bpm)
  - Warning/confirmation rules based on latest measurements
- Optional medication replacement/alternative suggestions:
  - User-defined alternatives for a medication
  - Not mandatory for every medication

### Health Tracking

- Blood pressure (systolic/diastolic)
- Pulse / heart rate
- Weight
- Blood glucose
- Body temperature
- Custom measurements (user-defined types)
- Measurement history and trends

### Exercise

- Walking goals (daily step/distance targets)
- Daily activity logging
- Exercise programs (future)

### Profiles

- Version 1: single active user
- Architecture supports future multi-profile:
  - Self
  - Elderly parents
  - Family members
- Profile switching without data migration

### Templates

- Health profiles/templates for common conditions:
  - Cardiac rehabilitation
  - Hypertension management
  - Diabetes management
  - General wellness
- Templates pre-populate measurement types, exercise goals, and schedules

## Next Planned Phase

### Phase 3 — Notification Infrastructure

**Planned work:**

- `NotificationScheduler` service for scheduling and managing notifications
- Android notification channel configuration
- Notification actions (mark as taken, snooze, skip)
- Background callbacks for scheduling medications and measurements
- Boot rescheduling — restore all scheduled notifications on device restart
- Exact alarm handling for precise timing
- Battery optimization handling and Doze mode considerations
- Real device testing on Pixel 7

## Development Rules

- Commit after every completed phase
- Keep documentation updated before moving to next phase
- Test on real Pixel device before moving to next phase
- Avoid implementing features before data model supports future requirements
- Run `flutter analyze` before committing — zero issues required
