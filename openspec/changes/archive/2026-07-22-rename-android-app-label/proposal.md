# Feature: Android app label from `bgg_meeple` to `BGG Meeple`

## Summary

Change the Android launcher label from the snake-case package name `bgg_meeple` to the readable brand name `BGG Meeple`.

## Motivation

The current `android:label` in `AndroidManifest.xml` uses the internal project/package identifier `bgg_meeple`. On the Android home screen and app drawer this looks unprofessional and does not match the app name used in README and marketing material. A user-friendly label improves brand recognition and first-time user trust.

## Proposed Solution

- Update `android/app/src/main/AndroidManifest.xml` so that `application android:label` reads `BGG Meeple`.
- Add an automated regression test that reads the manifest and asserts the Android application label equals `BGG Meeple`, so the label cannot silently revert.
- Update `REQUIREMENTS.md` to reference the new `android-app-label` capability spec.

## Alternatives Considered

- Deriving the label from `pubspec.yaml` or `strings.xml`: Overkill for a single static label. The Flutter project template already stores the label directly in `AndroidManifest.xml`, so editing the manifest is the minimal, idiomatic change.
- Using a string resource reference (`@string/app_name`): Also possible, but it introduces an additional file with no practical benefit unless multi-locale Android labels are needed later.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
