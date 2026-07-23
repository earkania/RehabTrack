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

## Next Planned Phase

### Phase 4B — Step 4: Medication Alternatives

**Status:** Completed

**What was done:**

**Providers Added (`medication_provider.dart`):**
- `medicationAlternativesProvider(medicationId)` — `StreamProvider.autoDispose.family<List<MedicationAlternative>, int>` for alternatives list
- `medicationAlternativeProvider(alternativeId)` — `FutureProvider.autoDispose.family<MedicationAlternative?, int>` for single alternative lookup

**Routing Updated (`app_router.dart`):**
- Added `/activities/medication/:id/alternative/add` route
- Added `/activities/medication/:id/alternative/:alternativeId/edit` route
- Routes parse both `id` and `alternativeId` parameters with `int.tryParse`
- Invalid IDs show `_InvalidRouteScreen`
- New imports for `AddAlternativeScreen` and `EditAlternativeScreen`

**MedicationAlternativeCard Widget (`medication_alternative_card.dart`):**
- Displays alternative name, dose (e.g., "5 mg"), doctor approved badge, notes preview
- Reusable across list views and detail screens
- Optional `onTap` callback for navigation

**MedicationAlternativeForm Widget (`medication_alternative_form.dart`):**
- Shared form for both add and edit screens
- Fields: name (required), dose amount (optional, numeric), dose unit (optional), doctor approved (switch), notes (optional)
- Validation: name required, dose must be positive when entered
- `MedicationAlternativeFormData` data class with `fromAlternative` factory
- Trims whitespace on save

**AddAlternativeScreen (`add_alternative_screen.dart`):**
- `ConsumerStatefulWidget` using shared form
- Verifies medication exists before save
- Saves through `MedicationRepository.createAlternative()`
- Returns to MedicationDetailScreen after success

**EditAlternativeScreen (`edit_alternative_screen.dart`):**
- Loads alternative using `medicationAlternativeProvider`
- Verifies alternative belongs to medication via `medicationId` check
- Saves through `MedicationRepository.updateAlternative()`
- Delete action in AppBar with confirmation dialog
- Delete through `MedicationRepository.deleteAlternative()`

**MedicationDetailScreen Updated:**
- Added `medicationAlternativesProvider(medicationId)` watch
- Alternatives section with "Add Alternative" button (only for active medications)
- Uses `MedicationAlternativeCard` for each alternative
- Uses `EmptyState` widget when no alternatives exist
- Tapping a card navigates to EditAlternativeScreen
- Delete does not affect Medication, MedicationSchedule, or MedicationLog

**Localization Keys Added:**
- `editAlternative`, `deleteAlternative`, `deleteAlternativeConfirmation`
- `alternativeAdded`, `alternativeUpdated`, `alternativeDeleted`
- `noAlternatives`, `noAlternativesDescription`, `alternativesSection`
- `genericSubstitute`, `confirmDeleteAlternative`
- Added to both `app_en.arb` and `app_ka.arb`
- Fixed duplicate `noSchedulesYet` key in both ARB files

**Files Created:**
- `lib/presentation/widgets/medication/medication_alternative_card.dart`
- `lib/presentation/widgets/medication/medication_alternative_form.dart`
- `lib/presentation/screens/activities/add_alternative_screen.dart`
- `lib/presentation/screens/activities/edit_alternative_screen.dart`
- `test/alternative_test.dart`

**Files Modified:**
- `lib/presentation/providers/medication_provider.dart`
- `lib/core/router/app_router.dart`
- `lib/presentation/screens/activities/medication_detail_screen.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ka.arb`
- `test/schedule_test.dart` (fixed unused variable warning)

**Tests:**
- 14 widget tests covering MedicationAlternativeCard, MedicationAlternativeForm, and data classes
- Tests: rendering name, dose, doctor approved badge, notes preview, onTap callback
- Tests: form validation (empty name, invalid dose), save with valid data, pre-populate fields, trim whitespace
- Tests: `fromAlternative` factory with all fields and with null optional fields

**Validation Results:**
| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (39/39) |

**Architecture Verification:**
- All CRUD operations go through `MedicationRepository`
- No direct DAO access from presentation layer
- No notification service access from presentation layer
- Delete does not affect medication, schedules, or logs
- Shared form widget used for both add and edit screens

**Validation Rules:**
- Name: required, trimmed
- Dose Amount: optional, must be positive when entered
- Dose Unit: optional, free text
- Doctor Approved: boolean switch, defaults to false
- Notes: optional, trimmed

**Known Limitations:**
- No medication interaction checking (by design — deferred)
- No automatic alternative suggestions (by design — user-entered only)

### Phase 4B — Step 5: Medication History & Adherence

**Status:** Completed

**What was done:**

**HistoryPeriod Domain Entity:**
- Created `lib/domain/entities/history_period.dart` — enum: `last7Days`, `last30Days`, `allTime`

**Providers Added (`medication_provider.dart`):**
- `medicationAllLogsProvider(scheduleId)` — `StreamProvider.autoDispose.family` for all logs of a schedule
- `medicationAdherenceStatsProvider(scheduleId)` — computes `AdherenceStats` from logs

**StatusChip Widget (`status_chip.dart`):**
- Material 3 chip showing medication log status (taken/skipped/missed/pending)
- Color-coded by status, reusable across screens

**MedicationHistoryScreen (`medication_history_screen.dart`):**
- Period selector (last 7 days, last 30 days, all time)
- Adherence summary with percentage and counts
- Log list with `StatusChip` for each entry
- Manual dose logging dialog

**MedicationDetailScreen Updated:**
- Added history section with preview and navigation button
- `/activities/medication/:id/history` route added

**Localization Keys Added:**
- 15 keys each for English and Georgian (history labels, status text, period options)

**Files Created:**
- `lib/domain/entities/history_period.dart`
- `lib/presentation/widgets/medication/status_chip.dart`
- `lib/presentation/screens/activities/medication_history_screen.dart`

**Files Modified:**
- `lib/presentation/providers/medication_provider.dart`
- `lib/presentation/screens/activities/medication_detail_screen.dart`
- `lib/core/router/app_router.dart`
- `lib/l10n/app_en.arb`, `lib/l10n/app_ka.arb`

**Tests:**
- 12 tests covering HistoryPeriod, StatusChip rendering, adherence stats computation

**Validation Results:**
| Check | Result |
|---|---|
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (51/51) |

### Phase 4B — Step 6: Notification Action Integration

**Status:** Completed

**What was done:**

**NotificationActionBridge (`notification_action_bridge.dart`):**
- Connects notification infrastructure to medication module
- `initialize(profileId)` — registers action callback, runs schedule recovery
- Action handlers: `Taken` (logs dose), `Skipped` (logs skipped), `Snooze` (reschedules 10 min)
- Static helpers: `parsePayload`, `computeNotificationIds`, `buildNotificationBody`
- Recovery: builds `ScheduleRecoveryEntry` list from active medications/schedules

**Providers Added (`notification_provider.dart`):**
- `notificationInitializerProvider` — eagerly initializes bridge and runs recovery at startup

**Startup Initialization (`main.dart`):**
- `ProviderContainer` reads `notificationInitializerProvider` before `runApp`
- Ensures notification callbacks registered before any notification can be received

**Action Flow:**
1. User taps notification action → `NotificationService` receives platform callback
2. Bridge `_handleAction` parses payload, dispatches to handler
3. Taken/Skip: creates `MedicationLog` with appropriate status
4. Snooze: fetches schedule/medication, reschedules notification for +10 minutes

**Schedule Recovery:**
- On app startup, bridge loads all active medications and schedules
- Builds `ScheduleRecoveryEntry` list with correct notification IDs per schedule type
- `ScheduleRecoveryService.recoverAllSchedules` restores missing notifications

**Files Created:**
- `lib/data/services/notification/notification_action_bridge.dart`
- `test/notification_action_bridge_test.dart`

**Files Modified:**
- `lib/presentation/providers/notification_provider.dart`
- `lib/main.dart`

**Tests:**
- 22 tests covering payload parsing, notification ID computation, notification body building, action handlers (taken/skipped/snooze), schedule recovery

**Validation Results:**
| Check | Result |
|---|---|
| `flutter analyze` | Passed (3 info lints — private field initializing formals) |
| `flutter test` | Passed (73/73) |

**Architecture Verification:**
- Bridge uses `MedicationRepository` (not DAOs) for all data access
- `NotificationActionCallback` typedef followed
- No UI dependency in bridge
- Provider-based initialization follows existing patterns

## Development Rules

- Commit after every completed phase
- Keep documentation updated before moving to next phase
- Test on real Pixel device before moving to next phase
- Avoid implementing features before data model supports future requirements
- Run `flutter analyze` before committing — zero issues required
