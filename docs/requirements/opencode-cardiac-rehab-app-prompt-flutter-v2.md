# OpenCode Agent Prompt — RehabTrack
## Personal Health Companion (Flutter, Android)

---

# Project Vision

RehabTrack is a modern Android application built with Flutter whose purpose is to help people manage their personal health information, daily health routines, medications, measurements, appointments and rehabilitation programs.

The application was initially inspired by the developer's own recovery after coronary angiography and coronary stent implantation. During recovery, several daily activities became important:

- taking medications on time
- measuring blood pressure and pulse
- monitoring recovery progress
- following doctor's recommendations
- maintaining regular walking and exercise
- organizing medical documents and laboratory results

Although cardiac rehabilitation is the initial use case, the application must **not** become a cardiac-only application.

Instead, RehabTrack should become a flexible personal health companion that can be adapted to many different medical conditions and health goals.

Examples include:

- Cardiac rehabilitation
- Hypertension management
- Diabetes monitoring
- Weight management
- Healthy lifestyle tracking
- Elderly care
- Long-term medication management
- General wellness

The application should remain simple enough for everyday users while being flexible enough to grow in the future.

---

# Design Philosophy

RehabTrack is **not** intended to become:

- a hospital information system
- an electronic medical record (EMR)
- a clinic management system
- a doctor portal
- a cloud healthcare platform

Instead, it should remain focused on helping individuals organize and monitor their own health.

The application should always prioritize:

- simplicity
- reliability
- offline availability
- privacy
- flexibility

---

# Long-Term Vision

Version 1 is intended primarily for the developer's personal use.

Future versions may be shared with friends, family members, or other users with similar health needs.

Although the application is primarily designed for one user, the architecture should not prevent future support for multiple profiles.

Examples:

- A user managing their own health.
- An adult child helping elderly parents.
- A caregiver tracking another family member's medications.

This capability should be considered during database and architecture design, but **does not need to be implemented in Version 1**.

---

# Primary Goals

The application should help users:

- remember medications
- track medication adherence
- record health measurements
- monitor long-term trends
- manage doctor visits
- organize laboratory results
- follow exercise recommendations
- manage diet recommendations
- generate reports
- securely store personal medical information

The application should never attempt to:

- diagnose illnesses
- replace doctors
- recommend treatments
- prescribe medications
- interpret laboratory results medically

Medical decisions always remain the responsibility of qualified healthcare professionals.

---

# Initial Functional Scope

Version 1 should include:

- Personal profile
- Medication management
- Medication reminders
- Dose history
- Blood pressure tracking
- Pulse tracking
- Blood glucose tracking
- Weight tracking
- Custom measurements
- Walking and exercise tracking
- Doctor directory
- Doctor visits
- Laboratory result storage
- Diet recommendations
- Reports
- Backup & Restore
- Localization
- Application security

---

# User Model

The application is designed around **Profiles** rather than Patients.

A Profile represents one person whose health information is stored.

Initially, only one profile ("My Profile") is required.

The application architecture should make future support for multiple profiles straightforward without requiring major database redesign.

Example future structure:

Profiles

• Me

• Father

• Mother

• Child

No cloud synchronization is required.

No user accounts are required.

No login is required.

---

# Offline First

RehabTrack is an offline-first application.

All data must be stored locally on the device.

No Internet connection should be required for normal operation.

Cloud synchronization may be added in a future version but must not influence Version 1 architecture.

---

# Supported Platform

Initial target platform:

Android

Flutter should remain cross-platform where practical, but Android is the only required platform.

iOS, Windows, Linux and macOS support may be added later.

---

# Technology Stack

Framework

- Flutter (Stable)

Language

- Dart

State Management

- Riverpod

Database

- Drift (SQLite)

Dependency Injection

- Riverpod Providers

Architecture

- Clean Architecture

Pattern

- Repository Pattern

Navigation

- GoRouter (preferred)

Charts

- fl_chart

Notifications

- flutter_local_notifications

Scheduling

- Android AlarmManager where required

Localization

- flutter_localizations
- intl
- ARB translation files

File Storage

- path_provider

Document Picker

- file_picker

Image Picker

- image_picker

PDF Viewer

- syncfusion_flutter_pdfviewer

PDF Generation

- pdf
- printing

Sharing

- share_plus

Permissions

- permission_handler

Security

- local_auth
- crypto

Backup

- archive

---

# Architectural Principles

The project must follow Clean Architecture.

The application should be divided into:

presentation/

domain/

data/

core/

Rules:

- Flutter widgets must never access the database directly.
- SQL must remain inside the data layer.
- Business logic belongs to the domain layer.
- UI should depend only on providers and domain models.
- Database implementation should be replaceable without changing UI code.

The application should be maintainable, testable and scalable.

---

# General Design Principles

The application should emphasize:

- Material 3
- clean UI
- large touch targets
- accessibility
- responsive layouts
- dark mode support
- localization from the beginning

Every visible string must come from localization resources.

Hardcoded user-visible strings should not exist anywhere in the application.

# Data Model and Database Design

## General Database Principles

The database must be designed around personal health management rather than clinical rehabilitation management.

Important principles:

- Health records should be independent.
- A user can record measurements without having a therapy program.
- A user can take medication without having a rehabilitation course.
- Exercise tracking should work independently.
- Historical data should never be silently deleted.
- The database should allow future multi-profile support.

Use:

- SQLite database
- Drift ORM
- Migration support from the beginning
- Repository pattern

All dates/timestamps must have a clearly defined strategy.

Recommended:

- Store absolute timestamps as UTC.
- Store user schedules as local wall-clock values.
- Recalculate future events from local schedule information.

This prevents problems with:

- timezone changes
- daylight saving changes
- travel

---

# Main Entities

## profile

Represents a person whose health information is managed.

Version 1:

Only one profile is active.

Future:

Multiple profiles may exist.

Fields:

```
id
first_name
last_name
birth_date
gender
height_cm
weight_kg
blood_type
allergies
emergency_contact_name
emergency_contact_phone
notes
created_at
updated_at
```

---

# Medication Module

## medication

Stores medication information.

Fields:

```
id
profile_id
name
description
active
start_date
end_date
notes
created_at
updated_at
```

Examples:

```
Aspirin
Bisoprolol
Atorvastatin
```

A medication itself does not contain scheduling information.

Scheduling is separated.

---

## medication_schedule

Defines when medication should be taken.

Fields:

```
id
medication_id
schedule_type
schedule_config
start_date
end_date
instructions
active
```

Schedule configuration is stored as JSON.

Examples:

Daily:

```json
{
"type":"daily",
"time":"08:00"
}
```

Multiple times:

```json
{
"type":"fixed_times",
"times":[
"08:00",
"20:00"
]
}
```

Every N days:

```json
{
"type":"interval_days",
"interval":3,
"time":"09:00"
}
```

The Dart model should use sealed classes for schedules.

Example:

```
ScheduleConfig

    DailySchedule

    FixedTimesSchedule

    IntervalDaysSchedule
```

Future schedule types should not require database migration.

---

## medication_log

Stores actual medication history.

Fields:

```
id
medication_schedule_id
scheduled_time
taken_time
status
notes
created_at
```

Status:

```
pending
taken
missed
skipped
```

This table is the source for adherence statistics.

---

# Health Measurement Module

## measurement_type

Defines available measurement categories.

Built-in examples:

```
Blood Pressure
Heart Rate
Weight
Blood Glucose
Temperature
```

Users may create custom types.

Fields:

```
id
profile_id
name
unit
measurement_category
is_system
active
```

Examples:

System:

```
Blood Pressure
```

Custom:

```
Sleep Quality
```

---

## measurement_record

Stores actual measurements.

Fields:

```
id
profile_id
measurement_type_id
timestamp
value_primary
value_secondary
value_tertiary
unit
notes
created_at
```

Examples:

Blood pressure:

```
value_primary = systolic
value_secondary = diastolic
value_tertiary = pulse
```

Weight:

```
value_primary = 82.5
unit = kg
```

Glucose:

```
value_primary = 110
unit = mg/dL
```

The stored unit must always remain with the record.

Changing user preferences later must not change historical data.

---

# Measurement Reminder Module

## measurement_schedule

Optional reminder configuration.

A user may choose:

- measure blood pressure every morning
- check glucose before meals
- weigh weekly

Fields:

```
id
profile_id
measurement_type_id
schedule_config
start_date
end_date
active
```

---

# Exercise Module

Exercise tracking is independent from rehabilitation.

## exercise_type

Examples:

```
Walking
Cycling
Swimming
Stretching
Breathing Exercise
Strength Training
```

Fields:

```
id
profile_id
name
unit
notes
active
```

---

## exercise_goal

Defines desired activity.

Examples:

```
Walk 5 km daily
Walk 30 minutes every day
```

Fields:

```
id
profile_id
exercise_type_id
target_value
target_unit
frequency
start_date
end_date
active
```

---

## exercise_log

Stores completed activities.

Fields:

```
id
profile_id
exercise_type_id
date_time
duration_minutes
distance
calories
notes
```

Example:

```
Walking
3.4 km
42 minutes
```

---

# Doctor Module

Doctors are personal contacts.

The application does not manage clinics.

## doctor

Fields:

```
id
profile_id
first_name
last_name
specialty
phone
email
clinic
notes
```

Specialty should be editable.

Examples:

```
Cardiologist
General Practitioner
Endocrinologist
Other
```

---

## doctor_visit

Stores appointments.

Fields:

```
id
profile_id
doctor_id
date_time
status
reason
notes
reminder_enabled
reminder_minutes_before
```

Status:

```
scheduled
completed
cancelled
```

---

# Medical Documents

## document_attachment

Generic attachment storage.

Used for:

- laboratory results
- medical documents
- prescriptions
- diet recommendations

Fields:

```
id
profile_id
category
title
file_name
mime_type
stored_path
file_size
created_at
notes
```

Categories:

```
Lab Result
Prescription
Diet Plan
Other
```

Files must be stored in application private storage.

Do not store directly in public folders.

---

# Diet Module

Diet information should be guidance storage, not automatic nutrition calculation.

## diet_plan

Fields:

```
id
profile_id
title
description
start_date
end_date
active
notes
```

---

## diet_item

Fields:

```
id
diet_plan_id
category
text
notes
```

Categories:

```
recommended
avoid
limit
```

Example:

Recommended:

```
Vegetables
Oats
Fish
```

Avoid:

```
Processed food
Excess salt
```

---

# Health Templates

Templates provide starting configurations.

They are not medical recommendations.

Examples:

## Cardiac Recovery Template

Creates:

- Blood pressure measurement
- Pulse measurement
- Weight tracking
- Walking exercise goal
- Medication reminders

## Diabetes Template

Creates:

- Glucose measurement
- Medication module
- Diet tracking

## General Wellness Template

Creates:

- Weight tracking
- Exercise tracking

---

## health_template

Fields:

```
id
name
description
configuration_json
```

The configuration describes which modules/settings should be enabled.

---

# Application Settings

## app_setting

Simple key-value storage.

Fields:

```
key
value
```

Examples:

```
language = en

theme = dark

app_lock_enabled = true

weight_unit = kg

glucose_unit = mmol/L
```

---

# Database Migration

Database versioning is mandatory.

Every schema change must have:

- migration number
- migration code
- upgrade path

Never require uninstalling the application to update the database.

Existing personal health data must always be preserved.

# Application Architecture

RehabTrack must follow Clean Architecture principles.

The main goal is to keep business logic independent from:

- Flutter widgets
- database implementation
- Android-specific APIs
- external packages

The architecture must allow future changes without rewriting the whole application.

---

# Project Folder Structure

Recommended structure:

```
lib/

├── core/
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   ├── router/
│   ├── localization/
│   ├── utils/
│   └── services/
│
├── data/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   ├── daos/
│   │   └── migrations/
│   │
│   ├── models/
│   │
│   ├── repositories/
│   │
│   └── services/
│       ├── notification_service.dart
│       ├── backup_service.dart
│       └── file_storage_service.dart
│
├── domain/
│   ├── entities/
│   ├── enums/
│   ├── repositories/
│   └── services/
│
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── dialogs/
│   └── providers/
│
└── l10n/
    ├── app_en.arb
    └── app_ka.arb
```

---

# Domain Layer

The domain layer contains pure Dart code.

It must not import:

```
package:flutter/*
package:drift/*
package:flutter_riverpod/*
```

It contains:

- entities
- enums
- business rules
- schedule calculations
- validation logic

Examples:

```
Medication
MedicationSchedule
MeasurementRecord
ExerciseActivity
Profile
```

---

# Data Layer

The data layer handles:

- SQLite database
- Drift tables
- DAOs
- repository implementations
- file storage
- notifications
- backup

The UI must never communicate directly with this layer.

Example:

Wrong:

```
Widget
   |
   |
SQLite query
```

Correct:

```
Widget

   |
Provider

   |
Repository

   |
DAO

   |
Database
```

---

# Presentation Layer

Contains:

- screens
- widgets
- dialogs
- forms
- providers

The presentation layer should only know:

- what data it needs
- what user actions exist

It should not know:

- SQL
- file paths
- notification implementation

---

# State Management

Use:

## Riverpod

Reasons:

- compile-time safety
- no BuildContext dependency
- works well with streams
- suitable for large applications

Avoid mixing:

- Provider
- Bloc
- GetX
- ChangeNotifier

Use one state-management solution consistently.

---

# Provider Organization

Recommended:

```
presentation/providers/

profile_provider.dart

medication_provider.dart

measurement_provider.dart

exercise_provider.dart

doctor_provider.dart

settings_provider.dart
```

---

# Repository Pattern

Each major feature has its own repository.

Examples:

```
ProfileRepository

MedicationRepository

MeasurementRepository

ExerciseRepository

DoctorRepository

DocumentRepository

SettingsRepository
```

Repositories expose application-level methods.

Example:

Instead of:

```
database.select(medicationTable)
```

UI uses:

```
medicationRepository.getActiveMedications()
```

---

# Stream-Based Data Updates

Drift provides reactive streams.

Use them wherever possible.

Example:

Database:

```
medicationStream()
```

Repository:

```
Stream<List<Medication>>
```

Provider:

```
StreamProvider
```

UI:

Automatically rebuilds when data changes.

---

# Navigation

Use:

## GoRouter

Recommended routes:

```
/

Today Dashboard

/profile

/medications

/measurements

/exercise

/doctors

/documents

/settings
```

Navigation should support:

- deep links in future
- nested navigation
- Android back button behavior

---

# Theme and UI

Use:

## Material 3

Enable:

```
useMaterial3: true
```

Support:

- light theme
- dark theme

Colors should communicate information:

Examples:

Medication:

- upcoming
- taken
- missed

Measurements:

- normal
- warning

Avoid excessive medical-looking UI.

The application should feel like a personal assistant.

---

# Notification Architecture

Notifications are one of the most important features.

The system must reliably handle:

- medication reminders
- measurement reminders
- doctor appointment reminders
- exercise reminders

---

# Notification Service

Create one central service:

```
NotificationScheduler
```

Responsibilities:

- create notifications
- schedule reminders
- cancel reminders
- reschedule after changes
- restore schedules after reboot

The rest of the application must not directly call notification plugins.

---

# Notification Flow

Example medication:

User creates:

```
Aspirin

08:00 daily
```

Flow:

```
Medication Screen

        |

MedicationRepository

        |

Database

        |

NotificationScheduler

        |

Android Alarm System

        |

Notification appears
```

---

# Notification Actions

Medication notifications should support:

Actions:

```
Taken

Snooze

Skip
```

Example:

Notification:

```
Aspirin

100 mg

08:00

[ Taken ]

[ Snooze ]

[ Skip ]
```

Action results must update:

```
medication_log
```

even if the application is not open.

---

# Android Background Handling

The implementation must verify:

- Android 13 notification permission
- Android 12 exact alarm restrictions
- device reboot handling
- battery optimization restrictions

Support:

```
RECEIVE_BOOT_COMPLETED

POST_NOTIFICATIONS

SCHEDULE_EXACT_ALARM
```

if required.

---

# Battery Optimization

Many Android manufacturers aggressively stop background tasks.

The application should:

- detect possible restrictions
- explain the problem to the user
- optionally request battery optimization exemption

Especially test:

- Samsung
- Xiaomi
- Huawei
- Pixel devices

---

# Time and Scheduling Rules

Never store future notifications as fixed timestamps.

Wrong:

```
Next alarm:
2026-08-01 08:00 UTC
```

because timezone changes may break it.

Correct:

Store:

```
Every day

08:00

Local time
```

Then calculate next execution time.

This prevents problems with:

- daylight saving
- timezone changes
- travel

---

# Background Reliability

On application startup:

Run:

```
ScheduleRecoveryService
```

It must:

1. Load active medication schedules.
2. Load measurement schedules.
3. Load exercise reminders.
4. Recalculate future notifications.
5. Restore missing alarms.

The app should recover automatically after:

- phone restart
- application update
- system cleanup

---

# Error Handling

All important operations must have:

- validation
- user-friendly messages
- error logging

Release builds must not expose:

- personal data
- health information
- file paths

Avoid:

```
print()
debugPrint()
```

with private information.

# Required Screens and User Interface Specification

The application should be designed around the user's daily workflow.

The main question the application should answer is:

> "What do I need to do today, and how is my health progressing?"

The most frequently used information must require the minimum number of taps.

---

# Main Navigation

Recommended bottom navigation:

```
Today

Health

Activities

Records

Settings
```

Alternative:

Navigation drawer may be used if the number of modules grows.

The navigation design should remain flexible.

---

# 1. Today Dashboard

The Today Dashboard is the main application screen.

It should open by default.

Purpose:

Provide an immediate overview of today's health tasks.

---

## Dashboard Sections

### Medication

Show:

- medications due today
- upcoming medication times
- completed medications
- missed medications

Example:

```
Today

Medication

✓ Aspirin
  08:00 Taken

○ Bisoprolol
  20:00 Upcoming
```

Quick actions:

```
Taken

Skip

Snooze
```

---

### Measurements

Show:

Today's required measurements.

Example:

```
Measurements

Blood Pressure

Not recorded yet

[Enter]
```

---

### Exercise

Show:

Daily activity progress.

Example:

```
Walking

2.4 km / 5 km

██████░░░░
```

---

### Upcoming Events

Show:

- doctor visits
- reminders
- important dates

Example:

```
Next appointment

Cardiologist

Tomorrow 14:00
```

---

### Health Summary

Display simple trends:

Examples:

```
Weight

82.5 kg
↓ 0.5 kg this month


Blood Pressure

Average:
125/80
```

This is informational only.

No medical interpretation.

---

# 2. Profile Screen

Purpose:

Manage personal information.

Initially:

Only one profile.

---

Fields:

```
First name

Last name

Birth date

Gender

Height

Weight

Blood type

Allergies

Emergency contact

Notes
```

---

Future:

Support:

```
Profiles

Me

Father

Mother
```

---

# 3. Medication Module

This is a core feature.

---

## Medication List

Display:

```
Medication

Aspirin

100 mg

Daily 08:00

Active
```

Actions:

- add
- edit
- archive
- view history

---

## Add/Edit Medication

Fields:

```
Name

Dose

Unit

Instructions

Start date

End date

Reminder enabled
```

Examples:

Units:

```
mg

ml

tablet

capsule
```

---

## Schedule Editor

The user must not edit JSON.

Provide a visual editor.

Supported types:

### Daily

```
Every day

08:00
```

---

### Multiple Times

```
Daily

08:00

14:00

20:00
```

---

### Interval

```
Every 3 days

09:00
```

---

## Medication History

Display:

Calendar or timeline.

Example:

```
August 2026

01 ✓ Taken

02 ✓ Taken

03 Missed

04 Skipped
```

Show:

- adherence percentage
- missed count
- taken count

---

# 4. Measurements Module

Purpose:

Record and review health values.

---

## Measurement Dashboard

Show:

Available measurements:

```
Blood Pressure

Heart Rate

Weight

Glucose
```

Custom measurements:

```
Sleep

Stress Level
```

---

## Measurement Entry

Forms depend on measurement type.

---

### Blood Pressure

Fields:

```
Systolic

Diastolic

Pulse

Notes
```

---

### Weight

Fields:

```
Weight

Unit

Notes
```

---

### Glucose

Fields:

```
Value

Unit

Notes
```

---

### Custom Measurement

Fields:

```
Value

Unit

Notes
```

---

## Measurement History

Features:

- list view
- chart view
- date filtering

Examples:

```
Last 7 days

Last month

Custom range
```

Charts:

Use:

```
fl_chart
```

or equivalent.

---

# 5. Exercise Module

Purpose:

Help users maintain healthy activity habits.

---

## Exercise Dashboard

Show:

Today's progress.

Example:

```
Walking

Goal:
5 km

Completed:
3.2 km
```

---

## Exercise Types

Built-in:

```
Walking

Cycling

Swimming

Stretching

Breathing exercises

Strength training
```

Users may add custom activities.

---

## Exercise Goal

Example:

```
Walk

5 km

Every day
```

Fields:

```
Activity type

Target value

Unit

Frequency

Start date

End date
```

---

## Exercise Log

Fields:

```
Activity

Date/time

Duration

Distance

Notes
```

---

# 6. Doctor Module

Doctors are personal contacts.

Not a medical network.

---

## Doctor List

Display:

```
Dr. John Smith

Cardiologist

Phone

Clinic
```

Actions:

- edit
- delete
- call

---

## Calling

Use:

```
url_launcher
```

with:

```
tel:
```

The application opens the phone application.

It must not place calls automatically.

---

# 7. Appointment Module

Manage personal medical appointments.

---

## Appointment List

Show:

Upcoming:

```
Cardiologist

Tomorrow

14:00
```

Past:

```
Completed visits
```

---

## Appointment Fields

```
Doctor

Date/time

Reason

Notes

Reminder
```

---

## Reminder

Allow:

```
At appointment time

1 hour before

1 day before
```

---

# 8. Documents Module

Purpose:

Store personal medical documents.

Examples:

- laboratory results
- prescriptions
- medical notes
- diet recommendations

---

## Document List

Display:

```
Blood Test

15 July 2026

PDF
```

---

## Add Document

Options:

Camera:

```
Take photo
```

Gallery:

```
Choose image
```

Files:

```
Select PDF
```

---

## Document Storage

Files must be stored:

Application private storage.

Never directly store in public folders.

---

# 9. Diet Module

Purpose:

Store personal diet guidance.

Not a nutrition calculation system.

---

## Diet Plan

Example:

```
Post-stent diet

Active
```

---

## Categories

Display:

### Recommended

```
Vegetables

Fish

Oats
```

---

### Avoid

```
Processed food

Excess salt
```

---

### Limit

```
Sugar

High-fat food
```

---

# 10. Reports Module

Purpose:

Export personal health history.

---

## Report Types

Allow:

Medication report:

```
Medication adherence
```

Measurement report:

```
Blood pressure history
Weight history
```

Exercise report:

```
Activity history
```

---

## Export Formats

Support:

PDF:

Readable report.

CSV:

Data analysis.

---

# 11. Backup and Restore

The user owns the data.

---

## Backup

Create:

```
.zip
```

containing:

```
database export

documents

settings

metadata
```

---

## Restore

Before restoring:

Show warning:

```
Current data will be replaced.
Continue?
```

Validate backup before import.

---

# 12. Settings

Contains:

---

## Language

Initial:

```
English

Georgian
```

Use:

```
flutter gen-l10n
```

---

## Appearance

Options:

```
System

Light

Dark
```

---

## Notifications

Settings:

```
Enable notifications

Default snooze time

Reminder behavior
```

---

## Security

Optional:

```
Biometric lock

PIN lock
```

Disabled by default.

---

## Units

Examples:

Weight:

```
kg

lb
```

Glucose:

```
mg/dL

mmol/L
```

Changing units must not modify old records.

---

# User Experience Principles

The application should:

- minimize typing
- use clear forms
- provide quick actions
- avoid unnecessary complexity
- work well for older users
- support large text sizes
- maintain accessibility

The application should feel like:

"A personal health assistant"

not:

"A medical database."

# Non-Functional Requirements

## Performance

The application must feel fast on normal Android devices.

Requirements:

- Database operations must not block the UI thread.
- Large history lists must use lazy loading where appropriate.
- Charts must handle long-term data without freezing.
- File operations must run asynchronously.
- Application startup should remain fast even with years of stored data.

---

# Reliability

Health information is personal and important.

The application must prioritize data safety.

Requirements:

- Never silently delete user data.
- Validate database operations.
- Handle application crashes gracefully.
- Recover notification schedules after restart.
- Validate imported backups before restoring.

---

# Offline-First Design

Normal operation must work without Internet access.

The application must not require:

- account creation
- login
- server connection
- network permissions

All features should work locally:

- medication reminders
- measurements
- documents
- reports
- backup

---

# Privacy and Security

Health data is sensitive.

The application must minimize exposure of personal information.

Requirements:

- Do not send health data anywhere.
- Do not include personal information in logs.
- Do not upload files automatically.
- Do not request unnecessary permissions.

---

# Logging Rules

Release builds must not log:

- names
- medications
- measurements
- documents
- phone numbers
- personal notes

Avoid:

```
print()
debugPrint()
```

with user information.

Use a controlled logging service:

Example:

```
Logger.info()

Logger.error()
```

with release filtering.

---

# Application Lock

Optional security feature.

Disabled by default.

Supported methods:

## Biometric

Using:

```
local_auth
```

Examples:

- fingerprint
- face recognition

---

## PIN

If enabled:

Requirements:

- Never store PIN directly.
- Store salted hash.
- Use secure local storage.

Example:

```
PIN

      |

Salt + Hash

      |

Stored value
```

---

# Database Security

Default:

SQLite database stored in application private storage.

Future option:

Encrypted database.

Possible future:

```
sqlcipher_flutter_libs
```

Do not make encryption mandatory for Version 1 unless it can be implemented reliably.

---

# File Storage Security

Documents must be stored:

```
Application private directory
```

Examples:

- laboratory PDFs
- images
- medical documents

Do not store automatically in:

```
Downloads

Public folders
```

unless the user explicitly exports them.

---

# Backup and Restore

The user must have full control over their data.

---

## Backup Format

Use:

```
ZIP archive
```

Contents:

```
backup.zip

├── database.json
├── settings.json
├── documents/
│
└── metadata.json
```

The backup must contain:

- database records
- attached files
- application settings

A backup containing only database references is not acceptable.

---

## Restore Process

Before restoring:

1. Validate archive structure.
2. Check version compatibility.
3. Check required files.
4. Ask user confirmation.

Example:

```
Warning:

Current application data will be replaced.

Continue?
```

---

# Localization Requirements

Localization must exist from the beginning.

Initial languages:

```
English

Georgian
```

Architecture must allow adding languages later.

---

# Localization Rules

All user-visible text must use:

```
AppLocalizations
```

Never hardcode:

- buttons
- labels
- validation messages
- notifications
- dialogs

---

Example:

Wrong:

```dart
Text("Save")
```

Correct:

```dart
Text(
  AppLocalizations.of(context)!.save
)
```

---

# Translation Files

Use:

```
l10n/

app_en.arb

app_ka.arb
```

---

# Date and Number Formatting

Use:

```
intl
```

for:

- dates
- numbers
- units

Respect user locale.

---

# Android Requirements

The application must correctly handle modern Android versions.

Target:

Android API 36

Minimum supported version should be chosen based on Flutter/plugin compatibility.

---

# Required Permissions

Only request permissions that are necessary.

Possible permissions:

## Notifications

Android 13+

```
POST_NOTIFICATIONS
```

---

## Exact Alarms

Android 12+

```
SCHEDULE_EXACT_ALARM
```

if required.

---

## Boot Recovery

For restoring reminders:

```
RECEIVE_BOOT_COMPLETED
```

---

## Camera

Only when user captures documents:

```
CAMERA
```

---

Avoid unnecessary permissions.

The application should not request:

- location
- contacts
- microphone
- storage access

unless a feature requires it.

---

# Notification Reliability

Medication reminders are a critical feature.

The implementation must verify:

- exact alarm behavior
- Doze mode behavior
- reboot recovery
- manufacturer restrictions

Test on:

- Google Pixel
- Samsung
- Xiaomi

---

# Battery Optimization

Some Android devices stop background applications.

The application should:

- detect possible problems
- explain why reminders may fail
- guide the user

Optional:

Request:

```
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
```

only when appropriate.

---

# Application Release

The application will initially be distributed as a direct APK.

No Play Store publishing is required initially.

---

# Application Identity

Configure permanently:

```
applicationId
```

Example:

```
com.earkania.rehabtrack
```

Changing it later creates a different Android application.

---

# Versioning

Use Flutter version format:

```
version: 1.0.0+1
```

Meaning:

```
1.0.0

version name


1

build number
```

Increase build number for every release.

---

# Release Signing

Create a release keystore.

Example:

```
keytool -genkey \
-v \
-keystore rehabtrack-release.jks \
-keyalg RSA \
-keysize 2048 \
-validity 10000 \
-alias rehabtrack
```

The keystore must be:

- stored safely
- backed up
- never committed to Git

---

# Signing Configuration

Use:

```
android/key.properties
```

Example:

```
storePassword=

keyPassword=

keyAlias=rehabtrack

storeFile=
```

This file must be excluded from Git.

---

# Building Release APK

Command:

```
flutter build apk --release
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

# Git Rules

The project must use Git.

Do not commit:

```
.dart_tool/

build/

*.jks

key.properties

local.properties
```

---

# Development Process

OpenCode should work incrementally.

Do not generate the entire application at once.

---

# Phase 1

Create:

- Flutter project structure
- dependencies
- architecture folders
- localization setup
- theme
- navigation

Verify:

```
flutter run
```

works.

---

# Phase 2

Implement:

Database:

- Drift setup
- migrations
- profile table
- settings table

Verify:

Database creation works.

---

# Phase 3

Implement:

Medication module:

- database
- repository
- providers
- UI
- notifications

Verify:

Reminder workflow works on a real Android device.

---

# Phase 4

Implement:

Measurements:

- recording
- history
- charts

---

# Phase 5

Implement:

Exercise:

- goals
- activity logs

---

# Phase 6

Implement:

Additional modules:

- doctors
- appointments
- documents
- reports
- backup
- security

---

# Testing Requirements

Each module should be tested before moving forward.

Important tests:

## Database

- migrations
- data persistence

## Notifications

- scheduling
- reboot recovery
- actions

## Backup

- export
- import
- corrupted file handling

## Localization

- language switching
- translated notifications

---

# Final Development Instruction For OpenCode

Before writing implementation code:

1. Analyze this specification.
2. Propose final folder structure.
3. Propose dependency list.
4. Propose database schema.
5. Explain major technical decisions.
6. Wait for approval before generating large amounts of code.

The goal is to create a maintainable personal health application, not only a working prototype.
