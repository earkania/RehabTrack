# RehabTrack v2 — Architecture Validation Analysis

## 1. Key Product Goals & Differences from v1

The v2 spec represents a **fundamental scope shift**, not just an iteration:

| Aspect | v1 (Cardiac Rehab) | v2 (Personal Health Companion) |
|---|---|---|
| **Target scope** | Post-stent cardiac rehab only | General-purpose: cardiac, hypertension, diabetes, weight, elderly care, wellness |
| **User model** | `patient` (single row) | `profile` (future multi-profile: self, parents, children) |
| **Medication model** | therapy_course → prescription → prescription_entry (nested) | medication → medication_schedule → medication_log (flat, standalone) |
| **Measurement types** | Hardcoded enum (`blood_pressure`, `glucose`, etc.) | Configurable `measurement_type` table with `is_system` flag + user-created custom types |
| **Exercise** | Not included | Full module: exercise_type, exercise_goal, exercise_log |
| **Health templates** | Not included | Templates (cardiac, diabetes, wellness) as starting configurations |
| **Document storage** | Separate tables: lab_analysis, lab_analysis_file, diet_plan_file | Unified `document_attachment` with category field |
| **Therapy courses** | Central organizing entity | Removed entirely — all modules are independent |
| **Navigation** | Not specified | 5-tab bottom nav: Today, Health, Activities, Records, Settings |
| **Dark mode** | Not mentioned | Explicit light/dark/system support |
| **Reports** | Dose adherence + measurements only | Medication + measurements + exercise |
| **Shopping list** | Included | Removed |

**Bottom line**: v2 is a cleaner, more modular design. Removing therapy courses as the central entity simplifies the data model significantly and makes the app genuinely general-purpose. The profile model is the right call for future multi-person support without over-engineering v1.

---

## 2. Architecture Review

The proposed Clean Architecture with `core/`, `data/`, `domain/`, `presentation/` is sound. A few observations:

**Strengths**:
- Domain layer correctly isolated from Flutter/Drift/Riverpod
- Repository pattern well-defined
- Stream-based reactive data flow (Drift → Repository → StreamProvider → UI) is the right pattern
- GoRouter specified for navigation

**Potential issues**:

1. **`domain/services/` is ambiguous**. The spec lists it but doesn't clarify what goes there vs `data/services/`. Recommendation: keep business logic (schedule calculations, validation) in `domain/`, keep infrastructure (notifications, file I/O, backup) in `data/services/`. The `NotificationScheduler` is infrastructure, not domain.

2. **`core/services/` vs `data/services/` overlap**. The spec puts `notification_service.dart` under `data/services/` but also lists `core/services/`. Recommendation: `core/` should contain only cross-cutting concerns (theme, constants, utils, router). All services belong in `data/services/`.

3. **`domain/repositories/` should hold interfaces only**. The spec lists `domain/repositories/` — this is correct for Clean Architecture (abstract interfaces in domain, implementations in data), but must be enforced. Provider files should depend on domain interfaces, not data implementations.

4. **Missing `core/errors/`**. Listed in the folder structure but never defined. Recommendation: create a simple `Failure` / `Result` type for error handling that propagates cleanly from repositories to providers.

---

## 3. Database Model Review

**v2 schema (17 tables)**:

| Table | Purpose | Notes |
|---|---|---|
| `profile` | Person info | Multi-profile ready; v1 = single row |
| `medication` | Drug info | Standalone, no course link |
| `medication_alternative` | Alternative medications | FK → medication; doctor_approved flag; info only |
| `medication_schedule` | Schedule config (JSON) | Sealed class in Dart |
| `medication_log` | Adherence history | Status: pending/taken/missed/skipped |
| `measurement_type` | Configurable categories | `is_system` flag for built-ins |
| `measurement_record` | Actual readings | Unit stored per row |
| `measurement_schedule` | Optional reminders | Links to measurement_type |
| `exercise_type` | Activity categories | Walking, cycling, etc. |
| `exercise_goal` | Target activity | Links to exercise_type |
| `exercise_log` | Completed activities | Links to exercise_type |
| `doctor` | Personal contacts | Specialty is free-text |
| `doctor_visit` | Appointments | Links to doctor + profile |
| `document_attachment` | Generic file storage | Category field for classification |
| `diet_plan` | Diet guidance | Standalone |
| `diet_item` | Guideline bullets | recommended/avoid/limit |
| `health_template` | Starting configs | configuration_json |
| `app_setting` | Key-value prefs | Language, units, lock, theme |

**Improvements suggested**:

1. **`profile` needs `created_at` and `updated_at`** — listed in the spec but must be enforced in schema for multi-profile support.

2. **`medication_schedule` lacks `profile_id`** — currently only links via `medication_id`. This is fine since medication already has `profile_id`, but consider whether `measurement_schedule` should follow the same pattern (it has `profile_id` directly). Recommendation: keep both patterns — `medication_schedule` via FK to medication is cleaner; `measurement_schedule` with direct `profile_id` is correct since measurements can be standalone.

3. **`document_attachment` category should be extensible** — the spec lists `Lab Result, Prescription, Diet Plan, Other` as categories. For future flexibility, store this as a string (not enum) in the DB so new categories don't require migration. Dart enum in domain for known values, but DB column accepts any string.

4. **`health_template` is read-only data** — consider whether this should be a static asset (JSON file bundled with the app) rather than a DB table. It never changes at runtime. Recommendation: bundle templates as JSON assets, parse at first-run or when user selects a template. Avoids unnecessary DB table.

5. **`exercise_goal` frequency field** — currently just a string. Should this be structured (like `schedule_config` JSON) for future reminder support? Recommendation: use a simple string for v1 (e.g. "daily", "3x per week"), plan for structured schedule in v2.

6. **Missing: `medication.dose_amount` and `medication.dose_unit`** — the v2 spec doesn't include dose info on the medication itself. In v1, `prescription_entry` had `dose_amount` and `dose_unit`. In v2, the `medication` table has `name`, `description`, but no dose fields. This seems like an oversight. **Recommendation: add `dose_amount` and `dose_unit` to `medication` table.**

7. **`medication_alternative` — optional but well-scoped** — supports storing doctor-recommended substitutes for when a prescribed medication is unavailable. Purely informational; the app must never recommend replacements or calculate dose equivalences. The `doctor_approved` boolean is sufficient to distinguish pharmacist-suggested vs user-noted alternatives. Should be displayed on the medication detail screen as an expandable section, not a separate tab. Cascade delete: deleting a medication should delete its alternatives (orphaned alternatives have no meaning). No notification or reminder integration needed — alternatives are reference data only.

---

## 4. Technology Choices Review

| Choice | Verdict | Notes |
|---|---|---|
| **Flutter + Dart** | Correct | Cross-platform potential, strong Android support |
| **Riverpod** | Correct | Best fit for stream-based reactive architecture |
| **Drift** | Correct | Type-safe, migration support, reactive streams |
| **GoRouter** | Correct | Deep links, nested nav, back button handling |
| **fl_chart** | Correct | Lightweight, well-maintained |
| **flutter_local_notifications** | Correct | Standard choice; verify exact-alarm + boot handling |
| **pdf + printing** | Correct | For report generation |
| **share_plus** | Correct | OS share sheet delegation |
| **local_auth + crypto** | Correct | Biometric + hashed PIN |
| **archive** | Correct | ZIP export/import |
| **syncfusion_flutter_pdfviewer** | Verify | License model — free for ≤$1M revenue, but verify terms for direct APK distribution |

**Missing dependencies to add**:
- `url_launcher` — spec mentions `tel:` for calling doctors but it's not in the dependency list
- `go_router` — listed as preferred but not in dependency list
- `json_annotation` + `json_serializable` — for schedule_config JSON serialization (or use manual to/fromJson)
- `freezed` — optional but recommended for sealed classes with serialization

**Recommendation on syncfusion**: `flutter_pdfview` or `pdfx` are MIT-licensed alternatives if syncfusion licensing is a concern. Verify terms before committing.

---

## 5. Final Implementation Plan

### Phase 1 — Project Foundation
- Update `pubspec.yaml` with all dependencies
- Create full folder structure (`core/`, `data/`, `domain/`, `presentation/`)
- Configure Material 3 theme with light/dark/system support
- Set up GoRouter navigation skeleton
- Set up `l10n/` with `app_en.arb` + `app_ka.arb` and `flutter gen-l10n`
- Configure AndroidManifest permissions
- Configure release signing (`key.properties`, `build.gradle`)
- Set `applicationId` to `com.earkania.rehabtrack`

### Phase 2 — Database & Core Data Layer
- Define all Drift tables (17 tables, excluding `health_template` as static asset)
- Implement migration strategy (schema versioning)
- Implement `ScheduleConfig` sealed class (`DailySchedule`, `FixedTimesSchedule`, `IntervalDaysSchedule`)
- Implement all 7 repositories (`ProfileRepository`, `MedicationRepository`, `MeasurementRepository`, `ExerciseRepository`, `DoctorRepository`, `DocumentRepository`, `SettingsRepository`)
- Implement `AppSettingRepository` for key-value preferences
- Seed `measurement_type` table with built-in types on first run
- Seed health templates from bundled JSON assets

### Phase 3 — Notification Infrastructure
- `NotificationScheduler` service (create/cancel/reschedule)
- `ScheduleRecoveryService` (app-start re-sync of all active schedules)
- Notification action callbacks (Taken/Snooze/Skip) updating `medication_log`
- Boot-completed rescheduling
- Battery optimization exemption prompt
- AndroidManifest: `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `VIBRATE`

### Phase 4 — Medication Module
- Medication CRUD screens
- Medication alternatives: add/edit/delete alternatives on medication detail screen (expandable section)
- Visual schedule editor (daily, fixed_times, interval_days)
- Medication list with status indicators
- Medication history (calendar/timeline + adherence stats)
- Notification integration test on real device

### Phase 5 — Measurements & Charts
- `measurement_type` management (view built-ins, create custom)
- Type-specific entry forms (BP, weight, glucose, custom)
- History list with date filtering
- Trend charts via `fl_chart`
- Unit preference from settings, stored per record

### Phase 6 — Exercise Module
- Exercise type management
- Goal setting and tracking
- Activity logging
- Today Dashboard exercise progress section

### Phase 7 — Doctors & Appointments
- Doctor directory (CRUD + `tel:` call via `url_launcher`)
- Appointment CRUD with reminder configuration
- Upcoming/past visit lists

### Phase 8 — Documents, Diet & Reports
- Unified document attachment (camera, gallery, PDF pick)
- In-app document viewing (images + PDF)
- Diet plan management (3-category guidelines)
- Report generation (PDF/CSV) for medication, measurements, exercise
- `share_plus` handoff

### Phase 9 — Security, Settings & Backup
- App lock (biometric + hashed PIN)
- Settings screens (language, theme, notifications, units, security)
- Language switching with notification reschedule
- Backup/restore (ZIP export/import with validation)

### Phase 10 — Today Dashboard & Polish
- Today Dashboard with all sections (medications, measurements, exercise, upcoming events, health summary)
- Missed-item catch-up on app launch
- Form validation pass
- Release build testing
- README

---

## 6. Missing Requirements & Decisions to Clarify

1. **Medication dose fields missing from spec** — `medication` table has no `dose_amount` or `dose_unit`. Need to add these or the medication list can't show "100 mg" as shown in the UI examples.

2. **`health_template` as DB table vs static asset** — Recommendation: static JSON assets, not DB table. Needs confirmation.

3. **`url_launcher` missing from dependency list** — Required for `tel:` doctor calls. Must be added.

4. **`go_router` missing from dependency list** — Listed as preferred navigation but not in pubspec dependencies.

5. **Exercise reminder mechanism** — The spec mentions "exercise reminders" in `ScheduleRecoveryService`, but `exercise_goal` has no `schedule_config` or reminder mechanism. Exercise reminders may need a separate schedule table or be deferred to v2.

6. **Multi-profile in v1** — The spec says "does not need to be implemented in Version 1" but "architecture should not prevent future support." All tables should have `profile_id` FK to be future-ready, but the UI only shows/manages one profile.

7. **Theme persistence** — The `app_setting` key `theme = dark` is listed, but the spec doesn't specify how the theme provider reads/updates this. Need a `ThemeMode` state notifier connected to `app_setting`.

8. **PDF license** — `syncfusion_flutter_pdfviewer` requires license verification for commercial use. Alternatives: `pdfx`, `flutter_pdfview` (both MIT).

9. **Exercise report format** — v2 mentions exercise reports but doesn't specify what fields. Recommendation: date range, exercise type filter, export as PDF/CSV with columns: date, type, duration, distance, notes.

10. **Notification snooze action** — The spec shows "Snooze" button on notifications but `medication_log` has no snooze field. Need either: (a) snooze creates a new pending `medication_log` entry for the snoozed time, or (b) add a `snoozed_until` field. Recommendation: option (a) — cleaner.

11. **Medication alternatives — UI placement** — Alternatives should appear as an expandable/collapsible section on the medication detail screen, not a separate tab or screen. This keeps the information visible when needed without cluttering the primary medication view. The section should show alternative name, dose (if provided), source (doctor-approved badge), and notes. No actions beyond add/edit/delete — no "switch to alternative" or dose comparison logic.
