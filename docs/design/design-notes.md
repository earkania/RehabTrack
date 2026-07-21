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

---

# Notes From Real Usage

Create a section specifically intended for recording observations that arise while actually using the application.

This section should become one of the primary sources of future improvements.

Examples:

- Problems discovered during daily usage
- Features that reduce routine effort
- Missing information that would be useful
- Things that are confusing or inconvenient