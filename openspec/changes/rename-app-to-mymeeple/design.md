# Design: Rename app display name from BGG Meeple to MyMeeple

## Overview

This is a pure rename change. No business logic, data model, or API contract changes. The goal is to replace the user-facing brand name `BGG Meeple` with `MyMeeple` everywhere it appears.

## Affected Artifacts

| File | Field/Element | Old value | New value |
|------|---------------|-----------|-----------|
| `android/app/src/main/AndroidManifest.xml` | `application android:label` | `BGG Meeple` | `MyMeeple` |
| `lib/presentation/l10n/app_en.arb` | `appTitle` | `BGG Meeple` | `MyMeeple` |
| `lib/presentation/l10n/app_de.arb` | `appTitle` | `BGG Meeple` | `MyMeeple` |
| `lib/presentation/l10n/app_localizations.dart` | generated doc comment | `BGG Meeple` | `MyMeeple` |
| `lib/presentation/l10n/app_localizations_en.dart` | `appTitle` getter | `BGG Meeple` | `MyMeeple` |
| `lib/presentation/l10n/app_localizations_de.dart` | `appTitle` getter | `BGG Meeple` | `MyMeeple` |
| `lib/presentation/app.dart` | doc comment | `BGG Meeple app` | `MyMeeple app` |
| `linux/runner/resources/com.bggmeeple.bgg_meeple.desktop` | `Name=` | `BGG Meeple` | `MyMeeple` |
| `README.md` | title, body, keystore example | `BGG Meeple` | `MyMeeple` |
| `REQUIREMENTS.md` | title, body, vision | `BGG Meeple` | `MyMeeple` |
| `test/android/app_label_test.dart` | assertion | `BGG Meeple` | `MyMeeple` |

## Out of Scope

The following identifiers are intentionally NOT renamed because they are internal package/technical identifiers and the user only asked to replace the literal display name `BGG Meeple`:

- Dart package name `bgg_meeple` in `pubspec.yaml`
- Android application ID and package paths `com.bggmeeple.bgg_meeple`
- Kotlin package `com.bggmeeple.bgg_meeple`
- Linux binary name `bgg_meeple` and application ID `com.bggmeeple.bgg_meeple`
- Drift database name `bgg_meeple_cache`
- CI artifact names and keystore names (`bgg-meeple-*`, `bgg_meeple_release.keystore`)
- GitHub Actions secret names (`BGG_MEEPL_*`)

Renaming those would break existing installs, require new signing keys, and change artifact URLs. They can be addressed in a follow-up change if desired.

## Implementation Order

1. Update generated and hand-written localization files.
2. Update Android manifest label.
3. Update Linux desktop entry.
4. Update code comments.
5. Update project documentation.
6. Update the Android app-label regression test.
7. Run `dart analyze` and `dart test`.

## Rationale

- Keeping internal identifiers unchanged preserves backward compatibility for installed apps and avoids regenerating signing keys.
- Updating the launcher label, window title, localized app title, and documentation removes the trademarked abbreviation from all user-visible surfaces.
- A single automated test guards the Android launcher label so it cannot silently revert.
