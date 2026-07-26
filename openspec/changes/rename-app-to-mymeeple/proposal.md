# Feature: Rename app display name from BGG Meeple to MyMeeple

## Summary

Replace every user-facing occurrence of `BGG Meeple` with `MyMeeple` to avoid potential trademark conflicts with BoardGameGeek (BGG).

## Motivation

`BGG` is a trademark of BoardGameGeek. Using it in the app name (`BGG Meeple`) creates a legal risk. The new name `MyMeeple` keeps the existing meeple metaphor while removing the trademarked abbreviation.

## Proposed Solution

- Introduce an `app-identity` capability spec that defines `MyMeeple` as the canonical app display name.
- Update the existing `android-app-label` spec to require the Android launcher label to be `MyMeeple`.
- Replace the literal string `BGG Meeple` with `MyMeeple` in all project files where it appears, including:
  - Flutter localization files (`app_en.arb`, `app_de.arb`) and generated localizations
  - Android manifest application label
  - Linux `.desktop` entry name
  - `README.md` and `REQUIREMENTS.md`
- Update the Android app-label regression test to assert `MyMeeple`.
- Run `dart analyze` and `dart test` to confirm the rename does not introduce regressions.

## Alternatives Considered

- `MeepleCollection`: Longer and less distinctive.
- `MyMeepleCollection`: Accurate but verbose for a launcher label.
- `MyMeeple` was chosen because it is short, brandable, and preserves the existing meeple identity.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] User-facing branding change
- [x] Documentation update required
