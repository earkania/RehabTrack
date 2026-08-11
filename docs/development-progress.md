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

### Phase 7B — Reminder Reliability & Notification Corrections

**Status:** Completed — all features verified on Pixel 7

**What was done:**

#### Defect Fixes

**Notification Action IDs:**
- Changed from generic `action_taken`, `action_skipped`, `action_snoozed`, `action_recordNow` to stable identifiers:
  - `medication_mark_taken`, `medication_skip`, `medication_snooze`
  - `measurement_record_now`, `measurement_skip`, `measurement_snooze`
- Action type enum updated to match: `medicationMarkTaken`, `medicationSkip`, `medicationSnooze`, etc.

**Test Reminder Differentiation:**
- Medication test: title = "Test medication reminder", body = "This is a test of medication reminder alerts."
- Measurement test: title = "Test measurement reminder", body = "This is a test of measurement reminder alerts."
- Different IDs (999999 medication, 999998 measurement) on appropriate channels

**Medication Title Formatting:**
- Title now includes strength when available: `"Clopidogrel 75 mg"` instead of just `"Clopidogrel"`
- Strength derived from `medicationComponents.doseAmount` + `medicationComponents.doseUnit` (NOT medication-level fields, which are always null)
- Falls back to name-only when components absent

**Background Action Processing:**
- `PendingActionStore` written by `_onBackgroundNotificationResponse` is now consumed on app startup
- `NotificationActionBridge.processPendingActions()` called at initialization
- All action handlers are async with proper `await`

**Configurable Settings:**
- `showPatientNameInNotifications` (default: true) — controls patient name visibility in notification body
- `showDetailsOnLockScreen` (default: true) — controls lock-screen notification visibility (uses `NotificationVisibility`)

**Lock Screen Privacy:**
- `NotificationService.scheduleNotification()` and `showNotification()` accept `NotificationVisibility` parameter
- When `showDetailsOnLockScreen` is disabled, notification uses `NotificationVisibility.secret`

**Idempotency & Action Results:**
- All medication actions check for existing logs before creating duplicates
- Structured `ActionResult` enum: success, alreadyCompleted, invalidPayload, entityNotFound, databaseError, unexpectedError
- Snooze preserves original occurrence identity, cancels current notification, schedules Android-backed alarm

**Timezone Handling:**
- Timezone detected from Android `TimeZone.getDefault().id` (returns IANA name like "Asia/Tbilisi")
- `tz.local` set correctly in `NotificationService.initialize()`
- All scheduling uses `TZDateTime` with `tz.local` — no double conversion

**Notification Channel Updates:**
- Only 2 channels remain: `rehabtrack_medications` and `rehabtrack_measurements` (General removed)
- Test notifications now use the appropriate channel (medication vs measurement)

#### Files Modified

| File | Changes |
|---|---|
| `notification_action_handler.dart` | New enum values for stable action IDs |
| `notification_service.dart` | Updated action IDs, added `visibility` param, updated `_parseActionType` |
| `notification_scheduler.dart` | Added `visibility` support, `NotificationVisibility` import |
| `notification_action_bridge.dart` | Rewritten: async handlers, pending action processing, idempotency, Result type, new action types |
| `reminder_content_formatter.dart` | Added `_formatMedicationName` with strength, `showProfileName` param, `medicationSubtext` |
| `reminder_payload.dart` | Added `notificationId` field, version bump to 2 |
| `app_constants.dart` | Added `showPatientNameInNotificationsKey`, `showDetailsOnLockScreenKey` |
| `reminder_settings_provider.dart` | Added `showPatientNameInNotificationsProvider`, `showDetailsOnLockScreenProvider` |
| `notification_provider.dart` | Added `processPendingActions()` call, `showProfileName`/`showDetailsOnLockScreen` injections |
| `settings_screen.dart` | Fixed test reminders differentiation, added Show patient name / Show details on lock screen toggles |
| `medication_repository_impl.dart` | No changes (already used correct API) |

#### Tests Updated

- `notification_action_bridge_test.dart` — Updated action types, added medicationTitle tests, profile visibility tests
- `settings_grace_period_test.dart` — Added `visibility` param to fake service

#### Validation Results

| Check | Result |
|---|---|
| `flutter analyze` | Passed (5 info lints — pre-existing) |
| `flutter test` | Passed (740/740; 1 pre-existing failure in today_screen_test.dart) |

#### Round 2 — Action Button Fix, Strength from Components, Correct Occurrence Times (2026-07-30)

**Date:** 2026-07-30

**Root Causes Discovered:**

1. **Medication strength never appeared:** `MedicationFormData` and `add_medication_screen.dart`/`edit_medication_screen.dart` save `doseAmount`/`doseUnit` to `MedicationComponents`, NOT to `Medication` entity fields. `Medication.doseAmount` is always null. The formatter checked medication-level fields and always fell back to name-only.

2. **Notification action buttons did nothing:** All actions used `showsUserInterface: false`, routing taps through `ActionBroadcastReceiver` → background isolate → `PendingActionStore` (JSON file). The foreground callback `_onNotificationResponse` was NEVER invoked for action buttons. `PendingActionStore` was only consumed at app startup via `processPendingActions()` — actions performed while app running sat in queue until next restart.

3. **Wrong occurrence time in payload:** `_scheduleNotifications` passed `DateTime.now()` as `scheduledTime` for ALL occurrences, so every notification body showed schedule-creation time.

**Fixes:**

- **Action buttons:** Changed all `_medicationActions` and `_measurementActions` from `showsUserInterface: false` to `showsUserInterface: true`. Now taps launch Activity → `onNewIntent` → `didReceiveNotificationResponse` → foreground callback → immediate processing.

- **Terminated-process handling:** Added `bridge.processAppLaunchAction()` using `getNotificationAppLaunchDetails()` with `_actionIdToTypeName` mapper. Called in `notificationInitializerProvider`.

- **Per-occurrence payloads:** `NotificationScheduler.scheduleOccurrences()` now accepts optional `perOccurrencePayload` callback — generates unique payload with correct `occurrenceTime` per occurrence. Updated `medication_repository_impl.dart`, `measurement_repository_impl.dart`, `measurement_schedule_screen.dart`, `ScheduleRecoveryService`/`ScheduleRecoveryEntry`.

- **Strength from components:** `_scheduleNotifications` in `medication_repository_impl.dart` now fetches `MedicationComponents` when `Medication.doseAmount` is null, passes extracted `doseAmount`/`doseUnit` to formatter. Same for `_recoverMedicationSchedules` and `_handleMedicationSnooze` in bridge.

- **Formatter refactored:** `ReminderContentFormatter._formatMedicationName()` changed from taking `Medication` object to explicit `name`, `doseAmount`, `doseUnit` parameters. `medicationTitle()` accepts optional `doseAmount`/`doseUnit`.

- **Removed "Scheduled for HH:MM":** Removed from `medicationBody()` — cannot be formatted statically per-occurrence with the single-payload architecture; Android notification timestamp provides this context.

- **Diagnostic logging:** Added `debugPrint` calls in foreground/background callbacks, action dispatch, and medication scheduling (remove after verification).

**Files Modified (Round 2):**

| File | Changes |
|---|---|
| `notification_service.dart` | `showsUserInterface: true` on all actions; debug logging |
| `notification_action_bridge.dart` | `processAppLaunchAction()`, `_actionIdToTypeName`, components fetch for dose in recovery/snooze |
| `notification_scheduler.dart` | `perOccurrencePayload` optional callback param |
| `reminder_content_formatter.dart` | `_formatMedicationName` takes name/doseAmount/doseUnit params; `medicationTitle` optional dose params; removed "Scheduled for" |
| `medication_repository_impl.dart` | Fetches components for dose; uses `perOccurrencePayload` callback |
| `measurement_repository_impl.dart` | Uses `perOccurrencePayload` callback |
| `measurement_schedule_screen.dart` | Uses `perOccurrencePayload` callback |
| `schedule_recovery_service.dart` | `ScheduleRecoveryEntry` supports `perOccurrencePayload` callback |
| `notification_provider.dart` | Calls `bridge.processAppLaunchAction()` |

**Validation Results:**

| Check | Result |
|---|---|
| `flutter analyze` | 5 info-level only (pre-existing `prefer_initializing_formals`) |
| `flutter test` (notification bridge) | 18/18 passed |
| `flutter test` (all) | 741 total; 14 failing (pre-existing, unrelated — `daily_agenda_test.dart`, `popup_dismissal_test.dart`) |

**Pixel 7 verification results (Round 2 + Round 3):**

| Test | Status |
|---|---|
| Notification title shows strength | ✅ Verified |
| Tap Mark as Taken → Today updates immediately | ✅ Verified |
| Tap Skip → Today updates immediately | ✅ Verified |
| Medication Snooze → notification reappears at configured time | ✅ Verified |
| Measurement Record Now → opens entry form | ✅ Verified |
| Measurement Skip → Today updates immediately | ✅ Verified |
| Measurement Snooze → notification reappears at configured time | ✅ Verified |
| Back navigation from Record Now form | ✅ Fixed — `go(AppRoutes.home)` then `push()` |
| Status not marked completed until after successful save | ✅ Fixed — `RecordNowExtra` passed as route extra |
| Temporary debugPrint calls removed | ✅ Done |

**Known issue (resolved):** After tapping a notification action, the Today screen showed stale data until manual pull-to-refresh. Root cause: `dailyAgendaProvider` is a `FutureProvider` that doesn't react to DB changes. The bridge processed actions via `_executeAction` and wrote to DB but never notified the provider layer. Fixed by adding `onActionProcessed` callback to bridge — called after every dispatched action — wired to `ref.invalidate(todayAgendaProvider)` at the provider level. Also invalidates explicitly in `notificationInitializerProvider` after processing pending/launch actions during initialization.

#### Round 3 — Measurement Action Corrections & Cleanup (2026-07-31)

**Changes:**
- **Record Now no longer marks completed prematurely:** `_handleMeasurementRecordNow` now returns `ActionResult.success` without touching the DB — the measurement entry form handles completion via `_completeReminder()` on successful save
- **Navigation uses `go()` then `push()`:** Record Now navigates to Today first (`go(AppRoutes.home)`) then pushes the entry form so the user can press back to return
- **`RecordNowExtra` passed as route extra:** The `onActionProcessed` callback creates `RecordNowExtra` from payload's `scheduleId` and `occurrenceTime`, passed via `go(push(..., extra: extra))` so the entry form can mark the correct reminder
- **Diagnostic `debugPrint` removed:** All 14 temporary debugPrint calls added in Round 2 removed from `notification_service.dart` (8) and `notification_action_bridge.dart` (6)

**Files Modified (Round 3):**
| File | Changes |
|---|---|
| `notification_action_bridge.dart` | Removed Record Now DB writes; removed temporary debugPrint |
| `notification_provider.dart` | Passes `RecordNowExtra` as route extra; uses `go()` then `push()` |
| `notification_service.dart` | Removed temporary debugPrint |
| `docs/development-progress.md` | Updated status and test results |

**Validation Results:**
| Check | Result |
|---|---|
| `flutter analyze` | 5 info-level only (pre-existing) |
| `flutter test` (notification bridge) | 18/18 passed |
| Pixel 7 — Medication Taken ✅ | Updates immediately, navigates to Today |
| Pixel 7 — Medication Skip ✅ | Updates immediately, navigates to Today |
| Pixel 7 — Medication Snooze ✅ | Reappears at configured time |
| Pixel 7 — Measurement Record Now ✅ | Opens entry form, back returns to Today, status updated only after successful save |
| Pixel 7 — Measurement Skip ✅ | Updates immediately |
| Pixel 7 — Measurement Snooze ✅ | Reappears at configured time |

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

### Today Popup-Menu Actions Regression Fix

**Date:** 2026-07-26

**Root cause of blank-screen issue:** `_AgendaItemMenu._handleAction()` called `Navigator.of(context).pop()` on line 322, but `PopupMenuButton.onSelected` is invoked **after** the popup overlay has already been dismissed by the framework. The `.pop()` was actually popping the shell navigator's current route (Today screen), removing it from the stack and leaving a blank Scaffold with only the bottom nav bar.

**Additional root causes found:**
1. **Measurement skip silently broken** — `_skip()` checked `item.medicationId != null`, which is always `null` for measurement items, so measurement skip silently returned without doing anything.
2. **No error feedback** when actions failed.
3. **No duplicate-tap prevention** while an async action was in flight.
4. **No `mounted` check** after async operations before using `BuildContext`.

**Fixes applied:**

1. **Removed `Navigator.of(context).pop()`** — PopupMenuButton already handles dismissing its own overlay before calling `onSelected`. No manual pop needed.
2. **Converted `_AgendaItemMenu` from `ConsumerWidget` to `ConsumerStatefulWidget`** — Added `_isProcessing` state to prevent duplicate taps while an async action is running. `onSelected` is set to `null` while processing.
3. **Fixed `_skip` to handle both medication and measurement items** — Medication skip uses `MedicationRepository.logDose()` with `status: 'skipped'`. Measurement skip uses `MeasurementRepository.logReminder()` with `MeasurementReminderAction.skipped`.
4. **Added `mounted` checks** after every `await` before accessing `BuildContext` or `ref`.
5. **Added error feedback** via `ScaffoldMessenger.showSnackBar()` with localized `actionFailed` message on exceptions.
6. **Added `measurement.dart` import** for `MeasurementReminderLog` and `MeasurementReminderAction`.
7. **Added `actionFailed` localization key** to `app_en.arb` ("Could not complete action") and `app_ka.arb` ("მოქმედების შესრულება ვერ მოხერხდა").
8. **Fixed stale background styling tests** — Updated 5 tests that expected old past/future color assignments to match the current (swapped) behavior.

**Identifier analysis:**
- `TodayAgendaItem.sourceScheduleId` is the correct schedule ID for both medication and measurement items (set from `MedicationSchedule.id` and `MeasurementSchedule.id` respectively). This is used correctly as `MedicationLog.medicationScheduleId` and `MeasurementReminderLog.measurementScheduleId`.
- `TodayAgendaItem.medicationId` is the `Medication.id` entity key, used for navigation to `AppRoutes.medicationDetail(medicationId)` and `AppRoutes.medicationHistory(medicationId)`.
- `TodayAgendaItem.measurementTypeId` is the `MeasurementType.id` entity key, used for navigation to `AppRoutes.measurementAdd(typeId)`, `AppRoutes.measurementHistory(typeId)`, and `AppRoutes.measurementTrends(typeId)`.
- No route receives a schedule ID where it expects an entity ID.

**Navigation approach:**
- Popup menu closes automatically via PopupMenuButton's built-in behavior (no manual `Navigator.pop`)
- `context.push()` used for all navigation (preserves Today in the stack)
- `context.go()` never used from popup actions
- Invalid/missing IDs silently return without navigating (safe no-op)
- All routes use canonical paths defined in `AppRoutes`, no old `/activities` or `/health` paths

**Files modified:**
- `lib/presentation/widgets/today/today_agenda_item.dart`: rewrote `_AgendaItemMenu` — removed `Navigator.pop`, added `ConsumerStatefulWidget`, fixed measurement skip, added mounted checks, error feedback, duplicate-tap prevention
- `lib/l10n/app_en.arb`: added `actionFailed` key
- `lib/l10n/app_ka.arb`: added `actionFailed` key
- `test/today_screen_test.dart`: added 13 new popup action tests, fixed 5 stale background styling tests, added GoRouter-aware test wrapper `_wrapWithGoRouter()`

**Tests added (13 new):**
1. `menu closes after tapping Details (no blank screen)` — verifies Details navigates to Medication Detail screen
2. `menu closes after tapping History` — verifies History navigates to Medication History screen
3. `measurement menu closes after tapping Trends` — verifies Trends navigates to Measurement Trends screen
4. `measurement menu closes after tapping Record Now` — verifies Record Now navigates to Add Reading screen
5. `medication item has medicationId for navigation` — verifies correct ID fields
6. `measurement item has measurementTypeId for navigation` — verifies correct ID fields
7. `medication due item shows Mark as Taken and Skip` — verifies correct menu items for due medication
8. `measurement due item shows Record Now and Skip` — verifies correct menu items for due measurement
9. `no old route paths used in agenda item` — verifies no `/health` or `/activities` text
10. `sourceScheduleId is the schedule ID not the entity ID` — verifies schedule vs entity ID separation
11. `invalid medicationId does not crash` — verifies null medicationId is handled safely
12. `invalid measurementTypeId does not crash` — verifies null measurementTypeId is handled safely
13. `snoozed medication shows Mark as Taken and Skip` — verifies snoozed status is actionable
14. `overdue measurement shows Record Now and Skip` — verifies overdue measurement is actionable
15. `menu does not allow duplicate tap during processing` — verifies _isProcessing guard

**Validation:**
- `flutter analyze`: 0 errors, 17 pre-existing infos/warnings only
- `flutter test`: 539 passed, 8 failed (all pre-existing in `phase5a_correction_test.dart` — pumpAndSettle timeouts)
- Pixel 7: APK built, installed, launched — no crashes in logcat

---

### Phase 6D — Scheduled Action Refinement

**Status:** Completed

**What was done:**

**Repository layer — occurrence-based methods:**
- `MedicationDao.getLogForOccurrence(scheduleId, scheduledTime)` — find existing log by schedule+time
- `MedicationDao.deleteLogForOccurrence(scheduleId, scheduledTime)` — delete log by schedule+time (for Reset to Pending)
- `MeasurementDao.deleteReminderLogForOccurrence(scheduleId, scheduledTime)` — delete reminder log by schedule+time
- `MedicationRepository.getLogForOccurrence()`, `deleteLogForOccurrence()` — domain interface
- `MeasurementRepository.deleteReminderLogForOccurrence()` — domain interface
- `MedicationRepositoryImpl` and `MeasurementRepositoryImpl` — implementations

**Popup menu restructure — measurement:**
- Actionable (upcoming/due/overdue/snoozed): Record Now, Skip, Schedules, History, Trends
- Completed/skipped: Reset to Pending, Schedules, History, Trends
- "Details" replaced by "Schedules" — navigates to `MeasurementScheduleListScreen`
- `RecordNowExtra` class created to carry occurrence context through GoRouter extra

**Popup menu restructure — medication:**
- Actionable (upcoming/due/overdue/snoozed): Mark as Taken, Skip, Details, History
- Completed: Change to Skipped, Reset to Pending, Details, History
- Skipped: Change to Taken, Reset to Pending, Details, History

**Status correction — medication:**
- `_changeStatus()` — updates existing log status or creates new log with new status
- `_resetToPending()` — deletes log for occurrence, reverting item to pending state

**Reset to Pending — measurement:**
- `_resetToPending()` — deletes `MeasurementReminderLog` for the occurrence via `deleteReminderLogForOccurrence()`

**Record Now context — measurement:**
- `RecordNowExtra` class carries `scheduledOccurrenceTime` and `reminderScheduleId`
- `_recordNow()` passes `RecordNowExtra` via `context.push(..., extra: extra)`
- Router extracts `state.extra as RecordNowExtra?` and passes to `MeasurementEntryScreen`
- `MeasurementEntryScreen` accepts optional `recordNowExtra` parameter
- `_completeReminder()` — on save, marks `MeasurementReminderLog` as `completed` (updates existing or creates new)

**All popup menu Rows use `mainAxisSize: MainAxisSize.min`** to prevent overflow on narrow screens, with `Flexible` + `TextOverflow.ellipsis` on longer labels.

**Localization:**
- `changeToSkipped` / `changeToTaken` / `resetToPending` — added to both `app_en.arb` and `app_ka.arb`

**Tests updated/added (4 new, 5 updated):**
- Updated: completed medication, skipped medication, measurement item, measurement due, overdue measurement — all now check for new menu items (Schedules, Reset to Pending, Change to Skipped/Taken)
- New: `completed measurement shows Reset to Pending and Schedules`
- New: `skipped measurement shows Reset to Pending and Schedules`
- New: `completed medication shows Change to Skipped and Reset to Pending`
- New: `skipped medication shows Change to Taken and Reset to Pending`

**Files modified:**
- `lib/data/database/daos/medication_dao.dart` — added `getLogForOccurrence`, `deleteLogForOccurrence`
- `lib/data/database/daos/measurement_dao.dart` — added `deleteReminderLogForOccurrence`
- `lib/domain/repositories/medication_repository.dart` — added interface methods
- `lib/domain/repositories/measurement_repository.dart` — added `deleteReminderLogForOccurrence`
- `lib/data/repositories/medication_repository_impl.dart` — implemented new methods
- `lib/data/repositories/measurement_repository_impl.dart` — implemented new method
- `lib/presentation/widgets/today/today_agenda_item.dart` — restructured popup menus, added status correction and reset actions
- `lib/core/router/app_routes.dart` — added `RecordNowExtra` class
- `lib/core/router/app_router.dart` — passes `RecordNowExtra` to `MeasurementEntryScreen`
- `lib/presentation/screens/health/measurement_entry_screen.dart` — accepts `recordNowExtra`, calls `_completeReminder()` on save
- `lib/l10n/app_en.arb` — added 3 keys
- `lib/l10n/app_ka.arb` — added 3 keys
- `test/today_screen_test.dart` — 4 new tests, 5 updated tests
- `test/notification_action_bridge_test.dart` — added missing mock methods

**Validation:**
- `flutter analyze`: 0 errors, 17 pre-existing infos/warnings only
- `flutter test`: 543 passed, 8 failed (all pre-existing in `phase5a_correction_test.dart` — pumpAndSettle timeouts)
- APK built successfully (Pixel 7 not connected for device verification)

---

### Phase 6D Fix Pass — Popup Menu Dismissal on Tab Switch

**Status:** Completed

**Root cause:** `PopupMenuButton` pushes a `PopupRoute` onto the shell navigator (`shellNavigatorKey`). GoRouter's `context.go()` only updates matched routes — it does not pop modal routes like `PopupRoute`. So when `_onItemTapped` called `context.go(...)`, the popup stayed visible even though the shell content changed.

**Fix in `lib/core/router/app_router.dart`:**

```dart
void _onItemTapped(BuildContext context, int index) {
  // Dismiss any open popup menu before switching tabs.
  final navigator = shellNavigatorKey.currentState;
  if (navigator != null) {
    navigator.popUntil((route) => route is! PopupRoute);
  }
  switch (index) { ... }
}
```

**Also:** Made `rootNavigatorKey` and `shellNavigatorKey` public (removed underscore prefix) to enable testing. No behavior change — only accessibility from test code.

**Tests added (`test/popup_dismissal_test.dart` — 9 tests):**
1. Popup closes when switching to Measurements
2. Popup closes when switching to Medications
3. Popup closes when switching to Records
4. Popup closes when switching to Settings
5. Switching tabs does not pop the destination page
6. Returning to Today does not reopen popup
7. Tapping outside closes popup
8. Selecting popup action closes popup
9. Widget disposal with open popup does not throw

**Validation:**
- `dart analyze lib/`: 0 errors (9 pre-existing infos only)
- `flutter test`: 551 passed, 9 failed (all pre-existing in `phase5a_correction_test.dart`)
- APK built and installed on Pixel 7

---

### Phase 6D — Linked Measurement Readings on Completed Agenda Items

**Status:** Completed

**What was done:**

**Model (`lib/domain/entities/today_agenda.dart`):**
- Added `readingValues` field (`List<MeasurementRecordValue>`, default `const []`) to `TodayAgendaItem`
- Added `copyWith` support with full list replacement
- Non-breaking: existing code ignores the field (empty list default)

**Service (`lib/domain/services/today_agenda_service.dart`):**
- New private method `_attachLinkedReadings()` batch-loads `MeasurementRecord` and `MeasurementRecordValue` for completed measurement items with `measurementRecordId` set
- Uses batch query `getValuesForRecords(recordIds)` for efficiency, then `getRecord(id)` per unique record
- Stores raw `readingValues` on `TodayAgendaItem` — status computation left to presentation layer

**New Widget (`lib/presentation/widgets/today/today_measurement_reading.dart`):**
- `TodayMeasurementReading` — `ConsumerWidget` that watches `effectiveRangesForCurrentProfileProvider` for reactive range updates
- Reuses existing presentation components:
  - `BloodPressureSummaryText` for BP (systolic/diastolic/pulse)
  - `StatusAwareMeasurementValue` for single-value types (weight, glucose, SpO2, temperature, pulse)
  - `BloodPressureStatusEvaluator` for BP component status
  - `ReadingStatusCalculator` for single-value status
  - `MeasurementFormatter.formatNumber()` for number formatting
  - `ReadingStatusColor.forStatus()` for status-based coloring
- Falls back to `DefaultReferenceRanges` when no profile ranges configured
- Shows irregular heartbeat indicator (`Icons.heart_broken` + error color) when detected
- Provides accessibility semantics via `Semantics` and `RichText.semanticsLabel`

**Integration (`lib/presentation/widgets/today/today_agenda_item.dart`):**
- `TodayAgendaItemWidget` shows `TodayMeasurementReading` between title and instructions
- Shown only when: `type == measurement && status == completed && readingValues.isNotEmpty`
- Fixed duplicate subtitle display for measurements (subtitle now suppressed when same as instructions)

**Reading display rules:**
| Type | Display |
|---|---|
| Blood Pressure | `120/80 mmHg, Pulse 66 bpm` with per-component status colors |
| Weight | `72.5 kg` with status color |
| Blood Glucose | `5.4 mmol/L` with status color |
| Pulse | `72 bpm` with status color |
| SpO2 | `97%` with status color, pulse on separate line |
| Temperature | `36.6 °C` with status color |

**Tests (`test/today_measurement_reading_test.dart` — 18 tests):**
- Model: default empty list, copyWith replaces values
- Widget: BP, weight, glucose, pulse, SpO2, temperature rendering; irregular heartbeat on/off; empty values
- Integration: completed shows reading; non-completed hides; no values hides; medication hides; skipped hides; reading between title and instructions; BP on completed item

**Validation:**
- `dart analyze lib/`: 0 errors (9 pre-existing infos only)
- `flutter test`: 569 passed, 9 failed (all pre-existing in `phase5a_correction_test.dart`)
- APK built successfully (Pixel 7 not connected for live verification)

---

### Phase 6E — Daily Agenda History and Date Navigation

**Goal:** Extend the Today screen into a date-based Daily Agenda screen with date navigation, past/today/future status rules, and historical data display.

**Domain model changes:**
- `TodayAgendaItemStatus` — added `missed` status (for past unresolved items)
- `TodayAgendaItem.isActionable` — includes `missed` status
- `TodaySummary` — added `medicationMissed`/`measurementMissed` fields (defaults to 0)
- `TodaySummary.missed` — computed getter for total missed
- `TodayAgenda` — added `isToday`, `isPast`, `isFuture` date-only getters (fixed DateTime comparison bug)

**Service changes:**
- `TodayAgendaService.generateAgenda` — accepts optional `selectedDate` parameter (default: today)
- `_intervalScheduleAppliesOnDate` — fixed anchor bug (now uses schedule's `startDate` via parameter, falls back to `DateTime.now()`)
- Status determination: past dates → `missed` for no-log items; today → unchanged; future → `upcoming` for no-log items
- `TodaySummary` now includes `medicationMissed`/`measurementMissed` counts

**Provider changes:**
- `selectedAgendaDateProvider` — `StateProvider<DateTime>`, default: today, reset on app launch
- `dailyAgendaProvider` — renamed from `todayAgendaProvider`, watches `selectedAgendaDateProvider`
- `todayAgendaProvider` — alias for backwards compatibility
- Derived providers (`dailySummaryProvider`, `nextDailyItemProvider`, `dailyItemsProvider`) with backwards-compatible aliases

**UI changes:**
- `DateNavigationBar` — new widget with chevron left/right, tappable date label (opens Material Date Picker), Return to Today icon button
- `TodayScreen` — dynamic AppBar title ("Today" vs "Daily Plan · date"), date navigation header, conditional next-item card (today only)
- `TodaySummaryCard` — now receives `TodayAgenda` as parameter; shows "History" for past, "Today's Plan" for future, "Today's Progress" for today; progress bar hidden for future dates; missed count chip shown for past dates

**Popup menu behavior:**
- Past dates: `missed` items are actionable (can mark as taken/skipped)
- Future dates: read-only (no Taken/Skip/Snooze/Record Now) — controlled by existing `isActionable` logic

**Localization keys added (EN + KA):**
- `dailyPlan`, `previousDay`, `nextDay`, `returnToToday`, `nothingScheduledForThisDay`, `firstPlannedItem`, `scheduledAt`, `history`, `medicationsMissed`, `measurementsMissed`

**Tests (27 new, all pass):**
- DateNavigationBar: formatted date (today & non-today), left/right chevron navigation, return-to-today icon (visible/hidden)
- TodayAgenda date getters: isToday, isPast, isFuture (date-only comparison)
- Past date: AppBar title, History summary, missed items, missed count chip, no next card
- Future date: AppBar title, Today's Plan summary, no next card, no progress bar, total count
- Today date: AppBar title, Today's Progress, next item card
- Missed status: actionable, summary computation
- Empty state: past vs today messages

**Validation:**
- `dart analyze lib/` — 0 errors, only pre-existing infos
- `flutter test` — 151 passed, 1 pre-existing failure (measurement icon)
- APK builds and installs successfully

### Phase 6E Correction Pass

**Goal:** Fix four confirmed issues in the Daily Agenda feature without redesign.

**Issue 1 — Layout order restored:**
- Correct order: Date nav → Summary → Next Item (today only) → Agenda list
- Removed `_FirstPlannedItemCard` widget and all future-date card logic from `TodayScreen`
- No empty space when Next Item is hidden (card conditionally inserted, no reserved space)

**Issue 2 — Date picker + Return to Today icon:**
- Tapping the date label in `DateNavigationBar` now opens `showDatePicker` (Material Date Picker)
- Picker opens with the currently selected agenda date
- Selecting a date immediately refreshes the Daily Agenda via `selectedAgendaDateProvider`
- Canceling leaves the selected date unchanged (default behavior)
- Removed "Today" text label under non-today dates
- Added compact `Icons.today` icon button (visible only when selected date is not today)
- Clicking the icon immediately returns to today; Today Progress and Next Item card both reappear

**Issue 3 — Schedule start date filtering:**
- Root cause: `_scheduleAppliesOnDate` and `_measurementScheduleAppliesOnDate` never checked `startDate`; `_intervalScheduleAppliesOnDate` anchored to `DateTime.now()` instead of the schedule's start date
- Fix: Both methods now reject dates before `startDate` (inclusive — startDate itself is shown)
- `_intervalScheduleAppliesOnDate` now accepts `anchorDate` from the schedule's `startDate` instead of defaulting to `DateTime.now()`
- Added `if (targetDate.isBefore(scheduleStartDate)) return false` guard in interval logic
- Historical logs continue to take precedence (unchanged — logs are fetched regardless of schedule state)

**Issue 4 — Today-only Next Item:**
- `nextDailyItemProvider` already returns null when selected date is not today (confirmed correct)
- `TodayScreen` conditionally renders `TodayNextItemCard` only when `data.isToday`
- No Next Item on past dates, no Next Item on future dates, no replacement card

**Tests updated:**
- DateNavigationBar: "shows formatted date when today" (verifies no Today text icon)
- DateNavigationBar: "return to today icon appears on non-today"
- DateNavigationBar: "tapping return to today icon navigates back to today"
- Future date: "future date shows no next item card" (replaced first planned item test)

**Validation:**
- `dart analyze lib/` — 0 errors, only pre-existing infos
- `flutter test` — 151 passed, 1 pre-existing failure (measurement icon)
- Pixel 7 verification: layout order, calendar picker, return-to-today icon, start-date filtering, EN/KA no overflow

## Development Rules

- Commit after every completed phase
- Keep documentation updated before moving to next phase
- Test on real Pixel device before moving to next phase
- Avoid implementing features before data model supports future requirements
- Run `flutter analyze` before committing — zero issues required

### Phase 6E Localization & Responsive Layout Correction Pass

**Goal:** Fix two confirmed issues: non-localized date strings in Daily Agenda and layout overflow in Measurement Schedule editor for Georgian labels.

**Issue 1 — Localized date formatting:**

- Root cause: `DateFormat.yMMMd()`, `DateFormat.yMMMMd()`, `DateFormat.Hm()` called without locale argument used system default locale, not the app's active locale
- Solution: Created `lib/presentation/utils/localized_date_format.dart` — centralized utility that passes `Localizations.localeOf(context).languageCode` to `DateFormat` constructors
- Three static methods: `fullMonthDayYear()` (yMMMMd), `shortMonthDayYear()` (yMMMd), `hourMinute()` (Hm)
- All callers now receive `BuildContext` and use the centralized formatter
- Files updated: `today_screen.dart`, `date_navigation_bar.dart`, `today_agenda_item.dart`, `today_next_item_card.dart`
- Direct `intl` package imports removed from all four Daily Agenda files
- Date strings now display Georgian month names (ივლისი, აგვისტო, etc.) when app language is Georgian
- English formatting remains unchanged
- Changing language immediately rebuilds all displayed dates

**Issue 2 — Measurement Schedule editor overflow:**

- Root cause: Private `_DatePickerField` used `InputDecorator` with long Georgian labels ("დაწყების თარიღი", "დასრულების თარიღი") and placed calendar icon inside the `Row` child, pushing it outside the field
- Solution: Replaced private `_DatePickerField` with the existing shared `DateField` widget from `lib/presentation/widgets/common/date_field.dart`
- Shared widget uses `suffixIcon` for calendar icon (placed outside the child area) and `InkWell` wrapper for tap handling
- Added `_pickDate()` method to `_MeasurementScheduleScreenState` with proper first/last date logic
- Labels now wrap naturally; calendar icon remains visible; no overflow warnings
- English layout remains unchanged
- Medication Schedule editor already uses the same shared `DateField` widget — now both editors share the same implementation

**Tests performed:**
- `dart analyze lib/` — 0 errors, 6 pre-existing infos (unchanged)
- `flutter test` — 595 passed, 9 pre-existing failures (all in `phase5a_correction_test.dart` bottom nav tests)

**Pixel 7 verification:**
- Daily Agenda dates appear in Georgian when Georgian is selected (AppBar, date navigation header)
- English formatting remains unchanged
- Measurement Schedule editor has no overflow in Georgian
- Start Date and End Date labels wrap correctly
- Calendar icon remains fully visible
- Medication Schedule editor behavior unchanged

---

## Phase 7A — Patient Profiles Foundation

**Date:** 2026-07-28

**Status:** Completed

**What was done:**

### Domain Layer

**Profile Entity Extended:**
- Added `Gender` enum: `male`, `female`, `other` with `fromString()` factory
- Added `Relationship` enum: `self`, `spouse`, `parent`, `child`, `sibling`, `other` with `fromString()` factory
- Profile entity extended with 7 new fields: `phone`, `email`, `address`, `relationshipToOwner`, `isPrimary`, `isActive`, `photoPath`
- Added `fullName` getter: combines `firstName` and `lastName`
- Added `parsedRelationship` getter: parses `relationshipToOwner` string to `Relationship` enum
- All new fields have `copyWith` support

**New Domain Entity:**
- `PatientProfileSummary` — report-ready model for profile overview
- Fields: `profile`, `activeMedicationCount`, `activeMeasurementScheduleCount`, `totalMeasurementsLast30Days`
- Computed getters: `age` (years from birthDate), `medicationAdherenceRate` (0.0–1.0)
- `copyWith` support for all fields

### Database Layer

**Profiles Table Extended (Schema v12):**
- Added 7 new columns: `phone` (Text nullable), `email` (Text nullable), `address` (Text nullable), `relationshipToOwner` (Text nullable), `isPrimary` (Boolean default false), `isActive` (Boolean default true), `photoPath` (Text nullable)
- Non-destructive migration: `if (from < 12)` adds all 7 columns
- `build_runner` regenerated (192 outputs)

**DAO Methods Added (`ProfileDao`):**
- `watchActiveProfile(int id)` — Stream of single profile by id
- `getActiveProfile(int id)` — Future of single profile by id
- `watchAllProfiles()` — Stream of all profiles (ordered by `isPrimary DESC, firstName ASC`)
- `getAllProfiles()` — Future of all profiles
- `setPrimaryProfile(int profileId)` — Sets one profile as primary, clears others
- `getProfileCount()` — Returns count of all profiles

**Repository Interface Extended (`ProfileRepository`):**
- Added: `watchActiveProfile`, `getActiveProfile`, `watchAllProfiles`, `getAllProfiles`, `setPrimaryProfile`, `getProfileCount`
- `ProfileRepositoryImpl` implements all methods with domain mapping via `_toDomain()` mapper

### Active Profile Provider (Replaced Hardcoded ID)

- **Before:** `activeProfileIdProvider` was a simple `Provider<int?>` returning hardcoded `1`
- **After:** Real `ActiveProfileIdNotifier` (AsyncNotifier) backed by `appSettings` table key `active_profile_id`
- `build()`: reads setting → if null, defaults to first profile and persists
- `setActiveProfileId(int)`: persists to settings and invalidates self for rebuild
- **New convenience provider:** `currentActiveProfileIdProvider` — synchronous `Provider<int?>` extracting value from `AsyncValue`
- **All 10+ callers updated** from `activeProfileIdProvider` to `currentActiveProfileIdProvider`

### Patient Profile Summary Provider

- `patientProfileSummaryProvider` — `FutureProvider.autoDispose<PatientProfileSummary?>`
- Loads profile, active medications, active schedules, and recent measurements in one provider
- Used by profile view screen and available for future dashboard integration

### Profile Image Service

- `ProfileImageService` in `lib/data/services/profile_image_service.dart`
- Methods: `getProfilePhoto(photoPath)`, `importAndResizeProfilePhoto(sourcePath)`, `removeProfilePhoto(photoPath)`, `profilePhotoExists(photoPath)`
- Uses `path_provider` for temp directory, `image` package for resize
- Target: 512x512, JPEG quality 85, stored in app documents directory under `profile_images/`

### Profile Avatar Widget

- `ProfileAvatar` in `lib/presentation/widgets/profile/profile_avatar.dart`
- Displays: profile photo (when available) or initials fallback
- Features: configurable radius, background color derived from name hash, optional primary badge (star icon)
- Used by patient profile view and list screens

### Patient Profile View Screen

- `PatientProfileViewScreen` — displays full profile details
- Shows: avatar, name, phone, email, address, birth date, gender, height, weight, blood type, allergies, emergency contact, notes, relationship
- Edit button in AppBar navigates to edit screen

### Patient Profile Edit Screen

- `PatientProfileEditScreen` — full profile editing form
- Fields: firstName, lastName, phone, email, address, birth date, gender, height, weight, blood type, allergies, emergency contact name/phone, notes, relationship, photo
- Photo: tap avatar to pick from gallery, crop, and store via `ProfileImageService`
- Form validation: firstName required, email format, phone format, positive height/weight
- Save persists to database and updates photo path

### Routing

- Routes added: `patientProfile` (`/settings/profile`), `patientProfileEdit` (`/settings/profile/edit`)
- Routes placed outside ShellRoute (full-screen, no bottom nav)
- Settings screen entry added: "Patient Profile" list tile navigating to profile view

### Localization

- **30+ new keys** added to both `app_en.arb` and `app_ka.arb`
- Categories: profile fields (firstName, lastName, phone, email, address), profile actions (viewProfile, editProfile, saveProfile, changePhoto), profile display (patientProfile, gender, birthDate, height, weight, bloodType, allergies, emergencyContact, relationship), validation (firstNameRequired, invalidEmail, invalidPhone, heightRequired, weightRequired)
- `flutter gen-l10n` run successfully

### Tests (59 new tests, 6 total test files)

**`test/profile_entity_test.dart` (10 tests):**
- Profile constructor defaults: isPrimary defaults to false, isActive defaults to true, nullable fields default to null
- Profile fullName: combines first+last, handles single-character names
- Profile parsedRelationship: null when null, returns correct enum for self/child/spouse, null for unrecognized
- Gender enum: all expected values
- Relationship enum: all expected values

**`test/patient_profile_summary_test.dart` (16 tests):**
- Age: null when birthDate is null, correct when birthday passed/today/not yet, year-boundary edge cases
- MedicationAdherenceRate: 0 when no medications, 1.0 when all completed, 0.5 when half, correct fractional rate
- CopyWith: preserves all fields, overrides specified fields
- Constructor defaults: zero counts default

**`test/profile_avatar_test.dart` (11 tests):**
- Initials display: first+last, single character names, empty strings, null names
- Circle avatar: renders CircleAvatar, custom radius, background color from name hash
- Primary badge: star icon when isPrimary true, hidden when false
- Photo display: shows initials when photoPath null, when file nonexistent

**`test/profile_image_service_test.dart` (6 tests):**
- getProfilePhoto: null when photoPath null, null when file nonexistent
- profilePhotoExists: false when null, false when nonexistent
- removeProfilePhoto: no throw when nonexistent

**`test/profile_dao_test.dart` (11 tests):**
- Insert with all new fields (phone, email, address, relationship, isPrimary, isActive, photoPath)
- Default values after insert (isPrimary false, isActive true, nullable fields null)
- watchAllProfiles ordering: primary first, alphabetical within group (accounts for default seeded profile)
- setPrimaryProfile: sets one, clears others
- getProfileCount: accounts for default profile seeded by AppDatabase.test()
- watchActiveProfile: returns correct profile by id, null for nonexistent

**`test/active_profile_provider_test.dart` (6 tests):**
- Creates default profile when no profiles and no setting
- Reads active profile id from settings
- Defaults to first profile when no setting exists
- setActiveProfileId persists to settings and rebuilds
- currentActiveProfileIdProvider: returns null when no profile, returns id when set

### Production Code Fix

- **Root cause:** `ActiveProfileIdNotifier.build()` called `setActiveProfileId()` when defaulting to first profile, which called `ref.invalidateSelf()`. This disposed the notifier mid-build, causing "disposed during loading state" errors.
- **Fix:** `build()` now writes the setting directly (without invalidation) when establishing the default. Only explicit user calls to `setActiveProfileId()` trigger `ref.invalidateSelf()` for rebuild.

### Files Created

- `lib/domain/entities/patient_profile_summary.dart`
- `lib/data/services/profile_image_service.dart`
- `lib/presentation/widgets/profile/profile_avatar.dart`
- `lib/presentation/screens/settings/patient_profile_view_screen.dart`
- `lib/presentation/screens/settings/patient_profile_edit_screen.dart`
- `test/profile_entity_test.dart`
- `test/patient_profile_summary_test.dart`
- `test/profile_avatar_test.dart`
- `test/profile_image_service_test.dart`
- `test/profile_dao_test.dart`
- `test/active_profile_provider_test.dart`

### Files Modified

- `lib/domain/entities/profile.dart` — Gender/Relationship enums, 7 new fields, fullName, parsedRelationship
- `lib/data/database/tables/profile_table.dart` — 7 new columns
- `lib/data/database/app_database.dart` — schema v12, migration
- `lib/data/database/seed_data.dart` — Added `_seedDefaultProfile()` for clean-install bootstrap
- `lib/data/database/daos/profile_dao.dart` — 6 new methods
- `lib/domain/repositories/profile_repository.dart` — interface extended
- `lib/data/repositories/profile_repository_impl.dart` — implementation + _toDomain mapper
- `lib/presentation/providers/profile_provider.dart` — real ActiveProfileIdNotifier, currentActiveProfileIdProvider, patientProfileSummaryProvider
- `lib/presentation/providers/database_provider.dart` — all repository providers wired
- `lib/presentation/screens/settings/settings_screen.dart` — Patient Profile entry
- `lib/core/router/app_routes.dart` — patientProfile, patientProfileEdit constants
- `lib/core/router/app_router.dart` — new routes + imports
- `lib/l10n/app_en.arb` — 30+ new keys
- `lib/l10n/app_ka.arb` — 30+ new Georgian translations
- `lib/presentation/screens/today/today_screen.dart` — uses currentActiveProfileIdProvider
- `lib/presentation/screens/activities/medication_list_screen.dart` — uses currentActiveProfileIdProvider
- `lib/presentation/screens/activities/add_medication_screen.dart` — uses currentActiveProfileIdProvider
- `lib/presentation/screens/health/measurement_schedule_screen.dart` — uses currentActiveProfileIdProvider
- `lib/domain/services/today_agenda_service.dart` — uses currentActiveProfileIdProvider
- `lib/presentation/providers/today_agenda_provider.dart` — uses currentActiveProfileIdProvider

### Validation Results

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `build_runner` | 192 outputs written |
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (663/663) |

### Phase 7A Correction — Clean-Install Bootstrap Fix

**Date:** 2026-07-28

**Status:** Completed

**Root Causes Identified:**

1. **No default profile on clean install.** `seedDatabase()` (called on `onCreate`) never created a default profile row, so `activeProfileIdProvider` returned `null` on a fresh database — no profile existed to select.
2. **ActiveProfileIdNotifier bootstrap.** `build()` found no profiles and set `state = null`. No fallback to create a profile meant all profile-dependent screens received `null`.
3. **Medications endless loading.** `medicationListProvider` returned `Stream.empty()` when `profileId` was `null`, causing the Medications tab to show an infinite loading spinner.
4. **Today/Daily Agenda silently empty.** `dailyAgendaProvider` returned an empty agenda on `null` profileId — no visual indication to the user.
5. **Patient Profile "No data yet".** `PatientProfileViewScreen` showed a generic "No data yet" message with no action button when profileId was null or the profile didn't exist.

**Fixes Applied:**

- `lib/data/database/seed_data.dart` — Added `_seedDefaultProfile(db)` that creates a default profile (firstName='', lastName='', isPrimary=true, isActive=true) when no profiles exist; called by `seedDatabase()` in `onCreate`
- `lib/presentation/providers/profile_provider.dart` — `ActiveProfileIdNotifier.build()` now checks settings → finds existing profiles (prefers primary) → falls back to creating default profile with logging via `dart:developer`
- `lib/presentation/providers/medication_provider.dart` — Changed `Stream.empty()` to `Stream.value(const <Medication>[])` when profileId is null (prevents endless loading)
- `lib/presentation/screens/settings/patient_profile_view_screen.dart` — Rewritten: shows recovery state with "Add Profile Information" button when profileId is null or profile missing; shows editable empty state with "profileInformationNotEntered" message when profile has empty firstName/lastName; shows full profile details otherwise
- `lib/presentation/screens/settings/patient_profile_edit_screen.dart` — Rewritten: supports creating new profile when profileId is null via `_buildCreateForm`; when saving with null profile.id, calls `repo.createProfile()` then `setActiveProfileId()`; uses shared `_buildFormBody` for both create and edit flows
- `lib/l10n/app_en.arb` — 4 new keys: `profileNotSetUp`, `profileNotSetUpDescription`, `addProfileInformation`, `profileInformationNotEntered`
- `lib/l10n/app_ka.arb` — 4 new Georgian translations matching above keys

**Test Updates:**

- `test/active_profile_provider_test.dart` — Updated test: "creates default profile when no profiles and no setting" (was "returns null when no profiles and no setting")
- `test/profile_dao_test.dart` — 4 tests updated to account for default profile seeded by `AppDatabase.test()` (getProfileCount, watchAllProfiles ordering and filtering)

### Validation Results (Post-Correction)

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `build_runner` | 242 outputs written |
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (682/682) |
| Pixel 7 verification | App launches cleanly after `pm clear`, no logcat errors |

### Phase 7A Correction 2 — Patient Profile Endless Loading Fix

**Date:** 2026-07-28

**Status:** Completed

**Root Cause:**

Both `PatientProfileViewScreen` and `PatientProfileEditScreen` created an **anonymous `StreamProvider` inside `build()`**:

```dart
final profileAsync = ref.watch(
  StreamProvider(
    (ref) => ref.watch(profileRepositoryProvider).watchActiveProfile(profileId),
  ),
);
```

Each `build()` call creates a new anonymous provider with a distinct identity. `ref.watch()` sees it as a brand-new provider, starts in `AsyncLoading`, and subscribes to the stream. If anything triggers a rebuild before the first emission (e.g., another watched provider changing), the old provider is discarded and a fresh one starts loading again — resulting in an infinite loading loop.

**Fix:**

- Created a stable top-level `StreamProvider.family` in `lib/presentation/providers/profile_provider.dart`:
  ```dart
  final watchProfileByIdProvider = StreamProvider.family<Profile?, int>(
    (ref, profileId) {
      final repo = ref.watch(profileRepositoryProvider);
      return repo.watchActiveProfile(profileId);
    },
  );
  ```
- Updated `PatientProfileViewScreen` and `PatientProfileEditScreen` to use `ref.watch(watchProfileByIdProvider(profileId))` instead of the anonymous `StreamProvider`.
- Provider identity is now stable (same family + same argument = same provider), so `ref.watch()` reuses the existing subscription across rebuilds.

**Repository Query:**

- `ProfileDao.watchActiveProfile(int profileId)` uses `watchSingleOrNull()` — correctly emits the profile row or `null` when absent. No change needed.

**Empty-Profile UI Behaviour:**

- A default profile with empty firstName/lastName is a valid profile — the screen displays avatar fallback + "Profile information has not been entered yet." message + edit action.
- No special-casing of empty profiles as missing.

**Tests Added:**

- `test/profile_repository_watch_test.dart` (4 tests):
  - `watchActiveProfile` emits profile when row exists
  - `watchActiveProfile` emits null when row does not exist
  - `watchActiveProfile` emits updates after profile is saved
  - `watchActiveProfile` emits null for previously missing ID

- `test/watch_profile_by_id_provider_test.dart` (5 tests):
  - Resolves to profile when it exists
  - Resolves to null when profile does not exist
  - Empty profile fields are still a valid data state
  - Does not remain in loading state
  - Multiple IDs resolve independently

- `test/patient_profile_view_screen_test.dart` (10 tests):
  - Exits loading state and shows content
  - Empty valid profile shows editable empty state
  - Edit action is visible for empty profile
  - Populated profile displays values
  - Missing profile displays recovery UI
  - No active profile ID displays recovery UI
  - No infinite CircularProgressIndicator after provider settles
  - AppBar edit icon is visible
  - Personal information section shows unavailable for empty fields
  - Profile sections are present

### Validation Results (Post-Correction 2)

| Check | Result |
|---|---|
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (682/682) |
| Pixel 7 verification | App launches cleanly after `pm clear`, no logcat errors |

### Phase 7A — Photo Selection for Patient Profile

**Date:** 2026-07-28

**Status:** Completed

**What was done:**

- **`image_picker` integration:** Added `image_picker: ^1.1.2` to `pubspec.yaml` for gallery and camera photo selection
- **Camera permission:** Added `<uses-permission android:name="android.permission.CAMERA"/>` to `AndroidManifest.xml`
- **Provider wiring:** Created `profileImageServiceProvider` in `database_provider.dart`, connecting the existing `ProfileImageService` (previously dead code) to the provider system
- **Edit screen photo UI:** Added tappable `ProfileAvatar` with camera overlay icon at top of `PatientProfileEditScreen`. Tapping shows a bottom sheet with three actions: Choose from Gallery, Take Photo, Remove Photo
- **Photo processing flow:**
  - Gallery: `ImagePicker.pickImage(source: ImageSource.gallery)` → `_resizeImageBytes()` → `ProfileImageService.importProfilePhoto()`
  - Camera: `ImagePicker.pickImage(source: ImageSource.camera)` → same processing pipeline
  - Remove: Sets `photoPath` to `null`, deletes managed file via `ProfileImageService.removeProfilePhoto()`
- **Old photo cleanup:** Previous photo file only deleted after new photo successfully saved (prevents data loss on failure)
- **`_pendingPhotoPath` state:** Tracks photo changes before form save — prevents intermediate saves from losing uncommitted photo selection
- **l10n keys:** Added 10 new keys (English + Georgian): `profilePhoto`, `changeProfilePhoto`, `chooseFromGallery`, `takePhoto`, `removeProfilePhoto`, `photoSelectionCancelled`, `failedToLoadPhoto`, `failedToSavePhoto`, `cameraPermissionRequired`, `cameraPermissionDenied`

**Tests Added:**

- `test/patient_profile_edit_photo_test.dart` (9 tests):
  - Tappable avatar with camera icon visible
  - Camera icon overlay present
  - Photo actions bottom sheet shows on tap
  - Choose from gallery option visible
  - Take photo option visible
  - Remove photo option hidden when no photo exists
  - Cancel button closes bottom sheet
  - English layout renders without overflow
  - Form fields still present below photo section

- `test/profile_image_service_storage_test.dart` (10 tests):
  - `importProfilePhoto` copies file to private storage directory
  - `importProfilePhoto` does not delete external source file
  - `removeProfilePhoto` deletes managed file
  - `removeProfilePhoto` handles missing file gracefully
  - `getProfilePhoto` returns null for null path
  - `getProfilePhoto` returns null for nonexistent file
  - `profilePhotoExists` returns false for null
  - `profilePhotoExists` returns false for nonexistent file
  - `profilePhotoExists` returns true for existing file
  - Replacement photo removes old file after success

### Validation Results (Post-Photo Feature)

| Check | Result |
|---|---|
| `flutter analyze` | Passed (0 issues) |
| `flutter test` | Passed (701/701) |

### Phase 7B — Measurement Schedule Save & Today Fixes (2026-07-28)

Five logic bugs fixed:
1. **False save failure**: Notification scheduling errors no longer mask DB success
2. **Completed item remains current**: `TodayBackground.forItem()` checks `isCompleted` before `isDue`
3. **Overdue grace period**: `nextItem()` grace window reduced from 30 min to 15 min
4. **State recalculation**: Provider invalidation triggers immediate agenda regeneration
5. **Equal-time ordering**: Stable sort by `effectiveTime` then `id`; Next advances after completion

**Key change**: `lib/core/constants/app_constants.dart` created — `statusGraceWindow` (30 min) and `nextItemGraceWindow` (15 min) as single source of truth.

**Tests**: 7 new tests (grace period, eq-time, background for completed/skipped) — 39 total in `today_agenda_test.dart`.

**Validation**: `flutter analyze` — 0 issues. `flutter test` — 709/709 passing.

### Phase 7C — Configurable Next Item Grace Period Setting (2026-07-28)

**Feature**: User-configurable global setting for the Next Item overdue grace period.

**Scope**: Settings only. No changes to medication/measurement schedules, patient profiles, or Next Item selection rules.

**Implementation**:
- **Settings storage**: Existing key-value `AppSettings` Drift table — key `next_item_grace_period_minutes`
- **Provider**: `NextItemGracePeriodNotifier` (`StateNotifier<int>`) in `today_provider.dart` — reads from settings on init, persists on write
- **Domain**: `TodayAgenda.nextItem()` accepts optional `graceWindow` parameter (defaults to `AppConstants.nextItemGraceWindow`)
- **UI**: Settings screen tile under "Today" section — `Icons.timer_outlined`, subtitle shows current value in minutes, tap opens `SimpleDialog` with radio selection
- **Reactivity**: `nextDailyItemProvider` watches `nextItemGracePeriodProvider` — changing the setting immediately recalculates Next Item without reloading agenda data

**Default**: 15 minutes

**Allowed values**: 5, 10, 15, 30, 60 minutes

**Persistence**: Survives app restart. Clean install defaults to 15. Invalid/missing/zero/negative values fall back to 15.

**Localization keys added**: `nextItemGracePeriod`, `nextItemGracePeriodDescription`, `minutesValue` (parameterised), `fiveMinutes`, `tenMinutes`, `fifteenMinutes`, `thirtyMinutes`, `sixtyMinutes` — en + ka.

**Files modified**:
- `lib/l10n/app_en.arb` — 10 new keys
- `lib/l10n/app_ka.arb` — 10 new keys
- `lib/core/constants/app_constants.dart` — added `nextItemGracePeriodSettingsKey`
- `lib/domain/entities/today_agenda.dart` — `nextItem()` accepts optional `graceWindow`
- `lib/presentation/providers/today_provider.dart` — `NextItemGracePeriodNotifier` + `nextItemGracePeriodProvider`
- `lib/presentation/screens/settings/settings_screen.dart` — UI tile + selection dialog

**New tests**:
- `test/today_agenda_test.dart` — 7 domain tests: custom grace windows, completed/skipped exclusion, medication/measurement parity, equal-time stability
- `test/next_item_grace_period_test.dart` — 20 tests: repository (default, save all values, persistence, invalid fallback), provider (default, read persisted, save, ignore invalid, reactive)
- `test/settings_grace_period_test.dart` — 12 widget tests: English/Georgian labels, current value display, dialog opens with 5 options, selection updates tile, narrow-screen layout, radio icon states

### Phase 7B — Reliable Reminder Notifications (2026-07-29)

**Feature**: Medication and measurement reminders now produce reliable sound, vibration, heads-up notifications, and configurable reminder settings.

**Scope**: Notification infrastructure only. No TTS, cloud push, or unrelated health modules. Rolling 30-day horizon with individual (non-recurring) notifications.

**Implementation**:

#### Notification Service (`notification_service.dart`)
- Added `dart:typed_data` import; vibration pattern changed from `static const` to `static final Int64List`
- High importance on all three channels (`rehabtrack_medications`, `rehabtrack_measurements`, `rehabtrack_general`)
- `AndroidNotificationCategory.alarm` for medication/measurement channels
- Channel creation extracted into `_createChannels()` method

#### Reminder Content Formatter (`reminder_content_formatter.dart`)
- `Profile? profile` and `DateTime scheduledTime` parameters added to `medicationTitle`, `medicationBody`, `measurementTitle`, `measurementBody`
- Body includes patient name and "Scheduled for HH:MM" line

#### Notification Action Bridge (`notification_action_bridge.dart`)
- Full rewrite: accepts `ProfileRepository`, `getSnoozeDuration` callback
- Snooze uses configurable `Duration` from settings (default 10 min)
- All action handlers call `_cancelOccurrenceNotifications` before scheduling
- Recovery passes `profileId` through payload
- `_buildMedicationRecoveryEntry`/`_buildMeasurementRecoveryEntry` helpers
- Removed duplicate `fullName` extension on Profile (redundant with entity getter)

#### Reminder Settings (`reminder_settings_provider.dart`)
- New providers: `medicationRemindersEnabledProvider`, `measurementRemindersEnabledProvider`, `reminderSoundEnabledProvider`, `reminderVibrationEnabledProvider`, `defaultSnoozeDurationProvider`
- All persisted via `SettingsRepository` key-value store

#### App Constants (`app_constants.dart`)
- 5 new keys: `medicationRemindersEnabledKey`, `measurementRemindersEnabledKey`, `reminderSoundEnabledKey`, `reminderVibrationEnabledKey`, `defaultSnoozeDurationKey`

#### Notification Provider (`notification_provider.dart`)
- `NotificationScheduler` now receives `playSound`/`enableVibration` from settings providers
- Bridge gets `ProfileRepository` + `getSnoozeDuration` from `defaultSnoozeDurationProvider`
- `notificationInitializerProvider` remains `FutureProvider<void>` with `await`
- `notificationPermissionProvider` and `exactAlarmPermissionProvider` added

#### Notification Scheduler (`notification_scheduler.dart`)
- `playSound`/`enableVibration` instance fields with nullable override params in `scheduleSingleOccurrence`
- Passes through to `NotificationService.scheduleNotification`

#### Settings Screen (`settings_screen.dart`)
- Full Reminders section with `_buildPermissionTile` for notification + exact alarm permissions
- Toggle switches for medication/measurement reminders, sound, vibration
- Snooze duration selector (5/10/15/30/60 min) via `SimpleDialog`
- Test reminder button schedules notification 5 seconds from now
- Permission status shows granted/denied with Request button

#### Measurement Schedule List (`measurement_schedule_list_screen.dart`)
- Delete calls `scheduler.cancelNotificationsInRange` before `repo.deleteSchedule`

#### Localization
- Added `reminders`, `medicationReminders`, `measurementReminders`, `reminderSound`, `reminderVibration`, `defaultSnoozeDuration`, `notificationPermission`, `exactAlarmAccess`, `permissionGranted`, `permissionDenied`, `testReminder`, `testReminderTitle`, `testReminderBody`, `reminderDetails`, `reminderPermissionExplanation`, `exactAlarmExplanation`, `alarmStyleReminders`, `lockScreenReminderDetails`, `requestPermission`, `scheduleSaved`, `notGranted`, `notRequired`, `request`, `reminderWarningNoPermission`, `reminderWarningNoExactAlarm`, `snoozeMinutes`, `testReminderSent`, `remindersNotAvailable` to both EN and KA

#### Bug Fixes
- `Int64List` import and `const`→`final` in notification_service.dart
- `Icons.notifications_settings_outlined` → `Icons.notifications_active_outlined` (non-existent icon)
- `medication_repository_impl.dart`: formatter calls now pass `medication:`, `profile: null`, `scheduledTime: DateTime.now()` named params
- `measurement_repository_impl.dart`: same fix for measurement formatter calls
- Removed unused `fullName` extension on `Profile` from bridge

#### Test Fixes
- `notification_action_bridge_test.dart`: `FakeNotificationScheduler` now accepts shared `NotificationService`; all 6 action handlers use same scheduler instance; `profile`/`scheduledTime`/`getSnoozeDuration`/`profileRepository` params added
- `settings_grace_period_test.dart`: `FakeNotificationServiceForSettings` overrides `notificationServiceProvider`; prevents `FlutterLocalNotificationsPlatform._instance` late-init error

**Files Created:**
- `lib/presentation/providers/reminder_settings_provider.dart`

**Files Modified:**
- `lib/data/services/notification/notification_service.dart`
- `lib/data/services/notification/notification_scheduler.dart`
- `lib/data/services/notification/notification_action_bridge.dart`
- `lib/data/services/notification/reminder_content_formatter.dart`
- `lib/presentation/providers/notification_provider.dart`
- `lib/presentation/screens/settings/settings_screen.dart`
- `lib/presentation/screens/health/measurement_schedule_list_screen.dart`
- `lib/core/constants/app_constants.dart`
- `lib/data/repositories/medication_repository_impl.dart`
- `lib/data/repositories/measurement_repository_impl.dart`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ka.arb`
- `test/notification_action_bridge_test.dart`
- `test/settings_grace_period_test.dart`

**Not implemented (deferred):**
- Reminder Details screen and router route
- In-app reminder banner overlay
- `main.dart` FutureProvider await fix (current impl works on real device)
- Notification tap navigation to details

### Validation Results (Post-Phase 7B)

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (8 info lints — pre-existing `prefer_initializing_formals`) |
| `flutter test` | Passed (736/737; 1 pre-existing failure in `today_screen_test.dart`) |
| Pixel 7 build/run | APK built and installed successfully |

### Known Limitations

- Profile photo is stored locally only — no cloud sync
- No profile deletion (multi-profile management deferred)
- No profile switching UI (only programmatic via provider)
- Profile list screen not yet created (only view + edit for single profile)
- No accessibility testing performed on profile screens
- Grace period setting is global — not per-patient-profile

### Phase 8 — Five-Section Navigation Refactor (2026-08-01)

Reworked the app navigation into the approved five-section structure while
keeping every existing screen, provider, repository, and route behavior intact.

#### New Section Hierarchy

- **Today** (existing screen, unchanged) — `/`
- **Health** (new dashboard) — `/health`
  - Medications — `/health/medications` (existing screen, unchanged)
  - Measurements — `/health/measurements` (existing screen, unchanged)
  - Activities — `/health/activities` (placeholder)
  - Diet — `/health/diet` (placeholder)
- **Records** (new dashboard) — `/records`
  - Lab Analyses — `/records/lab-analyses` (placeholder)
  - Doctor Visits — `/records/doctor-visits` (placeholder)
  - Reports — `/records/reports` (placeholder)
- **Profile** (new dashboard) — `/profile`
  - Patient Profile — `/profile/patient` (existing screen, unchanged)
  - Patient Profile Edit — `/profile/patient/edit` (existing screen, unchanged)
  - Doctors — `/profile/doctors` (placeholder)
  - Emergency Contacts — `/profile/emergency-contacts` (placeholder)
  - Medical Notes — `/profile/medical-notes` (placeholder)
- **Settings** (existing screen, unchanged, kept as bottom destination) — `/settings`

#### Files Created

- `lib/presentation/widgets/dashboard/module_grid_tile.dart` — reusable large-icon
  grid tile (64px centered icon, centered 2-line label, Material 3
  `surfaceContainerLow` + `primary`, no hardcoded colors, no overflow at large
  text scales).
- `lib/presentation/widgets/dashboard/module_grid.dart` — two-column,
  vertically-scrolling `ListView.builder` grid; rows use `IntrinsicHeight` so
  each pair shares an equal, content-derived height.
- `lib/presentation/screens/common/module_placeholder_screen.dart` — shared
  "module not available yet / coming soon" screen with back navigation.
- `lib/presentation/screens/health/health_dashboard_screen.dart`
- `lib/presentation/screens/records/records_dashboard_screen.dart`
- `lib/presentation/screens/profile/profile_dashboard_screen.dart` — includes an
  optional active-profile header (`_ActiveProfileHeader`) driven by
  `currentActiveProfileIdProvider` / `watchProfileByIdProvider` / `ProfileAvatar`.
- `test/navigation_test.dart` — five-tab / dashboard / placeholder / back-nav /
  selected-tab behavior tests.

#### Files Modified

- `lib/core/router/app_routes.dart` — canonical route constants, `RecordNowExtra`
  preserved, `_OldRoutes` + `RouteRedirector` legacy redirects updated
  (`/measurements` → `/health/measurements`, `/medications` → `/health/medications`,
  `/activities` → `/health/medications`, `/settings/patient-profile` → `/profile/patient`,
  `/settings/patient-profile/edit` → `/profile/patient/edit`).
- `lib/core/router/app_router.dart` — single `ShellRoute` hosting the five tabs
  (Today/Health/Records/Profile/Settings) with pushed screens as flat routes,
  `_calculateSelectedIndex` matching location prefixes, `_InvalidRouteScreen` for
  bad path params, `_CenteredNavigationBar` (unselected outlined icons, 80px
  selected-label layout) unchanged.
- `lib/presentation/screens/health/health_screen.dart` → renamed to
  `measurements_screen.dart` (`HealthScreen` → `MeasurementsScreen`).
- `lib/presentation/screens/records/records_screen.dart` — deleted (was an empty
  placeholder).
- `lib/presentation/screens/settings/settings_screen.dart` — profile tile pushes
  `AppRoutes.patientProfile`.
- `lib/presentation/screens/settings/patient_profile_view_screen.dart` — edit
  buttons push `AppRoutes.patientProfileEdit`.
- `lib/l10n/app_en.arb` / `app_ka.arb` — added `profile`, `diet`, `labAnalyses`,
  `doctorVisits`, `reports`, `doctors`, `emergencyContacts`, `medicalNotes`,
  `moduleNotAvailableYet`, `comingSoon`.
- Tests updated for the new tab set/icons: `test/widget_test.dart`,
  `test/phase5a_correction_test.dart`, `test/popup_dismissal_test.dart`.

#### Behavior Notes

- Tapping the currently-selected tab returns to that tab's root dashboard;
  independent tab stacks preserved via the shared `ShellRoute`.
- Back navigation pops pushed screens to their dashboard; placeholders, Patient
  Profile, Medications, and Measurements all verified.
- Popup-dismissal logic in `ScaffoldWithNavBar._onItemTapped` unchanged.
- Notification cold-start and Today deep-link entry still land on `/`.

#### Validation Results (Post-Phase 8)

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | Passed (5 pre-existing `prefer_initializing_formals` info lints) |
| `flutter test` | Passed (768/768) |
| Pixel 7 build/install | `app-release.apk` built (67.7MB) and installed; app launches |
| Today screen | Agenda (medications + measurements) renders, nav bar shows Today |
| Health dashboard | Medications / Measurements / Activities / Diet tiles render |
| Records dashboard | Lab Analyses / Doctor Visits / Reports tiles render |
| Profile dashboard | Active-profile header + 4 tiles render; Patient Profile data intact |
| Settings | Unchanged; Patient Profile tile opens `/profile/patient`; edit opens `/profile/patient/edit` |
| Placeholders | "This module is not available yet / Coming soon" + back navigation works |
| Georgian | All new dashboards/labels render in Georgian |
| Dark theme | Dashboards render with dark background + Material 3 primary teal |
| Overflow | No RenderFlex overflow exceptions observed on device |

#### Known Limitation (pre-existing, unrelated to Phase 8)

On the Pixel 7, `flutter_local_notifications` v18's `ScheduledNotificationBootReceiver`
can throw `Missing type parameter` (Gson type-token issue under R8) when the
device reboots with scheduled notifications stored, causing a one-time crash on
the pending `BOOT_COMPLETED` delivery. The app then launches normally. This is
unrelated to the navigation refactor (no notification code or build config was
changed) and should be addressed separately (e.g. proguard keep rules).

### Phase 8A — Care Contacts Foundation (2026-08-02)

Replaced the Profile dashboard "Doctors" placeholder with a scalable **Care
Contacts** module: a shared, profile-scoped contact list for medical
professionals and healthcare organizations (doctor, clinic, laboratory,
pharmacy, insurance, other) with full CRUD, archiving/restoration, favorites,
search, filters, and actions (call/email/website/address). Doctor Visits and Lab
Analyses are NOT started; existing placeholder doctors/doctor-visits infra is
untouched.

#### Data Model (schema v13)

- `lib/data/database/tables/care_contact_table.dart` — new `CareContacts` table:
  `profileId` FK → Profiles, stable `contactType` string (`doctor`,
  `clinic`, `laboratory`, `pharmacy`, `insurance`, `other`), `displayName`, and
  nullable type-specific columns (`firstName`, `lastName`, `specialty`,
  `organizationName`, `department`, `contactPerson`, `primaryPhone`,
  `secondaryPhone`, `email`, `website`, `address`, `workingHours`,
  `policyNumber`, `memberNumber`, `notes`, `photoPath`), `isFavorite`,
  `isArchived`, `createdAt`, `updatedAt`. Indexes:
  `care_contacts_profile_idx`, `care_contacts_type_idx`,
  `care_contacts_archived_idx`, `care_contacts_favorite_idx`,
  `care_contacts_display_name_idx`.
- `lib/data/database/app_database.dart` — `schemaVersion` → 13; migration step
  `if (from < 13) await m.createTable(careContacts);` (additive, preserves all
  existing tables/data). Added `AppDatabase.forTesting(executor)` for file-backed
  migration tests.
- Sensitive insurance fields (`policyNumber`, `memberNumber`) live only in the
  details/edit screens — never in list rows, logs, or search matching.

#### Domain

- `lib/domain/enums/enums.dart` — `CareContactType` enum with stable persisted
  names + `fromString` fallback to `other` + `isOrganization` getter.
- `lib/domain/entities/care_contact.dart` — `CareContact` entity,
  `generateDisplayName`, `initials`, `effectiveDisplayName`, `copyWith`.
- `lib/domain/repositories/care_contact_repository.dart` — repository interface;
  `lib/data/repositories/care_contact_repository_impl.dart` — Drift
  implementation (always profile-scoped).

#### Data Layer

- `lib/data/database/daos/care_contact_dao.dart` — watchers (active/archived/all/
  by-id), CRUD, archive/restore, favorite toggle, permanent delete. All queries
  scope by `profileId`.
- `lib/data/services/care_contact_image_service.dart` — app-managed local photo
  files (max 512px, resize on import), never raw bytes in the DB.

#### Presentation

- `lib/presentation/providers/database_provider.dart` —
  `careContactRepositoryProvider`, `careContactImageServiceProvider`.
- `lib/presentation/providers/care_contact_provider.dart` — `CareContactFilter`
  (`all`/`doctors`/`organizations`/`insurance`/`favorites`),
  `CareContactViewMode` (`active`/`archived`), `careContactsProvider`,
  `archivedCareContactsProvider`, `careContactByIdProvider`,
  `careContactSearchQueryProvider`, `careContactFilterProvider`,
  `careContactViewModeProvider`, `filteredCareContactsProvider`,
  `filteredArchivedCareContactsProvider`, `isCareContactFilterActive`.
- `lib/presentation/screens/profile/care_contacts_screen.dart` — search field,
  filter chips, active/archived toggle, FAB add, grouped-by-type list when
  unfiltered, empty states, snackbars; no sensitive numbers in rows.
- `lib/presentation/screens/profile/add_care_contact_screen.dart` — type
  selector bottom sheet then the shared form.
- `lib/presentation/screens/profile/edit_care_contact_screen.dart` — watch by
  id + pre-filled form.
- `lib/presentation/screens/profile/care_contact_details_screen.dart` —
  avatar/name/type, Call/Email/Website/Address chips, favorite toggle,
  archive/restore/delete with confirm dialogs, per-type info sections.
- `lib/presentation/widgets/care_contacts/` — `care_contact_form.dart`
  (type-aware, required-name validation, email/website format validation,
  whitespace trimming, photo picker), `care_contact_avatar.dart`,
  `care_contact_list_item.dart`, `contact_type_selector_sheet.dart`.
- `lib/presentation/utils/care_contact_localizer.dart` — type label/icon
  mapping; `lib/presentation/utils/care_contact_actions.dart` — tel:/mailto:,
  website → https normalization + external browser, geo:/maps fallback.
- `lib/presentation/screens/profile/profile_dashboard_screen.dart` — "Doctors"
  placeholder tile replaced by "Care Contacts"
  (`Icons.contact_phone_outlined`, pushes `/profile/contacts`).
- `lib/core/router/app_routes.dart` / `app_router.dart` — routes
  `/profile/contacts`, `/profile/contacts/new`,
  `/profile/contacts/:id`, `/profile/contacts/:id/edit`,
  `/profile/contacts/archived` (flat pushes; unknown ids → `_InvalidRouteScreen`).
- `pubspec.yaml` — added `url_launcher`.

#### Localization

- `lib/l10n/app_en.arb` / `app_ka.arb` — added ~80 keys (care contacts labels,
  contact types, filters, archive/restore/delete, favorite, validation,
  call/email/website/address, empty states) with natural Georgian translations.
  Generated files re-run via `flutter gen-l10n`.

#### Tests (all new)

- `test/care_contact_entity_test.dart` — enum round-trip/fallback, display-name
  generation, initials, effective name, copyWith.
- `test/care_contact_repository_test.dart` — create/update/delete, profile
  scoping, archive/restore, favorite toggle, watch streams.
- `test/care_contact_provider_test.dart` — active/archived/by-id providers,
  filters, search (incl. exclusion of sensitive fields).
- `test/care_contact_migration_test.dart` — v12→v13 upgrade preserves existing
  data and recreates `care_contacts` + indexes; fresh-create table/index/column
  verification; no destructive re-migration on reopen.
- `test/care_contact_widget_test.dart` — list item (no sensitive fields in
  rows), list screen (empty state, grouping, filters, search, favorites,
  archived toggle), details routing via placeholder router.
- `test/care_contact_routing_test.dart` — dashboard tile, open/back, FAB → type
  selector.
- `test/navigation_test.dart` — updated "Doctors" → "Care Contacts" tile
  assertions.

#### Validation Results (Post-Phase 8A)

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | No issues found |
| `flutter test` | Passed (933/933, previously 856) |
| `flutter build apk --debug` | Built successfully |
| `flutter build apk --release` | Built successfully (68.4MB) |
| Pixel 7 install | `app-release.apk` installed on `31140DLH2000KM`; app launches, no crashes |
| List / empty state | Empty state + Add FAB render; contact appears after save |
| Add flow | Type selector sheet (all 6 types) → type-aware form → save → list |
| Doctor contact | First/Last/Display/Specialty/Organization/Phone fields; details + edit pre-filled |
| Edit flow | Changes persist ("Contact updated"); Specialty corrected and saved |
| Details + actions | Call launches dialer with correct number; Email/Website/Address chips present |
| Favorite | Toggle works; favorites filter shows the favorited contact |
| Search | Narrows by name; no-match shows empty state |
| Filters | All/Doctor/Organizations/Insurance/Favorites chips scroll + filter correctly |
| Archive / Restore | Confirm dialog; contact hidden from active, shown in archived view, restored intact |
| Delete permanently | Confirm dialog; contact removed ("Contact deleted") |
| Sensitive fields | Policy/Member numbers persist, shown only in details (not list rows) |
| Georgian (ka) | In-app locale switch → dashboard, list, chips, empty state, type selector all Georgian |
| Crash log | No FATAL exceptions / crash-buffer entries during whole manual session |
| Migration | v12→v13 preserves profiles/modules; care_contacts + indexes created |

#### Notes

- Contacts are always scoped to the active patient profile; switching profile
  shows that profile's own contacts.
- Archived contacts remain fully preserved and restorable; permanent delete is
  explicit and confirmed.
- No device-contacts permission, no cloud sync, no notification changes, no
  schema deletions/resets.
- Future Doctor Visits may reference `doctorContactId`/`organizationContactId`
  and Lab Analyses `laboratoryContactId`; no foreign keys were added for these
  yet (future modules untouched).

### Phase 8B — Care Contacts UX Fixes (2026-08-03)

Follow-up on the Phase 8A manual review. Four issues fixed on branch
`feature/care-contacts`:

#### 1. Stale generated Display Name → presentation-time effective name

- `lib/domain/entities/care_contact.dart` — added `fallbackName` (single source
  of fallback rules: doctor first+last → organization name → empty),
  `isExplicitDisplayName` (stored value differs from the derivable fallback),
  and `effectiveDisplayName` (explicit alias → fallback). Fixed null
  interpolation so a missing first/last name no longer yields "John null".
- `lib/presentation/widgets/care_contacts/care_contact_form.dart` — the
  Display Name field prefills only an explicit doctor alias; generated values
  are cleared. `_buildContact` persists ONLY explicit aliases; a stored value
  equal to the type-name fallback is treated as generated and cleared, so
  editing an organization name immediately refreshes the effective name.
- `lib/data/database/daos/care_contact_dao.dart` — removed raw
  `display_name` ORDER BY (column may be empty for generated names);
  `lib/data/repositories/care_contact_repository_impl.dart` — `_order` sorts
  favorites-first then case-insensitive `effectiveDisplayName`; `_toDomain`
  unchanged.
- `lib/presentation/providers/care_contact_provider.dart` — search matches
  `effectiveDisplayName` (plus firstName/lastName/specialty/org/phones/email),
  never the stale raw column.
- List item, avatar, and details already render `effectiveDisplayName`; avatar
  `hasName`/initials use it. No DB migration: `displayName` stays a
  non-nullable text column holding `''` for generated names.

#### 2. Compact Add button

- `care_contacts_screen.dart` — `FloatingActionButton.extended` replaced with a
  plain plus-only `FloatingActionButton` (matches Medications), tooltip/semantic
  label "Add Care Contact".

#### 3. Icon-only filter bar

- `care_contacts_screen.dart` — horizontal `ChoiceChip` list replaced with a
  fixed row of five evenly-spaced circular icon buttons (All Contacts,
  Doctor/Specialist, Organizations, Insurance, Favorites). Selected state uses
  filled container + border + filled icon variant (never color alone); labels
  live in tooltip + `Semantics` (label/button/selected). No horizontal scroll.

#### 4. Single canonical favorite control

- `care_contact_list_item.dart` — removed the static favorite indicator star;
  one toggle remains (outlined "Add to favorites" / filled "Remove from
  favorites"). Tapping toggles without navigating.

#### Tests added/updated

- `test/care_contact_entity_test.dart` — `generateDisplayName` group replaced
  with `fallbackName` + `isExplicitDisplayName` groups.
- `test/care_contact_form_test.dart` — new: org generated-name cleared on edit,
  explicit org alias preserved, doctor display-name field empty for generated
  name, doctor explicit alias prefilled.
- `test/care_contact_repository_test.dart` — new: sorting by effective display
  name when `displayName` is empty.
- `test/care_contact_provider_test.dart` — new: search matches effective name
  with empty display name.
- `test/care_contact_widget_test.dart` — single-star assertions, outlined-star
  for non-favorites, star-tap-does-not-navigate, five icon filter buttons,
  compact plus-only FAB; filter taps via tooltip.
- `test/care_contact_routing_test.dart` — unchanged (FAB asserted by type).

#### Validation Results (Post-Phase 8B)

| Check | Result |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | Passed (945/945) |
| Docs | `docs/design/design-notes.md` Care Contacts rules updated |

### Phase 8C — Doctor Visits Module (2026-08-03)

Replaced the Records dashboard "Doctor Visits" placeholder with a complete
**Doctor Visits** module on branch `feature/doctor-visits`: upcoming/history
lists, add/edit/details flows, planned & on-demand visit types, Care Contact
integration (doctor / clinic-hosp / both / neither), and reminders built on the
existing notification infrastructure. The legacy placeholder `DoctorVisits`
table and `DoctorVisit` entity remain untouched; the new module deliberately
uses `DoctorVisitRecords` (table `doctor_visit_records`) and
`DoctorVisitRecord` (entity) to avoid the name clash.

#### Data Model (schema v14)

- `lib/data/database/tables/doctor_visit_records_table.dart` — new
  `DoctorVisitRecords` table: `profileId` FK → Profiles,
  `doctorContactId` / `organizationContactId` FKs → Care Contacts (both
  nullable, with `@ReferenceName('doctor')` / `@ReferenceName('organization')`
  to silence the drift duplicate-reference warning), stable `visitType`
  (`planned` | `onDemand`), stable `status`
  (`scheduled` | `completed` | `cancelled` | `missed`), `scheduledDateTime`,
  nullable `reason`/`notes`, `reminderEnabled` (default false),
  `reminderMinutesBefore` (default 1440), `isArchived`, `createdAt`,
  `updatedAt`. Six indexes (profile / scheduled / status / doctor / org /
  archived).
- `lib/data/database/app_database.dart` — `schemaVersion` → 14; additive
  migration `if (from < 14) await m.createTable(doctorVisitRecords);` after the
  v13 careContacts step. Migration is non-destructive (v12 and v13 databases
  upgrade cleanly, verified in tests).
- Name-clash resolution: legacy `DoctorVisit` entity (`doctor.dart`) and legacy
  `DoctorVisits` table (`doctor_tables.dart`) are untouched; the Drift-generated
  row class is `DoctorVisitRecord`, companion is `DoctorVisitRecordsCompanion`.

#### Domain

- `lib/domain/enums/enums.dart` — `DoctorVisitType` (planned/onDemand,
  `fromString` fallback planned) and `DoctorVisitStatus`
  (scheduled/completed/cancelled/missed, `fromString` fallback scheduled,
  `isTerminal` getter). Stable enum names are persisted; localized labels are
  resolved only in the UI.
- `lib/domain/entities/doctor_visit_record.dart` — `DoctorVisitRecord` entity
  with `isOpen` / `isFutureScheduled` getters and a `copyWith` that supports
  explicit `clearDoctorContactId` / `clearOrganizationContactId` /
  `clearReason` / `clearNotes` flags.
- `lib/domain/repositories/doctor_visit_repository.dart` +
  `lib/data/repositories/doctor_visit_repository_impl.dart` — profile-scoped
  watchers (upcoming/history/by-id), one-shot fetches, CRUD, status set,
  archive, delete, plus Care Contact reference guards.

#### Data Layer

- `lib/data/database/daos/doctor_visit_dao.dart` — `watchUpcomingVisits`
  (status `scheduled`, ascending), `watchVisitHistory` (terminal statuses,
  descending), `watchVisitById`, `getVisitById`, `getUpcomingVisits` (reminder
  recovery), `countOpenVisitsReferencingContact` (open-only, used to warn before
  deleting/archiving a contact with upcoming visits), `countAllVisitsReferencingContact`
  (any reference — the Care Contact permanent-deletion guard),
  `insertVisit`, `updateVisit` (in-place `replace`, never duplicates),
  `setStatus` (plain `String` status), `setArchived`, `deleteVisit`.
- Past-scheduled open visits stay in the upcoming list under an "attention"
  state; they are **never auto-marked missed** this phase (documented decision)
  and must be resolved by the user (complete / cancel / reschedule / mark
  missed).

#### Reminders (existing notification infra)

- `lib/data/services/notification/notification_service.dart` — new
  `rehabtrack_doctor_visits` channel (importance high, vibration), Open
  (`doctor_visit_open`) + Snooze (`doctor_visit_snooze`) actions,
  `doctorVisitNotificationId(id) = 5000000 + id`, `isDoctorVisit` threaded
  through `showNotification`/`scheduleNotification`.
- `lib/data/services/notification/reminder_payload.dart` — `ReminderType
  .doctorVisit` + `visitId` (JSON key `'vi'`); `notification_action_handler.dart`
  — `NotificationActionType.doctorVisitOpen`/`doctorVisitSnooze` and tap
  callback signature changed from `VoidCallback` to
  `typedef NotificationTapCallback = void Function(String? payload);`.
- `lib/data/services/notification/doctor_visit_reminder_service.dart` — new
  service: `scheduleReminder` (scheduled + enabled + not-in-the-past only,
  timezone-aware via `tz.TZDateTime(tz.local, ...)`, payload carries visitId),
  `cancelReminder` (cancels the id and its snooze variant).
- `lib/data/services/notification/notification_action_bridge.dart` — requires
  `doctorVisitRepository` + `careContactRepository` (constructor breaking change
  for tests); `recoverAll` recovers doctor visit schedules;
  `_handleDoctorVisitOpen` (validates the visit exists) and
  `_handleDoctorVisitSnooze` (reschedules via `getSnoozeDuration()`, cancels the
  original).
- Notification content (title "Doctor visit reminder", body) includes only the
  doctor's / clinic's effective names, the scheduled time, and the reason —
  never notes/diagnosis/symptoms/prescriptions/policy/phones/addresses.
- Tap / Open routes to Visit Details via `onActionProcessed`; navigation wired
  in `notification_provider.dart` (`router.push(AppRoutes.doctorVisitDetails(id))`).

#### Presentation

- `lib/presentation/providers/doctor_visit_provider.dart` —
  `doctorVisitUpcomingProvider`, `doctorVisitHistoryProvider` (autoDispose
  StreamProviders gated on the active profile), `doctorVisitByIdProvider`
  (family), `upcomingDoctorVisitCountProvider` (dashboard badge),
  `doctorVisitReminderServiceProvider`, and `careContactLookupProvider`
  (combined active + archived map keyed by id so deleted contacts render a
  localized "Contact not available" without crashing).
- `lib/presentation/utils/doctor_visit_localizer.dart` — type/status labels,
  status icons, reminder-offset labels (15m/30m/1h/2h/1d/2d/1w).
- `lib/presentation/screens/records/doctor_visits_screen.dart` — segmented
  Upcoming/History lists, attention state for past open visits, status chips in
  History, empty states, add FAB.
- `lib/presentation/screens/records/doctor_visit_form_screen.dart` — shared
  Add/Edit form: planned/on-demand toggle (on-demand defaults to completed
  unless "save as scheduled later"), date+time pickers, doctor / clinic-hosp
  contact pickers (bottom sheets filtered by type), reason, notes, reminder
  switch + offset dropdown, save + cancel.
- `lib/presentation/screens/records/doctor_visit_details_screen.dart` — contact
  cards (with "Contact not available" fallback), reminder summary, open-visit
  actions (Mark completed / Mark missed / Reschedule / Cancel), edit + delete
  with confirmation. Terminal states are preserved in History and never
  auto-reopened.
- `lib/presentation/screens/records/records_dashboard_screen.dart` — Doctor
  Visits tile shows an open-visit count badge (hidden when zero).
- `lib/core/router/app_routes.dart` / `app_router.dart` — `recordsDoctorVisits`
  now maps to the real list screen; added
  `/records/doctor-visits/add`, `/records/doctor-visits/:id`,
  `/records/doctor-visits/:id/edit` (unknown ids → `_InvalidRouteScreen`).
- `lib/presentation/screens/profile/care_contact_details_screen.dart` — delete
  guard: refuses permanent deletion when any visit references the contact
  (`contactReferencedByVisits` snackbar).

#### Localization

- `lib/l10n/app_en.arb` / `app_ka.arb` — added ~50 keys (visit types, statuses,
  list/detail/form labels, reminder offsets, empty states, delete guard) with
  natural Georgian translations; `flutter gen-l10n` re-run.

#### Tests (new + updated)

- `test/doctor_visit_entity_test.dart` — entity defaults, `isOpen`,
  `isFutureScheduled`, copyWith incl. clear-contact flags, enum fallbacks.
- `test/doctor_visit_repository_test.dart` — CRUD (no duplicates on update),
  status transitions, archive hides from upcoming, delete, watch streams,
  contact reference guards (incl. open-only counts and archived references).
- `test/doctor_visit_reminder_content_test.dart` — title, body composition
  (doctor/clinic/time/reason, fallback, no profile name), payload round-trip.
- `test/doctor_visit_reminder_service_test.dart` — schedules on the doctor
  visit channel with `isDoctorVisit`, skips disabled/non-scheduled/past
  reminders, cancel cancels main + snooze ids.
- `test/doctor_visit_routing_test.dart` — dashboard tile, open/back, FAB → add.
- `test/notification_action_bridge_test.dart` — updated fakes for the new
  constructor deps + `isDoctorVisit`; new doctor-visit open/snooze action tests.
- `test/care_contact_migration_test.dart` — schema assertion 13 → 14; fresh-create
  doctor_visit_records table/index/column checks; new v13→v14 upgrade test;
  doctor_visit_records added to the surviving-tables list.
- `test/notification_scheduler_cancel_test.dart`,
  `test/settings_grace_period_test.dart` — fakes updated for `isDoctorVisit`.

#### Validation Results (Post-Phase 8C)

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed successfully |
| `flutter analyze` | No issues found |
| `flutter test` | Passed (991/991) |
| `dart run build_runner build` | Success; no drift warnings (ReferenceName applied) |
| Pixel 7 manual | Verified — full flows below |

#### Notes

- **Pixel 7 manual validation (adb/uiautomator)**: Records dashboard tile +
  dashboard badge (shows "1" when an upcoming visit exists, hidden at zero);
  list with Upcoming/History segmented toggle, empty state, Add FAB; Add form
  (visit-type toggle, save-as-scheduled-later switch for on-demand, date/time
  pickers, doctor bottom-sheet selector, clinic empty-eligible snackbar,
  reminder switch + offset); Planned save → "Visit saved" snackbar + tile +
  `zonedSchedule id=5000001 channelId=rehabtrack_doctor_visits`; Details screen
  sections + actions; Mark completed → "Completed · History" with snackbar;
  on-demand default records straight to History as Completed; Reschedule (Edit)
  pre-fills fields, date change Aug 10→Aug 12 updated the SAME record and
  re-scheduled the reminder `id=5000003` to Aug 11 (no duplicate); Cancel visit →
  "Cancelled · History", pending notification removed (dumpsys count 0); Delete →
  confirmation dialog → "Visit deleted"; no FATAL/exception in logcat.
- Doctor Visits reference Care Contacts optionally and by live FK reference;
  archived contacts stay visible in history; deleted/missing references show a
  localized fallback without crashing.
- Reminders default to enabled, 24h before, with 15m/30m/1h/2h/1d/2d/1w options;
  no past reminders are scheduled.
- Missed-rule decision: past scheduled visits are **not** auto-marked missed in
  this phase; they remain visible under an "attention" state until the user
  completes/cancels/reschedules/marks them missed.
- Lab Analyses, Reports, Activities, Diet, attachments, cloud sync, and spoken
  reminders are out of scope this phase.
- Today integration for doctor visits is deferred (kept minimal); the provider
  layer and data layer are ready for a future Today agenda entry.


## Phase 9A — Settings Navigation Refactor

**Goal:** Turn Settings into a dashboard with two destinations (App Settings and
Backup & Restore) without touching settings behavior, notification services, or
storage.

### Navigation

| Route | Screen |
|---|---|
| `/settings` | `SettingsDashboardScreen` (bottom-nav destination) |
| `/settings/app` | `AppSettingsScreen` (was `SettingsScreen`) |
| `/settings/backup-restore` | `BackupAndRestoreScreen` (placeholder) |
| `/settings/notification-diagnostics` | unchanged |

- The bottom navigation Settings destination now opens the Settings dashboard.
- `AppSettingsScreen` holds all previous settings content unchanged; only its
  AppBar title changed from "Settings" to "App Settings" (localized).
- `BackupAndRestoreScreen` is a clean placeholder (icon + coming-soon text +
  non-interactive planned-item list). No backup/restore functionality.
- Unknown/unmatched routes fall back to `_InvalidRouteScreen` via the GoRouter
  `errorBuilder` (previously GoRouter's default red error screen).

### Design

- Settings dashboard reuses the shared `ModuleGrid` + `ModuleGridTile`
  two-column large-icon layout (same as Health / Records / Profile). No new
  visual style and no `ListTile` dashboard.
- Icons: App Settings → `settings_outlined`; Backup & Restore →
  `settings_backup_restore`.

### Notification regression

- The dashboard and child screens are pure `StatelessWidget`s / `ConsumerWidget`s;
  no new `ProviderScope`, no recreated notification services, no stored
  `BuildContext`, and the root navigator keys are untouched. Notification
  initialization, reminder scheduling, permission handling, and Android
  notification settings all remain application-scoped as before.

### Localization (en + ka)

Added `appSettings`, `backupAndRestore`, `backupRestoreComingSoon`,
`createBackup`, `restoreBackup`, `backupInformation`; regenerated via
`flutter gen-l10n`.

### Tests

- `test/settings_navigation_test.dart` (19 tests): 5-tab nav, Settings opens
  dashboard, two-column module grid + equal tile sizes, no reminder controls on
  the dashboard, App Settings opens full settings content, Backup & Restore
  opens placeholder, placeholder has no active actions, back navigation from
  both child screens, tab switching keeps valid state, route-level tests
  (`/settings`, `/settings/app`, `/settings/backup-restore`, unknown child →
  safe fallback), light/dark themes, Georgian, narrow Pixel size, large text.
- `test/settings_grace_period_test.dart` updated for the renamed
  `AppSettingsScreen`.
- Renamed `SettingsScreen` → `AppSettingsScreen`
  (`lib/presentation/screens/settings/app_settings_screen.dart`).

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1022/1022 passed |
| Pixel 7 manual | See below |


## Phase 9B — Backup & Restore: Manual Backup (2026-08-04)

**Goal:** Implement Phase 1 of Backup & Restore — a manual backup that produces
a single `.rtb` archive (database + app-managed photos + settings) and saves it
to a user-chosen location via the system file picker. Restore is deliberately
out of scope and shown as coming soon.

### Archive format (`.rtb`, format version 1)

A `.rtb` file is a standard ZIP archive with these entries, in order:

| Entry | Contents |
|---|---|
| `manifest.json` | Backup metadata (see below) |
| `database.sqlite` | Consistent SQLite snapshot via `VACUUM INTO` |
| `preferences.json` | Allowlisted user settings (`{key: storedValue}`) |
| `files/profile_images/…` | Profile photos (streamed from disk) |
| `files/care_contact_images/…` | Care contact photos (streamed from disk) |

`manifest.json` fields: `backupFormatVersion` (1), `appVersion`, `databaseSchemaVersion`,
`createdAt` (UTC ISO 8601), `platform`, `databaseFileName`, `preferencesFileName`,
`fileCount`, `totalUncompressedSize`, `checksums` (SHA-256 per entry, keyed by
archive path). The format version is independent of the database schema version.

### Key decisions

- **Consistent snapshot:** `VACUUM INTO '<path>'` produces a consistent DB copy
  while the live connection stays open. Validated in a scratch test; the device
  DB uses `journal_mode=delete` (no WAL sidecar today). Drift 2.34.2 has no
  built-in backup API.
- **Destination:** `file_picker.saveFile` drives Android SAF
  `ACTION_CREATE_DOCUMENT` (no broad storage permission). Passing `bytes` lets
  the picker write the archive during document creation. Suggested filename:
  `RehabTrack-Backup-yyyy-MM-dd_HH-mm.rtb`.
- **Preferences:** only user-facing settings are exported (language, grace
  period, reminders, snooze, notification content). Operational metadata such as
  `last_backup_at` is excluded.
- **Managed files:** all files under `profile_images/` and
  `care_contact_images/` are scanned; archive paths mirror the on-disk directory
  names so restore can place them back without renaming. DB-referenced photos
  missing on disk are tolerated and reported as a non-sensitive warning.
- **Path safety:** every archive entry name is validated (no absolute paths, no
  `..`, no backslashes, root entries restricted to the three known files).
- **Last-backup metadata:** `last_backup_at` (ISO 8601) is written to app
  settings only after the archive is successfully stored at the destination.
- **Results:** structured enum (`success`, `cancelled`, `storageFailure`,
  `databaseFailure`, `archiveFailure`, `permissionDenied`, `notEnoughStorage`,
  `operationAlreadyInProgress`, `unexpectedFailure`) mapped to localized UI
  messages.

### Implementation

- `lib/domain/backup/` — `backup_manifest.dart`, `backup_result.dart`,
  `backup_phase.dart`, `backup_operation_state.dart`.
- `lib/data/services/backup/` — `backup_archive_writer.dart`
  (`ZipFileEncoder`, streams files from disk), `backup_storage_gateway.dart`
  (file picker + error mapping), `preferences_exporter.dart` (allowlist),
  `managed_file_collector.dart` (scan + missing-file warnings),
  `backup_service.dart` (orchestration: collect → snapshot → manifest → archive
  → save).
- `lib/presentation/providers/backup_provider.dart` —
  `backupServiceProvider`, `backupOperationProvider`
  (`BackupOperationController`), `lastBackupAtProvider`.
- `lib/presentation/screens/settings/backup_and_restore_screen.dart` — replaced
  the placeholder with the functional backup screen (description, last-backup,
  what's-included, Create backup button with progress, coming-soon restore).
- `lib/core/constants/app_constants.dart` — added `appVersion` and
  `lastSuccessfulBackupKey`.
- Dependencies: added `archive`, `file_picker`, `crypto`.

### Localization (en + ka)

Added backup keys (description, what's-included, progress, success/cancel/fail
dialogs, missing-files note, last-backup labels) and regenerated via
`flutter gen-l10n`.

### Tests

- `test/backup_manifest_test.dart` — JSON round-trip, format-version/validation
  checks, checksum completeness.
- `test/backup_archive_writer_test.dart` — valid ZIP, entry order, path-traversal
  rejection.
- `test/backup_preferences_exporter_test.dart` — allowlist filtering, metadata
  exclusion.
- `test/backup_managed_file_collector_test.dart` — directory scans, missing-file
  warnings, orphan inclusion.
- `test/backup_service_test.dart` — end-to-end archive with verified manifest +
  checksums + restored snapshot; cancel/storage-failure/unexpected mapping;
  injected clock filename.
- `test/backup_provider_test.dart` — controller state transitions, metadata
  write policy, `operationAlreadyInProgress`, `lastBackupAtProvider`.
- `test/backup_screen_test.dart` — renders, progress while running, success /
  cancel / failure dialogs, last-backup display.
- `test/settings_navigation_test.dart` — updated the two placeholder tests to
  assert the functional screen.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1082/1082 passed |
| Pixel 7 manual | Pending — device disconnected from adb mid-session |


## Phase 9C — Backup & Restore: Restore Foundation (2026-08-05)

**Goal:** Implement Phase 2 of Backup & Restore — select a `.rtb` backup via the
Android Storage Access Framework, read and validate it (archive structure,
manifest, checksums, format/schema compatibility, read-only database and
preferences checks), and present a safe preview. Confirming restore does **not**
modify any data yet: the restore engine is deferred to a later phase.

### Decisions (approved)

- **Selection:** SAF `ACTION_OPEN_DOCUMENT` with `application/octet-stream`
  (+`application/zip`) MIME. The file extension `.rtb` is not trusted; archive
  contents are validated independently. The chosen document is copied into an
  app-owned temp file via the content resolver — `content://` URIs are never
  treated as filesystem paths and never exposed. Cancelling the picker is a
  normal outcome, not an error.
- **Full validation before any restore:** the archive must pass every check
  before a preview is shown. Newer backup formats and newer database schemas are
  rejected; older supported schemas are accepted and flagged "migration
  required"; schemas below the minimum are rejected. Unsafe paths, duplicate
  entries and bad checksums are rejected. No sensitive data (profiles, meds,
  measurements, notes, contacts, internal paths) is surfaced in the preview.
- **Phase 2 does not modify data:** no live DB replacement, no preferences/files
  restore, no notification rebuild, no rollback, no migrations, no auto
  commit/push.

### Compatibility rules

- `.rtb` format version must be **exactly 1**; >1 rejected as newer, <1 as
  invalid.
- DB schema ≤ current (14) accepted; equal → "compatible", older → "compatible,
  migration required" (migration strategy covers every `from ≥ 1`).
- DB schema > current → rejected (`newerDatabaseVersion`); <
  `minSupportedDatabaseSchemaVersion` (1) → rejected
  (`unsupportedOldDatabaseVersion`).
- `AppDatabase.currentSchemaVersion = 14` added as the canonical constant; the
  schema getter returns it.

### Archive limits (`BackupLimits`)

| Limit | Value |
|---|---|
| Archive file | ≤ 2 GiB |
| Entry count | ≤ 5000 |
| Per-entry uncompressed | ≤ 512 MiB |
| Total uncompressed | ≤ 4 GiB |
| Compression ratio | ≤ 200:1 |
| Manifest / preferences | ≤ 1 MiB each |

### Policy

- Unknown/undocumented future preference keys are tolerated (do not fail a
  backup merely because a newer version added an optional key); known keys must
  have stable types (`app_language` string; `default_snooze_duration`,
  `next_item_grace_period_minutes` int; the rest boolean).
- Checksum keys must be `database.sqlite`/`preferences.json` or under `files/`;
  anything else is an unsafe key (`invalidManifest`).
- Duplicate archive entry names → `unsafeArchivePath`.
- Profile count is best-effort (`SELECT COUNT(*) FROM profiles`); on the count
  query failing it is omitted (`null`), while `-1` marks an invalid database.

### Validation order (`BackupValidator`)

Duplicates → entry-path safety → entry-count/total size → manifest parse/validate
→ format version → required entries → `fileCount` vs managed files → checksum
presence/coverage → SHA-256 verify each checksummed entry → compatibility → read-only
SQLite check → preferences JSON type check → preview.

### Database / preferences checks (read-only)

- SQLite header magic `"SQLite format 3\0"` checked before opening.
- `database.sqlite` is written to a temp file, opened `OpenMode.readOnly`, and
  closed + deleted in `finally`. It never touches the live DB.
- Cross-checks `db.userVersion == manifest.databaseSchemaVersion`; verifies core
  tables `profiles`, `medications`, `measurement_types`, `app_settings`.

### Implementation

- `lib/domain/backup/` — `restore_phase.dart` (idle/selecting/reading/validating/
  verifying/checking/ready/cancelled/failure), `restore_operation_state.dart`
  (`isRunning`, `isReadyForPreview`), `backup_compatibility.dart`,
  `backup_preview.dart` (no sensitive data; optional `profileCount`),
  `backup_validation_result.dart` (16-result enum incl. `valid`, `cancelled`,
  `newerDatabaseVersion`, `unsupportedOldDatabaseVersion`).
- `lib/data/database/app_database.dart` — `AppDatabase.currentSchemaVersion = 14`.
- `lib/data/services/backup/` — `backup_limits.dart`, `backup_document_gateway.dart`
  (MethodChannel `openDocument`/`copyDocument`), `backup_archive_reader.dart`
  (lazy content, duplicate detection from central-directory headers, size checks
  before decompression; a zero-entry decode is treated as corrupt),
  `backup_validator.dart`, `restore_selection_service.dart`.
- `lib/presentation/providers/restore_provider.dart` — `backupDocumentGatewayProvider`,
  `restoreSelectionServiceProvider`, `backupArchiveReaderProvider`,
  `backupValidatorProvider`, `restoreOperationProvider` (`RestoreOperationController`
  with temp-file handling and cleanup in `finally`).
- `lib/presentation/screens/settings/backup_preview_screen.dart` — compatibility
  banner, details list, warnings, confirm (informational, no data changes).
- `lib/presentation/screens/settings/backup_and_restore_screen.dart` — Restore
  button + progress, mutual exclusion with backup, error dialogs by result,
  removed the coming-soon section.
- `android/app/src/main/kotlin/com/earkania/rehabtrack/MainActivity.kt` —
  `openDocument`/`copyDocument` handlers + `handleOpenDocumentResult`
  (request code 2002).
- `pubspec.yaml` — added `sqlite3: ^3.5.0`.

### Localization (en + ka)

Added the full restore key set (selection/reading/validation/checksum/compatibility
progress, preview labels, each failure message, newer/too-old database messages,
restore/confirm/cancel). Regenerated via `flutter gen-l10n`.

### Tests

- `test/helpers/backup_test_utils.dart` — builds valid `.rtb` archives (SQLite +
  manifest + checksums), raw ZIPs with duplicate entries, temp-file helpers.
- `test/backup_archive_reader_test.dart` — structure, duplicate detection,
  truncated/corrupt, missing-file.
- `test/backup_validator_test.dart` — valid (compatible / migration-required /
  older-app-version), and every rejection (format, schema, missing entries,
  checksum mismatch, unsafe path, duplicates, file-count, invalid DB,
  invalid prefs).
- `test/restore_selection_service_test.dart` — success/cancel/storage-failure,
  copy-target wiring.
- `test/restore_provider_test.dart` — controller phases, ready-for-preview,
  cancel/fail, `operationAlreadyInProgress`, temp cleanup.
- `test/backup_preview_test.dart` — model metadata, banner/details render,
  confirm-without-data, pop.
- `test/backup_restore_ui_test.dart` — mutual exclusion of buttons, progress,
  preview navigation, mapped error dialog, cancelled-does-nothing.
- `test/backup_screen_test.dart` / `test/settings_navigation_test.dart` —
  updated for the Restore button replacing the coming-soon text.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1125/1125 passed |
| Pixel 7 manual | Verified — cancel picker (no error), valid `.rtb` → progress → preview → confirm → not-implemented, invalid file rejected, en+ka, light+dark, no logcat errors |

## Phase 9D — Backup & Restore: Restore Engine (2026-08-05)

**Goal:** Implement Phase 3 of Backup & Restore — a replace-style, all-or-nothing
restore that creates a private safety snapshot of the current live state, stages
and re-validates the selected backup (database, managed files, preferences) in a
temp workspace, swaps the live state atomically, reinitializes database-backed
services, verifies the restored state, and rolls back fully on any failure.
Interrupted operations are detected and recovered on the next app start.

### Scope (Phase 3)

- Replace-style restore only: live state (DB + managed files + preferences)
  mirrors the backup exactly. No merge, no selective/partial restore.
- Migration-required backups (older schema) are gated with a
  "migration not available yet" message; the engine never starts Phase 3 for
  them. Newer schemas are already rejected in Phase 2.
- No notification rebuild: after a successful restore, scheduled notifications
  are cancelled and the user is told reminders must be rebuilt (full rebuild
  deferred to Phase 4). Notification-permission state is untouched.
- No auto backups, no cloud/encryption.

### Key decisions (approved)

- **Safety snapshot before any live change:** `database.sqlite`,
  `preferences.json` (allowlist only) and `profile_images/`/`care_contact_images/`
  are copied into the workspace before the first write. This snapshot is the
  ground truth for rollback and for interrupted-operation recovery.
- **Prepare everything in temp, then swap:** validation of the restored DB
  (SQLite header, `user_version`, core tables, read-only count queries) is
  re-run immediately before the swap, never trusting cached validation. Managed
  files are re-checked against the manifest SHA-256 checksums during extraction.
- **Atomic-ish file swaps via rename:** the live DB (plus WAL/SHM/journal
  sidecars) and each managed root are moved aside into the rollback workspace
  and the prepared files are renamed into place. Any partial failure during the
  move moves already-aside items back before rethrowing.
- **Standalone preference write:** restored preferences are applied directly
  into the live DB file (`app_settings`) by `AppSettingsWriter`, a plain
  sqlite3 read-write session that is decoupled from the app's connection
  lifecycle, so it works both mid-swap and during rollback/recovery.
- **Photo path portability:** `profiles.photoPath` / `care_contacts.photoPath`
  are remapped to `<liveDocumentsDir>/<root>/<basename>` on the prepared DB so
  backups restore correctly to a different device or relocated documents dir.
- **Rollback contract:** a post-swap failure rolls the DB, files and
  preferences back from the safety snapshot, reopens/reinitializes, and
  verifies. Success → `rollbackSucceeded`; the workspace and recovery metadata
  are deleted. Failure → `rollbackFailed`; the workspace and recovery metadata
  are retained for startup recovery. Pre-swap failures never touch the live
  state and report `rollbackSucceeded`.
- **Interrupted recovery:** minimal non-sensitive recovery metadata (operation
  id, phase, workspace path, swap flags) is persisted before the critical
  replacement. On startup, `runStartupRestoreRecovery` detects a non-finalized
  operation and rolls the device back to the safety snapshot, then reopens and
  verifies.
- **Cancellation only pre-swap:** the UI offers Cancel only in safe phases
  (`preparingRestore` → `preparingPreferences`); once the live state is being
  replaced cancellation is ignored and the restore either succeeds or rolls
  back.
- **Privacy:** logs and UI never contain personal data or full internal paths;
  only an operation/recovery id, phase names, format/schema versions, counts,
  sizes and status are shown.

### Implementation

- `lib/domain/restore/` — `restore_apply_phase.dart` (13 progress phases),
  `restore_result.dart` (success, cancelled, validationFailure,
  safetySnapshotFailure, databasePreparationFailure, databaseReplacementFailure,
  managedFileRestoreFailure, preferencesRestoreFailure, reinitializationFailure,
  verificationFailure, rollbackSucceeded, rollbackFailed, migrationNotSupported,
  unexpectedFailure), `restore_failure.dart` (`success` factory; `succeeded`,
  `rollbackFailed`, `originalDataRecovered`; non-sensitive recoveryId),
  `restore_rollback_result.dart`.
- `lib/data/services/restore/` — `restore_workspace.dart` (create/open, layout,
  `deleteEntirely`), `restore_recovery_metadata.dart` (`RestoreRecoveryMetadata`
  + `RestoreRecoveryStore` with lazy base-dir resolver),
  `restore_environment.dart` (abstract environment bound to the live app),
  `restore_image_path_remapper.dart`, `restore_safety_snapshot_service.dart`
  (+ `SafetySnapshotContent`), `restore_database_manager.dart`
  (`prepare`/`validatePrepared`/`RestoreDatabaseSwap` with sidecar handling),
  `restore_file_manager.dart` (extract/replace/restore +
  `restoreManagedFilesFrom`/`copyDirectoryTree`),
  `restore_preferences_manager.dart`, `app_settings_writer.dart`,
  `restore_reinitializer.dart`, `restore_app_environment.dart` (snapshot via
  `VACUUM INTO`, preference writes, provider invalidation,
  `cancelAllNotifications`), `restore_service.dart` (orchestrator),
  `restore_interrupted_recovery_service.dart`.
- `lib/presentation/providers/restore_apply_provider.dart` — `RestoreApplyState`
  (idle/running/finished + applyPhase), `RestoreApplyController`
  (`apply`, `requestCancel`, `reset`; `canCancel` gating),
  `restoreRecoveryStoreProvider`, `restoreApplyProvider`,
  `runStartupRestoreRecovery`.
- `lib/presentation/providers/restore_provider.dart` — validated backup copy
  persisted to `<tempBase>/pending-restore/selected.rtb`; `backupFilePath` in
  state; `reset()` deletes the pending file.
- `lib/presentation/screens/settings/backup_preview_screen.dart` — real restore
  flow: confirm dialog, non-dismissable progress dialog with phase label and
  cancel button (safe phases only), outcome dialog (completed + reminder
  warning, cancelled, migration gate, rollback-recovered, critical
  recovery-required), `restoreApplyPhaseLabel`.
- `lib/presentation/screens/settings/backup_and_restore_screen.dart` — Restore
  covered by `restoreApply.isRunning` mutual exclusion.
- `lib/main.dart` — `runStartupRestoreRecovery(container)` before
  `_warmUpPersistedSettings`.
- Localization: 9 confirm/outcome keys + 13 phase labels added to `app_en.arb`
  and `app_ka.arb`; `flutter gen-l10n` run (generated files never hand-edited).

### Fixed during implementation

- `RestoreImagePathRemapper._columnExists` read `PRAGMA table_info` column 0
  (the cid) instead of column 1 (the column name), so remapping never matched;
  now reads `r[1]`.
- `RestoreService` ignored a `false` verification result and reported success;
  now a failed verification rolls back with `verificationFailure`.
- Pre-swap failures reported `rollback: null`, so the UI could not state that
  the original data was intact; `cleanupAndFail` now sets
  `rollbackSucceeded` (cancellation stays null).
- The preview confirm dialog showed the long replacement sentence as its title
  and "Backup preview" as its body; swapped so the body carries the
  replacement warning.

### Tests

- `test/helpers/restore_test_utils.dart` — `buildRestorableSqliteBytes`,
  `buildRestorableBackupZip`, `readAllowlistedSettings`, `readProfileCount`,
  `FakeRestoreEnvironment` (configurable failures, one-shot reinit failure,
  applied-prefs recording), `writeLiveDatabase`, `writeManagedFile`,
  `managedFileExists`, `BackupSource`.
- Component units: `app_settings_writer_test.dart`, `restore_image_path_remapper_test.dart`,
  `restore_safety_snapshot_service_test.dart`, `restore_database_manager_test.dart`
  (incl. sidecar swap round-trip), `restore_file_manager_test.dart` (checksum
  rejection, replace/restore round-trip), `restore_preferences_manager_test.dart`,
  `restore_recovery_metadata_test.dart`.
- Orchestration: `restore_service_test.dart` — success replaces A with B
  (DB, allowlisted prefs, remapped photo paths, managed files, notifications
  cancelled, workspace cleaned), migration gate, cancel, preview mismatch,
  corrupted archive, snapshot/pause failures, rollback on failed
  reinitialization, `rollbackFailed` retention on failed verification.
- Recovery: `restore_interrupted_recovery_service_test.dart` — none /
  recovered (half-restored B → A) / discarded non-recovery metadata / missing
  workspace / verification failure.
- UI: `restore_apply_ui_test.dart` (fake `RestoreService`) — success dialog +
  reminder warning, cancel button in safe phase only, no cancel during live
  replacement, rollback-recovered, critical recovery-required, cancelled.
  `backup_preview_test.dart` updated for the confirm dialog, invalid-file
  notice and migration gate.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1167/1167 passed |
| Pixel 7 manual | Build/install/launch verified on device — no crashes, no logcat errors, startup-recovery hook clean. Interactive visual flow (data set A → backup → restore → B; photos; en/ka, light/dark; injected-failure recovery; kill/relaunch) scheduled for human verification (agent cannot view screenshots) |


## Phase 9E — Backup & Restore: Compatibility, Migration, Path Repair & Reminder Rebuilding (2026-08-06)

**Goal:** Implement Phase 4 of Backup & Restore — let older-schema backups be
restored by migrating them to the current schema on a temporary copy, repair
stored file paths to the restoring device, and rebuild future reminders after a
restore. Phase 3 already delivered the replace-style engine; this phase removes
the "migration not yet available" gate.

### Key decisions

- **Canonical version policy** (`lib/domain/backup/backup_version_policy.dart`)
  is the single source of truth: current schema = `AppDatabase.currentSchemaVersion`
  (14), oldest restore-compatible = 1 (Drift's cumulative `onUpgrade` covers
  every `from >= 1`), backup format = `BackupManifest.currentFormatVersion` (1).
  `BackupValidator` now reads `minSupportedDatabaseSchemaVersion` from it.
- **Migration runs only on the temp copy.** `RestoreSqliteMigrator`
  (`lib/data/services/restore/restore_sqlite_migrator.dart`) opens the prepared
  workspace copy with `AppDatabase.forTesting(NativeDatabase.createInBackground(file))`,
  lets Drift replay the same cumulative `onUpgrade` blocks, then validates
  schema version, core tables, sample queries and `PRAGMA foreign_key_check`.
  The live database is never migrated in place. Failure aborts before any swap
  and maps to the new `RestoreResult.migrationFailure` (original data intact).
- **Path repair** (`RestoreImagePathRemapper`): canonical persisted form stays
  `<managedRoot>/<dir>/<basename>` (matches how the app persists photo paths and
  how `File(photoPath)` consumers resolve them). It now also normalises
  `content://` URIs, refuses unusable basenames, clears references whose managed
  file is absent from the restored archive (UI falls back to initials/avatars,
  never crashes), only touches the `photoPath` columns, and never rewrites
  `website`/other fields. A `RestorePathRepairReport` surfaces
  `successWithMissingOptionalFiles` when photos are missing.
- **Reminder rebuild** is part of `RestoreEnvironment`
  (`rebuildScheduledNotifications`), implemented by `RestoreAppEnvironment`
  through the existing `NotificationActionBridge.recoverAll(profileId)` so the
  normal scheduling and notification-ID scheme is reused. The bridge's recovery
  methods now return per-type counts. The rebuild runs after verification; a
  failure yields `successWithReminderWarning` (data restore is still success,
  never a rollback of medical data) and the UI offers
  `retryReminderRebuild`. An interrupted rebuild is recovered automatically by
  the existing startup `notificationInitializerProvider.recoverAll`.
- **Durable completion marker:** the recovery metadata is written `finalized:true`
  immediately after verification, so an interruption during reminder rebuilding
  never triggers a rollback of already-restored data.
- Old `RestoreResult.migrationNotSupported` and its "not available yet" gate are
  removed.

### New/changed files

- `lib/domain/backup/backup_version_policy.dart` (new)
- `lib/data/services/restore/restore_sqlite_migrator.dart` (new)
- `lib/data/services/restore/restore_image_path_remapper.dart` (report + content-URI/missing handling)
- `lib/domain/restore/reminder_rebuild_report.dart` (new)
- `lib/domain/restore/restore_result.dart` — added `migrationFailure`,
  `pathRepairFailure`, `databaseVerificationFailure`,
  `successWithReminderWarning`, `successWithMissingOptionalFiles`,
  `reminderRebuildFailure`; removed `migrationNotSupported`.
- `lib/domain/restore/restore_failure.dart` — success-with-warning factories;
  `succeeded` covers them.
- `lib/domain/restore/restore_apply_phase.dart` — added `migratingDatabase`,
  `validatingMigratedDatabase`, `repairingFilePaths`, `rebuildingReminders`.
- `lib/data/services/restore/restore_environment.dart` +
  `restore_app_environment.dart` — `rebuildScheduledNotifications()`.
- `lib/data/services/notification/notification_action_bridge.dart` — recovery
  methods return counts.
- `lib/data/services/restore/restore_service.dart` — migrate on temp copy,
  reordered prepare (database → migrate → files → repair → validate), durable
  marker, reminder rebuild, success variants.
- `lib/data/services/backup/backup_validator.dart` — reads the shared policy.
- `lib/presentation/providers/restore_apply_provider.dart` — new safe phases,
  `retryReminderRebuild`.
- `lib/presentation/screens/settings/backup_preview_screen.dart` — migration
  gate removed, new phase labels, warning outcomes + retry dialog.
- Localization: ~10 new keys added to `app_en.arb`/`app_ka.arb`;
  `flutter gen-l10n` run (generated files never hand-edited).

### Tests

- `test/restore_sqlite_migrator_test.dart` (new) — faithful v13 fixture (real
  Drift schema, `doctor_visit_records` dropped, user_version demoted to 13)
  migrates to 14 and re-adds the table; already-current is a no-op; garbage is
  rejected.
- `test/restore_image_path_remapper_test.dart` — content-URI rewrite,
  missing-file clearing + report, `website` untouched.
- `test/restore_service_test.dart` — older-schema backup now migrates and
  restores (user_version 14, `doctor_visit_records` present);
  failed reminder rebuild still restores data with `successWithReminderWarning`.
- `test/backup_preview_test.dart` — migration-required preview now starts the
  confirmation instead of the "not available yet" gate.
- `test/restore_apply_ui_test.dart` — reminder-warning success dialog now shows
  the "Reminders could not be fully rebuilt" copy (via
  `successWithReminderWarning`).
- `test/helpers/restore_test_utils.dart` — `FakeRestoreEnvironment` implements
  `rebuildScheduledNotifications` with failure hooks and call counting.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1174/1174 passed |
| Pixel 7 manual | Not yet run for the Phase 4 flow (planned: current-schema backup restore, older-schema fixture restore, reminder rebuild for all three types, exact-alarm permission toggling, en/ka, light/dark, force-close/reopen duplicate check) |

Known limitation: automated migration fixtures currently exercise the v13→v14
step (the last cumulative step); older historical steps reuse the identical
production `onUpgrade` code and are covered by the existing in-app upgrade path,
but a full fixture matrix (v1→v14) is a documented follow-up.

## Phase 9F — Backup & Restore: Polish, Hardening & Final Verification (2026-08-06)

**Goal:** Implement Phase 5 of Backup & Restore — harden the backup and restore
flows (archive self-check, storage guards, filename handling, stale-temp
cleanup, recovery retry limits, deeper verification, duplicate-notification
detection), surface Last Backup / Last Restore metadata, polish the screens and
accessibility, and validate the whole feature. No automatic backups, no cloud,
no merge/selective restore, no encryption (all explicit non-goals).

### Key decisions

- **Archive self-check after writing, before saving.** `BackupService` reopens
  the just-written archive with `BackupArchiveReader` and validates entries,
  paths, manifest, `checksumsComplete` and a SHA-256 spot-check. Failure maps to
  `BackupResult.archiveFailure` and the picker save is never offered, so a
  corrupt archive can never reach the user's documents.
- **Storage-space guard on both sides.**
  - Backup: `StorageInspector.freeBytes()` (native `StatFs` on the app cache
    dir, channel `com.earkania.rehabtrack/backup` method `freeBytes`) is compared
    against 2× the archive size → `BackupResult.notEnoughStorage`.
  - Restore: before any live change, the restore workspace size × 2 is compared
    against free space → `RestoreResult.insufficientStorage`, mapped in the
    preview screen to `restoreNotEnoughStorage`. A guard failure leaves the live
    state fully intact (no snapshot, no pause).
- **Filename handling.** `BackupService._sanitizeFileName` strips
  `[\\/:*?"<>|\x00-\x1f]` before suggesting
  `RehabTrack-Backup-yyyy-MM-dd_HH-mm.rtb`; the document provider may rename the
  file, and `BackupStorageGateway.save` now returns
  `BackupSaveResult{result, path, displayName}` (native `createDocument` resolves
  the display name via `OpenableColumns.DISPLAY_NAME` and returns a JSON
  `{uri, displayName}` payload). The provider-reported name is stored as the
  Last Backup display name.
- **Last Backup / Last Restore metadata.** New settings keys
  `last_backup_at` (already existed), `last_backup_display_name`,
  `last_restore_at`. `last_restore_at` is written **only after** the restored
  state and reminder rebuild finalize — never after a rollback or cancellation —
  and restoring never overwrites the last-backup marker. The backup screen shows
  localized "Last backup created: …" + "Stored as: …" and a "Last restore
  completed: …" tile.
- **Startup cleanup** (`RestoreStaleWorkspaceCleaner`): removes
  `restore-workspace` directories not referenced by any `needsRecovery` marker
  (a real interrupted restore is never wiped), abandoned `rehabtrack_backup_*`
  temp dirs, and a stale `pending-restore` copy. Runs from
  `runStartupRestoreRecovery` after recovery.
- **Recovery retry limit.** `RestoreInterruptedRecoveryService` records an
  `attemptCount` in the recovery metadata and stops automatic retries after
  `maxRecoveryAttempts = 3` (`RestoreInterruptedRecoveryResult.recoveryLimitReached`,
  terminal state) so a persistent failure is never retried forever; metadata and
  snapshot are retained for manual action.
- **Deeper restore verification** (`RestoreStateVerifier`, wired into
  `RestoreAppEnvironment.verifyRestoredState`): SQLite header magic, exact
  `userVersion`, presence of all core tables, `COUNT(*)` on each, and the
  managed-files root existing. It never logs row values.
- **Notification duplicate-prevention audit.** `RestoreEnvironment` gained
  `verifyScheduledNotificationsNoDuplicates()`; `RestoreService` detects
  duplicate scheduled notification IDs after the rebuild and downgrades the
  verdict to `successWithReminderWarning` (data is never rolled back for a
  reminder issue).
- **Accessibility & localization.** Semantics live regions on the backup and
  restore progress dialogs, semantics labels for the progress/operations tiles,
  localized date formatting (`LocalizedDateFormat.fullMonthDayYear` +
  `hourMinute`), and five new ARB keys (`backupLastCreated`,
  `restoreLastCompleted`, `restoreCancellationUnavailable`,
  `restoreNotEnoughStorage`, `backupStoredAs`) in en + ka.
- **Negative scope (unchanged):** no automatic backups, no cloud backup, no
  merge/selective restore, no backup encryption.

### New/changed files

- `lib/core/constants/app_constants.dart` — `last_backup_display_name`,
  `last_restore_at` keys.
- `lib/data/services/storage/storage_inspector.dart` (new) — `freeBytes`.
- `lib/data/services/backup/backup_service.dart` — self-check, storage guard,
  filename sanitize, `savedFileName`.
- `lib/data/services/backup/backup_storage_gateway.dart` — `displayName` in
  `BackupSaveResult`, JSON `{uri, displayName}` decode.
- `android/.../MainActivity.kt` — `createDocument` returns JSON payload with
  display name; `freeBytes` method.
- `lib/data/services/restore/restore_state_verifier.dart` (new) — deep verifier.
- `lib/data/services/restore/restore_stale_workspace_cleaner.dart` (new).
- `lib/data/services/restore/restore_interrupted_recovery_service.dart` +
  `restore_recovery_metadata.dart` — `attemptCount`, `maxRecoveryAttempts`,
  `recoveryLimitReached`.
- `lib/data/services/restore/restore_service.dart` — storage guard,
  duplicate-ID detection, `_directoryBytes`.
- `lib/data/services/restore/restore_environment.dart` +
  `restore_app_environment.dart` — `verifyScheduledNotificationsNoDuplicates()`,
  verifier-backed `verifyRestoredState()`.
- `lib/domain/restore/restore_result.dart` — `insufficientStorage`.
- `lib/presentation/providers/restore_apply_provider.dart` — controller writes
  `last_restore_at` on success, `lastRestoreAtProvider`,
  `runStartupRestoreRecovery` cleanup wiring.
- `lib/presentation/providers/backup_provider.dart` — stores
  `last_backup_display_name`, `lastBackupDisplayNameProvider`.
- `lib/presentation/screens/settings/backup_and_restore_screen.dart`,
  `backup_preview_screen.dart` — tiles, wording, a11y, error mapping.
- Localization: 5 new keys in `app_en.arb`/`app_ka.arb`; `flutter gen-l10n` run.

### Tests

- `test/backup_restore_integration_test.dart` (new) — real end-to-end cycle
  (BackupService archive → RestoreService over different live data), a second
  full cycle restoring the newest backup, and no recovery/leftover markers.
- `test/restore_hardening_test.dart` (new) — `RestoreStateVerifier` (valid db,
  missing file, mismatched schema, non-SQLite, missing core table, managed root)
  and `RestoreStaleWorkspaceCleaner` (keeps active workspaces, removes abandoned
  ones + backup temps + stale pending-restore, never touches unrelated cache).
- `test/restore_apply_metadata_test.dart` (new) — `last_restore_at` written only
  on success, never on failure or cancellation.
- `test/backup_service_test.dart` — self-check failure → `archiveFailure` and no
  save; low free space → `notEnoughStorage` and no save; sanitized filename;
  provider-renamed display name exposure.
- `test/restore_service_test.dart` — low free space aborts with
  `insufficientStorage` before any swap; duplicate notification IDs →
  `successWithReminderWarning`.
- `test/restore_interrupted_recovery_service_test.dart` — terminal
  `recoveryLimitReached` state and attempt-counter increments across launches.
- `test/restore_apply_ui_test.dart` — `insufficientStorage` localized message.
- `test/backup_screen_test.dart` — stored-as filename, last-restore tile.
- `test/helpers/restore_test_utils.dart` — `FakeRestoreEnvironment` gained
  `verifyScheduledNotificationsNoDuplicates`, `hasDuplicateNotificationIds`,
  `reopenDatabaseCalls`; test SQLite builder now creates all verifier core tables.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1199/1199 passed (full suite) |
| Pixel 7 manual | Not yet run for the Phase 5 flow (planned below) |

### Remaining manual verification on Pixel 7

1. Create a backup with several photos + reminders; confirm the picker save, the
   success dialog, the "Stored as: …" name, and the Last Backup timestamp.
2. Cancel the backup picker → cancelled dialog; cancel during a safe restore
   phase → "Restore cancelled" (and no cancel button once the swap begins).
3. Restore the current-schema backup; confirm reminders are rebuilt (all three
   types), Last Restore tile updates, and force-close/reopen shows no duplicate
   reminders.
4. Restore an older-schema fixture (v13) → migration path.
5. Corrupt/truncate a `.rtb` → rejected before any change, original data intact.
6. en/ka, light/dark, and screen-reader (TalkBack) pass on the backup screens.
7. Storage-full scenario on the test device (free space below the guard) →
   `notEnoughStorage` / `insufficientStorage` messages and untouched data.

## Phase 10 — Doctor Prescriptions Module (2026-08-09)

**Goal:** Replace the Records placeholder with a full Doctor Prescriptions
archive: list (search / filter / sort / archived toggle), add/edit form with
doctor, clinic/hospital, related doctor visit pickers, details screen with
attachments (PDF/image/photo) and a non-automatic **Create Medication** prefill,
soft archive + permanent delete, and full backup/restore integration. No OCR,
no automatic parsing, no reminder scheduling, no AI (explicit non-goals).

### Key decisions

- **Schema v15 → v16, additive migration.** New `DoctorPrescriptions` and
  `DoctorPrescriptionAttachments` tables with FKs to Profiles (cascade), Care
  Contacts (`setNull`) and Doctor Visit Records (`setNull`); no columns added to
  existing tables. `currentSchemaVersion` moved 15 → 16 across the app and all
  schema-version test fixtures.
- **Managed-file storage mirrors Lab Analyses.** Attachment files live at
  `<appDocs>/doctor_prescriptions/<profileId>/<prescriptionId>/<uuid><ext>`, the
  DB stores the relative path, and delete removes both the row and the file.
  `fileType` = `pdf` | `image` | `other`.
- **Create Medication never auto-saves.** The details screen builds
  `MedicationFormData(name: title, notes: reason+"\n"+notes)` from any non-empty
  title/reason/notes and pushes the existing Medication Add route with it —
  the user still completes and saves. `AddMedicationScreen` gained an optional
  `initialData` parameter (route passes `state.extra`). Empty fields → snackbar.
- **Archive is soft, delete is permanent.** AppBar toggle switches the active ↔
  archived lists; restoring brings a row back to active; delete shows a confirm
  dialog and removes attachment files too.
- **Backup/restore covers attachments.** `ManagedFileCollector` scans the nested
  `doctor_prescriptions` root and tracks DB-referenced attachment paths;
  `RestoreFileManager.managedRootNames` includes the folder, so files round-trip
  exactly like lab analyses.

### New/changed files

- `lib/data/database/tables/doctor_prescription_tables.dart` (new) — both tables
  + indexes.
- `lib/data/database/app_database.dart` — schema 16, migration, imports,
  `doctorPrescriptionDao`.
- `lib/data/database/daos/doctor_prescription_dao.dart` (new) — CRUD, watch,
  archive, search, attachments.
- `lib/domain/entities/doctor_prescription.dart`, `lib/domain/repositories/
  doctor_prescription_repository.dart`, `lib/data/repositories/
  doctor_prescription_repository_impl.dart` (new).
- `lib/presentation/providers/doctor_prescription_provider.dart` (new).
- `lib/presentation/screens/records/doctor_prescriptions_screen.dart`,
  `doctor_prescription_form_screen.dart`, `doctor_prescription_details_screen.dart`,
  `archived_doctor_prescriptions_screen.dart`, `doctor_prescription_attachments_section.dart`
  (new).
- `lib/presentation/screens/activities/add_medication_screen.dart` — `initialData`.
- `lib/core/router/app_routes.dart` / `app_router.dart` — prescription routes +
  `state.extra` prefill wiring.
- `lib/presentation/screens/records/records_dashboard_screen.dart` — grid tile.
- `lib/data/services/backup/managed_file_collector.dart`,
  `lib/data/services/restore/restore_file_manager.dart` — backup integration.
- `lib/l10n/app_en.arb` / `app_ka.arb` — new keys in en + ka.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1216/1216 passed (full suite) |
| Pixel 7 manual | Passed (see below) |

**Pixel 7 manual verification (adb 31140DLH2000KM):** dashboard tile → list →
details (doctor/clinic/attach/date all render); Create Medication prefill
carries the title + reason into the medication form; added a new prescription; the
AppBar toggle shows archived; archive confirm dialog; backup created with the
prescription attachment present in the archive (`files/doctor_prescriptions/1/1/...`);
restore round-trip returned the active + archived prescriptions; delete with
confirm dialog removed the test row. All flows verified via UI hierarchy dump on
`31140DLH2000KM`.

## Phase 10A — Backup & Restore: Manage Backups (2026-08-10)

**Goal:** Add "Manage Backups" (Settings → Backup & Restore → Manage Backups):
list the backups this app created, with detail / restore / share / delete
actions. Enforced scope-storage rules: no `MANAGE_EXTERNAL_STORAGE`, no loose
permissions. Out of scope (explicit non-goals): automatic/retention/scheduled
backups, cloud sync, selective/merge restore, encryption.

### Key decisions

- **Backup Registry.** Scoped storage prevents listing arbitrary user documents,
  so the app tracks every successfully created backup as non-sensitive metadata
  persisted as JSON under the `backup_registry` settings key (via
  `SettingsRepository`): `contentUri`, `displayName`, `createdAt`, `fileSize`,
  `backupFormatVersion`, `databaseSchemaVersion`, `available`. **No patient,
  clinical or personal data and no filesystem paths are stored.**
- **Persisted SAF permissions.** After `ACTION_CREATE_DOCUMENT`, the native side
  calls `takePersistableUriPermission(READ|WRITE)` and reports `persisted` plus
  provider metadata (`displayName`, `size`, `lastModified`) in the
  `createDocument` payload. Registry entries are only written for `content://`
  URIs; a failed registry write never fails an otherwise-successful backup.
- **Availability is probed, never assumed.** The list re-probes every entry via
  the native `queryDocument` (a live document-provider query). Missing/moved/
  revoked documents are shown with an "Unavailable" marker; restore and share are
  disabled for them, delete stays available (to clear the stale entry). The UI
  never silently claims a deleted file still exists. "Last backup" semantics stay
  a creation-event timestamp — distinct from current file availability.
- **Restore reuses the existing pipeline.** "Restore" on a row copies the
  `content://` document to an app temp file via the existing
  `RestoreSelectionService.selectFromUri` → `BackupArchiveReader` →
  `BackupValidator` → `BackupPreviewScreen` → restore-engine flow. No database
  schema migration was needed.
- **Share via ACTION_SEND.** Uses the `content://` URI directly with
  `FLAG_GRANT_READ_URI_PERMISSION` (MIME `application/octet-stream`); filesystem
  paths are never exposed to share targets or the UI.
- **Delete via DocumentsContract.** `deleteDocument` deletes through the provider;
  the registry entry is removed regardless so the list never claims the file
  exists after failure.

### Implementation

- `lib/domain/backup/registered_backup.dart` (new) — registry model + JSON.
- `lib/data/services/backup/backup_registry.dart` (new) — SettingsRepository-backed
  persistence, upsert-by-URI, availability updates, offline-safe decoding.
- `lib/data/services/backup/backup_management_service.dart` (new) — `refresh` /
  `refreshAll` / `share` / `delete` with `BackupDeleteOutcome`.
- `lib/data/services/backup/backup_storage_gateway.dart` — `BackupSaveResult`
  gained `fileSize`/`persisted`; added `queryDocument`, `deleteDocument`,
  `shareDocument`, `hasPersistedPermission` + `BackupDocumentMetadata`.
- `lib/data/services/backup/restore_selection_service.dart` — added
  `selectFromUri` (copy a known URI without the picker).
- `lib/presentation/providers/restore_provider.dart` — added
  `RestoreOperationController.restoreFromUri`; shared validation pipeline
  (`_continueFromSelection`) with `await` kept so the `finally` temp cleanup never
  deletes the work directory mid-operation.
- `lib/presentation/providers/manage_backups_provider.dart` (new) —
  `backupRegistryProvider`, `backupManagementServiceProvider`,
  `manageBackupsProvider` (`ManageBackupsController`).
- `lib/presentation/providers/backup_provider.dart` — registers each successful
  backup (content URI only) in the registry.
- `lib/presentation/screens/settings/manage_backups_screen.dart` (new) — empty /
  load-failed / list states, availability markers, details dialog (restore /
  share / delete with confirmations).
- `lib/presentation/screens/settings/backup_and_restore_screen.dart` — "Manage
  Backups" entry; `lib/core/router/app_routes.dart`, `app_router.dart` —
  `/settings/backup-restore/manage` route.
- `android/app/src/main/kotlin/com/earkania/rehabtrack/MainActivity.kt` —
  `takePersistableUriPermission`, `queryDocument` (via `DocumentsContract.Document.
  COLUMN_LAST_MODIFIED`), `deleteDocument`, `shareDocument`,
  `persistableUriPermission` handlers.
- `lib/l10n/app_en.arb` / `app_ka.arb` — new keys in en + ka.

### Tests

- `test/backup_storage_gateway_test.dart` (new) — payload parsing (URI/name/size/
  persisted), legacy path fallback, ENOSPC mapping, `queryDocument`/`delete`/
  `share`/permission channel calls.
- `test/backup_registry_test.dart` (new) — round-trip, upsert dedupe, ordering,
  corrupt-payload resilience, availability/update/remove.
- `test/backup_management_service_test.dart` (new) — availability probing,
  throwing-gateway tolerance, share/delete outcomes, entry drop on unresolved
  delete.
- `test/backup_restore_from_uri_test.dart` (new) — `restoreFromUri` validates a
  known URI, maps failures, rejects concurrent runs.
- `test/backup_provider_test.dart` — registry registration (content:// only),
  no duplicates.
- `test/manage_backups_screen_test.dart` (new) — empty/list/unavailable states,
  details dialog, delete flow + cancel, restore-confirm cancel, unavailable
  disables restore/share, confirm-restore pop-then-navigate regression (gated
  fake controller reproduces the on-device async gap).

**Bug found & fixed during device validation.** Confirming "Restore" on a row
opened the restore, but the result was silently dropped (and later threw
`Bad state: Cannot use "ref" after the widget was disposed`) because the
details dialog is popped before the restore completes, disposing the dialog's
`context`/`ref`. Fix: `_BackupDetailsDialog` now receives the managing screen's
`WidgetRef` (`parentRef`) and `_confirmRestore` captures the root
`Navigator`/`ScaffoldMessenger` before the pop, so the restore outcome (preview
push or failure snackbar) is surfaced on the still-alive screen.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1283/1283 passed (full suite) |
| `:app:compileDebugKotlin` | Passed |
| Pixel 7 manual | Verified — see below |

**Pixel 7 manual verification (adb `31140DLH2000KM`, uiautomator + logcat):**
Settings → Backup & Restore → Manage Backups: back button appears (left-top) and
returns to Backup & Restore; empty state renders before any tracked backup.
Create backup via SAF save picker → registry entry appears with date + size
(`RehabTrack-Backup-2026-08-10_08-49.rtb`, 4.9 MB). Details dialog shows
date/size/versions + Share / Delete / Close / Restore. Restore → confirmation →
preview opens with full metadata (Compatible, date, app 1.0.0, format 1, DB 17,
profiles 1, managed files 6, size 4.9 MB); back returns to Manage Backups
(restore NOT applied). Share opens the system share sheet ("Sharing 1 file").
Delete → confirmation → entry removed, file gone from Downloads, empty state +
"Backup deleted" snackbar. No logcat errors; `flutter test` regression covers
the disposed-context restore path.

## Phase 10B — Backup & Restore: Import + Unavailable States (2026-08-11)

**Goal:** Extend "Manage Backups" with "Import Existing Backups" (SAF
multi-select, valid with the canonical `BackupValidator`) and full
unavailable-backup lifecycle (probed availability, error-container visuals,
"Remove from List" that never deletes a file, and a "File unavailable" Last
Backup tile). Still no `MANAGE_EXTERNAL_STORAGE`, no loose permissions, no
filesystem enumeration, no commit/push.

### Key decisions (approved design)

- **Import via SAF multi-select.** `ACTION_OPEN_DOCUMENT` with
  `EXTRA_ALLOW_MULTIPLE`; per-URI `takePersistableUriPermission(READ)`. Each
  selection is copied to an app temp file and validated with the canonical
  `BackupValidator`; invalid files are skipped without failing the batch.
  Duplicate URIs refresh the existing entry (contain → update) instead of
  duplicating. Picker cancel never touches the registry; results surface as
  controlled counts (imported / already-present / invalid-skipped).
- **Registry model v2.** `RegisteredBackup` now carries
  `availabilityState` (`BackupAvailability` enum persisted as the stable
  non-localized `name`) plus `lastCheckedAt`/`lastModified`; legacy
  `available` booleans still decode. Only non-sensitive metadata is stored.
- **Availability is probed, never assumed.** Ope/load, pull-to-refresh and
  opening row details re-probe every URI (`queryDocument`); accessible docs also
  get display-name/size/last-modified refreshed (external rename shows the new
  name). Missing/moved/revoked files are marked unavailable and **never
  auto-removed**.
- **Unavailable rows:** `errorContainer`/`onErrorContainer` + `cloud_off`,
  "Unavailable" badge + "Backup file not found", single announced semantics node
  "<name>, Unavailable" (tap kept via `InkWell` under `ExcludeSemantics`).
  Restore/Share disabled; delete becomes "Remove from List".
- **Remove from List** removes the registry entry only — never touches storage.
  Available rows keep delete-document-first, then registry removal; a failed
  registry cleanup marks the entry unavailable so the next refresh repairs it
  rather than showing a deleted file as available.
- **Last Backup tile** keeps "Last backup created: {time}"; adds "File
  unavailable" when the linked registry entry (via the new
  `last_backup_content_uri` key written on each successful backup) is
  unavailable.
- **Native probe hardened:** `queryDocument` verifies accessibility by opening
  (and closing) the input stream rather than trusting a query cursor — Downloads
  returns a synthetic row for a gone `raw:` URI.

### Implementation

- `lib/domain/backup/backup_availability.dart` (new) — enum + stable `storageKey`
  + legacy-bool `fromStorage`.
- `lib/domain/backup/registered_backup.dart` — availability/lastCheckedAt/
  lastModified, `id` => contentUri, copyWith/toJson/fromJson, legacy read.
- `lib/data/services/backup/backup_registry.dart` — `applyProbe`, `update`,
  `contains`, `remove`, `all` (newest-first; unavailable stays in order),
  upsert `add`.
- `lib/data/services/backup/backup_import_service.dart` (new) —
  `BackupImportStatus`/`BackupImportOutcome`/`import()` (temp copy → read →
  validate → upsert, per-file skip/count, temp cleanup).
- `lib/data/services/backup/backup_storage_gateway.dart` —
  `BackupImportDocument`/`BackupImportPickResult`/`pickBackupDocuments`
  (channel `openDocuments`).
- `lib/data/services/backup/backup_management_service.dart` — `refresh` (probe +
  metadata refresh), `refreshAll` (catch → unavailable fallback, no removal),
  `delete` (doc-first; registry failure → `applyProbe` unavailable),
  `removeFromList` (registry only).
- `android/.../MainActivity.kt` — `openDocuments` + `handleOpenDocumentsResult`
  (multi-select, per-URI read grant), `tryTakePersistablePermission(flags)`;
  `queryDocument` accessibility now open-stream based.
- `lib/presentation/providers/manage_backups_provider.dart` — `isImporting`,
  `importBackups`, `refreshOne`, `removeFromList`; `backupImportServiceProvider`.
- `lib/presentation/providers/backup_provider.dart` — writes
  `last_backup_content_uri` on success; `lastBackupAvailabilityProvider`.
- `lib/presentation/screens/settings/manage_backups_screen.dart` — Import button
  + result snackbars; unavailable row visuals/semantics; Remove from List +
  confirmation; details re-probes before opening.
- `lib/presentation/screens/settings/backup_and_restore_screen.dart` — Last
  Backup tile "File unavailable" + invalidate on Manage Backups navigation.
- `lib/l10n/app_en.arb` / `app_ka.arb` — new import/unavailable/remove keys in
  en + ka; `flutter gen-l10n` regenerated app_localizations.

### Tests

- `test/backup_import_service_test.dart` (new) — single/multi import, dedupe
  refresh, cancel, picker failure, invalid-skip-without-failing-batch, copy
  failure counting, temp-creation failure, temp cleanup.
- `test/backup_registry_test.dart` — availability state/`applyProbe`/update,
  stable non-localized persistence, legacy-`available` read, unknown default,
  no-op probe for unknown URIs.
- `test/backup_management_service_test.dart` — rename refresh, probe timestamp
  persistence, unavailable stays listed after `refreshAll`, `removeFromList`
  registry-only, delete marks unavailable when registry cleanup fails.
- `test/manage_backups_screen_test.dart` — Import entry + result snackbars
  (imported/already-present/invalid-skipped/failure/cancel-silent), unavailable
  row semantics + not-found subtitle, disabled Restore/Share, Remove from List
  flow (file untouched), original tests moved to new `availability:` model and
  two-arg controller.
- `test/backup_screen_test.dart` — Last Backup tile shows "File unavailable"
  when linked entry unavailable; keeps "Stored as" when available.

**Bug found & fixed during device validation.** The `queryDocument` probe judged
a document "accessible" from any non-null query cursor; Downloads returns a
synthetic row for a `raw:` URI whose file was already moved, so a renamed/deleted
document was shown as available with size "0 B". Fixed on the native side to open
(and close) the document's input stream as the existence/access probe.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1311/1311 passed (full suite) |
| `:app:compileDebugKotlin` | Passed |
| Pixel 7 manual | Verified — see below |

**Pixel 7 manual verification (adb `31140DLH2000KM`, uiautomator):** Import
Existing Backups opens the multi-select SAF picker; importing a previously
unregistered older backup → "1 backups imported" + row appears with full
metadata (`backupFormatVersion 1`, `databaseSchemaVersion 17` persisted);
re-importing the same file → "1 backups were already in your list and were
updated" with no duplicate; importing a non-backup file → "1 files were not
valid RehabTrack backups and were skipped" with the list unchanged. A moved
file's row becomes Unavailable (error-container row, semantics
"<name>, Unavailable"); its details dialog shows "This file is no longer
available", Restore and Share disabled, and "Remove from List" enabled —
confirming it removes the entry while the physical file stays on disk. A manual
move (provider URI change) marks the original entry unavailable; the Last Backup
tile then shows "File unavailable" (verified on a fresh backup whose
`last_backup_content_uri` was written; legacy pre-key entries fall back to
"Stored as"). Georgian locale shows "არსებული სარეზერვო ასლების იმპორტი" and
"<name>, მიუწვდომელია". All test fixtures removed and device state restored
(3 registered backups, all probed available).

## Phase 10C — Diet Module: Foods + General Guidance (2026-08-11)

**Goal:** Replace the Health → Diet `ModulePlaceholderScreen` with a fully
patient-managed Diet module. Two content sections via a single screen —
**Foods** (Food Guidance: `allowed` / `caution` / `avoid` stable categories,
search / filter / sort / archive / details / edit / permanent delete) and
**General Guidance** (free-form rules: `diet` / `smoking` / `hydration` /
`caffeine` / `alcohol` / `other` categories, search / filter / archive /
details / edit / delete). Patient-managed reference data only — no calorie
tracking, meal planning, nutrition database or AI suggestions. No commit/push.

### Key decisions (approved design)

- **Schema v18.** New `DietItems` (profile-owned, `name`, `category`,
  `foodGroup?`, `notes?`, `source?`, `isArchived`, timestamps) and
  `DietGuidanceRules` (profile-owned, `title`, `category`, `description?`,
  `source?`, `sortOrder?`, `isArchived`, timestamps) tables with explicit
  indexes (`*_profile_idx`, `*_category_idx`, `*_archived_idx`, plus
  `diet_items_name_idx` and `diet_guidance_rules_title_idx` / `_sort_idx`).
  The legacy unused `DietPlans` scaffolding is removed. The `from < 18`
  migration drops the old `diet_items`/`diet_plans`/new `diet_guidance_rules`
  tables (guarded `IF EXISTS`, so idempotent) then recreates — `@TableIndex`
  indexes must be created explicitly via `m.createIndex` because Drift's
  `m.createTable` does not create them.
- **Stable, non-localized categories.** Patient-visible labels are mapped at
  the UI layer (`diet_category_visuals.dart`, theme-derived tint colors, icon
  + semantics label), never persisted. Category values are free-text columns
  (no CHECK constraint), so adding a category requires no migration.
- **Alcohol category (2026-08-11).** Added `alcohol` to General Guidance
  between `caffeine` and `other` — dropdown (add/edit), list filter, list /
  details / archived display all use `local_bar_outlined` + tertiary tint +
  localized label ("Alcohol" / "ალკოჰოლი"). No migration; existing rows
  unchanged; backup/restore covers the whole `database.sqlite`, so alcohol
  records round-trip automatically.
- **Single screen, two sections.** `SegmentedButton<DietSection>` switches
  Foods / General Guidance; each section keeps independent search / filter /
  sort / archive-flag state so switching never loses data.
- **Search/filter/sort.** Rudimentary case-insensitive `LIKE` on name / group /
  notes / source (no transliteration); food sort A–Z / Z–A / by category
  (allowed=0, caution=1, avoid=2, then name); guidance ordered by
  `sortOrder ASC` then `title ASC`.
- **Actions.** Active lists offer details + edit + archive + delete; archived
  lists offer restore + delete + delete confirmation. Archive mode hides the
  FAB and uses the shared `ArchivedToggleButton` selected state (filled icon +
  `secondaryContainer`).
- **Routing.** `/health/diet` → `DietScreen`; `/health/diet/foods/:id`,
  `foods/new`, `foods/:id/edit`, `/health/diet/guidance/:id`, `guidance/new`,
  `guidance/:id/edit` (int-param guarded like record routes).

### Implementation

- `lib/data/database/tables/diet_tables.dart` — rewritten `DietItems` +
  `DietGuidanceRules` with `@TableIndex` annotations.
- `lib/data/database/app_database.dart` — schema v18, `if (from < 18)`
  migration (drop legacy + recreate + explicit `m.createIndex` for all diet
  indexes), table registration updated.
- `lib/data/database/daos/diet_dao.dart` — profile-scoped
  watch/search/insert/update/archive/restore/delete for both tables.
- `lib/domain/entities/diet.dart` — `DietItem` + `DietGuidanceRule` with
  `fromDb` / `toCompanion` / `toUpdateCompanion`.
- `lib/domain/repositories/diet_repository.dart` +
  `lib/data/repositories/diet_repository_impl.dart` — interface + Drift impl.
- `lib/presentation/providers/diet_provider.dart` — food + guidance search /
  filter / sort / archived providers, by-id providers, `DietSection` and
  `activeDietSectionProvider`.
- `lib/presentation/screens/health/diet_screen.dart` — `SegmentedButton`
  sections, per-section search + filter + sort controls, foods/guidance lists
  (with archive mode), empty states, archive-mode restore/delete popups.
- `lib/presentation/screens/health/diet_food_form_screen.dart`,
  `diet_food_details_screen.dart`, `diet_guidance_form_screen.dart`,
  `diet_guidance_details_screen.dart` — add/edit + details (archive/restore/
  delete with confirmation) screens.
- `lib/presentation/screens/health/diet_category_visuals.dart` — stable
  category constants + localized labels + theme-tinted icons.
- `lib/core/router/app_routes.dart` + `app_router.dart` — diet routes wired to
  real screens (placeholder removed).
- `lib/l10n/app_en.arb` / `app_ka.arb` — diet keys; `flutter gen-l10n`
  regenerated `app_localizations.dart`.
- `test/diet_category_visuals_test.dart` (new) — stable `alcohol` value, full
  category list, localized label, `local_bar_outlined` icon, tertiary tint,
  unknown-category fallback.
- `test/backup_restore_integration_test.dart` — added an alcohol guidance
  record backup → restore round-trip test (survives restore intact).

### Tests

- `test/diet_repository_test.dart` (new) — food create/update/archive/restore/
  delete, active/archived watch + A–Z, profile scoping, search by name/group/
  category, archived-inclusion; guidance create/update/archive/restore/delete,
  `sortOrder`→title ordering, search by title/description/category, delete.
- `test/diet_provider_test.dart` (new) — food/guidance active + archived +
  by-id providers, search/filter/sort, food A–Z/Z–A/by-category, section
  switcher; fake repo.
- `test/diet_screen_test.dart` (new) — foods list/categories/empty state/search,
  archive toggle hides FAB, narrow-screen no overflow, Georgian labels; guidance
  switch, preserve-foods-on-switch, archived toggle; fake repo + active profile.
- `test/diet_form_test.dart` (new) — food/guidance forms require name/title in
  en + ka, category dropdown options.
- `test/diet_routing_test.dart` (new) — Health → Diet tile navigation, back
  navigation, Foods FAB route, narrow-screen no overflow (full app).
- `test/care_contact_migration_test.dart` — schema-version assertion updated
  17 → 18; added v17 → v18 diet migration test (data preserved, tables/explicit
  indexes exist, DAO writes work).
- `test/restore_sqlite_migrator_test.dart` — schema16 fixture now migrates
  to 18; "already current" no-op at 18.

### Validation

| Check | Result |
|---|---|
| `flutter gen-l10n` | Completed |
| `flutter analyze` | No issues |
| `flutter test` | 1358/1358 passed (full suite) |
| `:app:compileDebugKotlin` | Passed |

Not committed/pushed — feature branch `feature/diet` only.
