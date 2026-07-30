> This document evolves continuously throughout the project. Before starting any major implementation phase, review this document and report whether any ideas should now become part of the official requirements.

# RehabTrack Design Notes

## Purpose

This file is a living collection of ideas, future improvements, design decisions, usability observations, and real-world scenarios that should be considered during development.

It supplements the official requirements (`docs/requirements/opencode-cardiac-rehab-app-prompt-flutter-v2.md`) and the architecture analysis (`docs/analysis/opencode-rehabtrack-analysis-v3.md`). It should never replace them.

When a note becomes an approved requirement, it should be moved into the official specification while optionally remaining here as historical context.

---

## Design Principles

- RehabTrack is primarily a personal health companion.
- The application should remain simple for everyday use.
- Advanced functionality should be optional.
- The architecture should remain extensible without overengineering.
- The application should work completely offline.
- Privacy is a priority.
- Medical history should never be silently lost.
- Users should be able to customize the application according to their own health needs.
- The application should assist users in following their own health plans, but should not make medical decisions.

---

## Future Ideas

# Medication Management

## Medication alternatives

Some prescribed medications may have acceptable replacements.

The user should optionally be able to define one or more substitute medications.

Example:

Original:
Concor

Alternatives:
- Bisoprolol (generic)
- Another equivalent approved by the doctor

The application should show these alternatives whenever viewing medication details.

This feature is optional per medication.

The application should not recommend replacements automatically. Alternatives are only user-entered information based on advice from a doctor or other trusted source.

---

## Administration guidance

Medication may include guidance such as:

- Before meal
- After meal
- With meal
- On empty stomach
- Before bedtime
- Morning only
- Drink plenty of water
- Avoid alcohol

These instructions should be shown together with medication reminders.

The instructions are informational only.

The application must not provide medical recommendations or change prescriptions. It only reminds the user of instructions they entered or received from a healthcare professional.

---

## Conditional administration

Some medications require checking measurements before taking them.

Example:

Medication:
Concor

Schedule:
10:00

Condition:
Take only if pulse is at least 55 bpm.

Administration conditions should be generic rather than medication-specific.

Possible future conditions may include:

- Pulse
- Blood pressure
- Blood glucose
- Temperature
- Weight
- Custom measurements

The system should allow conditions to be defined per medication but should not contain built-in medical rules.

---

## Medication safety workflow

Some conditional medications may require the user to verify a measurement before confirming that a dose was taken.

Example:

Medication:
Concor

Schedule:
10:00

Condition:
Take only if pulse >= 55 bpm.

Possible future workflow:

1. Notification appears:
   "Time to take Concor"

2. User opens notification.

3. Application checks whether a recent required measurement exists.

4. If no recent measurement exists:
   - Ask the user to enter the required value (for example pulse).
   - Show whether the entered value satisfies the configured condition.

5. If the condition is satisfied:
   - Allow marking the medication as taken.

6. If the condition is not satisfied:
   - Allow skipping the dose.
   - Optionally record the reason.

The application should not decide whether a medication is safe or unsafe. It only helps the user follow their predefined instructions.

---

# Exercise Ideas

Leave space for future exercise planning and rehabilitation features.

Possible future improvements:

- Walking goals
- Exercise schedules
- Activity tracking
- Exercise reminders
- Progress tracking

---

# Health Monitoring Ideas

Leave space for future health tracking improvements.

Examples:

- Wearable integration
- Automatic measurement import
- Trends
- Risk indicators
- Additional health metrics

---

# User Experience Ideas

Record usability improvements whenever discovered during development.

Examples:

- Simplifying daily workflows
- Reducing the number of steps needed for common actions
- Improving visibility of important information
- Making the application easier for elderly users

---

# Measurement Schedules — Design Rule

**Approved:** 2026-07-26

Each `MeasurementSchedule` represents exactly **one scheduled time**.

Multiple daily measurement times (e.g., morning and evening blood pressure) are represented by **multiple independent `MeasurementSchedule` records**, each with its own:

- Notification
- Today agenda occurrence
- Active/inactive toggle
- Start/end date range
- Instructions

This design ensures:

- Disabling one schedule does not affect others
- Each schedule has independent notification lifecycle
- Today agenda shows each occurrence separately
- Users can configure different instructions per time slot

**Medication schedules remain unchanged.** `MedicationSchedule` continues to use `ScheduleConfig` with `times: List<String>` to support multiple times per schedule record, because medication timing semantics differ (multiple times per day is the common case for medications).

---

# Scheduled Action Refinement — Design Rules

**Approved:** 2026-07-26

## Status correction semantics

**Medication:**
- `Completed` → `Change to Skipped` — updates the existing log's status field to `skipped`
- `Skipped` → `Change to Taken` — updates the existing log's status field to `taken`
- `Completed/Skipped` → `Reset to Pending` — deletes the log record for the occurrence, reverting the item to pending

**Measurement:**
- `Completed/Skipped` → `Reset to Pending` — deletes the `MeasurementReminderLog` record for the occurrence, reverting the item to pending

Status correction is best-effort: the menu item is always shown, even if the underlying log record may not exist. If the log is missing, a new log with the target status is created.

## Record Now with occurrence context

When the user taps "Record Now" from the Today screen popup menu, the occurrence context (`scheduledOccurrenceTime` and `reminderScheduleId`) is passed to the measurement entry screen via GoRouter `extra`.

On save, the measurement entry screen marks the corresponding `MeasurementReminderLog` as `completed` if context was provided. This ensures the Today screen reflects the correct status immediately after saving.

The "Add Reading" button on the Measurements screen remains independent — it does not carry occurrence context and does not affect reminder logs.

## Menu structure

**Measurement actionable:** Record Now, Skip, Schedules, History, Trends
**Measurement completed/skipped:** Reset to Pending, Schedules, History, Trends
**Medication actionable:** Mark as Taken, Skip, Details, History
**Medication completed:** Change to Skipped, Reset to Pending, Details, History
**Medication skipped:** Change to Taken, Reset to Pending, Details, History

"Schedules" replaces "Details" for measurement items, navigating to `MeasurementScheduleListScreen`.

---

## Linked measurement readings on completed Today agenda items

When a completed measurement agenda item has a linked `MeasurementRecord` (via `measurementRecordId`), the formatted reading is shown directly below the measurement name on the Today card.

**Display rules:**
- Reading only appears when: `type == measurement && status == completed && readingValues.isNotEmpty`
- Reading is hidden for pending/due/overdue/skipped/snoozed items and for all medication items
- Reading values are batch-loaded in `TodayAgendaService._attachLinkedReadings()`
- Status computation uses `effectiveRangesForCurrentProfileProvider` (reactive to range changes)
- Falls back to `DefaultReferenceRanges` when no profile ranges configured

**Type-specific formatting (reuses existing presentation layer):**
- Blood Pressure: `BloodPressureSummaryText` → `120/80 mmHg, Pulse 66 bpm`
- Weight: `StatusAwareMeasurementValue` → `72.5 kg`
- Blood Glucose: `StatusAwareMeasurementValue` → `5.4 mmol/L`
- Pulse: `StatusAwareMeasurementValue` → `72 bpm`
- SpO2: `StatusAwareMeasurementValue` → `97%` (pulse shown separately)
- Temperature: `StatusAwareMeasurementValue` → `36.6 °C`
- Irregular heartbeat: `Icons.heart_broken` indicator in error color

---

# Future Features

Keep an expandable checklist for ideas that may be implemented later.

- [ ] Multiple profiles
- [ ] Cloud backup
- [ ] Calendar integration
- [ ] Doctor portal
- [ ] Family caregiver mode
- [ ] Smart watch integration
- [ ] Medication interaction checking
- [ ] AI health assistant
- [ ] Voice reminders
- [ ] Home screen widgets
- [x] Patient profiles foundation (Phase 7A)

---

# Patient Profiles — Design Rules

**Approved:** 2026-07-28

## Active profile architecture

The active profile is stored as a setting (`active_profile_id` in `AppSettings`) and managed by `ActiveProfileIdNotifier` (Riverpod `AsyncNotifier`).

**Key design decisions:**

1. **Default on first launch:** When no setting exists and profiles exist, the first profile (alphabetically by firstName) is automatically set as active. This is persisted to settings immediately. The `build()` method writes the setting directly (without `ref.invalidateSelf()`) to avoid a disposal-during-build error.

2. **Setting-only source of truth:** The `isPrimary` flag on the `Profiles` table is a separate concept from the active profile setting. A profile can be primary without being active, and vice versa. The `isPrimary` flag is for display ordering; the `active_profile_id` setting determines which profile's data is shown throughout the app.

3. **Synchronous convenience provider:** `currentActiveProfileIdProvider` is a synchronous `Provider<int?>` that extracts the value from the `AsyncValue`. This allows callers to read the profile ID without dealing with `AsyncValue` wrapping. All existing callers (Today, Medications, Measurements, etc.) use this provider.

4. **Provider invalidation on switch:** `setActiveProfileId()` calls `ref.invalidateSelf()`, which triggers a full rebuild of the notifier. The convenience provider re-reads automatically. Callers that watch `currentActiveProfileIdProvider` rebuild automatically.

## Profile data model

**Relationship to Owner:** Stored as a string key (`self`, `spouse`, `parent`, `child`, `sibling`, `other`) rather than an integer enum value. This makes the database human-readable and extensible without schema changes. The `parsedRelationship` getter on the domain entity provides typed access.

**Profile photo storage:** Photos are stored locally in the app's documents directory under `profile_images/`. The `photoPath` column stores the filename only (not the full path). The `ProfileImageService` handles path resolution. Photos are resized to 512x512 JPEG (quality 85) on import to conserve storage.

**Profile ordering:** Profiles are ordered by `isPrimary DESC, firstName ASC` in all queries. This ensures the primary profile always appears first in lists and is the default selection.

## Multi-profile data isolation

**Phase 7A scope:** All 13 tables with `profileId` foreign keys already exist from Phase 2. Phase 7A activates the active profile setting but does NOT yet implement:
- Profile switching UI (manual selection from a list)
- Profile deletion
- Profile creation (only editing the initial/default profile)
- Data migration between profiles

**Future profile switching:** When implemented, switching profiles only requires updating `active_profile_id` in settings. All providers already filter by profile ID, so data isolation is automatic. No schema changes needed.

---

## Phase 6E — Daily Agenda History and Date Navigation

### Status rules for different date contexts

| Date context | No log with schedule | With log |
|---|---|---|
| **Past** | `missed` | stored action (completed/skipped) |
| **Today** | `due`/`overdue`/`upcoming` (existing logic) | stored action |
| **Future** | `upcoming` | stored action |

### Past date behavior
- Inactive schedules do not generate planned future occurrences
- Historical logs must still be considered even if a schedule is now inactive
- Items use the `missed` status for no-log occurrences (not `overdue`)
- Progress bar and completion percentage hidden for past dates
- "History" summary title shown instead of "Today's Progress"
- Missed count chip displayed (event_busy icon)

### Future date behavior
- Planning view only — no action buttons (Taken/Skip/Snooze/Record Now)
- "Today's Plan" summary title shown
- No progress bar — total count only
- No Next Item card (today-only behavior)

### Date navigation
- Chevron left/right for day-by-day navigation
- Tappable date label opens Material Date Picker
- `Icons.today` return button appears only when selected date is not today
- AppBar title: "Today" for today, "Daily Plan · formatted date" otherwise
- Selected date stored in `selectedAgendaDateProvider` (reset on app launch)

### Schedule start date filtering
- Occurrences must never be generated before the schedule's `startDate`
- `startDate` is inclusive — the schedule appears on its start date
- `_intervalScheduleAppliesOnDate` anchors to the schedule's `startDate` (not `DateTime.now()`)
- `DailySchedule` and `MeasurementSchedule` both check `startDate` before generating
- End date behavior unchanged

### Data precedence for past dates
1. Stored action logs (ground truth)
2. Schedule reconstruction (when no logs exist)
3. Known limitation: inactive schedules may not appear in historical views (documented)

### Known limitations
- Inactive schedules are not queried for past dates (only active schedules processed)
- Historical view limited to schedules that were active when generated

---

# Notes From Real Usage

Create a section specifically intended for recording observations that arise while actually using the application.

This section should become one of the primary sources of future improvements.

Examples:

- Problems discovered during daily usage
- Features that reduce routine effort
- Missing information that would be useful
- Things that are confusing or inconvenient

### Date formatting decision
- All date formatting in Daily Agenda uses `LocalizedDateFormat` utility
- Utility passes `Localizations.localeOf(context).languageCode` to `DateFormat` constructors
- This ensures Georgian month names are used when the app language is Georgian
- Pattern: `fullMonthDayYear` (yMMMMd) for date navigation header, `shortMonthDayYear` (yMMMd) for AppBar subtitle, `hourMinute` (Hm) for agenda item times
- No hardcoded locale strings — all date formatting is locale-aware

### Shared date field widget
- `DateField` widget in `lib/presentation/widgets/common/date_field.dart` is the standard date picker field
- Used by both Medication Schedule editor and Measurement Schedule editor
- Uses `InputDecorator` with `suffixIcon` for calendar icon (placed outside child area)
- Labels wrap naturally — no overflow with long Georgian text
- `onTap` and `onClear` callbacks for parent widget integration

---

## Patient Profile — Photo Selection

### Implementation decisions

- **image_picker** used for gallery and camera selection (no custom camera implementation needed)
- Photos resized to 512x512 JPEG at 85% quality via existing `ProfileImageService.importProfilePhoto()` to conserve storage
- Old photo deleted only after new photo saves successfully — prevents data loss on failure
- `_pendingPhotoPath` tracks photo changes before form save — photo not committed until user taps Save
- Tappable avatar with camera overlay icon provides clear affordance for photo actions
- Bottom sheet presents gallery/camera/remove options — standard Material 3 pattern

### Profile avatar widget

- `ProfileAvatar` in `lib/presentation/widgets/profile/profile_avatar.dart` handles three states:
  1. Photo available: `Image.file()` with `errorBuilder` fallback to initials
  2. No photo: Initials on colored circle (color derived from name hash)
  3. No name: `?` character
- Reused in: view screen, edit screen, Settings tile (with `radius: 20` for compact display)
- Camera overlay icon (white circle + camera icon) appears only in edit mode when tappable

### Camera permission

- `CAMERA` permission added to AndroidManifest.xml for camera capture
- `image_picker` handles runtime permission requests automatically on Android
- Gallery access uses storage permissions (handled by image_picker internally)

## Next Item Grace Period — Design Rules (Approved 2026-07-28)

### Problem

The Next Item overdue grace period was hardcoded (15 minutes). Users needed to configure it for their workflow.

### Design Decision

- **Global setting** (not per-profile) — keep implementation simple; profile-specific deferred
- **Existing key-value storage** (AppSettings Drift table) — no schema change
- **StateNotifierProvider** pattern matching `activeProfileIdProvider` — reads from settings on init, persists on write
- **Reactive**: `nextDailyItemProvider` watches the grace period provider; changing the setting immediately recalculates Next Item without reloading agenda data
- **Domain purity**: `TodayAgenda.nextItem()` accepts optional `Duration? graceWindow` — no repository dependency in domain layer

### Allowed Values

5, 10, 15, 30, 60 minutes. Stored as integer minutes. Invalid/zero/negative values fall back to 15.

### Separation of Concerns

- **Next Item grace period** (configurable): Controls Next-card eligibility after scheduled time. Used in `nextItem()`.
- **Status/due visual window** (`statusGraceWindow`, hardcoded 30 min): Controls due/overdue status classification. Remains separate unless explicitly unified in future design.

### Rationale for Separation

The Next grace period determines whether an unresolved item appears in the "Next" card. The status grace period determines whether an item is styled as "due" (blue tint) vs "overdue" (red tint). These are conceptually distinct — a user might want a short Next card (get to items quickly) but a longer due window (avoid red panic). Keeping them independent is more flexible.

---

# Reliable Reminder Notifications — Design Notes (Approved 2026-07-29)

## Phase 7B Scope

Medication and measurement reminders produce reliable sound, vibration, and heads-up notifications on Android. No TTS, cloud push, or unrelated health modules.

## Notification Channels

Three channels created at startup with `AndroidNotificationChannel`:

| Channel ID | Purpose | Importance | Category |
|---|---|---|---|
| `rehabtrack_medications` | Medication dose reminders | High | alarm |
| `rehabtrack_measurements` | Measurement recording reminders | High | alarm |
| `rehabtrack_general` | Test reminders, general alerts | Default | (none) |

## Vibration Pattern

```
Int64List.fromList([0, 250, 200, 250])
```
— vibrate 250ms, pause 200ms, vibrate 250ms (repeats via channel).

## Notification ID Offsets

| Type | Offset | Range |
|---|---|---|
| Medication | 100,000 | 100000–999999 |
| Measurement | 1,000,000 | 1000000–1999999 |
| Snooze | 2,000,000 | 2000000+ |

Offsets are added to the schedule's `id` to produce unique notification IDs.

## Scheduling Model

- Rolling 30-day horizon: occurrences computed from `scheduleConfig` (Daily or IntervalDays) for the next 30 days.
- Individual (non-recurring) notifications: each occurrence is one `scheduleNotification` call.
- `cancelNotificationsInRange` cancels all future occurrences for a given schedule.

## Action Model

The bridge handles 5 action types:

1. **Taken** — Creates a `MedicationLog` with `taken` status; cancels pending snoozes for this occurrence
2. **Skipped** — Creates a `MedicationLog` with `skipped` status; cancels pending snoozes
3. **Snoozed** — Schedules a single notification `getSnoozeDuration()` minutes from now; cancels pending snoozes first; copies original payload with `snoozeSourceOccurrence` set
4. **Record Now** — Only for measurement; navigates to measurement entry screen with `RecordNowExtra`
5. **Dismiss** — Removes notification; cancels pending snoozes

All action handlers call `_cancelOccurrenceNotifications()` first to prevent duplicate notifications.

## Configurable Reminder Settings

All settings use `StateNotifierProvider` pattern over `SettingsRepository` (key-value, not profile-specific):

| Setting | Default | Provider |
|---|---|---|
| Medication reminders enabled | true | `medicationRemindersEnabledProvider` |
| Measurement reminders enabled | true | `measurementRemindersEnabledProvider` |
| Sound enabled | true | `reminderSoundEnabledProvider` |
| Vibration enabled | true | `reminderVibrationEnabledProvider` |
| Snooze duration (minutes) | 10 | `defaultSnoozeDurationProvider` |

## Snooze Design

- Snooze duration is a `Duration Function()` callback injected into `NotificationActionBridge` — allows runtime configurability without coupling bridge to settings storage
- The factory provider reads from `defaultSnoozeDurationProvider` at bridge creation time
- Re-snoozing: each snooze call first cancels any existing snoozes for that occurrence, then schedules a new one
- Snooze notification ID: `snoozeNotificationId(originalId) = 2000000 + originalId`

## Notification Content

- **Title**: Medication/measurement name
- **Body**: Patient name (if available) + dose info/schedule instructions + "Scheduled for HH:MM"
- **Payload**: JSON-encoded `ReminderPayload` with version, type, profileId, scheduleId, occurrenceTime, medicationId/measurementTypeId, optional snooze source

## Test Reminder

- Schedules a notification on `rehabtrack_general` channel 5 seconds from now
- Body: "This is a test reminder to verify notification sound, vibration, and presentation."
- ID: 999999
- Accessible from Settings → Reminders → Test reminder tile

## Notification Initialization

- `NotificationActionBridge.initialize()` registers the action callback with `NotificationService`
- `scheduleRecoveryService.recoverAll(profileId)` runs after a 2-second delay (to let DB queries settle)
- Recovery iterates all medication and measurement schedules, computes future occurrences, and re-schedules them

## Deferred Items

- Full-screen intent (locked-device presentation) — fallback is high-importance heads-up notification
- In-app reminder banner/queue
- Reminder Details screen (tap notification → navigate to details)
- Notification tap routing through GoRouter
- `main.dart` FutureProvider await (current implementation works on real device)

## Key Files

| File | Purpose |
|---|---|
| `notification_service.dart` | Core plugin wrapper, channels, scheduling, action parsing |
| `notification_scheduler.dart` | 30-day rolling horizon computation |
| `notification_action_bridge.dart` | Action response handling and recovery |
| `reminder_content_formatter.dart` | Notification title/body with patient identity and time |
| `reminder_payload.dart` | Typed JSON payload for notification data |
| `reminder_settings_provider.dart` | Configurable reminder preferences |
| `notification_provider.dart` | Riverpod providers wiring all services |
| `settings_screen.dart` | Reminder settings UI with permission tiles