# RehabTrack

A personal health companion application built with Flutter.

RehabTrack helps individuals organize and monitor their own health — medications, measurements, exercise, doctor visits, and medical documents. Initially inspired by cardiac rehabilitation recovery, the application is designed to be a flexible health management tool for many conditions.

## Status

**Current phase:** Phase 1 — Project Foundation

## Getting Started

### Prerequisites

- Flutter stable channel
- Dart SDK ^3.12.2
- Android SDK (API 35+)

### Run the application

```bash
flutter pub get
flutter run
```

### Build debug APK

```bash
flutter build apk --debug
```

## Architecture

Clean Architecture with four layers:

```
lib/
├── core/          # Theme, router, constants, errors, utilities
├── data/          # Database, repositories, services
├── domain/        # Entities, enums, repository interfaces
└── presentation/  # Screens, widgets, providers
```

**State management:** Riverpod
**Navigation:** GoRouter
**Database:** Drift (SQLite) — to be added in Phase 2
**Localization:** English + Georgian (ARB files)

## Project Structure

| Directory | Purpose |
|---|---|
| `lib/core/` | Cross-cutting concerns: theme, router, constants, errors |
| `lib/data/` | Infrastructure: database, repository implementations, services |
| `lib/domain/` | Business logic: entities, enums, repository interfaces |
| `lib/presentation/` | UI: screens, widgets, Riverpod providers |
| `lib/l10n/` | Localization ARB files and generated code |
| `docs/` | Project documentation |

## Documentation

| Folder | Contents |
|---|---|
| `docs/requirements/` | Official specifications |
| `docs/architecture/` | Architecture decisions |
| `docs/analysis/` | Implementation analyses |
| `docs/design/` | Design notes and future ideas |
| `docs/planning/` | Development phases and roadmaps |

## Android Configuration

- **Application ID:** `com.earkania.rehabtrack`
- **Min SDK:** Flutter default
- **Target SDK:** Flutter default
- **Version:** 1.0.0+1
