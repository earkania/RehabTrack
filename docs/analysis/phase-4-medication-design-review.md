# Phase 4 — Medication Module Design Review

**Date:** 2026-07-21
**Purpose:** Validate that the current architecture and database design are ready for medication implementation.

---

## 1. Current Medication Data Model

### Entity: Medication

| Field | Type | Status |
|---|---|---|
| `id` | `int?` | Implemented |
| `profileId` | `int` | Implemented |
| `name` | `String` | Implemented |
| `description` | `String?` | Implemented |
| `active` | `bool` | Implemented |
| `startDate` | `DateTime?` | Implemented |
| `endDate` | `DateTime?` | Implemented |
| `notes` | `String?` | Implemented |
| `createdAt` | `DateTime` | Implemented |
| `updatedAt` | `DateTime` | Implemented |
| `doseAmount` | `String?` | **MISSING** |
| `doseUnit` | `String?` | **MISSING** |

### Entity: MedicationSchedule

| Field | Type | Status |
|---|---|---|
| `id` | `int?` | Implemented |
| `medicationId` | `int` | Implemented |
| `scheduleType` | `String` | Implemented |
| `scheduleConfig` | `ScheduleConfig` | Implemented |
| `startDate` | `DateTime?` | Implemented |
| `endDate` | `DateTime?` | Implemented |
| `instructions` | `String?` | Implemented |
| `active` | `bool` | Implemented |
| `administrationCondition` | `String?` | **MISSING** |

### Entity: MedicationLog

| Field | Type | Status |
|---|---|---|
| `id` | `int?` | Implemented |
| `medicationScheduleId` | `int` | Implemented |
| `scheduledTime` | `DateTime` | Implemented |
| `takenTime` | `DateTime?` | Implemented |
| `status` | `String` | Implemented |
| `notes` | `String?` | Implemented |
| `createdAt` | `DateTime` | Implemented |
| `conditionResult` | `String?` | **MISSING** |

### Relationship Chain

```
Profiles (id)
  └── Medications.profileId (FK)
        └── MedicationSchedules.medicationId (FK)
              └── MedicationLogs.medicationScheduleId (FK)
```

This relationship chain is correct and supports the required queries.

---

## 2. ScheduleConfig Design

### Current Implementation (Sealed Class)

```dart
sealed class ScheduleConfig
    ├── DailySchedule          { time: String }
    ├── FixedTimesSchedule     { times: List<String> }
    └── IntervalDaysSchedule   { interval: int, time: String }
```

### Assessment: Ready

- All three schedule types specified in requirements are implemented
- JSON serialization/deserialization works correctly
- The sealed class pattern allows future schedule types without DB migration
- The `NotificationScheduler` already converts these to Android notifications

### Future Extension Point

The sealed class pattern supports adding new schedule types (e.g., `WeeklySchedule`, `CustomIntervalSchedule`) by adding new subclasses. The `NotificationScheduler._scheduleFromConfig` switch statement will require updating, but no database migration is needed.

---

## 3. Medication History & Adherence

### Current Status: Ready

The `MedicationLog` entity and DAO support:
- Creating log entries on dose events
- Querying logs by schedule ID with optional date range
- Filtering by status (pending, taken, missed, skipped)

### Adherence Statistics

Adherence calculation is not yet implemented but the data model supports it:
- `taken` count: `logs.where(status == 'taken').length`
- `missed` count: `logs.where(status == 'missed').length`
- `skipped` count: `logs.where(status == 'skipped').length`
- Adherence percentage: `taken / (taken + missed + skipped) * 100`

This should be implemented as a domain-level calculation, not a database query.

---

## 4. Notification Integration

### Current Status: Ready

Phase 3 completed the notification infrastructure:
- `NotificationService` handles low-level notification operations
- `NotificationScheduler` converts `ScheduleConfig` to scheduled notifications
- `ScheduleRecoveryService` restores notifications on app start
- Notification actions (Taken, Snooze, Skip) are defined

### Integration Points for Phase 4

When a medication schedule is created/updated/deleted:
1. Call `NotificationScheduler.scheduleFromConfig()` with the schedule
2. Include medication name, dose, and instructions in notification text
3. On app start, `ScheduleRecoveryService` restores all active medication notifications

When a notification action is received:
1. `NotificationActionHandler` provides the callback
2. Phase 4 must connect this to `MedicationRepository.logDose()`
3. Create a `MedicationLog` entry with the appropriate status

---

## 5. Gaps Requiring Database Migration

### Gap 1: Dose Information

**Required by:** Analysis v3 point 6, Requirements UI spec
**Impact:** High — medication list cannot show "100 mg" without this

Add to `Medications` table:
```
doseAmount  TextColumn  .nullable()
doseUnit    TextColumn  .nullable()
```

Add to domain entity:
```dart
class Medication {
  ...
  final String? doseAmount;
  final String? doseUnit;
  ...
}
```

### Gap 2: Medication Alternatives

**Required by:** Analysis v3 point 7, Design notes
**Impact:** Medium — informational only, not blocking core functionality

Create new table `MedicationAlternatives`:
```
id              IntColumn     autoIncrement()
medicationId    IntColumn     references(Medications, #id)
name            TextColumn    required
doseAmount      TextColumn    .nullable()
doseUnit        TextColumn    .nullable()
doctorApproved  BoolColumn    withDefault(Constant(false))
notes           TextColumn    .nullable()
createdAt       DateTimeColumn required
```

Create domain entity:
```dart
class MedicationAlternative {
  final int? id;
  final int medicationId;
  final String name;
  final String? doseAmount;
  final String? doseUnit;
  final bool doctorApproved;
  final String? notes;
  final DateTime createdAt;
}
```

### Gap 3: Administration Guidance — Schedule-Specific

**Required by:** Analysis v3 point 8, Design notes
**Impact:** Medium — informational, shown in notifications

**Clarification:** Administration instructions are **schedule-specific**, not medication-specific. A medication can have different instructions depending on the schedule:

- Morning dose: "after breakfast"
- Evening dose: "before bedtime"

The existing `MedicationSchedule.instructions` field is the correct location for this. No separate table is needed.

**Already implemented:**
```dart
class MedicationSchedule {
  ...
  final String? instructions;  // Schedule-specific guidance
  ...
}
```

**Recommended approach:** Use the `instructions` field on `MedicationSchedule` to store free-text guidance. Optionally, add a `guidanceCategory` field to classify the instruction type (e.g., `beforeMeal`, `afterMeal`).

Add to `MedicationSchedules` table (optional enhancement):
```
guidanceCategory  TextColumn  .nullable()  (enum stored as string)
```

Create domain enum:
```dart
enum AdministrationGuidanceCategory {
  beforeMeal,
  afterMeal,
  withMeal,
  emptyStomach,
  beforeBedtime,
  morningOnly,
  drinkWater,
  avoidAlcohol,
  other,
}
```

### Gap 4: Administration Condition

**Required by:** Analysis v3 point 9, Design notes
**Impact:** Low for v1 — can be deferred to later phase

Add to `MedicationSchedules` table:
```
administrationCondition  TextColumn  .nullable()  (JSON)
```

Create domain sealed class:
```dart
sealed class AdministrationCondition {
  factory AdministrationCondition.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson();
}

class MeasurementCondition extends AdministrationCondition {
  final String measurementType;
  final String operator;  // 'gte', 'lte', 'gt', 'lt', 'eq'
  final double threshold;
  final String unit;
}
```

### Gap 5: Condition Result

**Required by:** Analysis v3 point 14
**Impact:** Low for v1 — only needed when conditions are implemented

Add to `MedicationLogs` table:
```
conditionResult  TextColumn  .nullable()
```

---

## 6. Priority Assessment for Phase 4

### Must Have (Block Core Functionality)

| Item | Reason |
|---|---|
| `doseAmount` / `doseUnit` on Medication | UI cannot display medication details without this |
| Medication CRUD screens | Core feature |
| Schedule editor (visual) | Users must create schedules |
| Medication list with status | Primary view |
| Notification integration | Core feature |

### Should Have (Important but Not Blocking)

| Item | Reason |
|---|---|
| Medication alternatives | Informational, can be added as expandable section |
| Schedule-specific instructions | Already implemented in `MedicationSchedule.instructions` |
| Medication history (calendar/timeline) | Adherence tracking |

### Could Have (Defer to Later)

| Item | Reason |
|---|---|
| Administration conditions | Complex, requires measurement module integration |
| Condition-check flow | Depends on conditions being implemented |
| Condition result logging | Depends on conditions being implemented |

---

## 7. Recommended Phase 4 Scope

### In Scope

1. **Database migration to schema v2:**
   - Add `doseAmount` and `doseUnit` to `Medications` table
   - Create `MedicationAlternatives` table
   - (Optional) Add `guidanceCategory` to `MedicationSchedules` table

2. **Domain entities:**
   - Update `Medication` with dose fields
   - Create `MedicationAlternative` entity
   - (Optional) Create `AdministrationGuidanceCategory` enum
   - Create `AdministrationCondition` sealed class (for future use)

3. **Data layer:**
   - New DAOs for alternatives
   - Update MedicationDao with new queries
   - Update repository implementations

4. **UI screens:**
   - Medication list screen
   - Medication detail screen (with alternatives section)
   - Add/edit medication screen
   - Schedule editor (visual, not JSON)
   - Medication history screen

5. **Notification integration:**
   - Connect notification actions to medication logs
   - Include schedule-specific instructions in notification body
   - Reschedule notifications when medication changes

### Out of Scope (Defer to Phase 5+)

- Administration conditions (requires measurement module)
- Condition-check flow at reminder time
- Condition result logging

---

## 8. Migration Strategy

### Schema Version 1 → 2

The migration should:
1. Add `doseAmount` TEXT column to `Medications` table (nullable, no default needed)
2. Add `doseUnit` TEXT column to `Medications` table (nullable, no default needed)
3. Create `MedicationAlternatives` table
4. (Optional) Add `guidanceCategory` TEXT column to `MedicationSchedules` table

No existing data is affected. All new columns are nullable or have defaults.

### Code Changes Required

| File | Change |
|---|---|
| `lib/data/database/tables/medication_tables.dart` | Add columns, add new tables |
| `lib/data/database/app_database.dart` | Bump schema version, add migration |
| `lib/data/database/daos/medication_dao.dart` | Add new query methods |
| `lib/domain/entities/medication.dart` | Add dose fields |
| `lib/domain/entities/` (new) | Create alternative entity |
| `lib/domain/enums/enums.dart` | (Optional) Add guidance category enum |
| `lib/data/database/app_database.g.dart` | Regenerate via build_runner |

---

## 9. Architecture Compliance

### Clean Architecture Boundaries

| Layer | Medication Responsibility | Status |
|---|---|---|
| Domain | Entities, enums, repository interfaces, schedule calculations | Compliant |
| Data | DAOs, repository implementations, notification service | Compliant |
| Presentation | UI screens, providers | Compliant |

### Key Rules

- UI must not call `flutter_local_notifications` directly — use `NotificationScheduler`
- Domain must not import Flutter or plugin packages — already enforced
- Repository interfaces live in `domain/repositories/` — already implemented
- Repository implementations live in `data/repositories/` — already implemented

---

## 10. Summary

### Readiness Assessment

| Aspect | Status | Notes |
|---|---|---|
| Database schema | Partial | Missing dose fields, alternatives table |
| Domain entities | Partial | Missing dose fields, alternative entity |
| Repository pattern | Ready | Interfaces and implementations exist |
| Schedule model | Ready | Sealed class hierarchy complete |
| Schedule instructions | Ready | `MedicationSchedule.instructions` field exists |
| Notification infrastructure | Ready | Phase 3 complete |
| DAO layer | Partial | Needs new queries for alternatives |
| Migration strategy | Ready | Schema v1 → v2 is straightforward |

### Conclusion

The architecture is sound. The main gaps are:
1. **Dose information** on the Medication entity (must fix before UI)
2. **MedicationAlternatives** table (can add in Phase 4 or defer)
3. **AdministrationCondition** (defer to measurement module integration)

Administration instructions are **schedule-specific**, not medication-specific. The existing `MedicationSchedule.instructions` field is the correct location. A medication can have different instructions per schedule (e.g., "after breakfast" for morning dose, "before bedtime" for evening dose).

Phase 4 can proceed with a database migration to add the missing columns and tables. The existing notification infrastructure is ready for integration. The sealed class pattern for schedules supports future extension without migration.
