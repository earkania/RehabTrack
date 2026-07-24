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
| Health | `/health` | HealthScreen | Placeholder — icon + "No data yet" |
| Activities | `/activities` | MedicationListScreen | Medication list — shows empty state or medication cards |
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
- Added routes for `/activities/medication/add`, `/activities/medication/:id`, `/activities/medication/:id/edit`
- Routes are outside ShellRoute (no bottom nav during detail/form screens)
- `int.tryParse` safety on all `:id` parameters with `_InvalidRouteScreen` for invalid IDs
- `ScaffoldWithNavBar` updated: Activities tab now highlights for all `/activities/medication/*` routes

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
- **Measurements screen:** Shows measurement type cards with `Symbols.weight` icon and `IconButton(Icons.add_circle_outline)` for add reading
- **Measurement entry/edit/history screens:** Generic form-driven UI for all measurement types, using `MeasurementLocalizer` for type names and field labels; Measurement History AppBar uses same `IconButton(Icons.add_circle_outline)` for add reading
- **Navigation:** Bottom nav uses custom `_CenteredNavigationBar` (replaces Flutter's `NavigationBar`) with only-selected labels, centered wrapped text (`TextAlign.center`, `maxLines: 2`), `monitor_heart_outlined` / `medication_outlined` icons
- **Routes:** `/health/measurement/:typeId/add`, `/health/measurement/:typeId/history`, `/health/measurement/record/:recordId/edit`
- **Localization corrections:** Georgian Blood Pressure → `არტერიული წნევა` (was `სისხლის წნევა`), `measuredAt` → `გაზომილია` (was `გაზომულია`), duplicate `viewHistory` key removed, new keys: `addReadingTooltip`, `pulseLabel`
- **Dependencies:** Added `material_symbols_icons: ^4.2951.0` for `Symbols.weight`
- **Tests:** 193 tests — `phase5a_correction_test.dart` (23), `measurement_formatter_test.dart` (16), `measurement_validator_test.dart` (16), `measurement_seed_test.dart` (23), `measurement_health_screen_test.dart` (3), plus existing widget/form tests

**Root cause of duplicates:** The v3→v4 migration called `_seedMeasurementTypesV4()` which looked up existing types by `key`. But old types from v1-v3 had `NULL` keys (the column didn't exist before v4). So it never found them and inserted NEW types with keys, creating duplicates alongside the old fieldless types.

**Root cause of Heart Rate duplication:** An older system type from pre-v4 that had NULL key and was never cleaned up, appearing alongside the new canonical "Pulse" type.

**Migration strategy (v5):**
1. Find all system types with same name where one has a key and one doesn't → deactivate the keyless one, migrate its records to the keyed canonical type
2. Find active "Heart Rate" type → migrate its records to "Pulse" (deduplicating by timestamp+profile), deactivate it
3. Ensure all 6 canonical keyed types have field definitions (seed fields if missing)

**Test Results:** 193/193 passing (flutter test), 1 pre-existing info lint (`prefer_initializing_formals` in `notification_action_bridge.dart:19`)

---

## Development Rules

- Commit after every completed phase
- Keep documentation updated before moving to next phase
- Test on real Pixel device before moving to next phase
- Avoid implementing features before data model supports future requirements
- Run `flutter analyze` before committing — zero issues required
