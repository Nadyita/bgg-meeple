# Change: Simplify detail page to match spec

## Why

The `game-detail` spec was updated by `update-spec-game-detail` to require that the detail page shows only a fixed, explicitly listed set of details. The previous implementation displayed many additional metadata fields (description, categories, mechanics, designers, publishers, weight, etc.) that are no longer allowed by the spec.

## What Changes

- Remove all extra detail fields from `GameDetailPage` so only the spec-mandated details remain.
- Keep the following fields in strict order: image, name, status badges, original name, year published, version, players, playing time, rating, rank, plays.
- Preserve external BGG link and alternate/localized names toggle.
- Remove obsolete localization keys and regenerate `AppLocalizations`.
- Update widget tests to assert the simplified layout and absence of removed fields.

## Affected Capabilities

- `game-detail`

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] UI/UX changes
- [x] New tests required
- [ ] New route/page added
