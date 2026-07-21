# RehabTrack — Technical Plan Summary

## 1. Architecture

Clean Architecture with three layers: **presentation** → **domain** → **data**. Presentation contains screens, widgets, and Riverpod providers. Domain holds plain Dart entities, enums, and the `ScheduleConfig` sealed class (no Flutter dependencies). Data contains Drift database, DAOs, repository implementations, and services (notifications, file storage, backup). SQL never leaks into widgets.

## 2. Folder Structure

```
lib/
├── core/          # theme, router, localization helpers, utilities
├── data/
│   ├── database/      # Drift tables, migrations
│   ├── repositories/  # 10 repository classes (one per aggregate)
│   └── services/      # NotificationScheduler, FileStorage, Backup
├── domain/
│   ├── entities/      # Pure Dart model classes
│   └── enums/         # Status/type enums
├── presentation/
│   ├── screens/       # ~19 screen directories
│   ├── widgets/       # Reusable components
│   └── providers/     # Riverpod providers (one per domain)
l10n/                  # app_en.arb, app_ka.arb
```

## 3. State Management

**Riverpod** — compile-safe, no context required, works with `Stream`s from Drift. Each repository exposes `Stream<List<T>>` methods wrapped by `StreamProvider`, so UI rebuilds automatically on DB writes. Form state uses `StateNotifierProvider`. Settings and locale use `StateNotifierProvider` for immediate rebuild on change.

## 4. Main Modules/Features

| Module | Key Functionality |
|---|---|
| Today Dashboard | At-a-glance daily view: doses, measurements, upcoming visit, diet summary, missed-item catch-up |
| Therapy Courses | CRUD, soft delete (archive), prescription entries with schedule editor UI |
| Dose Tracking | Scheduled reminders with notification actions (Taken/Snooze/Skip), adherence log + stats |
| Measurements | BP/glucose/weight/custom entry, trend charts via `fl_chart`, unit preference from settings |
| Lab Analyses | Attach photos/PDFs, in-app viewing, download to device, delete with confirmation |
| Doctors & Visits | Directory with `tel:` call handoff, appointment CRUD with configurable reminders |
| Diet Plans | 3-category guideline lists (recommended/avoid/limit), file attachments, history |
| Reports & Sharing | Date-range PDF/CSV generation, doctor email pre-fill, `share_plus` handoff |
| Backup/Restore | Full ZIP export (DB JSON + files), validated import with destructive-restore confirmation |
| App Lock | Optional biometric (`local_auth`) or hashed PIN, off by default |
| Localization | EN/KA via ARB files + `flutter gen-l10n`, all strings translatable, notifications rescheduled on language change |

## 5. Data Models

15 tables: `patient`, `therapy_course`, `prescription`, `prescription_entry`, `dose_log`, `measurement_schedule`, `measurement_reading`, `lab_analysis`, `lab_analysis_file`, `doctor`, `doctor_visit`, `diet_plan`, `diet_guideline_item`, `diet_plan_file`, `app_setting` (key-value).

**Schedule config** stored as JSON text in `prescription_entry` and `measurement_schedule`, parsed via a Dart sealed class (`FixedTimesPerDaySchedule` / `IntervalDaysSchedule`) — new schedule types added later without schema migration.

Dates stored as UTC in DB; wall-clock strings in schedule config. Next fire time recomputed per trigger, not once at schedule time.

## 6. Backend/API

**None.** Fully offline, local-only. Database is Drift over SQLite (app-private). Files stored via `path_provider`. Notifications via `flutter_local_notifications` + `AlarmManager`. Export via ZIP (`archive` package). Sharing via `share_plus` (OS share sheet). No network permissions requested.

## 7. Development Phases

1. **Setup** — Dependencies, permissions, theme, router, localization scaffold, release signing config.
2. **Database & Data Layer** — All 15 Drift tables, 10 repositories, `ScheduleConfig` sealed class, migration strategy.
3. **Notification Infrastructure** — `NotificationScheduler`, action callbacks, boot rescheduling, battery exemption prompt.
4. **Core Screens** — Today Dashboard, Patient Info, Therapy Courses, Prescriptions, Dose Log.
5. **Measurements & Charts** — Entry forms, history, trend charts, unit preferences.
6. **Doctors, Visits & Diet** — Directory, appointments, diet plan management.
7. **Lab Analyses** — File pickers, in-app viewing, download, delete.
8. **Reports, Sharing & Backup** — PDF/CSV generation, `share_plus`, ZIP export/import.
9. **Security & Settings** — App lock, notification permissions, language switching.
10. **Polish** — Validation, missed-item catch-up, debug logging strip, README.

## 8. Key Risks & Decisions

| Decision | Recommendation |
|---|---|
| **Drift vs sqflite** | Drift — type-safe queries + automatic migration support justify codegen overhead for 15 tables. |
| **Notification reliability under Doze** | Verify plugin empirically on real devices; fallback: thin native `BroadcastReceiver` via platform channel. Always prompt battery exemption. |
| **DST safety** | Recompute fire times from wall-clock strings per trigger, never store fixed absolute timestamps. |
| **Language change + pending notifications** | Reschedule all pending notifications when locale changes (listen to locale provider). |
| **Encrypted DB** | Defer to `sqlcipher_flutter_libs` as follow-up; note in README as planned. |
| **PIN storage** | Hash with salt via `crypto`; never plaintext. Gate behind `app_setting` row. |
| **Single-patient enforcement** | App logic only — `patient` table always has one row; no multi-user UI needed. |
