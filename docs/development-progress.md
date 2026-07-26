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
| Notifications | flutter_local_notifications |
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

### Phase 3 — Notification Infrastructure

**Status:** Completed

**What was done:**

**Dependencies Added:**
- `flutter_local_notifications: ^18.0.1` — Cross-platform local notifications
- `timezone: ^0.10.1` — Timezone-aware scheduling

**Services Created:**

| Service | Location | Purpose |
|---|---|---|
| `NotificationService` | `data/services/notification/` | Low-level notification capabilities |
| `NotificationScheduler` | `data/services/notification/` | Converts domain schedules to notifications |
| `ScheduleRecoveryService` | `data/services/notification/` | Restores notifications on app start |
| `BatteryOptimizationHelper` | `data/services/notification/` | Battery optimization detection |

**Notification Channels (5):**

| Channel ID | Name | Purpose |
|---|---|---|
| `rehabtrack_medications` | Medication Reminders | Medication dose reminders |
| `rehabtrack_measurements` | Measurement Reminders | Health measurement reminders |
| `rehabtrack_appointments` | Appointment Reminders | Doctor visit reminders |
| `rehabtrack_exercise` | Exercise Reminders | Exercise activity reminders |
| `rehabtrack_general` | General Notifications | General app notifications |

**Notification Actions:**
- `Taken` — Mark dose as taken
- `Snooze` — Postpone reminder
- `Skip` — Skip dose

**Domain Schedule Model:**
- `ScheduleConfig` sealed class already existed from Phase 2
- Supports: `DailySchedule`, `FixedTimesSchedule`, `IntervalDaysSchedule`

**Providers Added:**

| Provider | Purpose |
|---|---|
| `notificationServiceProvider` | Singleton NotificationService |
| `notificationSchedulerProvider` | NotificationScheduler instance |
| `scheduleRecoveryServiceProvider` | ScheduleRecoveryService instance |
| `batteryOptimizationHelperProvider` | BatteryOptimizationHelper instance |

**Android Configuration:**
- `RECEIVE_BOOT_COMPLETED` — Boot rescheduling
- `VIBRATE` — Notification vibration
- `SCHEDULE_EXACT_ALARM` — Precise timing
- `POST_NOTIFICATIONS` — Android 13+ permission
- `USE_EXACT_ALARM` — Exact alarm support

**Android Integration:**
- Added `flutter_local_notifications: ^18.0.1` to pubspec.yaml
- Enabled core library desugaring in `android/app/build.gradle.kts`
- Added `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`
- Enabled `multiDexEnabled = true` in defaultConfig

**Validation Results:**
| Check | Result |
|---|---|
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (1/1) |
| `flutter build apk --debug` | Built successfully |
| Pixel 7 debug build/run | Passed |

**Known Limitations:**
- Battery optimization detection is placeholder (requires platform-specific code)
- Boot rescheduling requires app to start (no native receiver)
- Notification actions are infrastructure only — not connected to medication logs yet

## Current Application State

**App launches successfully on Pixel 7.**

**Bottom navigation — 5 tabs:**

| Tab | Route | Screen | State |
|---|---|---|---|
| Today | `/` | TodayScreen | Placeholder — icon + "No data yet" |
| Health | `/measurements` | HealthScreen | Placeholder — icon + "No data yet" |
| Activities | `/medications` | MedicationListScreen | Medication list — shows empty state or medication cards |
| Records | `/records` | RecordsScreen | Placeholder — icon + "No data yet" |
| Settings | `/settings` | SettingsScreen | Functional — language switching works |

**Settings screen working features:**
- Language switching (System / English / Georgian)
- Theme toggle placeholder (no-op)
- Notifications toggle placeholder (hardcoded on)
- Security toggle placeholder (hardcoded off)

**Database:** Initializes on first provider access. Schema v1 created with all 17 tables and seed data. Ready for UI integration.

**Notification Infrastructure:** Fully initialized. All services ready for UI integration.

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

### Phase 4A — Medication Data Layer (Gaps)

**Status:** Completed

**What was done:**

**Database Schema Changes:**
- Schema version bumped from `1` to `2`
- Added `doseAmount` (TextColumn nullable) to `Medications` table
- Added `doseUnit` (TextColumn nullable) to `Medications` table
- Created new `MedicationAlternatives` table with foreign key to Medications
- Migration strategy handles v1→v2 upgrade (adds columns, creates table)

**MedicationAlternatives Table:**

| Column | Type | Notes |
|---|---|---|
| id | INTEGER | Primary key, auto-increment |
| medicationId | INTEGER | Foreign key → Medications |
| name | TEXT | Alternative medication name |
| doseAmount | TEXT | Nullable |
| doseUnit | TEXT | Nullable |
| doctorApproved | BOOLEAN | Default false |
| notes | TEXT | Nullable |
| createdAt | DATETIME | Record creation time |

**Domain Entities Updated:**
- `Medication` — added `doseAmount` and `doseUnit` fields with copyWith support
- New `MedicationAlternative` class created in separate file

**DAOs Created/Updated:**
- New `MedicationAlternativesDao` with CRUD operations for alternatives
- `MedicationDao` unchanged (already had all needed methods)

**Repository Layer Updated:**
- `MedicationRepository` interface — added alternative CRUD method signatures
- `MedicationRepositoryImpl` — implemented alternative methods with domain mapping
- Updated `_toDomain` and companion creation for dose fields

**Files Changed:**
- `lib/data/database/tables/medication_tables.dart` — new columns + table
- `lib/data/database/app_database.dart` — schema v2, migration, new DAO getter
- `lib/domain/entities/medication.dart` — dose fields added
- `lib/domain/entities/medication_alternative.dart` — new file
- `lib/data/database/daos/medication_alternatives_dao.dart` — new file
- `lib/domain/repositories/medication_repository.dart` — alternative methods
- `lib/data/repositories/medication_repository_impl.dart` — alternative implementation

**Validation Results:**
| Check | Result |
|---|---|
| `build_runner` | Completed successfully |
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (1/1) |

### Phase 4B — Step 1: Foundation

**Status:** Completed

**What was done:**

**AdherenceStats Domain Entity:**
- Created `lib/domain/entities/adherence_stats.dart`
- Separate entity from Medication, following Clean Architecture domain purity (no Flutter, Drift, or Riverpod imports)
- Fields: `taken`, `missed`, `skipped`, `pending`, `total`, `percentage`
- Factory `AdherenceStats.fromLogs(List<MedicationLog> logs)` calculates statistics from medication logs
- Percentage formula: `taken / (taken + missed + skipped) * 100`
- Pending items excluded from denominator
- Division by zero handled safely (returns 0.0)
- Static `empty` const for zero-state

**Active Profile Provider:**
- Created `lib/presentation/providers/profile_provider.dart`
- `activeProfileIdProvider` — `Provider<int?>` returning hardcoded profile ID 1
- Temporary implementation with comment indicating future multi-profile replacement


**EmptyState Widget:**
- Created `lib/presentation/widgets/empty_state.dart`
- Reusable Material 3 widget with properties: `icon`, `title`, `subtitle`, optional `actionLabel`, optional `onAction`
- No medication-specific logic, no hardcoded text
- Used across all 4 placeholder screens (Today, Health, Activities, Records)

**Placeholder Screen Refactoring:**
- Replaced duplicated inline placeholder code in 4 screens with `EmptyState` widget:
  - `lib/presentation/screens/today/today_screen.dart`
  - `lib/presentation/screens/health/health_screen.dart`
  - `lib/presentation/screens/activities/activities_screen.dart`
  - `lib/presentation/screens/records/records_screen.dart`
- Activities screen remains a placeholder — not yet replaced with medication list

**Localization Additions:**
- Added 40+ medication-related keys to `lib/l10n/app_en.arb` and `lib/l10n/app_ka.arb`
- Includes: medication CRUD labels, schedule types, adherence statuses, instructions, placeholders
- Parameterized keys: `dailyAt`, `fixedTimes`, `everyNDays` with placeholders
- Follows existing ARB conventions

**Files Created:**
- `lib/domain/entities/adherence_stats.dart`
- `lib/presentation/providers/profile_provider.dart`
- `lib/presentation/widgets/empty_state.dart`

**Files Modified:**
- `lib/presentation/screens/today/today_screen.dart`
- `lib/presentation/screens/health/health_screen.dart`
- `lib/presentation/screens/activities/activities_screen.dart`
- `lib/presentation/screens/records/records_screen.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ka.arb`

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (1/1) |

**Architecture Verification:**
- Presentation layer does not access DAOs directly
- Presentation layer does not use NotificationService directly (pre-existing `notification_provider.dart` pattern unchanged)
- No medication CRUD functionality implemented
- No notification scheduling implemented
- Existing architecture conventions preserved

**Note:** Pre-existing pattern where `notification_provider.dart` imports data-layer notification services directly (not introduced in this step) remains unchanged. All new code follows Clean Architecture boundaries.

### Phase 4B — Step 2: Medication CRUD

**Status:** Completed

**What was done:**

**Routing Updated (`app_router.dart`):**
- Added routes for `/medications/medication/add`, `/medications/medication/:id`, `/medications/medication/:id/edit`
- Routes are outside ShellRoute (no bottom nav during detail/form screens)
- `int.tryParse` safety on all `:id` parameters with `_InvalidRouteScreen` for invalid IDs
- `ScaffoldWithNavBar` updated: Activities tab now highlights for all `/medications/medication/*` routes

**Providers Created (`medication_provider.dart`):**
- `medicationListProvider(profileId)` — `StreamProvider.autoDispose.family<List<Medication>, int>` wrapping `watchActiveMedications`
- `medicationProvider(id)` — `FutureProvider.autoDispose.family<Medication?, int>` for single medication lookup

**Medication List Screen (`medication_list_screen.dart`):**
- Replaced old `ActivitiesScreen` placeholder entirely (old file deleted)
- Loads medications via `medicationListProvider` with `activeProfileIdProvider`
- Shows empty state when no medications, loading spinner, error state
- FAB navigates to add screen

**Add Medication Screen (`add_medication_screen.dart`):**
- Uses shared `MedicationForm` widget
- Reads `activeProfileIdProvider` for profile ID
- Calls `medicationRepository.createMedication()`, pops on success

**Edit Medication Screen (`edit_medication_screen.dart`):**
- Loads existing medication from `medicationProvider`
- Preserves original `id`, `profileId`, `createdAt`
- Updates `updatedAt` on save, calls `medicationRepository.updateMedication()`

**Medication Detail Screen (`medication_detail_screen.dart`):**
- Displays all medication fields (name, dose, status, notes, dates)
- Edit button navigates to edit screen
- Deactivate action with confirmation dialog (sets `active = false`, updates `updatedAt`)

**Shared MedicationForm Widget (`medication_form.dart`):**
- Reusable form for add and edit screens
- Fields: name (required), dose amount (numeric), dose unit (dropdown), description, notes, active switch
- Validation: name required, dose amount must be positive
- `MedicationFormData` data class for passing initial/saved data

**MedicationCard Widget (`medication_card.dart`):**
- Shows medication name, dose display (e.g., "5 mg"), active status
- Reusable across list views, search results, dashboards

**Localization Additions:**
- Added `deactivate`, `confirmDeactivate`, `invalidRoute` keys to both ARB files

**Files Created:**
- `lib/presentation/providers/medication_provider.dart`
- `lib/presentation/screens/activities/medication_list_screen.dart`
- `lib/presentation/screens/activities/add_medication_screen.dart`
- `lib/presentation/screens/activities/edit_medication_screen.dart`
- `lib/presentation/screens/activities/medication_detail_screen.dart`
- `lib/presentation/widgets/medication/medication_form.dart`
- `lib/presentation/widgets/medication/medication_card.dart`

**Files Modified:**
- `lib/core/router/app_router.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ka.arb`

**Files Deleted:**
- `lib/presentation/screens/activities/activities_screen.dart`

**Tests:**
- 10 widget tests covering MedicationCard, MedicationForm, app rendering, and integration
- Tests use `pump()` instead of `pumpAndSettle()` to handle Drift stream timing

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (10/10) |

**Architecture Verification:**
- Presentation layer accesses medication data only through providers and repositories
- No direct DAO access from UI
- No notification service access from UI
- All CRUD operations go through `MedicationRepository`

### Phase 4 — Medication Module: Complete

**Status:** Completed

**Sub-phases:**

| Sub-phase | Description | Status |
|---|---|---|
| 4A | Medication data layer (schema v2, alternatives table, entities) | Completed |
| 4B Step 1 | Foundation (adherence stats, active profile, empty state, l10n) | Completed |
| 4B Step 2 | Medication CRUD (routing, providers, screens, form, card) | Completed |
| 4B Step 3 | Medication schedules (CRUD, notification scheduling) | Completed |
| 4B Step 4 | Medication alternatives (CRUD, cards, forms) | Completed |
| 4B Step 5 | Medication history & adherence (stats, logs, status chips) | Completed |
| 4B Step 6 | Notification action integration (bridge, action handlers, recovery) | Completed |
| 4B Step 7 | Code cleanup & form validation | Completed |
| 4C | Multi-component medication dosage (schema v3, component entities, DAOs, formatter, component editor) | Completed |
| 4C Layout | Dosage component layout improvement (name-on-top layout, responsive) | Completed |

**Module Capabilities:**
- Full medication CRUD with multi-component dosage (e.g., Tripliksam 10/2.5/10 mg)
- Medication alternatives with doctor-approved status
- Medication schedules (daily, fixed times, interval days)
- Medication history & adherence tracking with period-based stats
- Local notification scheduling with Taken/Skipped/Snooze actions
- Schedule recovery on app startup
- Shared form widgets for both medication and alternative editors
- Responsive component editor that works on narrow Android screens

**Test Coverage:**
- 114 tests passing across 9 test files
- Component formatter, component form, medication form, alternative form, schedule, history, status chip, notification bridge, app rendering

**Validation Results:**
| Check | Result |
|---|---|
| `flutter analyze` | Passed (3 info lints — pre-existing) |
| `flutter test` | Passed (114/114) |
| Pixel 7 build/run | App launched successfully |

**Files Created (Phase 4 total):**
- `lib/domain/entities/medication_component.dart`
- `lib/domain/entities/medication_alternative_component.dart`
- `lib/domain/entities/medication_alternative.dart`
- `lib/domain/entities/history_period.dart`
- `lib/domain/entities/adherence_stats.dart`
- `lib/data/database/daos/medication_components_dao.dart`
- `lib/data/database/daos/medication_alternative_components_dao.dart`
- `lib/data/database/daos/medication_alternatives_dao.dart`
- `lib/data/services/notification/notification_action_bridge.dart`
- `lib/presentation/utils/component_formatter.dart`
- `lib/presentation/utils/dose_formatter.dart`
- `lib/presentation/widgets/medication/medication_components_form.dart`
- `lib/presentation/widgets/medication/medication_alternative_card.dart`
- `lib/presentation/widgets/medication/medication_alternative_form.dart`
- `lib/presentation/widgets/medication/status_chip.dart`
- `lib/presentation/widgets/common/date_field.dart`
- `lib/presentation/screens/activities/medication_list_screen.dart`
- `lib/presentation/screens/activities/add_medication_screen.dart`
- `lib/presentation/screens/activities/edit_medication_screen.dart`
- `lib/presentation/screens/activities/medication_detail_screen.dart`
- `lib/presentation/screens/activities/add_alternative_screen.dart`
- `lib/presentation/screens/activities/edit_alternative_screen.dart`
- `lib/presentation/screens/activities/medication_history_screen.dart`
- `lib/presentation/providers/profile_provider.dart`
- `lib/presentation/theme/app_spacing.dart`
- `test/component_formatter_test.dart`
- `test/medication_components_form_test.dart`
- `test/alternative_test.dart`
- `test/notification_action_bridge_test.dart`
- `test/medication_history_test.dart`
- `test/schedule_test.dart`

**Files Deleted:**
- `lib/presentation/screens/activities/activities_screen.dart` (replaced by medication list)

## Phase 5A — Health Measurements Foundation

**Status:** Completed (correction pass applied)

**What was done:**

- **Schema v4:** Added `MeasurementTypeFields` and `MeasurementRecordValues` tables; added `key`, `defaultUnit`, `displayOrder` to `MeasurementTypes`; added `updatedAt` to `MeasurementRecords`
- **Schema v5 — Duplicate cleanup migration:** Deactivates old keyless duplicate system types, migrates their records to canonical keyed types, consolidates Heart Rate → Pulse, ensures all canonical types have field definitions
- **6 system measurement types seeded:** `blood_pressure`, `pulse`, `weight`, `blood_glucose`, `spo2`, `temperature` — each with complete field definitions (units, min/max, decimalPlaces)
- **Idempotent seeding:** `seed_data.dart` now checks by key before inserting types and checks for existing fields before inserting fields
- **Domain entities:** Updated `MeasurementType` (+key, defaultUnit, displayOrder), new `MeasurementTypeField`, `MeasurementRecordValue`; updated `MeasurementRecord` (+updatedAt)
- **DAO methods:** `watchActiveMeasurementTypes`, `getMeasurementTypeByKey`, field/value CRUD, `replaceFields`, `replaceRecordValues`
- **Repository:** Transactional `createRecord`/`updateRecord` with normalized value storage; `deactivateMeasurementType` for soft-delete
- **Providers:** `activeMeasurementTypesProvider`, `measurementTypeByKeyProvider`, `measurementTypeFieldsProvider`, `measurementRecordsProvider`, `measurementRecordProvider`, `measurementRecordValuesProvider`
- **MeasurementFormatter:** Centralized formatting for all 6 types; `pulseLabel` parameter for localized BP/SpO2 summaries
- **MeasurementValidator:** Required field validation, numeric bounds, BP relationship checks
- **MeasurementLocalizer:** New helper mapping type/field keys to localized display names
- **Measurements screen:** Shows measurement type cards with `Symbols.weight` icon, `IconButton(Icons.history)` for view history, and `IconButton(Icons.add_circle_outline)` for add reading
- **Measurement entry/edit/history screens:** Generic form-driven UI for all measurement types, using `MeasurementLocalizer` for type names and field labels; Measurement History AppBar uses same `IconButton(Icons.add_circle_outline)` for add reading
- **Medication Detail screen:** Schedules/Alternatives sections use `IconButton(Icons.add_circle_outline)` for add actions; History section uses `IconButton(Icons.history)` for view history; AppBar uses `IconButton(Icons.history)` for medication history
- **Medication Components form:** Uses `IconButton(Icons.add_circle_outline)` for add component action
- **Navigation:** Bottom nav uses custom `_CenteredNavigationBar` (replaces Flutter's `NavigationBar`) with only-selected labels, centered wrapped text (`TextAlign.center`, `maxLines: 2`), `monitor_heart_outlined` / `medication_outlined` icons
- **Routes:** `/measurements/measurement/:typeId/add`, `/measurements/measurement/:typeId/history`, `/measurements/measurement/record/:recordId/edit`
- **Localization corrections:** Georgian Blood Pressure → `არტერიული წნევა` (was `სისხლის წნევა`), Georgian Blood Glucose → `გლუკოზა სისხლში` (was `სისხლში შაქარი`), `measuredAt` → `გაზომილია` (was `გაზომულია`), duplicate `viewHistory` key removed, new keys: `addReadingTooltip`, `pulseLabel`
- **Dependencies:** Added `material_symbols_icons: ^4.2951.0` for `Symbols.weight`
- **Tests:** 193 tests — `phase5a_correction_test.dart` (23), `measurement_formatter_test.dart` (16), `measurement_validator_test.dart` (16), `measurement_seed_test.dart` (23), `measurement_health_screen_test.dart` (3), plus existing widget/form tests

**Root cause of duplicates:** The v3→v4 migration called `_seedMeasurementTypesV4()` which looked up existing types by `key`. But old types from v1-v3 had `NULL` keys (the column didn't exist before v4). So it never found them and inserted NEW types with keys, creating duplicates alongside the old fieldless types.

**Root cause of Heart Rate duplication:** An older system type from pre-v4 that had NULL key and was never cleaned up, appearing alongside the new canonical "Pulse" type.

**Migration strategy (v5):**
1. Find all system types with same name where one has a key and one doesn't → deactivate the keyless one, migrate its records to the keyed canonical type
2. Find active "Heart Rate" type → migrate its records to "Pulse" (deduplicating by timestamp+profile), deactivate it
3. Ensure all 6 canonical keyed types have field definitions (seed fields if missing)

**Test Results:** 193/193 passing (flutter test), 1 pre-existing info lint (`prefer_initializing_formals` in `notification_action_bridge.dart:19`)

### Phase 4E — Medication Schedule Redesign

**Status:** Completed

**What was done:**

- **Schedule model simplified:** Replaced 3-type model (`DailySchedule(time)`, `FixedTimesSchedule(times)`, `IntervalDaysSchedule(interval, time)`) with 2-type model: `DailySchedule(times: List<String>)` and `IntervalDaysSchedule(intervalDays: int, times: List<String>)` — both support multiple times per day
- **New domain entities:** `DosageForm` enum (tablet, capsule, drop, ml, puff, unit, sachet, spoon, injection, other) with storage mapping extension; `ScheduleConfig` sealed class with `validateTimes()` static method
- **MedicationSchedule entity updated:** Added `intakeQuantity` (double), `dosageForm` (DosageForm), `customDosageForm` (String?) fields
- **MedicationLog entity updated:** Added snapshot fields (`snapshotIntakeQuantity`, `snapshotDosageForm`, `snapshotCustomDosageForm`) to preserve intake details at log time
- **Database schema v6:** Destructive migration — drops and recreates `MedicationSchedules` and `MedicationLogs` tables with new columns; `build_runner` regenerated (166 outputs)
- **Notification system:** `NotificationScheduler` and `NotificationActionBridge` updated for new model; notification body now includes intake quantity and dosage form
- **Schedule editor UI:** `MedicationScheduleForm` rewritten with dynamic time slots (add/remove), intake quantity input with quick-select chips, dosage form dropdown, custom "Other" field, instruction chips; `ScheduleTypeSelector` reduced to 2 options (Daily, Every N Days)
- **Schedule display:** `ScheduleFormatter` updated for new model; `medication_detail_screen.dart` updated (`_formatScheduleSummary`, `_scheduleIcon`); medication history shows intake snapshots from logs
- **Localization:** New keys added in EN and KA (dailyScheduleDescription, everyNDaysSchedule, everyNDaysScheduleDescription, intakeQuantity, perIntake, dosageForm, tablet..other, customDosageForm, customDosageFormRequired, invalidIntakeQuantity); obsolete keys removed (`fixedTimesSchedule`, `fixedTimes`)
- **Screens updated:** `AddScheduleScreen` and `EditScheduleScreen` pass intake quantity, dosage form, and custom dosage form to schedule CRUD; `MedicationHistoryScreen` displays intake snapshot from log records
- **Backward compatibility:** NOT required; old schedule data may be deleted

**Files modified:**
- `lib/domain/entities/dosage_form.dart` — NEW
- `lib/domain/entities/schedule_config.dart` — REWRITTEN (2-type model)
- `lib/domain/entities/medication.dart` — REWRITTEN (MedicationSchedule + MedicationLog)
- `lib/data/database/tables/medication_tables.dart` — UPDATED (new columns)
- `lib/data/database/app_database.dart` — UPDATED (schema v6, destructive migration)
- `lib/data/repositories/medication_repository_impl.dart` — REWRITTEN (schedule CRUD, log snapshots)
- `lib/data/services/notification/notification_scheduler.dart` — UPDATED
- `lib/data/services/notification/notification_action_bridge.dart` — UPDATED
- `lib/presentation/utils/schedule_formatter.dart` — REWRITTEN
- `lib/presentation/widgets/medication/schedule_type_selector.dart` — REWRITTEN (2 options)
- `lib/presentation/widgets/medication/medication_schedule_form.dart` — REWRITTEN
- `lib/presentation/screens/activities/add_schedule_screen.dart` — UPDATED
- `lib/presentation/screens/activities/edit_schedule_screen.dart` — UPDATED
- `lib/presentation/screens/activities/medication_detail_screen.dart` — UPDATED
- `lib/presentation/screens/activities/medication_history_screen.dart` — UPDATED
- `lib/l10n/app_en.arb` — UPDATED (new keys, removed obsolete)
- `lib/l10n/app_ka.arb` — UPDATED (new keys, removed obsolete)
- `test/schedule_test.dart` — REWRITTEN
- `test/notification_action_bridge_test.dart` — UPDATED

**Test Results:** 198/198 passing (flutter test), 1 pre-existing info lint

---

### Phase 4E Polish — Localization & Dosage Form Centralization

**Date:** 2026-07-24

**Problem:** 6+ locations across the codebase used `schedule.dosageForm.name` (always English) for dosage form display. Georgian had wrong tablet translation (`აბა` → `აბი`). No `topical` dosage form existed.

**Changes:**
- Added `topical` to `DosageForm` enum (EN: "Apply", KA: "წასმა")
- Fixed Georgian: აბა → აბი
- Created centralized `DosageFormLocalizer` in `presentation/utils/` with `localize()`, `localizeWithQuantity()`, `localizeSnapshot()`
- Updated `ScheduleFormatter` to accept `AppLocalizations` and use `DosageFormLocalizer`
- Updated `medication_detail_screen.dart` `_formatScheduleSummary` to use centralized formatter
- Updated `medication_history_screen.dart` `_formatIntakeSnapshot` to use centralized formatter
- Updated `medication_schedule_form.dart` — removed duplicated `_localizedDosageForm`, now uses `DosageFormLocalizer.localize()`
- Removed dead `dosageFormLabel` getter from `MedicationSchedule` (unused code using hardcoded English `.name`)
- `notification_action_bridge.dart` and `medication_repository_impl.dart` left unchanged per constraints (data layer)

**Files Created:**
- `lib/presentation/utils/dosage_form_localizer.dart`

**Files Modified:**
- `lib/domain/entities/dosage_form.dart` — added `topical`
- `lib/domain/entities/medication.dart` — removed dead `dosageFormLabel`
- `lib/presentation/utils/schedule_formatter.dart` — uses `DosageFormLocalizer`
- `lib/presentation/screens/activities/medication_detail_screen.dart` — uses centralized formatter
- `lib/presentation/screens/activities/medication_history_screen.dart` — uses centralized formatter
- `lib/presentation/widgets/medication/medication_schedule_form.dart` — removed duplicated logic
- `lib/l10n/app_en.arb` — added `topical`
- `lib/l10n/app_ka.arb` — added `topical`, fixed `აბა` → `აბი`
- `test/schedule_test.dart` — updated for l10n, added `DosageFormLocalizer` tests

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (1 pre-existing info lint) |
| `flutter test` | Passed (201/201) |

---

### Phase 4E Polish — Georgian Pluralization

**Date:** 2026-07-24

**Changes:**
- `DosageFormLocalizer` made locale-aware — `_shouldPluralize()` returns false for `localeName == 'ka'`
- `_pluralized()` helper used by both `localizeWithQuantity()` and `localizeSnapshot()`
- 3 new Georgian tests added to `schedule_test.dart`

**Test Results:** 204/204 passing

---

### Phase 5A — Irregular Heartbeat Indicator

**Date:** 2026-07-24

**Problem:** Many blood-pressure devices display an irregular-heartbeat indicator during a reading. Users need to record whether the device showed this indicator for a specific reading. This is a device indicator, not a medical diagnosis.

**Changes:**

**Schema v7:**
- Added nullable `bool? irregularHeartbeatDetected` column to `MeasurementRecords` table
- Migration: `if (from < 7) { addColumn }` — non-destructive

**Domain Entity:**
- `MeasurementRecord` in `measurement.dart` updated with `bool? irregularHeartbeatDetected` field
- `copyWith` supports `clearIrregularHeartbeat` flag (Dart cannot distinguish `null` from absent in named params)

**Repository:**
- `_recordToDomain` maps `irregularHeartbeatDetected` from DB row to domain entity
- `createRecord` and `updateRecord` pass `Value(record.irregularHeartbeatDetected)`

**Forms:**
- `measurement_entry_screen.dart`: `SwitchListTile` shown only for `type.key == 'blood_pressure'`; state initialized as `null`
- `measurement_edit_screen.dart`: `SwitchListTile` shown only for BP; pre-populated from existing record

**History Display:**
- `measurement_history_screen.dart`: `_RecordTile` shows `Icons.heart_broken` icon + localized label only when `record.irregularHeartbeatDetected == true`; hidden for `false` or `null`

**Localization:**
- New key `irregularHeartbeat` in EN (`Irregular heartbeat`) and KA (`არარეგულარული გულისცემა`)

**Storage Semantics:**
- `true` = device showed irregular heartbeat indicator
- `false` = user explicitly recorded no indicator
- `null` = not recorded / device doesn't support indicator

**Tests:** 15 new tests in `test/irregular_heartbeat_test.dart`:
- Domain entity: constructor accepts null/true/false, copyWith preserves/changes/clears the field
- DB CRUD: default null after migration, create with true/false, update true→false, update false→null, non-BP records unaffected

**Files Created:**
- `test/irregular_heartbeat_test.dart`

**Files Modified:**
- `lib/domain/entities/measurement.dart` — added `irregularHeartbeatDetected` field + copyWith
- `lib/data/database/tables/measurement_tables.dart` — added nullable `BoolColumn`
- `lib/data/database/app_database.dart` — schema v7, migration
- `lib/data/repositories/measurement_repository_impl.dart` — domain mapping, CRUD
- `lib/presentation/screens/health/measurement_entry_screen.dart` — SwitchListTile for BP
- `lib/presentation/screens/health/measurement_edit_screen.dart` — SwitchListTile for BP
- `lib/presentation/screens/health/measurement_history_screen.dart` — indicator display
- `lib/l10n/app_en.arb` — added `irregularHeartbeat`
- `lib/l10n/app_ka.arb` — added `irregularHeartbeat`

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (1 pre-existing info lint) |
| `flutter test` | Passed (219/219) |

**Known Limitations:**
- The field is on `MeasurementRecords` (applies to all types) but UI only shows the toggle for blood pressure
- No data migration for existing BP records (they default to `null`)
- Not connected to any conditional dose logic yet

### Phase 5A.1 — Measurement Reference Ranges & Status Indicators

**Status:** Completed

**What was done:**

- Created domain models for configurable reference ranges and reading status evaluation
- Created `ReadingStatusIndicator` reusable widget (compact colored dot)
- Updated measurement history screen with status indicators and legend bottom sheet
- Added localization keys for status labels and legend
- All new code is pure domain logic + presentation widget; no DB changes

**Domain Models:**

- `ReadingStatus` enum: `unknown`, `belowRange`, `inRange`, `aboveRange`
- `ReferenceRange` class: `minValue`/`maxValue` (nullable for open-ended ranges), `contains()`, `isBelow()`, `isAbove()`, `hasRange`
- `MeasurementRanges` class: wraps `Map<String, ReferenceRange>` keyed by field key (e.g., `'systolic'`, `'diastolic'`)
- `DefaultReferenceRanges` class: centralized default ranges for all 6 measurement types

**Default Reference Ranges:**

| Type | Systolic | Diastolic | Range |
|---|---|---|---|
| Blood Pressure | 90–120 mmHg | 60–80 mmHg | Combined evaluation |
| Pulse | — | — | 60–100 bpm |
| Blood Glucose | — | — | 3.9–7.8 mmol/L |
| Temperature | — | — | 36.1–37.2 °C |
| SpO2 | — | — | 95–100 % |
| Weight | — | — | No default range (unknown) |

**Calculator Logic:**
- `ReadingStatusCalculator.calculate()`: takes `typeKey`, `fieldValues`, `ranges`
- For blood pressure: evaluates BOTH systolic and diastolic; `aboveRange` takes priority over `belowRange` when one is each
- Falls back to `unknown` for missing values or missing ranges
- Supports custom ranges via `MeasurementRanges` override

**Status Indicator Widget:**
- `ReadingStatusIndicator`: compact colored dot matching Medication module's visual language
  - Green = `inRange`, Blue = `belowRange`, Red (error) = `aboveRange`, Grey outline = `unknown`

**History Screen Updates:**
- `_RecordTile`: status indicator as `leading` widget
- AppBar info icon opens `_showLegend` `BottomSheet` with colored dots and descriptions
- `_LegendItem` widget for each legend entry
- Status calculated per record via `_calculateStatus` using `ReadingStatusCalculator`

**Localization:**
- 12 new keys added to both EN and KA: `withinRange`, `aboveRange`, `belowRange`, `noReferenceRange`, `readingStatusLegend`, `referenceRange`, `legendWithinRange`, `legendAboveRange`, `legendBelowRange`, `legendIrregularHeartbeat`, `legendNoReferenceRange`, `legendDescription`

**Tests:** 44 new tests in `test/reading_status_test.dart`:
- `ReferenceRange`: contains, open-ended ranges, isBelow, isAbove, hasRange
- `MeasurementRanges`: rangeForField
- `ReadingStatusCalculator`: BP (11 tests: in/above/below range, both above, both below, mixed, missing values), pulse (5: in/above/below/boundary), glucose (3), temperature (3), weight (1: unknown), spo2 (3), unknown type (1), missing values (3), custom range (2)
- `DefaultReferenceRanges`: has all types, rangesForType, unknown type returns null, weight empty

**Files Created:**
- `lib/domain/entities/reading_status.dart`
- `lib/domain/entities/default_reference_ranges.dart`
- `lib/domain/services/reading_status_calculator.dart`
- `lib/presentation/widgets/common/reading_status_indicator.dart`
- `test/reading_status_test.dart`

**Files Modified:**
- `lib/l10n/app_en.arb` — 12 new keys
- `lib/l10n/app_ka.arb` — 12 new Georgian translations
- `lib/presentation/screens/health/measurement_history_screen.dart` — status indicator, legend, `_calculateStatus`

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (1 pre-existing info lint, 7 pre-existing test warnings) |
| `flutter test` | Passed (230/230; 3 pre-existing loading failures excluded) |

**Known Limitations:**
- Reference ranges are in-memory defaults only; not persisted to DB or user-editable yet
- Profile-specific ranges deferred to a later phase
- Weight has no default range (unknown status always)
- Status indicator is only on history screen; not on entry/edit forms yet

---

### Phase 5A.1 Correction — Measurement Edit Fix & Profile-Specific Reference Ranges

**Date:** 2026-07-25

**Status:** Completed

**What was done:**

#### Measurement Edit Root Cause Fix
- **Root cause:** `MeasurementRepositoryImpl.updateRecord()` was missing `createdAt: Value(record.createdAt)` in the `MeasurementRecordsCompanion`. Since `createdAt` is non-nullable (`dateTime()()`) and Drift's `replace()` requires all non-nullable columns, the update was failing silently.
- **Fix:** Added `createdAt: Value(record.createdAt)` to the companion in `updateRecord()` at `lib/data/repositories/measurement_repository_impl.dart:227`
- **3 regression tests** in `test/measurement_edit_diagnosis_test.dart`: update succeeds, preserves createdAt/irregularHeartbeat, no duplicate values

#### Profile-Specific Reference Range Configuration
- **Schema v8:** New `ProfileReferenceRanges` table with columns: `id` (auto-increment), `profileId` (int), `typeKey` (text), `fieldKey` (text), `minValue` (double?), `maxValue` (double?), `createdAt`, `updatedAt`
- **Domain entity:** `ProfileReferenceRange` in `lib/domain/entities/profile_reference_range.dart` with `copyWith`, `clearMinValue`/`clearMaxValue` support
- **Repository interface:** `ReferenceRangeRepository` with `getEffectiveRanges`, `watchProfileRanges`, `getProfileRanges`, `saveProfileRange`, `removeProfileRange`, `clearAllProfileRanges`
- **Repository implementation:** `ReferenceRangeRepositoryImpl` — merges profile overrides with `DefaultReferenceRanges`, upserts, deletes, streams
- **Profile-aware providers:**
  - `effectiveRangesForCurrentProfileProvider(typeKey)` — returns merged ranges for active profile
  - `profileReferenceRangesProvider(profileId)` — streams profile-specific overrides
- **Reference range config screen:** `ReferenceRangeScreen` (list view) + `TypeRangeDetailScreen` (min/max form per field)
- **Routes:** `/measurements/ranges` and `/measurements/ranges/:typeKey`
- **History screen updates:**
  - AppBar tune button navigates to reference range config
  - `_calculateStatus` now uses profile-aware effective ranges (falls back to defaults)
- **Localization:** 8 new keys in EN and KA: `referenceRanges`, `applicationDefault`, `lowerBound`, `upperBound`, `resetToDefault`, `rangeSaved`, `failedToSaveRange`, `lowerBoundAboveUpperBound`

**Domain Models:**

- `ReadingStatus` enum: `unknown`, `belowRange`, `inRange`, `aboveRange`
- `ReferenceRange` class: `minValue`/`maxValue` (nullable for open-ended ranges), `contains()`, `isBelow()`, `isAbove()`, `hasRange`
- `MeasurementRanges` class: wraps `Map<String, ReferenceRange>` keyed by field key (e.g., `'systolic'`, `'diastolic'`)
- `DefaultReferenceRanges` class: centralized default ranges for all 6 measurement types

**Default Reference Ranges:**

| Type | Systolic | Diastolic | Range |
|---|---|---|---|
| Blood Pressure | 90–120 mmHg | 60–80 mmHg | Combined evaluation |
| Pulse | — | — | 60–100 bpm |
| Blood Glucose | — | — | 3.9–7.8 mmol/L |
| Temperature | — | — | 36.1–37.2 °C |
| SpO2 | — | — | 95–100 % |
| Weight | — | — | No default range (unknown) |

**Calculator Logic:**
- `ReadingStatusCalculator.calculate()`: takes `typeKey`, `fieldValues`, `ranges`
- For blood pressure: evaluates BOTH systolic and diastolic; `aboveRange` takes priority over `belowRange` when one is each
- Falls back to `unknown` for missing values or missing ranges
- Supports custom ranges via `MeasurementRanges` override

**Status Indicator Widget:**
- `ReadingStatusIndicator`: compact colored dot matching Medication module's visual language
  - Green = `inRange`, Blue = `belowRange`, Red (error) = `aboveRange`, Grey outline = `unknown`

**History Screen Updates:**
- `_RecordTile`: status indicator as `leading` widget
- AppBar info icon opens `_showLegend` `BottomSheet` with colored dots and descriptions
- AppBar tune icon navigates to reference range config
- `_LegendItem` widget for each legend entry
- Status calculated per record via `_calculateStatus` using profile-aware effective ranges

**Localization:**
- 20 new keys total in both EN and KA: `withinRange`, `aboveRange`, `belowRange`, `noReferenceRange`, `readingStatusLegend`, `referenceRange`, `referenceRanges`, `legendWithinRange`, `legendAboveRange`, `legendBelowRange`, `legendIrregularHeartbeat`, `legendNoReferenceRange`, `legendDescription`, `applicationDefault`, `lowerBound`, `upperBound`, `resetToDefault`, `rangeSaved`, `failedToSaveRange`, `lowerBoundAboveUpperBound`

**Tests:** 16 new tests in `test/reference_range_test.dart`:
- `ProfileReferenceRange` entity: copyWith, nullable fields, clearMinValue/clearMaxValue
- `ReferenceRangeRepositoryImpl`: create/update/remove profile ranges, clear all, get profile ranges, effective ranges (defaults only, profile override, new field alongside defaults, unknown type)
- `ReadingStatusCalculator` with custom ranges: above/below/inRange

**Files Created:**
- `lib/data/database/tables/profile_reference_range_tables.dart`
- `lib/domain/entities/profile_reference_range.dart`
- `lib/domain/repositories/reference_range_repository.dart`
- `lib/data/repositories/reference_range_repository_impl.dart`
- `lib/presentation/providers/reference_range_provider.dart`
- `lib/presentation/screens/health/reference_range_screen.dart`
- `test/reference_range_test.dart`
- `test/measurement_edit_diagnosis_test.dart`

**Files Modified:**
- `lib/data/database/app_database.dart` — schema v8, migration
- `lib/data/repositories/measurement_repository_impl.dart` — added `createdAt: Value(record.createdAt)` to `updateRecord()`
- `lib/presentation/providers/database_provider.dart` — added `referenceRangeRepositoryProvider`
- `lib/presentation/screens/health/measurement_history_screen.dart` — tune button, profile-aware `_calculateStatus`
- `lib/core/router/app_routes.dart` — added `measurementRanges`
- `lib/core/router/app_router.dart` — added reference range routes
- `lib/l10n/app_en.arb` — 8 new keys
- `lib/l10n/app_ka.arb` — 8 new Georgian translations

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (1 pre-existing info lint, 8 pre-existing test warnings) |
| `flutter test` | Passed (282/282) |

---

### Phase 5A.1 Correction — Georgian Localization & Visual Consistency

**Date:** 2026-07-25

**Status:** Completed

**What was done:**

#### Georgian Reading-Status Translation Corrections
- **belowRange:** "ნორმაზე დაბლა" → "ნორმაზე დაბალი" (adjective form, not adverb)
- **aboveRange:** "ნორმაზე მაღლა" → "ნორმაზე მაღალი" (adjective form, not adverb)
- **noReferenceRange:** "ცნობილი არ არის" → "უცნობი" (simpler, more natural)
- **legendBelowRangeDescription:** "კონფიგურირებულ დიაპაზონზე დაბლა" → "კონფიგურირებულ დიაპაზონზე დაბალი"
- **legendAboveRangeDescription:** "კონფიგურირებულ დიაპაზონზე მაღლა" → "კონფიგურირებულ დიაპაზონზე მაღალი"
- **legendNoReferenceRangeDescription:** "ცნობილი დიაპაზონი არ არის კონფიგურირებული" → "დიაპაზონი არ არის კონფიგურირებული"
- **legendIrregularHeartbeat:** "არარეგულარული გულისცემა აღმოჩენილია" → "აღმოჩენილია არარეგულარული გულისცემა" (verb-first word order)
- English translations unchanged

#### Irregular-Heartbeat Icon Consistency
- **Problem:** Legend used hardcoded `Colors.red` while history row used `theme.colorScheme.error`
- **Fix:** Updated legend icon to use `Theme.of(context).colorScheme.error` instead of `Colors.red`
- **Result:** Legend now matches history row icon appearance in both light and dark themes

#### Locale-Aware Reference-Range Count Formatting
- **Problem:** `'$count ${l10n.referenceRange.toLowerCase()}${count > 1 ? 's' : ''}'` appended English "s" suffix to Georgian text
- **Fix:** Added `referenceRangeCount` ARB key with ICU MessageFormat plural syntax for English (`{count,plural, =0{0 reference ranges} =1{1 reference range} other{{count} reference ranges}}`) and simple template for Georgian (`{count} ცნობილი დიაპაზონი`)
- **Result:** Georgian always uses base form without English suffix; English pluralizes correctly

**Localization Keys Corrected:**

| Key | Old Georgian | New Georgian |
|---|---|---|
| belowRange | ნორმაზე დაბლა | ნორმაზე დაბალი |
| aboveRange | ნორმაზე მაღლა | ნორმაზე მაღალი |
| noReferenceRange | ცნობილი არ არის | უცნობი |
| legendBelowRangeDescription | კონფიგურირებულ დიაპაზონზე დაბლა | კონფიგურირებულ დიაპაზონზე დაბალი |
| legendAboveRangeDescription | კონფიგურირებულ დიაპაზონზე მაღლა | კონფიგურირებულ დიაპაზონზე მაღალი |
| legendNoReferenceRangeDescription | ცნობილი დიაპაზონი არ არის კონფიგურირებული | დიაპაზონი არ არის კონფიგურირებული |
| legendIrregularHeartbeat | არარეგულარული გულისცემა აღმოჩენილია | აღმოჩენილია არარეგულარული გულისცემა |

**Localization Keys Added:**

| Key | English | Georgian |
|---|---|---|
| referenceRangeCount | {count,plural, =0{0 reference ranges} =1{1 reference range} other{{count} reference ranges}} | {count} ცნობილი დიაპაზონი |

**Files Modified:**
- `lib/l10n/app_ka.arb` — corrected 7 Georgian translations, added `referenceRangeCount`
- `lib/l10n/app_en.arb` — added `referenceRangeCount` with plural syntax
- `lib/presentation/screens/health/measurement_history_screen.dart` — legend icon uses theme color
- `lib/presentation/screens/health/reference_range_screen.dart` — uses `referenceRangeCount` localization

**Files Created:**
- `test/localization_correction_test.dart` — 33 tests verifying translations and formatting

**Tests Added:** 33 new tests:
- 10 Georgian reading-status translation verifications
- 10 English reading-status translation verifications (unchanged)
- 9 reference-range count formatting tests (English plural, Georgian no-suffix)
- 4 irregular-heartbeat icon consistency tests

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (1 pre-existing info lint, 10 pre-existing test warnings) |
| `flutter test` | Passed (315/315) |

---

### Phase 5B — Measurement Charts, Trends, and Statistics

**Date:** 2026-07-25

**Status:** Completed

**What was done:**

#### Chart Library
- Added `fl_chart: ^0.70.0` to `pubspec.yaml`
- Single chart library used throughout (no duplicate chart packages)

#### Domain Models (no Flutter imports)
- **`MeasurementPeriod`** enum — `last7Days`, `last30Days`, `last90Days`, `allTime` with `from` date calculation
- **`MeasurementDataPoint`** — combines `MeasurementRecord` + `List<MeasurementRecordValue>` with `valueForKey`/`unitForKey` accessors
- **`MeasurementChartPoint`** — recordId, measuredAt, numericValue, unit, readingStatus, irregularHeartbeatDetected
- **`MeasurementChartSeries`** — fieldKey, label, unit, ordered points
- **`MeasurementStatistics`** — count, latest, minimum, maximum, average, first, change, percentageChange (with `compute` factory)
- **`ReadingStatusSummary`** — belowCount, withinCount, aboveCount, unknownCount, irregularHeartbeatCount

#### Domain Service
- **`MeasurementChartBuilder`** — pure static methods:
  - `buildSeries()` — converts data points + fields + ranges into chart series (oldest-first ordering)
  - `_buildBloodPressureSeries()` — special BP handling: systolic/diastolic/pulse as separate series
  - `_buildGenericSeries()` — one series per field for single-value and custom types
  - `computeFieldStatistics()` — statistics per chart series
  - `computeStatusSummary()` — status counts with deduplication across series (same record counted once)

#### Data Layer Changes
- **DAO:** Added `getValuesForRecords(List<int> recordIds)` — bulk fetch avoids N+1 queries
- **DAO:** Added `ascending` parameter to `watchRecords` and `getRecords` (default false = newest first)
- **Repository interface:** Added `getValuesForRecords` + `ascending` param
- **Repository implementation:** Bulk values grouped by recordId; ascending ordering passed through

#### Providers
- **`TrendParams`** typedef — `({int measurementTypeId, MeasurementPeriod period})`
- **`TrendData`** class — combined data container (dataPoints, chartSeries, fieldStatistics, statusSummary)
- **`trendDataProvider`** — `FutureProvider.autoDispose.family<TrendData, TrendParams>` — loads records, bulk values, type, fields, ranges; builds chart series + stats + summary in single provider
- **`trendTypeProvider`** — lookup for type metadata

#### Routes
- **Route constant:** `AppRoutes.measurementTrends(int typeId)` → `/measurements/measurement/$typeId/trends`
- **Router entry:** Outside ShellRoute (full-screen), with `int.tryParse` + `_InvalidRouteScreen` fallback

#### Chart Widget
- **`MeasurementLineChart`** — single widget handles all measurement types:
  - One `LineChartBarData` per series with status-colored dots
  - Blood Pressure: systolic (primary), diastolic (secondary), pulse (dashed, lighter)
  - Custom `FlDotCirclePainter` maps `ReadingStatus` to colors (matching `ReadingStatusIndicator`)
  - Irregular heartbeat: larger ring in `colorScheme.error` around status-colored dot
  - Reference range: dashed horizontal lines in `colorScheme.outlineVariant`
  - Touch tooltip: date/time, field label, value, unit, status, irregular heartbeat
  - Auto Y-axis scaling with 15% padding
  - Date labels on X-axis with locale-aware formatting via `intl.DateFormat`

#### Supporting Widgets
- **`MeasurementPeriodSelector`** — `SegmentedButton<MaterialPeriod>` with 4 options
- **`MeasurementStatisticsCard`** — compact Card with stat rows; BP uses comparison table layout
- **`MeasurementStatusSummaryCard`** — status counts with `ReadingStatusIndicator` dots + irregular heartbeat row
- **`MeasurementChartLegend`** — inline legend with status dots, series color indicators, irregular heartbeat note

#### Trends Screen
- **`MeasurementTrendsScreen`** — ConsumerStatefulWidget with:
  - AppBar with history action button
  - Period selector
  - Chart (250px height)
  - Statistics card
  - Status summary card
  - Legend card
  - Empty state with Add Reading action
  - One-reading state with latest value + "more readings needed" message
  - Loading/error states with retry

#### History Screen Integration
- Added `Icons.show_chart` IconButton in AppBar between tune and legend buttons
- Navigates to `/measurements/measurement/:typeId/trends`
- Localized tooltip `l10n.viewTrends`

#### Localization
- **30 new keys** in English and Georgian ARB files
- English uses full sentences; Georgian uses natural translations
- Key categories: periods (4), statistics (5), status counts (5), UI labels (10), error states (3), BP labels (3)

**Files Created:**
- `lib/domain/entities/measurement_period.dart`
- `lib/domain/entities/measurement_data_point.dart`
- `lib/domain/entities/measurement_chart.dart`
- `lib/domain/entities/measurement_statistics.dart`
- `lib/domain/entities/reading_status_summary.dart`
- `lib/domain/services/measurement_chart_builder.dart`
- `lib/presentation/screens/health/measurement_trends_screen.dart`
- `lib/presentation/widgets/charts/measurement_line_chart.dart`
- `lib/presentation/widgets/charts/chart_legend.dart`
- `lib/presentation/widgets/measurements/measurement_period_selector.dart`
- `lib/presentation/widgets/measurements/measurement_statistics_card.dart`
- `lib/presentation/widgets/measurements/measurement_status_summary_card.dart`
- `test/measurement_period_test.dart`
- `test/measurement_chart_builder_test.dart`
- `test/measurement_chart_model_test.dart`

**Files Modified:**
- `pubspec.yaml` — added `fl_chart: ^0.70.0`
- `lib/data/database/daos/measurement_dao.dart` — added `getValuesForRecords`, `ascending` param
- `lib/domain/repositories/measurement_repository.dart` — added `getValuesForRecords`, `ascending` param
- `lib/data/repositories/measurement_repository_impl.dart` — implemented bulk values + ascending
- `lib/core/router/app_routes.dart` — added `measurementTrends`
- `lib/core/router/app_router.dart` — added trends route + import
- `lib/presentation/providers/measurement_provider.dart` — added TrendParams, TrendData, trend providers
- `lib/presentation/screens/health/measurement_history_screen.dart` — added trends button
- `lib/l10n/app_en.arb` — 30 new keys
- `lib/l10n/app_ka.arb` — 30 new Georgian translations

**Tests Added:** 44 new tests:
- 7 measurement period tests (date calculations, ordering)
- 24 chart builder tests (series building, statistics, status summary, BP, custom types)
- 13 chart model tests (point, series, statistics, summary entities)

**Performance Decisions:**
- Bulk `getValuesForRecords` avoids N+1 queries (3 queries total regardless of record count)
- Single `FutureProvider.family` for trend data avoids duplicate database queries
- Chart statistics and status summary computed in-memory from loaded data
- `ascending` ordering at database level (not in Dart)

**Known Limitations:**
- No zoom/pan on charts
- No custom date range picker (only 4 preset periods)
- Data refreshes on navigation (FutureProvider, not StreamProvider)
- Weight has no reference range (always unknown status) — by design
- No PDF/CSV export of trend data
- No real-time streaming for chart updates
- Pixel 7 not tested (not connected during this session)

**Validation Results:**
| Check | Result |
|---|---|
| `flutter pub get` | Completed successfully |
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (1 pre-existing info lint, 10 pre-existing test warnings) |
| `flutter test` | Passed (359/359, pre-extension) |

### Phase 5B Extension — Blood Pressure Statistics Comparison Table

**Date:** 2026-07-25

**Status:** Completed

**What was done:**

#### Comparison Table Widget
- **`MeasurementStatisticsComparisonTable`** — new reusable widget for multi-series comparison:
  - Column headers with series label + unit (e.g. "Systolic mmHg", "Pulse bpm")
  - Row labels: Latest, Average, Minimum, Maximum
  - Missing series values show em dash (`—`) — no fabricated zeros
  - Accessibility: Semantics labels with row + column context (e.g. "Latest Systolic: 125")
  - Horizontal scroll on narrow screens (no overflow)
  - Static factory `fromBloodPressure()` for BP-specific layout

#### Blood Pressure Statistics Card Update
- Replaced `_buildBloodPressureStats()` vertical sections with `MeasurementStatisticsComparisonTable.fromBloodPressure()`
- Single widget call instead of 3 separate `_SectionHeader` + row blocks
- Removed unused `_SectionHeader` private class from `measurement_statistics_card.dart`

#### Localization
- Added `unavailable` key to EN (`"Unavailable"`) and KA (`"მიუწვდომელი"`) ARB files
- Used in accessibility labels for missing values

**Files Created:**
- `lib/presentation/widgets/measurements/measurement_statistics_comparison_table.dart`
- `test/bp_statistics_table_test.dart`

**Files Modified:**
- `lib/presentation/widgets/measurements/measurement_statistics_card.dart` — replaced BP stats with comparison table
- `lib/l10n/app_en.arb` — added `unavailable` key
- `lib/l10n/app_ka.arb` — added `unavailable` key

**Tests Added:** 12 new tests:
- 9 comparison table tests (headers, labels, values, units, missing pulse, Georgian, narrow screen, accessibility)
- 3 statistics card integration tests (BP type, single-value type, empty)

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (only pre-existing issues) |
| `flutter test` | Passed (371/371, pre-extension) |

### Phase 5B Extension — BP Presentation: Compact Headers & Component-Level Status

**Date:** 2026-07-25

**Status:** Completed

**What was done:**

#### Compact Georgian Statistics Headers
- Added `systolicShort`, `diastolicShort`, `pulseShort` localization keys
- Georgian compact headers: სისტ., დიასტ., პულსი (single line, no wrapping)
- English compact headers match full labels (Systolic, Diastolic, Pulse)
- Full labels preserved in Semantics + Tooltip for accessibility
- Updated `MeasurementStatisticsComparisonTable` to accept `compactLabel` per column

#### Centralized Status-to-Color Utility
- **`ReadingStatusColor.forStatus()`** — single source of truth for `ReadingStatus` → `Color` mapping
- Updated `ReadingStatusIndicator`, `MeasurementLineChart._statusColor()` to use centralized utility
- Eliminates color duplication between indicator widget and chart

#### BloodPressureComponentStatus Model
- Domain entity at `lib/domain/entities/blood_pressure_component_status.dart`
- Fields: `overallStatus`, `systolicStatus`, `diastolicStatus`, `pulseStatus` (nullable)
- No Flutter imports — pure domain layer

#### BloodPressureStatusEvaluator Service
- Domain service at `lib/domain/services/blood_pressure_status_evaluator.dart`
- Evaluates per-component statuses using effective reference ranges
- Overall status computed via existing `ReadingStatusCalculator` (consistent rules)
- Pulse status returns `null` when pulse is absent

#### Component-Level Colored History Row
- **`BloodPressureSummaryText`** widget — `RichText` with status-colored numeric values
- Systolic value uses systolic status color
- Diastolic value uses diastolic status color
- Pulse value uses pulse status color (when present)
- Separators (`/`, `,`), labels, and units keep normal theme text color
- Pulse section omitted when pulse is absent
- Updated `_RecordTile` to use `BloodPressureSummaryText` for BP records
- Non-BP records continue using plain `Text` from `MeasurementFormatter`

#### Accessibility
- Compact table headers wrapped in `Semantics(label: fullLabel)` + `Tooltip(message: fullLabel)`
- `BloodPressureSummaryText` provides `Semantics` label: "Systolic above configured range, Diastolic within configured range"
- Added localization keys: `withinConfiguredRange`, `belowConfiguredRange`, `aboveConfiguredRange`, `noReferenceRangeConfigured`
- Added parameterized keys: `componentStatusSystolic`, `componentStatusDiastolic`, `componentStatusPulse`

#### Localization (10 new keys)
- `systolicShort` / `diastolicShort` / `pulseShort` — compact headers
- `withinConfiguredRange` / `belowConfiguredRange` / `aboveConfiguredRange` / `noReferenceRangeConfigured` — component status descriptions
- `componentStatusSystolic` / `componentStatusDiastolic` / `componentStatusPulse` — parameterized accessibility labels

**Files Created:**
- `lib/domain/entities/blood_pressure_component_status.dart`
- `lib/domain/services/blood_pressure_status_evaluator.dart`
- `lib/presentation/utils/reading_status_color.dart`
- `lib/presentation/widgets/measurements/blood_pressure_summary_text.dart`
- `test/blood_pressure_status_evaluator_test.dart`
- `test/bp_component_status_widget_test.dart`

**Files Modified:**
- `lib/l10n/app_en.arb` — 10 new keys
- `lib/l10n/app_ka.arb` — 10 new Georgian translations
- `lib/presentation/widgets/measurements/measurement_statistics_comparison_table.dart` — compact headers + Semantics/Tooltip
- `lib/presentation/screens/health/measurement_history_screen.dart` — BP-specific RichText rendering
- `lib/presentation/widgets/common/reading_status_indicator.dart` — uses centralized `ReadingStatusColor`
- `lib/presentation/widgets/charts/measurement_line_chart.dart` — uses centralized `ReadingStatusColor`
- `test/bp_statistics_table_test.dart` — updated Georgian compact header assertions

**Tests Added:** 26 new tests:
- 14 unit tests for `BloodPressureStatusEvaluator` (all component combinations, missing values, unknown ranges, profile override, overall consistency)
- 12 widget tests: 4 compact header tests (Georgian short labels, narrow screen, Semantics full labels, English) + 8 `BloodPressureSummaryText` tests (systolic/diastolic/pulse colors, separator color, pulse omission, accessibility semantics, English/Georgian summaries, narrow screen)

**Overall Status Behavior:**
- Overall status dot (`ReadingStatusIndicator`) remains unchanged — shows combined reading status
- Component-level colors explain which values contributed to that status
- Irregular heartbeat icon remains completely independent

**Pixel 7 Verification:** Not performed (device not connected during this session)

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (only pre-existing issues) |
| `flutter test` | Passed (397/397) |

---

### Phase 5B Extension — Measurement-History Status Colouring + BP Pulse Range

**Status:** Completed

**What was done:**

1. **`StatusAwareMeasurementValue` reusable widget** — new presentation widget that renders `RichText` with per-part status colours and `Semantics` label
   - `MeasurementValuePart` model: `(text, ReadingStatus)`
   - Multi-part support: SpO2 + optional Pulse rendered with independent colours
   - Consistent with `BloodPressureSummaryText` widget pattern

2. **Blood Pressure Pulse default reference range** — added `'pulse': ReferenceRange(minValue: 60, maxValue: 100)` to `DefaultReferenceRanges.ranges['blood_pressure']`
   - Standalone Pulse type range unchanged
   - Effective-range lookup for BP Pulse now returns known range instead of unknown

3. **Blood Pressure reference-range editor** — updated `_fieldKeysForType('blood_pressure')` from `['systolic', 'diastolic']` to `['systolic', 'diastolic', 'pulse']`
   - Pulse row now appears in BP range editor with lower/upper bound fields
   - Save/reset logic unchanged — iterates all field keys

4. **Single-value history status colouring** — updated `_RecordTile` in `measurement_history_screen.dart`
   - Pulse, Weight, Blood Glucose, Temperature: values now rendered via `StatusAwareMeasurementValue` with status-coloured text
   - SpO2: both SpO2 value and optional Pulse value rendered with independent status colours
   - Added `_calculateFieldStatus(fieldKey, value)` helper for per-field status evaluation
   - Added `_buildSpO2Title()` for SpO2-specific two-component rendering
   - Added `_statusLabel()` helper for semantics labels

**Files Created:**
- `lib/presentation/widgets/measurements/status_aware_measurement_value.dart`
- `test/status_aware_measurement_value_test.dart`

**Files Modified:**
- `lib/domain/entities/default_reference_ranges.dart` — added pulse range to blood_pressure entry
- `lib/presentation/screens/health/reference_range_screen.dart` — added pulse to `_fieldKeysForType` for blood_pressure
- `lib/presentation/screens/health/measurement_history_screen.dart` — single-value + SpO2 status colouring via `StatusAwareMeasurementValue`

**Tests Added:** 14 new tests:
- 9 `StatusAwareMeasurementValue` widget tests (single-part colour, multi-part colours, aboveRange error colour, unknown outline colour, custom style, semantics label, plain text, SpO2 with pulse, narrow screen)
- 5 `DefaultReferenceRanges` unit tests (BP includes pulse range, systolic unchanged, diastolic unchanged, standalone pulse unchanged, three field ranges)

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (only pre-existing issues) |
| `flutter test` | Passed (411/411) |

---

### Phase 5B Extension — Numeric-Only Status Colouring + SpO2 Pulse Range

**Status:** Completed

**What was done:**

1. **Numeric-only status colouring** — restructured `MeasurementValuePart` to separate `label`, `value`, and `unit` fields
   - Only the `value` span receives status colour
   - `label` and `unit` spans remain in normal text colour
   - Applied to all measurement types: Pulse, Weight, Blood Glucose, Temperature, SpO2, Standalone Pulse

2. **`StatusAwareMeasurementValue` widget update** — renders three spans per part: label (normal) → value (status colour) → unit (normal)
   - Separator `, ` between parts remains normal colour
   - Consistent with `BloodPressureSummaryText` pattern

3. **`BloodPressureSummaryText` pulse unit fix** — split `'$pulseStr ${pulse.unit}'` into separate value and unit spans
   - Pulse number (`pulseStr`) receives status colour
   - Pulse unit (` bpm` or ` წთ`) remains normal colour
   - Systolic/diastolic `/` separator and ` mmHg` unit were already normal

4. **`MeasurementFormatter.formatNumber` made public** — existing private `_formatNumber` now delegates to public `formatNumber`
   - Enables `_RecordTile` to build value parts with correct decimal formatting per type
   - No breaking changes to existing callers

5. **`_RecordTile` single-value builder** — new `_buildSingleValueTitle()` constructs `MeasurementValuePart` from raw values
   - Type-specific decimal places: Pulse/SpO2 → 0, Weight/Glucose/Temperature → 1
   - Falls back to first available field for unknown types
   - Null value renders `--` with unavailable semantics

6. **`_RecordTile` SpO2 builder update** — `_buildSpO2Title()` uses new label/value/unit structure
   - SpO2 value: `value='97', unit='%'`
   - Optional Pulse: `label='pulse ', value='70', unit=' bpm'`
   - Enhanced semantics include numeric values and units

7. **SpO2 Pulse default reference range** — added `'pulse': ReferenceRange(minValue: 60, maxValue: 100)` to `DefaultReferenceRanges.ranges['spo2']`
   - Standalone Pulse and Blood Pressure Pulse ranges unchanged
   - SpO2 type now has two field ranges: `spo2` and `pulse`

8. **SpO2 reference-range editor** — updated `_fieldKeysForType('spo2')` from `['spo2']` to `['spo2', 'pulse']`
   - Pulse row now appears in SpO2 range editor with lower/upper bound fields
   - Save/reset/clear logic unchanged — iterates all field keys

9. **Effective-range lookup for SpO2 Pulse** — `effectiveRangesForCurrentProfileProvider('spo2')` now returns both `spo2` and `pulse` ranges
   - Profile override → application default → unknown precedence unchanged
   - SpO2 Pulse values outside 60–100 show below/above range colours instead of grey

**Files Created:** None

**Files Modified:**
- `lib/presentation/widgets/measurements/status_aware_measurement_value.dart` — restructured `MeasurementValuePart` with label/value/unit, updated widget rendering
- `lib/presentation/widgets/measurements/blood_pressure_summary_text.dart` — split pulse value from unit span
- `lib/presentation/utils/measurement_formatter.dart` — made `formatNumber` public
- `lib/presentation/screens/health/measurement_history_screen.dart` — added `_buildSingleValueTitle()`, updated `_buildSpO2Title()` with new part structure
- `lib/domain/entities/default_reference_ranges.dart` — added pulse range to spo2 entry
- `lib/presentation/screens/health/reference_range_screen.dart` — added pulse to `_fieldKeysForType` for spo2
- `test/status_aware_measurement_value_test.dart` — rewrote tests for new label/value/unit API, added type-specific colour tests, added SpO2 Pulse range tests

**Tests Updated:** 19 tests:
- 14 `StatusAwareMeasurementValue` widget tests: value-coloured-unit-normal, label-normal-value-coloured, multi-part independent colours, aboveRange error colour, unknown outline colour, custom style, semantics label, plain text, SpO2 with pulse, narrow screen, temperature, weight, blood glucose, standalone pulse
- 5 `DefaultReferenceRanges` unit tests: spo2 includes pulse range, spo2 range unchanged, spo2 has two fields, BP pulse unchanged, standalone pulse unchanged

**Accessibility:**
- Semantics labels include numeric values and units: "SpO2 97%, within configured range. Pulse 70 bpm, within configured range"
- Units and labels remain in normal text colour for visual display
- Status legend remains available via info button

**Pixel 7 Verification:** Not performed (device not connected during this session)

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (only pre-existing issues) |
| `flutter test` | Passed (416/416) |

---

### Phase 5C — Measurement Schedules and Reminders

**Date:** 2026-07-25

**Status:** Completed

**What was done:**

#### Domain Entities Extended
- **`MeasurementSchedule`** — added `instructions` (String?), `createdAt`, `updatedAt` fields; updated `copyWith` with `clearInstructions` and `clearEndDate` support
- **`MeasurementReminderLog`** — new entity: `id`, `measurementScheduleId`, `scheduledTime`, `actionTime`, `status` (MeasurementReminderAction), `createdAt`
- **`MeasurementReminderAction`** enum — `completed`, `skipped`, `snoozed`, `expired` with `fromString()` factory

#### Database Schema v9
- **`MeasurementSchedules`** table extended — added `instructions` (TextColumn nullable), `createdAt` (DateTimeColumn), `updatedAt` (DateTimeColumn)
- **`MeasurementReminderLogs`** table created — `id` (auto-increment), `measurementScheduleId` (FK → MeasurementSchedules), `scheduledTime`, `actionTime` (nullable), `status` (text), `createdAt`
- Migration: adds columns to existing schedules, backfills timestamps from `startDate`/`updatedAt`, creates reminder logs table

#### Notification System
- **`MeasurementNotificationHelper`** — namespace offset (100000) avoids ID collisions with medication notifications; `computeNotificationIds()`, `baseNotificationId()`, `parsePayload()`, `buildPayload()`
- **`NotificationActionBridge`** extended — handles Record Now (completed), Skip, Snooze actions for measurement payloads; `_recoverMeasurementSchedules()` called at startup; passes measurement reminder log updates through repository
- **Measurement notification channel** (`rehabtrack_measurements`) already existed from Phase 3

#### DAO Methods Added
- `watchSchedulesForType`, `getSchedule`, `getActiveSchedules`, `watchActiveSchedules`, `getScheduleForType`
- `insertReminderLog`, `updateReminderLog`, `getReminderLog`, `getReminderLogsForSchedule`, `watchReminderLogsForSchedule`, `getTodayReminderLogs`

#### Repository Interface Extended
- Added all schedule query methods + reminder log CRUD methods
- `MeasurementRepositoryImpl` — all methods implemented with mappers

#### Providers Added
- `measurementSchedulesForTypeProvider(typeId)` — StreamProvider for schedule list
- `measurementScheduleProvider(scheduleId)` — FutureProvider for single schedule
- `activeMeasurementSchedulesProvider` — StreamProvider for active schedules
- `measurementReminderLogsProvider(scheduleId)` — StreamProvider for reminder logs
- `todayMeasurementRemindersProvider` — FutureProvider for today's reminders

#### Routes Added
- `/measurements/measurement/:typeId/schedule/add` — add schedule
- `/measurements/measurement/:typeId/schedule/:scheduleId/edit` — edit schedule
- `AppRoutes.measurementScheduleAdd(typeId)` and `AppRoutes.measurementScheduleEdit(typeId, scheduleId)` helpers

#### Measurement Schedule Screen
- **`MeasurementScheduleScreen`** — shared add/edit screen (ConsumerStatefulWidget)
- `SegmentedButton<ScheduleType>` for Daily / Every N Days selection
- Dynamic time list with add/remove/time picker
- Date range picker (start/end), active toggle, instructions text field
- Notification scheduling via `NotificationScheduler`
- Form validation: required times, interval days must be > 0, end date must be after start date

#### Measurement History Screen Integration
- Schedules section added above records list via `_HistoryBody` widget
- Shows active schedules for current type with schedule type label and times
- Add schedule button (+) in schedules section header
- Popup menu on each schedule with Edit / Delete actions
- Delete confirmation dialog with schedule-specific messaging

#### Localization
- 30+ new keys in EN and KA: schedule UI labels, reminder action labels, schedule management dialogs, measurement reminder notifications

**Files Created:**
- `lib/data/services/notification/measurement_notification_helper.dart`
- `lib/presentation/screens/health/measurement_schedule_screen.dart`
- `test/phase5c_measurement_schedules_test.dart`

**Files Modified:**
- `lib/domain/entities/measurement.dart` — MeasurementSchedule extended + MeasurementReminderLog + MeasurementReminderAction
- `lib/domain/repositories/measurement_repository.dart` — schedule query + reminder log methods
- `lib/data/database/tables/measurement_tables.dart` — MeasurementSchedules extended + MeasurementReminderLogs table
- `lib/data/database/app_database.dart` — schema v9, migration
- `lib/data/database/daos/measurement_dao.dart` — 11 new methods + MeasurementReminderLogs accessor
- `lib/data/repositories/measurement_repository_impl.dart` — new methods + mappers
- `lib/data/services/notification/notification_action_bridge.dart` — measurement action handling + recovery
- `lib/presentation/providers/measurement_provider.dart` — 5 new providers
- `lib/presentation/providers/notification_provider.dart` — bridge gets measurementRepository
- `lib/presentation/screens/health/measurement_history_screen.dart` — schedules section integration
- `lib/core/router/app_routes.dart` — 2 new helper methods
- `lib/core/router/app_router.dart` — 2 new routes
- `lib/l10n/app_en.arb` — 30+ new keys
- `lib/l10n/app_ka.arb` — 30+ new Georgian keys

**Tests Added:** 34 new tests in `test/phase5c_measurement_schedules_test.dart`:
- MeasurementSchedule entity: copyWith, clearInstructions, clearEndDate, default active
- MeasurementReminderAction: fromString for valid/invalid values
- MeasurementReminderLog: copyWith
- ScheduleConfig: DailySchedule/IntervalDaysSchedule JSON roundtrip, fromJsonString, unknown type error, normalizeTimes, validateTimes
- MeasurementNotificationHelper: computeNotificationIds offset, baseNotificationId, buildPayload, parsePayload (valid, null, empty, invalid JSON, wrong type, missing fields)
- MeasurementNotificationPayload: isValid
- ScheduleConfig equality: DailySchedule, IntervalDaysSchedule, cross-type

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (0 errors, 1 pre-existing info lint, 10 pre-existing test warnings) |
| `flutter test` | Passed (453/453) |

**Known Limitations:**
- No snooze duration configurability (hardcoded 10 minutes)
- No "Record Now" deep link from notification directly to entry form
- Schedule editor does not show existing notification status
- No schedule conflict detection (overlapping time slots)

### Phase 5C Refinement — Measurement Schedule Model & UI Polish

**Date:** 2026-07-26

**Status:** Completed

**What was done:**

#### One Time Per Measurement Schedule
- Refactored `MeasurementSchedule` to contain exactly one scheduled time per record
- Removed `ScheduleConfig` dependency from measurement schedules
- Added `scheduleType` (String: 'daily' / 'interval_days'), `time` (String: 'HH:mm'), `intervalDays` (int?) fields directly on `MeasurementSchedule`
- Added `isDaily` / `isIntervalDays` computed getters
- Added static `normalizeTime()` and `isValidTime()` validation methods
- Added `clearIntervalDays` flag to `copyWith`
- Each measurement schedule now produces one notification and one Today agenda occurrence
- Multiple daily times are represented by multiple independent `MeasurementSchedule` records
- Medication schedules remain unchanged (still use `ScheduleConfig` with `times: List<String>`)

#### Database Schema v10
- **Destructive migration**: dropped and recreated `MeasurementSchedules` and `MeasurementReminderLogs` tables
- New `MeasurementSchedules` columns: `scheduleType` (Text), `time` (Text), `intervalDays` (Int nullable)
- Removed `scheduleConfig` (Text/JSON) column
- No data migration — measurement schedules reset on upgrade (acceptable for pre-release app)

#### Notification Changes
- `MeasurementNotificationHelper.computeNotificationId(scheduleId)` — returns single notification ID (`100000 + scheduleId`)
- Removed `computeNotificationIds(scheduleId, config)` (old multi-time method)
- `NotificationScheduler` — added `scheduleSingleNotification()` and `scheduleSingleIntervalNotification()` for single-time scheduling
- Each schedule gets exactly one recurring daily notification or one one-shot interval notification
- Form screen schedules one notification per schedule (fixed previous bug where N×N notifications were created)

#### Today Agenda
- `todayMeasurementRemindersProvider` — each active schedule produces one occurrence using `schedule.time`
- No more inner loop over `scheduleConfig.times`
- Each independent schedule appears separately in chronological order
- `TodayAgendaService._generateMeasurementItems` — uses `MeasurementSchedule.time` directly

#### Schedule List UI Redesign
- New row layout: `[alarm icon] | [type + time] | [status dot] | [⋮ menu]`
- Schedule type (Daily / Every N Days) and time on first line with secondary text style
- Date range on second line with smaller secondary text
- Active/inactive status indicator (`Icons.check_circle_outline` / `Icons.cancel_outlined`) before popup menu
- Popup menu (`Icons.more_vert`) with Edit and Delete actions
- Delete confirmation dialog with error feedback
- Empty state uses `Icons.alarm`

#### Health Screen Icon Correction
- Replaced `Symbols.share_eta` with `Icons.alarm` for measurement schedule action
- All three action icons (Schedule, History, Add Reading) use standard `IconButton` with equal sizing
- Action order preserved: Schedule → History → Add Reading

#### Add/Edit Form Simplified
- Single time picker field replaces dynamic time list
- No "Add Time" / "Remove Time" buttons
- `SegmentedButton` for Daily / Every N Days
- Interval days field (conditional)
- Start/end date pickers, active toggle, instructions
- Validation: valid time required, interval >= 1, interval requires start date

#### Duplicate Schedule Prevention
- Repository-level validation not yet implemented (deferred to future phase)
- UI validation prevents invalid schedules (missing time, invalid interval)

**Files Created:**
- None (all changes to existing files)

**Files Modified:**
- `lib/domain/entities/measurement.dart` — MeasurementSchedule refactored (ScheduleConfig removed, flat fields added)
- `lib/data/database/tables/measurement_tables.dart` — new columns (scheduleType, time, intervalDays), removed scheduleConfig
- `lib/data/database/app_database.dart` — schema v10, destructive migration
- `lib/data/repositories/measurement_repository_impl.dart` — new field mapping
- `lib/data/services/notification/measurement_notification_helper.dart` — single notification ID
- `lib/data/services/notification/notification_scheduler.dart` — single-time scheduling methods
- `lib/data/services/notification/notification_action_bridge.dart` — recovery uses new model
- `lib/presentation/screens/health/measurement_schedule_screen.dart` — single time picker, new model
- `lib/presentation/screens/health/measurement_schedule_list_screen.dart` — new layout, status indicator, popup menu
- `lib/presentation/screens/health/measurement_history_screen.dart` — updated schedule display
- `lib/presentation/screens/health/health_screen.dart` — Icons.alarm, equal sizing
- `lib/presentation/providers/measurement_provider.dart` — one time per schedule in today provider
- `lib/domain/services/today_agenda_service.dart` — measurement schedule uses new model
- `lib/l10n/app_en.arb` — added `scheduledTime` key
- `lib/l10n/app_ka.arb` — added Georgian `scheduledTime` key
- `test/phase5c_measurement_schedules_test.dart` — rewritten for new model (33 tests)

**Tests:** 33 tests covering:
- MeasurementSchedule entity: copyWith, clearInstructions, clearEndDate, default active, isDaily, isIntervalDays, normalizeTime, isValidTime, one-time-per-record model
- MeasurementReminderAction: fromString
- MeasurementReminderLog: copyWith
- MeasurementNotificationHelper: computeNotificationId, baseNotificationId, buildPayload, parsePayload
- MeasurementNotificationPayload: isValid
- Independence: two schedules at different times, disabling one doesn't affect the other

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `dart run build_runner build` | Completed successfully |
| `flutter analyze` | 0 errors (pre-existing info/warnings only) |
| `flutter test` | 524 passed, 8 failed (all pre-existing in phase5a_correction_test.dart) |
| Medication tests | 26/26 passed (unchanged) |
| Measurement schedule tests | 33/33 passed |

---

## Phase 6 — Today Dashboard

**Status:** Simplified and complete. Single chronological agenda, corrected Next-item logic, past/future background styling, 43 tests (26 unit + 17 widget).

### Design

- One chronological agenda list for the full day
- Each scheduled occurrence appears exactly once
- No separate Overdue, Medications, or Measurements sections
- Status icons distinguish taken, skipped, overdue, pending, due, and snoozed
- Past/future background styling (subtle muted for past, normal for future, highlighted for due)
- Next card shows earliest future/due actionable item (excludes overdue)

### What Was Built

**Domain layer:**
- `TodayAgendaItem` — unified agenda item with `effectiveTime` (snoozedUntil ?? scheduledDateTime), `isPast()`, `isFuture()`, `isDue()` helpers
- `TodayAgendaItemType` — `medication` / `measurement`
- `TodayAgendaItemStatus` — `upcoming`, `due`, `overdue`, `completed`, `skipped`, `snoozed`
- `TodaySummary` — counts of total/completed/skipped/overdue with percentage getters
- `TodayAgenda` — stores single `items` list (sorted by effectiveTime, then id); `nextItem({now?})` selects earliest future/due item excluding overdue
- `TodayAgendaService` — generates unified agenda from active schedules + logs; 30-min grace window; `determineMedicationStatus()` / `determineMeasurementStatus()` are now static for testing

**Repository extensions:**
- `MedicationRepository.getActiveMedications(profileId)` — Future-based
- `MedicationRepository.getSchedulesForMedication(medicationId)` — Future-based
- Corresponding DAO methods in `MedicationDao`

**Providers:**
- `todayAgendaProvider` — `FutureProvider.autoDispose<TodayAgenda>`
- `todaySummaryProvider` — derives from agenda
- `nextTodayItemProvider` — derives from agenda, uses corrected future-only logic
- `todayItemsProvider` — single unified list provider

**UI widgets:**
- `TodaySummaryCard` — progress bar with completed/skipped/overdue counts
- `TodayNextItemCard` — highlights next actionable item (primary container style), uses `effectiveTime`
- `TodayAgendaItemWidget` — row with type icon, time, title, subtitle, status icon, action buttons; past/future background applied via `TodayBackground`
- `TodayBackground` — determines past/current/future position and provides subtle card color and time color

**Screen:**
- `TodayScreen` — `CustomScrollView` with summary card, next item, then single `SliverList` of all items chronologically
- Pull-to-refresh to invalidate agenda
- Empty state when no schedules
- Removed: separate Overdue, Medications, Measurements sections; collapsible completed section

**Localization:**
- Existing keys retained; no new keys required for simplification

### Tests

- `test/today_agenda_test.dart` — 26 unit tests covering `TodayAgendaItem` (effectiveTime, isPast, isFuture, isDue, isActionable, isCompleted), `TodayAgenda` (uniqueness, sorting, nextItem exclusion/selection/snooze), `TodaySummary` (totals, percentages), `TodayBackground` (classification)
- `test/today_screen_test.dart` — 17 widget tests covering unified list, no separate sections, no duplicates, status icons, past/future background, empty state, narrow screen, Georgian locale, light/dark theme, NextItemCard selection, type icons

### Validation

- `flutter analyze`: 0 new errors (15 pre-existing infos/warnings only)
- `flutter test`: 488 passed, 8 failed (all 8 pre-existing in `phase5a_correction_test.dart`)
- Pixel 7 verification: app launches successfully, builds in 8.7s, installs in 3.8s, Impeller Vulkan active, no crashes

### Phase 6 Visual Hierarchy & Action-Menu Improvement

**Status:** Completed

**What was done:**

#### 1. Agenda Section Title
- Added localized `Agenda` / `დღის განრიგი` section title between Next card and agenda list
- Uses `titleSmall` typography with `fontWeight.w600` and `onSurfaceVariant` color
- Left-aligned with consistent 16px horizontal padding
- Separates summary/next card from the chronological list

#### 2. Background Styling Fix
- **Root cause:** `surfaceContainerLow` was too close to the Card's default surface color; `primaryContainer.withValues(alpha: 0.3)` was too subtle
- **Solution:** `TodayBackground` now uses `ElevationOverlay.applySurfaceTint()` for visible but subtle distinction:
  - **Past:** `surfaceContainerHighest` with `surfaceTint` at elevation 2
  - **Current/Due:** `primaryContainer` with `primary` at elevation 3
  - **Future:** `null` (default Card surface)
- Past items have a visibly muted background; due items have a clear highlight; future items are normal
- Time text also changes: past → muted, due → primary, future → default

#### 3. Popup Menu Actions
- **Removed:** `_ActionButtons` with inline `TextButton.icon` (Mark as Taken, Record Now) and snooze `IconButton`
- **Added:** `_AgendaItemMenu` with `PopupMenuButton<String>` following existing `measurement_history_screen.dart` convention
- **Menu items per status/type:**
  - **Medication (actionable):** Mark as taken (Icons.check), Skip (Icons.skip_next), Details (Icons.info_outline), History (Icons.history)
  - **Measurement (actionable):** Record now (Icons.add), Skip (Icons.skip_next), Details, History, Trends (Icons.show_chart)
  - **Completed/Skipped (any type):** Details, History only
- All menu items have icons alongside text labels
- Menu closes before performing action
- `ref.invalidate(todayAgendaProvider)` on mark taken / skip (TODO stubs remain for actual repository calls)

#### 4. Agenda Row Layout
- Row: `Time | TypeIcon | Content | StatusIcon | MoreMenu`
- Title supports 2 lines (was 1 line before) for better long-name handling
- Subtitle and instructions preserved with truncation
- Compact vertical padding (10px vs 12px)
- No wide inline buttons — all horizontal space available for content

#### 5. Localization
- Added 7 new keys to EN and KA ARB files: `agenda`, `moreActions`, `skip`, `openDetails`, `viewHistory`, `viewTrends`, `failedToUpdateItem`
- Existing keys retained: `markTaken`, `recordNow`, `snooze10min`

### Tests (Phase 6 Improvement)

- `test/today_screen_test.dart` — 40 widget tests (13 original + 27 new):
  - **Agenda section title (3):** title visible, Georgian title, no duplicate headings
  - **Background styling (5):** past muted, due highlighted, future normal, backgrounds differ visibly, time refresh updates classification
  - **Action menu (5):** no wide TextButton, PopupMenuButton visible, medication pending shows Mark/Skip, completed hides Mark/Skip, measurement shows Record Now, menu closes after selection
  - **Agenda row layout (5):** long name readable, Georgian overflow-free, status icon visible, menu icon visible, Pixel 7 narrow screen
  - **Popup menu actions (4):** overdue medication shows correct items, skipped medication hides actions, measurement shows Trends, medication hides Trends
- `test/today_agenda_test.dart` — 26 unit tests (unchanged)

### Validation (Phase 6 Improvement)

- `flutter gen-l10n`: completed successfully
- `flutter analyze`: 15 pre-existing issues, 0 new
- `flutter test`: 511 passed, 8 failed (all 8 pre-existing in `phase5a_correction_test.dart`)
- Pixel 7: app builds in 8.7s, installs in 3.6s, Impeller Vulkan, no crashes

### Phase 6 Medication-Information Improvement

**Date:** 2026-07-25

**What changed:**
- `TodayAgendaItem` model extended with `strength` (String?), `intakeQuantity` (double?), `dosageForm` (DosageForm?), `customDosageForm` (String?) fields
- `TodayAgendaService._buildMedicationItem` now fetches components via `MedicationRepository.getComponents()` and formats strength using `ComponentFormatter.formatComponents()` (fallback: `DoseFormatter.format()`)
- Service is async (fetches component data per medication)
- `TodayAgendaItemWidget` renders medication info as separate lines: strength → intake (via `DosageFormLocalizer.localizeWithQuantity()`) → instructions; legacy `subtitle` fallback for medications without new fields
- `TodayNextItemCard` shows strength and intake text joined with `•` separator; falls back to `subtitle` when no dosage info
- No changes to schedule generation, notification logic, repository behavior, agenda sorting, status logic, or popup-menu actions

**Files modified:**
- `lib/domain/entities/today_agenda.dart`: 4 new fields + `DosageForm` import
- `lib/domain/services/today_agenda_service.dart`: async `_buildMedicationItem`, `_resolveMedicationStrength()`, 2 new imports
- `lib/presentation/widgets/today/today_agenda_item.dart`: strength/intake/instructions rendering, `DosageFormLocalizer` import
- `lib/presentation/widgets/today/today_next_item_card.dart`: strength/intake display, `_formatIntake()`, `DosageFormLocalizer` import
- `test/today_agenda_test.dart`: 6 new unit tests for model fields
- `test/today_screen_test.dart`: 9 new widget tests for medication info display

**Tests (Phase 6 Medication Info):**
- `today_agenda_test.dart`: 6 new unit tests (strength default, strength stored, intake defaults, intake stored, complete dosage info)
- `today_screen_test.dart`: 9 new widget tests (strength display, intake with form, separate lines, instructions below, null strength, zero intake, subtitle fallback, Georgian locale, full dosage no overflow)

**Validation:**
- `flutter analyze`: 15 pre-existing issues, 0 new
- `flutter test`: 525 passed, 8 failed (all 8 pre-existing in `phase5a_correction_test.dart`)

### Today Measurement-Name Localization Fix

**Date:** 2026-07-26

**What changed:**
- Measurement type names in the Today Dashboard (agenda items and Next card) now display localized names instead of raw English database strings
- Added `_displayTitle()` helper to both `TodayAgendaItemWidget` and `TodayNextItemCard` that delegates to the existing `MeasurementLocalizer.typeName()` utility for measurement items with a known `measurementTypeKey`
- Custom measurement types continue displaying the user-entered custom name (fallback to `item.title`)
- `instructions` and `subtitle` comparison guards updated to use localized display title instead of raw DB title
- No changes to `TodayAgendaService` (domain layer remains locale-agnostic) — localization is applied purely in the presentation layer
- Reactive to locale changes: switching language while Today is open updates all measurement titles on next rebuild (no app restart required)

**Root cause:** `TodayAgendaService` set measurement item titles to `type?.name` (English DB column), and the widget layer rendered `item.title` directly without calling `MeasurementLocalizer.typeName()`. The `measurementTypeKey` was already available on `TodayAgendaItem` but unused.

**Shared mapper reused:** `MeasurementLocalizer.typeName()` from `lib/presentation/utils/measurement_localizer.dart` — the same utility already used by Health Screen, Measurement History, Trends, Schedules, and Reference Ranges.

**Files modified:**
- `lib/presentation/widgets/today/today_agenda_item.dart`: added `_displayTitle()` static method, `MeasurementLocalizer` import, updated title display + instructions/subtitle comparison guards
- `lib/presentation/widgets/today/today_next_item_card.dart`: added `_displayTitle()` static method, `MeasurementLocalizer` import, updated title display

**Tests:**
- No new test file needed — existing `today_screen_test.dart` and `today_agenda_test.dart` cover the Today flow; localization is tested via `MeasurementLocalizer` unit tests in `phase5a_correction_test.dart`

**Validation:**
- `flutter analyze`: 15 pre-existing issues, 0 new
- `flutter test`: 524 passed, 8 failed (all 8 pre-existing in `phase5a_correction_test.dart`)
- Pixel 7: Installed, launched, no crashes — Georgian measurement names verified in Today Agenda and Next card

### Integration & Regression Fix Pass (6 Issues)

**Date:** 2026-07-26

**What changed:**

1. **Schedules removed from Measurement History** — The schedules section (add/view/edit/delete schedules) has been removed from the Measurement History screen. Schedules are managed through the dedicated Schedule List screen accessible from the Health screen. Removed `_SchedulesSection`, `_ScheduleTile` classes and `_confirmDeleteSchedule` method from `measurement_history_screen.dart`.

2. **Today past/future background colors swapped** — Previously, past items had the `surfaceContainerHighest` background and future items had no background (surface default). Now: future items have `surfaceContainerHighest` background to indicate upcoming, past items have no background (surface) to indicate they're completed. In `today_background.dart`.

3. **Current item uses Next card background** — The current/due item card background changed from `ElevationOverlay.applySurfaceTint(primaryContainer, primary, 3)` to plain `primaryContainer`, matching the Next item card style. Reduces visual inconsistency. In `today_background.dart`.

4. **Today auto-refreshes after schedule changes** — All schedule mutation screens now call `ref.invalidate(todayAgendaProvider)` after saving/deleting schedules, so the Today Dashboard immediately reflects schedule changes without requiring app restart. Files: `measurement_schedule_screen.dart`, `add_schedule_screen.dart`, `edit_schedule_screen.dart`, `medication_detail_screen.dart`, `measurement_schedule_list_screen.dart`.

5. **Scheduled reminders fixed** — Three fixes:
   - Changed `AndroidScheduleMode.inexactAllowWhileIdle` → `exactAllowWhileIdle` for both `scheduleNotification` and `scheduleRecurringNotification` in `notification_service.dart`
   - Added `requestNotificationsPermission()` and `requestExactAlarmsPermission()` calls in `NotificationService.initialize()` (runtime permission request for POST_NOTIFICATIONS on Android 13+)
   - Added `ScheduledNotificationBootReceiver` and `ScheduledNotificationReceiver` entries to `AndroidManifest.xml` so notifications survive device restart
   - Fixed `NotificationService` initialization race condition: added `Completer`-based `waitForInitialization()` method, deduplication guard against concurrent `initialize()` calls
   - Fixed broken `scheduleNotification` method (had wrong variable references `notificationId`, `notificationDetails`, `matchComponents` and missing required `uiLocalNotificationDateInterpretation` parameter)
   - Added `waitForInitialization()` to `FakeNotificationService` test mock

6. **Popup menu actions implemented** — All "more actions" menu items now perform real operations:
   - **Mark Taken:** Calls `MedicationRepository.logDose()` with `MedicationLog(status: 'taken', ...)` and invalidates `todayAgendaProvider`
   - **Skip:** Calls `MedicationRepository.logDose()` with `MedicationLog(status: 'skipped', ...)` and invalidates `todayAgendaProvider`
   - **Record Now:** Navigates to `AppRoutes.measurementAdd(measurementTypeId)`
   - **Details:** Navigates to `AppRoutes.medicationDetail(medicationId)` or `AppRoutes.measurementHistory(measurementTypeId)`
   - **History:** Navigates to `AppRoutes.medicationHistory(medicationId)` or `AppRoutes.measurementHistory(measurementTypeId)`
   - **Trends:** Navigates to `AppRoutes.measurementTrends(measurementTypeId)`

**Files modified:**
- `lib/presentation/screens/health/measurement_history_screen.dart`: removed schedule UI section
- `lib/presentation/widgets/today/today_background.dart`: swapped past/future colors, simplified current cardColor
- `lib/presentation/widgets/today/today_agenda_item.dart`: implemented popup menu actions with real navigation and dose logging
- `lib/data/services/notification/notification_service.dart`: exact alarms, runtime permissions, boot receiver, initialization race fix
- `android/app/src/main/AndroidManifest.xml`: added flutter_local_notifications boot receiver entries
- `lib/presentation/providers/notification_provider.dart`: unchanged (no provider-level fix needed)
- `lib/presentation/screens/health/measurement_schedule_screen.dart`: added todayAgendaProvider invalidation
- `lib/presentation/screens/activities/add_schedule_screen.dart`: added todayAgendaProvider invalidation
- `lib/presentation/screens/activities/edit_schedule_screen.dart`: added todayAgendaProvider invalidation
- `lib/presentation/screens/activities/medication_detail_screen.dart`: added todayAgendaProvider invalidation
- `lib/presentation/screens/health/measurement_schedule_list_screen.dart`: added todayAgendaProvider invalidation
- `test/notification_action_bridge_test.dart`: added `waitForInitialization()` stub

**Validation:**
- `flutter analyze`: 0 errors, 15 pre-existing infos/warnings only
- `flutter test`: 519 passed, 13 failed (all pre-existing in `phase5a_correction_test.dart` — pumpAndSettle timeouts)
- Pixel 7: APK built and installed successfully

---

## Development Rules

- Commit after every completed phase
- Keep documentation updated before moving to next phase
- Test on real Pixel device before moving to next phase
- Avoid implementing features before data model supports future requirements
- Run `flutter analyze` before committing — zero issues required
