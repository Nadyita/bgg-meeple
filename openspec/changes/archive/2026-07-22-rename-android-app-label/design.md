# Design: Android app label from `bgg_meeple` to `BGG Meeple`

## Decision

No architectural or cross-cutting design decisions are required for this change. The Android application label is a single static value in `AndroidManifest.xml`.

## Implementation Details

- File: `android/app/src/main/AndroidManifest.xml`
- Attribute: `<application android:label="BGG Meeple" ...>`
- Validation: A Dart test reads the manifest, parses the root `<application>` element, and asserts that `android:label` equals `BGG Meeple`.

## Rationale

Keeping the label directly in the manifest is consistent with the default Flutter project structure and avoids introducing an extra string resource file for a single static value.
