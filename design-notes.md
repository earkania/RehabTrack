> This document evolves continuously throughout the project. Before starting any major implementation phase, review this document and report whether any ideas should now become part of the official requirements.

# RehabTrack Design Notes

## Purpose

This file is a living collection of ideas, future improvements, design decisions, usability observations, and real-world scenarios that should be considered during development.

It supplements the official requirements (`opencode-cardiac-rehab-app-prompt-flutter-v2.md`) and the architecture analysis (`opencode-rehabtrack-analysis-v3.md`). It should never replace them.

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

---

## Future Ideas

### Medication Management

#### Medication alternatives

Some prescribed medications may have acceptable replacements.

The user should optionally be able to define one or more substitute medications.

Example:

Original:
Concor

Alternatives:
Bisoprolol (generic)
Another equivalent approved by the doctor

The application should show these alternatives whenever viewing medication details.

This feature is optional per medication.

---

#### Administration guidance

Medication may include guidance such as:

- Before meal
- After meal
- With meal
- On empty stomach
- Before bedtime
- Morning only
- Drink plenty of water
- Avoid alcohol

These instructions are informational.

---

#### Conditional administration

Some medications require checking measurements before taking them.

Example:

Take Concor only if pulse is at least 55 bpm.

Administration conditions should be generic rather than medication-specific.

Future conditions may include:

- Pulse
- Blood pressure
- Blood glucose
- Temperature
- Weight
- Custom measurements

---

### Exercise Ideas

Leave space for future exercise planning and rehabilitation features.

---

### Health Monitoring Ideas

Leave space for future health tracking improvements.

Examples:

- wearable integration
- automatic measurement import
- trends
- risk indicators

---

### User Experience Ideas

Record usability improvements whenever discovered during development.

---

## Future Features

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

## Notes From Real Usage

Create a section specifically intended for recording observations that arise while actually using the application.

This section should become one of the primary sources of future improvements.
