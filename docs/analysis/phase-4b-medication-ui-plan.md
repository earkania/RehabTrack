# Phase 4B — Medication UI & Notification Integration Plan

**Date:** 2026-07-21
**Status:** Step 1 (Foundation) Completed
**Depends on:** Phase 4A (completed — schema v2, dose fields, MedicationAlternatives)

---

## 1. Scope

Phase 4B delivers the medication user interface and connects the notification infrastructure to medication data. This is the first phase with significant presentation-layer work.

### In Scope

| Area | Deliverables |
|---|---|
| Medication CRUD | List, add, edit, detail screens |
| Schedule editor | Visual daily / fixed-times / interval-days editors |
| Medication history | Log timeline, adherence statistics |
| Notification integration | Schedule sync, action callbacks, recovery |
| State management | Riverpod providers for all medication UI state |

### Out of Scope (deferred)

- Administration conditions (requires measurement module)
- Condition-check flow at reminder time
- Medication interaction checking
- Multi-profile medication switching

---

## 2. Architecture Decisions

### 2.1 Routing Strategy

Current routing is flat (`/`, `/health`, `/activities`, `/records`, `/settings`). Phase 4B introduces the first nested/detail routes.

Decision:

Medication screens live under the Activities tab (`/activities`).

Routes:

/activities
    -> ActivitiesScreen (medication list)

/activities/medication/add
    -> AddMedicationScreen

/activities/medication/:id
    -> MedicationDetailScreen

/activities/medication/:id/edit
    -> EditMedicationScreen

/activities/medication/:id/schedule/add
    -> AddScheduleScreen

/activities/medication/:id/schedule/:scheduleId/edit
    -> EditScheduleScreen

/activities/medication/:id/history
    -> MedicationHistoryScreen


Detail and form screens are outside the ShellRoute.

Reason:

- Forms and timelines need maximum screen space
- Bottom navigation should not appear during editing/details
- Existing prefix matching for `/activities` continues to highlight the Activities tab


### 2.2 Screen Widget Pattern

Use existing project conventions.

Rules:

- ConsumerWidget for screens that only read Riverpod providers
- ConsumerStatefulWidget for forms requiring controllers or local state
- No base screen class
- Localization only through AppLocalizations
- No hardcoded user-visible strings


### 2.3 State Management Pattern

Provider responsibilities:

Medication list:
    StreamProvider<List<Medication>>

Single medication:
    FutureProvider<Medication?>

Medication schedules:
    StreamProvider<List<MedicationSchedule>>

Single schedule:
    FutureProvider<MedicationSchedule?>

Medication logs:
    StreamProvider<List<MedicationLog>>

Alternatives:
    StreamProvider<List<MedicationAlternative>>

Adherence statistics:
    Computed Provider

Form state:
    Local ConsumerState state

Notification bridge:
    Provider


### 2.4 Active Profile Provider

Medication queries require only the profile ID.

Create:

activeProfileIdProvider

Type:

Provider<int?>

Implementation:

Returns profile ID 1 for now.

Do not create Provider<Profile>.

Reason:

- Medication repositories only require profileId
- Avoid unnecessary coupling with profile domain
- Future authentication or multi-profile support can replace this implementation without changing medication providers


### 2.5 Notification Scheduling Responsibility

Notification scheduling must not be called directly from UI screens.

Incorrect:

AddScheduleScreen
    |
    +-- createSchedule()
    |
    +-- NotificationScheduler.schedule()


Preferred:

Screen
    |
    v
MedicationRepository
    |
    +-- Save schedule
    |
    +-- Schedule notification


Reason:

- UI remains independent from notification infrastructure
- Scheduling logic exists in one place
- Future synchronization, import, and background operations can reuse the same logic

Repository layer coordinates medication persistence and notification side effects.


### 2.6 Medication Deletion Policy

Medication deletion is logical deletion, not physical deletion.

Delete action:

Medication
    |
    +-- active = false
    +-- endDate = current date


Historical data remains:

Medication
    |
    +-- MedicationSchedule
            |
            +-- MedicationLog


Reason:

- Medical history must never disappear
- Future adherence reports require historical records


### 2.7 Required Additional Providers

Create:

medicationScheduleProvider(scheduleId)


Purpose:

- Load one schedule for EditScheduleScreen
- Avoid loading complete schedule lists when editing one schedule


Pattern:

FutureProvider.autoDispose.family<MedicationSchedule?, int>


### 2.8 Shared Widgets

Create:

lib/presentation/widgets/medication/medication_card.dart


Purpose:

Reusable medication summary component.

Used by:

- Medication list
- Future dashboard
- Search results
- Other medication views


Responsibilities:

- Medication name
- Dose display
- Next dose information
- Active/inactive status


Additional shared widgets:

- EmptyState
- ScheduleTypeSelector
- TimePickerField
- DoseDisplay
- StatusChip


### 2.9 Repository Rules

Presentation layer must communicate only through providers and repositories.

Forbidden in presentation layer:

- NotificationService()
- flutterLocalNotificationsPlugin
- Direct notification scheduling


Allowed architecture:

UI
 |
Provider
 |
Repository
 |
NotificationService


Reason:

Keeps architecture clean and prevents business logic duplication.

---

## 3. Medication Screens

### 3.1 Medication List (Activities Tab)

**File:** `lib/presentation/screens/activities/activities_screen.dart`

This screen replaces the current Activities placeholder and serves as the medication list for Phase 4B.

**Data source:** `medicationRepositoryProvider` → `watchActiveMedications(profileId)`

**Layout:**
- AppBar: "Medications" + FAB (add medication)
- Body: `ListView.builder` of medication cards
- Each card shows: name, dose ("5 mg"), next dose time, schedule summary
- Tap → push to `/activities/medication/:id`
- Empty state: icon + "No medications yet" + "Add your first medication"

**Card content per medication:**
```
┌─────────────────────────────────────┐
│ 💊 Concor 5 mg                      │
│ Daily at 08:00, 20:00               │
│ After breakfast                      │
│ ○ Next dose: tomorrow 08:00         │
└─────────────────────────────────────┘
```

**Providers needed:**
- `medicationListProvider(profileId)` — StreamProvider wrapping `watchActiveMedications`
- `activeProfileIdProvider` — Provider<int?> returning the current profile ID (hardcoded to 1 for now)

### 3.2 Add Medication Screen

**File:** `lib/presentation/screens/activities/add_medication_screen.dart`

**Widget type:** `ConsumerStatefulWidget` (form state + text controllers)

**Form fields:**

| Field | Widget | Required | Notes |
|---|---|---|---|
| Name | `TextFormField` | Yes | Free text |
| Description | `TextFormField` | No | Multiline, optional |
| Dose Amount | `TextFormField` | No | Numeric input |
| Dose Unit | `DropdownButtonFormField` | No | mg, g, ml, units, drops, tablets, etc. |
| Active | `SwitchListTile` | Yes | Default: true |
| Start Date | `DatePicker` | No | Nullable |
| End Date | `DatePicker` | No | Nullable |
| Notes | `TextFormField` | No | Multiline |

**Flow:**
1. User fills form → taps Save
2. `Medication` entity created with profileId = activeProfileIdProvider value
3. `medicationRepositoryProvider.createMedication(medication)` called
4. On success → navigate back to list (pop)
5. On failure → show `SnackBar` error

**After medication is created**, prompt: "Add a schedule for this medication?" with Yes/No. If Yes, navigate to schedule editor.

### 3.3 Edit Medication Screen

**File:** `lib/presentation/screens/activities/edit_medication_screen.dart`

**Widget type:** `ConsumerStatefulWidget`

**Reuses** the same form layout as Add, but pre-populated with existing values. Receives medication ID via route parameter.

**Flow:**
1. Load medication by ID from provider
2. Populate form fields
3. User edits → taps Save
4. `medicationRepositoryProvider.updateMedication(medication)` called
5. On success → pop back to detail screen

### 3.4 Medication Detail Screen

**File:** `lib/presentation/screens/activities/medication_detail_screen.dart`

**Widget type:** `ConsumerWidget`

**Layout:**

```
AppBar: "Medication Name" + Edit button

ScrollView:
  Section: Overview
    - Name
    - Dose: "5 mg"
    - Status: Active / Inactive
    - Start Date / End Date
    - Notes

  Section: Schedules
    - List of active schedules
    - Each shows: type icon, time(s), instructions
    - Tap schedule → edit schedule
    - FAB: Add schedule

  Section: Alternatives (if any)
    - List of alternatives
    - Each shows: name, dose, doctor-approved badge
    - FAB: Add alternative

  Section: History (summary)
    - Last 7 days: taken/missed/skipped counts
    - "View full history" link → push to history screen

  Section: Actions
    - Delete medication (with confirmation dialog)
```

**Providers needed:**
- `medicationProvider(id)` — Provider that fetches a single medication by ID
- `medicationSchedulesProvider(medicationId)` — StreamProvider for schedules
- `medicationAlternativesProvider(medicationId)` — StreamProvider for alternatives
- `adherenceStatsProvider(medicationId)` — Computed provider providing medication adherence statistics

---

## 4. Schedule Editor

### 4.1 Schedule Type Selection

When adding a schedule, the user first selects the type:

```
┌─────────────────────────────────────────┐
│  Schedule Type                           │
│                                          │
│  ○ Daily — same time every day           │
│  ○ Fixed times — multiple times per day  │
│  ○ Interval — every N days               │
└─────────────────────────────────────────┘
```

### 4.2 Daily Schedule Editor

**Fields:**

| Field | Widget | Required |
|---|---|---|
| Time | `TimePicker` (Material) | Yes |
| Start Date | `DatePicker` | No |
| End Date | `DatePicker` | No |
| Instructions | `TextFormField` | No |

**Produces:** `DailySchedule(time: "08:30")`

### 4.3 Fixed Times Schedule Editor

**Fields:**

| Field | Widget | Required |
|---|---|---|
| Times | Dynamic list of `TimePicker`s | Yes (min 1) |
| Start Date | `DatePicker` | No |
| End Date | `DatePicker` | No |
| Instructions | `TextFormField` | No |

**UI:** List of time chips with "+" button to add more times. Each chip shows the time and has a delete icon.

**Produces:** `FixedTimesSchedule(times: ["08:00", "12:00", "20:00"])`

### 4.4 Interval Days Schedule Editor

**Fields:**

| Field | Widget | Required |
|---|---|---|
| Interval | `Slider` or `DropdownButton` (1-30 days) | Yes |
| Time | `TimePicker` | Yes |
| Start Date | `DatePicker` | No |
| End Date | `DatePicker` | No |
| Instructions | `TextFormField` | No |

**Produces:** `IntervalDaysSchedule(interval: 3, time: "14:00")`

### 4.5 Schedule Instructions

All three schedule types share an optional "Instructions" field. This is the `MedicationSchedule.instructions` field — **schedule-specific**, not medication-specific.

Suggested quick-select chips (optional, free text also accepted):
- Before meal
- After meal
- With meal
- On empty stomach
- Before bedtime
- Morning only

These are convenience presets that fill the text field. The user can type custom text.

### 4.6 Schedule Save Flow

1. User configures schedule → taps Save
2. `MedicationSchedule` entity created with `medicationId`
3. `medicationRepositoryProvider.createSchedule(schedule)` called

4. **After schedule is saved**, MedicationRepository coordinates notification scheduling.
The repository:
- saves the schedule
- creates notification configuration
- calls NotificationScheduler.scheduleFromConfig()

UI does not call NotificationScheduler directly.

5. On success → pop back to detail screen

### 4.7 Schedule Update/Delete

**Update:**
UI requests schedule update/delete through MedicationRepository.

Repository responsibilities:
- update database
- cancel old notifications when required
- create new notifications when required

**Delete:**
1. Confirmation dialog: "Remove this schedule?"
2. Cancel notifications for this schedule
3. `medicationRepositoryProvider.deleteSchedule(id)` called

---

## 5. Medication Details Display

### 5.1 Overview Section

Displays from `Medication` entity:
- **Name:** Bold, large text
- **Dose:** Formatted as "{doseAmount} {doseUnit}" — e.g., "5 mg". If both null, show "Not specified"
- **Status:** Green chip "Active" or gray chip "Inactive"
- **Dates:** "Started Jan 1, 2026" / "Ends Dec 31, 2026" — show only if set
- **Notes:** Italic text block, if not null

### 5.2 Schedules Section

Lists all schedules for this medication. Each schedule card shows:

```
┌─────────────────────────────────────┐
│ 🔁 Daily at 08:30                   │
│ "After breakfast"                   │
│ Active ✓                            │
└─────────────────────────────────────┘
```

```
┌─────────────────────────────────────┐
│ 🔁 Fixed times: 08:00, 12:00, 20:00│
│ "With meals"                        │
│ Active ✓                            │
└─────────────────────────────────────┘
```

```
┌─────────────────────────────────────┐
│ 🔁 Every 3 days at 14:00            │
│ Active ✓                            │
└─────────────────────────────────────┘
```

### 5.3 Alternatives Section

Only shown if alternatives exist. Each card:

```
┌─────────────────────────────────────┐
│ Bisoprolol 5 mg                     │
│ ✅ Doctor approved                  │
│ "Generic substitute"                │
└─────────────────────────────────────┘
```

Add alternative form (inline or separate screen):
- Name (required)
- Dose Amount (optional)
- Dose Unit (optional dropdown)
- Doctor Approved (checkbox)
- Notes (optional)

---

## 6. Medication History

### 6.1 History Screen

**File:** `lib/presentation/screens/activities/medication_history_screen.dart`

**Widget type:** `ConsumerWidget`

**Data source:** `medicationLogsProvider(medicationId, from, to)`

The provider aggregates log entries from every schedule belonging to the medication within the selected date range.

**Layout:**
- AppBar: "History — {medication.name}"
- Tab bar: "Week" | "Month" | "All" (date range filter)
- Body: Timeline list of log entries

**Each log entry:**
```
┌─────────────────────────────────────┐
│ ✅ Taken                            │
│ Concor 5 mg                         │
│ Scheduled: Jan 15, 2026 08:00       │
│ Taken at: Jan 15, 2026 08:15        │
│ Note: "After breakfast"             │
└─────────────────────────────────────┘
```

**Status indicators:**
- ✅ Taken — green check
- ⏭ Skipped — yellow skip icon
- ❌ Missed — red X
- ⏳ Pending — gray clock (future doses)

### 6.2 Adherence Statistics

**Computed provider** (derived from logs, not a database query):

```dart
class AdherenceStats {
  final int taken;
  final int missed;
  final int skipped;
  final int pending;
  final int total;
  final double percentage; // taken / (taken + missed + skipped) * 100
}
```

**Display:**
- Circular progress indicator with percentage
- Breakdown: "15 taken, 2 missed, 1 skipped"
- Period: "Last 7 days" / "Last 30 days" / "All time"

### 6.3 Log Creation

Log entries are created in three ways:

1. **Notification action callback** (Taken/Skip) — handled in Section 7
2. **Manual logging** from history screen — "Log a dose" button
3. **Automatic missed detection** — not in Phase 4B scope (requires background service)

---

## 7. Notification Integration

### 7.1 Schedule Creation → Notification Scheduling

**Trigger:** `medicationRepositoryProvider.createSchedule(schedule)` completes successfully

**Action:** MedicationRepository coordinates notification scheduling.

Internally:
MedicationRepository
    |
    +-- NotificationScheduler.scheduleFromConfig()

```
notificationId = schedule.id  (base ID; FixedTimesSchedule uses id, id+1, id+2...)
title = "Time to take {medication.name}"
body = "{dose} — {instructions}"  (e.g., "5 mg — after breakfast")
config = schedule.scheduleConfig
channelType = NotificationChannelType.medication
includeActions = true
```

**Payload:** JSON string containing `{ "scheduleId": X, "medicationId": Y }` — used by action callbacks to identify which dose was acted on.
The payload format should remain stable and backward compatible so notifications scheduled by older application versions can still be processed correctly.

### 7.2 Schedule Update → Re-schedule Notifications

UI requests schedule updates only through MedicationRepository.

Repository responsibilities:
1. Update the schedule in the database
2. Cancel notifications associated with the previous schedule configuration
3. Schedule notifications using the updated configuration
4. Return the updated schedule to the caller

The presentation layer never performs notification management directly.

### 7.3 Schedule Delete → Cancel Notifications

UI requests schedule deletion only through MedicationRepository.

Repository responsibilities:
1. Delete (or deactivate) the schedule
2. Cancel every notification associated with that schedule
3. Ensure no orphaned scheduled notifications remain

The presentation layer never calls NotificationScheduler directly. Notification cleanup is part of the repository operation, keeping persistence and notification state synchronized.

### 7.4 Notification Action Callbacks

**Current state:** `NotificationActionHandler` defines the callback type. `NotificationService.setActionCallback()` registers it. But nothing calls `setActionCallback()` yet.

**Phase 4B action:** Create a `NotificationActionBridge` service that:

1. Is initialized on app start (e.g., from `main.dart` or a provider)
2. Calls `notificationService.setActionCallback(_handleAction)`
3. On action received:
   - Parse payload JSON to get `scheduleId` and `medicationId`
   - **Taken:** Create `MedicationLog(status: 'taken', takenTime: DateTime.now())`
   - **Skip:** Create `MedicationLog(status: 'skipped')`
   - **Snooze:** Re-schedule the same notification for +10 minutes

**File:** `lib/data/services/notification/notification_action_bridge.dart`

**Provider:** `notificationActionBridgeProvider`

### 7.5 Schedule Recovery on App Start

**Current state:** `ScheduleRecoveryService.recoverAllSchedules()` exists but is never called.

**Phase 4B action:**
1. On app start, query all active medication schedules
2. For each schedule, build a `ScheduleRecoveryEntry` with:
   - `notificationIds`: computed from schedule ID and config type
   - `title`: "Time to take {medication.name}"
   - `body`: "{dose} — {instructions}"
   - `config`: `schedule.scheduleConfig`
   - `channelType`: `NotificationChannelType.medication`
   - `includeActions`: `true`
   - `payload`: JSON with scheduleId and medicationId
3. Call `scheduleRecoveryService.recoverAllSchedules(entries)`
4. Recovery must be idempotent. Running recovery multiple times must not create duplicate scheduled notifications.

**Integration point:** Call from `main.dart` after provider initialization, or from a startup service.

### 7.6 Notification Content Examples

| Medication | Schedule | Notification Body |
|---|---|---|
| Concor 5 mg | Daily 08:00 | "Time to take Concor — 5 mg after breakfast" |
| Metformin 500 mg | Fixed 08:00, 20:00 | "Time to take Metformin — 500 mg with meal" |
| Aspirin 100 mg | Every 3 days 14:00 | "Time to take Aspirin — 100 mg" |

---

## 8. State Management

### 8.1 New Providers

| Provider | Type | Purpose |
|---|---|---|
| `activeProfileIdProvider` | `Provider<int?>` | Current user profile (hardcoded to ID 1) |
| `medicationListProvider(profileId)` | `StreamProvider<List<Medication>>` | Active medications list |
| `medicationProvider(id)` | `FutureProvider<Medication?>` | Single medication by ID |
| `medicationSchedulesProvider(medicationId)` | `StreamProvider<List<MedicationSchedule>>` | Schedules for a medication |
| `medicationAlternativesProvider(medicationId)` | `StreamProvider<List<MedicationAlternative>>` | Alternatives for a medication |
| `medicationLogsProvider(scheduleId, from, to)` | `StreamProvider<List<MedicationLog>>` | Logs for a schedule with date range |
| `adherenceStatsProvider(medicationId)` | `Provider<AdherenceStats>` | Computed adherence from logs |
| `notificationActionBridgeProvider` | `Provider<NotificationActionBridge>` | Connects notification actions to logs |



### 8.2 Provider Organization

New providers go in `lib/presentation/providers/medication_provider.dart`, grouped by concern.

**Pattern:**
```dart
// Stream providers for reactive lists
final medicationListProvider = StreamProvider.autoDispose.family<List<Medication>, int>((ref, profileId) {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.watchActiveMedications(profileId);
});

// Future providers for single items
final medicationProvider = FutureProvider.autoDispose.family<Medication?, int>((ref, id) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getMedication(id);
});

// Computed providers (derived state)
final adherenceStatsProvider = Provider.autoDispose.family<AdherenceStats, int>((ref, medicationId) {
  // Watch logs, compute stats
});
```

### 8.3 UI State Flow

**Medication List:**
```
MedicationListScreen (ConsumerWidget)
  └── watches: medicationListProvider(profileId)
  └── state: AsyncValue<List<Medication>>
  └── loading: CircularProgressIndicator
  └── error: ErrorWidget with retry
  └── data: ListView.builder
```

**Add Medication Form:**
```
AddMedicationScreen (ConsumerStatefulWidget)
  └── local state: _nameController, _descriptionController, etc.
  └── on save: ref.read(medicationRepositoryProvider).createMedication(...)
  └── on success: context.pop()
  └── on error: ScaffoldMessenger.showSnackBar(...)
```

**Medication Detail:**
```
MedicationDetailScreen (ConsumerWidget)
  └── watches: medicationProvider(id)
  └── watches: medicationSchedulesProvider(id)
  └── watches: medicationAlternativesProvider(id)
  └── state: combines three AsyncValues
```

---

## 9. Missing Architecture Pieces

### 9.1 Active Profile Provider

**Gap:** No provider exists for the current user profile. All medication queries need `profileId`.

**Solution:** Create `activeProfileIdProvider` that returns the current profile ID.

Implementation returns 1 until authentication/multi-profile support is introduced.

No Profile object is created at this layer.

**File:** `lib/presentation/providers/profile_provider.dart`

### 9.2 AdherenceStats Domain Entity

**Gap:** No domain entity for adherence calculation. The calculation is domain logic, not UI logic.

**Solution:** Create `AdherenceStats` class in `lib/domain/entities/medication.dart` (or a separate file).

```dart
class AdherenceStats {
  final int taken;
  final int missed;
  final int skipped;
  final int pending;
  final int total;
  final double percentage;

  const AdherenceStats({
    required this.taken,
    required this.missed,
    required this.skipped,
    required this.pending,
    required this.total,
    required this.percentage,
  });

  factory AdherenceStats.fromLogs(List<MedicationLog> logs) {
    final taken = logs.where((l) => l.status == 'taken').length;
    final missed = logs.where((l) => l.status == 'missed').length;
    final skipped = logs.where((l) => l.status == 'skipped').length;
    final pending = logs.where((l) => l.status == 'pending').length;
    final total = logs.length;
    final completed = taken + missed + skipped;
    final percentage = completed > 0 ? (taken / completed) * 100 : 0.0;
    return AdherenceStats(
      taken: taken, missed: missed, skipped: skipped,
      pending: pending, total: total, percentage: percentage,
    );
  }
}
```

### 9.3 Notification Action Bridge

**Gap:** `NotificationActionHandler` defines the callback type but nothing registers it or connects it to medication logs.

**Solution:** Create `NotificationActionBridge` service that:
- Registers the callback on initialization
- Parses payload JSON
- Creates `MedicationLog` entries via repository
- Handles snooze by re-scheduling

### 9.4 Schedule Recovery Integration

**Gap:** `ScheduleRecoveryService.recoverAllSchedules()` is never called.

**Solution:** Create a startup hook that:
1. Queries all active medication schedules with their medications
2. Builds `ScheduleRecoveryEntry` list
3. Calls `recoverAllSchedules()` on app start

### 9.5 Empty State Widget

**Gap:** Four screens repeat identical placeholder code.

**Solution:** Extract `EmptyState` widget:

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });
}
```

Update existing placeholder screens to use it.

### 9.6 Localization Keys

**Gap:** No medication-specific localization keys exist.

**Solution:** Add ~50 new keys to `app_en.arb` and `app_ka.arb`:

| Key | English | Georgian |
|---|---|---|
| `medications` | Medications | მედიკამენტები |
| `addMedication` | Add Medication | მედიკამენტის დამატება |
| `editMedication` | Edit Medication | მედიკამენტის რედაქტირება |
| `medicationName` | Medication Name | მედიკამენტის სახელი |
| `doseAmount` | Dose Amount | დოზა |
| `doseUnit` | Dose Unit | დოზის ერთეული |
| `scheduleType` | Schedule Type | გრაფიკის ტიპი |
| `dailySchedule` | Daily | ყოველდღიური |
| `fixedTimesSchedule` | Fixed Times | ფიქსირებული დრო |
| `intervalSchedule` | Interval Days | ინტერვალი დღეებში |
| `instructions` | Instructions | ინსტრუქციები |
| `alternatives` | Alternatives | ალტერნატივები |
| `addAlternative` | Add Alternative | ალტერნატივის დამატება |
| `doctorApproved` | Doctor Approved | ექიმის მიერ დამტკიცებული |
| `history` | History | ისტორია |
| `adherence` | Adherence | მიყოლა |
| `taken` | Taken | მიღებული |
| `missed` | Missed | გამოტოვილი |
| `skipped` | Skipped | გაცდენილი |
| `pending` | Pending | მოლოდინში |
| `noMedicationsYet` | No medications yet | მედიკამენტები ჯერ არ არის |
| `addFirstMedication` | Add your first medication | დაამატეთ თქვენი პირველი მედიკამენტი |
| `scheduleAdded` | Schedule added | გრაფიკი დაემატა |
| `scheduleDeleted` | Schedule deleted | გრაფიკი წაიშალა |
| `confirmDelete` | Are you sure? | დარწმუნებული ხართ? |
| `nextDose` | Next dose | შემდეგი დოზა |
| `logDose` | Log a dose | დოზის აღრიცხვა |

### 9.7 Route Parameters

**Gap:** No route parameters exist in the codebase yet. Phase 4B introduces the first `:id` parameters.

**Decision:** GoRouter handles this natively. The pattern:

```dart
GoRoute(
  path: '/activities/medication/:id',
  builder: (context, state) {
    final id = int.tryParse(state.pathParameters['id'] ?? '');

    if (id == null) {
      return const InvalidRouteScreen();
    }

    return MedicationDetailScreen(medicationId: id);
  },
),
```

No changes to existing routes needed. Only new routes are added.

---

## 10. Implementation Order

### Step 1: Foundation (no UI yet) ✅ COMPLETED

1. Create `AdherenceStats` domain entity ✅
2. Create `activeProfileIdProvider` ✅
3. Create `EmptyState` shared widget ✅
4. Update existing placeholder screens to use `EmptyState` ✅
5. Add localization keys for medication module ✅
6. Run `build_runner` if any new entities require code generation (not needed — AdherenceStats is pure Dart, no code generation required)

### Step 2: Medication CRUD

7. Add medication routes to `app_router.dart`
8. Create `MedicationListScreen` (replaces Activities placeholder)
9. Create `AddMedicationScreen`
10. Create `EditMedicationScreen`
11. Create `MedicationDetailScreen`
12. Create medication providers (`medicationListProvider`, `medicationProvider`)

### Step 3: Schedule Editor

13. Create `AddScheduleScreen` with type selector
14. Implement daily schedule editor
15. Implement fixed-times schedule editor
16. Implement interval-days schedule editor
17. Create `EditScheduleScreen`
18. Create `medicationSchedulesProvider`

### Step 4: Alternatives

19. Create add/edit alternative form (inline in detail screen or separate)
20. Create `medicationAlternativesProvider`

### Step 5: History & Adherence

21. Create `MedicationHistoryScreen`
22. Create `medicationLogsProvider`
23. Create `adherenceStatsProvider`
24. Implement adherence statistics display

### Step 6: Notification Integration

25. Create `NotificationActionBridge` service
26. Create `notificationActionBridgeProvider`
27. Integrate notification scheduling into schedule create/update/delete
28. Integrate schedule recovery into app startup
29. Test notification actions on real device

### Step 7: Polish & Validation

30. Run `flutter analyze` — zero issues
31. Run `flutter test` — all tests pass
32. Test on Pixel 7 — full medication workflow
33. Update `docs/development-progress.md`
34. Commit

---

## 11. File Manifest

### New Files

| File | Purpose |
|---|---|
| `lib/domain/entities/adherence_stats.dart` | AdherenceStats entity |
| `lib/presentation/providers/medication_provider.dart` | All medication UI providers |
| `lib/presentation/providers/profile_provider.dart` | Active profile ID provider |
| `lib/presentation/screens/activities/add_medication_screen.dart` | Add medication form |
| `lib/presentation/screens/activities/edit_medication_screen.dart` | Edit medication form |
| `lib/presentation/screens/activities/medication_detail_screen.dart` | Medication detail |
| `lib/presentation/screens/activities/add_schedule_screen.dart` | Schedule editor |
| `lib/presentation/screens/activities/edit_schedule_screen.dart` | Schedule editor (edit) |
| `lib/presentation/screens/activities/medication_history_screen.dart` | History + adherence |
| `lib/presentation/widgets/empty_state.dart` | Shared empty state widget |
| `lib/presentation/widgets/medication/dose_display.dart` | Dose formatting widget |
| `lib/presentation/widgets/medication/schedule_type_selector.dart` | Schedule type picker |
| `lib/presentation/widgets/medication/time_picker_field.dart` | Time input widget |
| `lib/presentation/widgets/status_chip.dart` | Status indicator chip |
| `lib/data/services/notification/notification_action_bridge.dart` | Action callback bridge |

### Modified Files

| File | Change |
|---|---|
| `lib/core/router/app_router.dart` | Add medication routes |
| `lib/presentation/screens/activities/activities_screen.dart` | Replace placeholder with medication list |
| `lib/presentation/screens/today/today_screen.dart` | Use EmptyState widget |
| `lib/presentation/screens/health/health_screen.dart` | Use EmptyState widget |
| `lib/presentation/screens/records/records_screen.dart` | Use EmptyState widget |
| `lib/l10n/app_en.arb` | Add medication localization keys |
| `lib/l10n/app_ka.arb` | Add medication localization keys (Georgian) |
| `lib/main.dart` | Initialize NotificationActionBridge, schedule recovery |

---

## 12. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Notification actions may not fire on all Android versions | High | Test on Pixel 7 (Android 14+). Document minimum Android version. |
| Schedule recovery may miss notifications if app is force-stopped | Medium | Accept limitation. Boot receiver would fix this but requires native code. |
| Adherence calculation assumes logs are created for every scheduled dose | Medium | Log creation happens on Taken/Skip actions. Missed doses require background service (deferred). |
| Form validation complexity | Low | Use Flutter's built-in `Form` + `GlobalKey<FormState>` pattern. Standard approach. |
| Route parameter parsing errors | Low | Validate ID parsing with try/catch. Show error screen for invalid IDs. |

---

## 13. Testing Strategy

### Unit Tests

- `AdherenceStats.fromLogs()` — verify calculation with various log combinations
- `NotificationActionBridge._parsePayload()` — verify JSON parsing

### Widget Tests

- `MedicationListScreen` — verify empty state, list rendering
- `AddMedicationScreen` — verify form validation, save flow
- Schedule editor — verify time picker integration, schedule config generation

### Integration Tests

- Full workflow: add medication → add schedule → verify notification scheduled → tap Taken → verify log created
- Schedule update: edit time → verify old notification cancelled, new one scheduled
- Schedule delete: delete → verify notifications cancelled

### Device Tests

- Test on Pixel 7: notification appears at scheduled time
- Test notification actions: Taken, Skip, Snooze
- Test app restart: notifications are recovered correctly

---

## 14. Summary

Phase 4B is the largest UI phase to date. It delivers:

- 6 medication-related screens (Activities list, add, edit, detail, schedule editor, history)
- **~12 new providers** for medication state
- **5 shared widgets** extracted for reuse
- **1 new service** (NotificationActionBridge) connecting notifications to data
- **~50 localization keys** in English and Georgian
- **First use of route parameters** in the navigation system

The phase follows existing conventions (ConsumerWidget, GoRouter, Riverpod, AppLocalizations) and introduces no new dependencies. All notification infrastructure from Phase 3 is fully utilized.
