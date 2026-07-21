# Change: Fix detail page rating count label wording

## Summary

The game detail page currently formats the Bayes average rating together with the user count as:

`6.19 (5567 Anzahl Bewertungen)` (German)  
`6.19 (5567 Number of ratings)` (English)

The label string contains a counting noun (`Anzahl`, `Number of`) that is redundant and ungrammatical when placed after the numeric value. This change aligns the implementation with the existing `game-detail` spec, which describes the line as:

`Rating: <rating>.<bayesavg> (<rating>.<usersrated> votes)`

## Why

The current wording is a visible localization bug. The label is interpolated by `game_detail_page.dart` directly after the count, so the localization value must be a plain noun, not a full noun phrase.

## What Changes

Update the localization string `detailUserCount` in the source ARB files and regenerate the generated localization classes:

- `app_de.arb`: change `Anzahl Bewertungen` → `Bewertungen`
- `app_en.arb`: change `Number of ratings` → `votes`
- Regenerate `app_localizations_de.dart` and `app_localizations_en.dart` via `flutter gen-l10n`.

The formatting code in `lib/presentation/pages/game_detail_page.dart` remains unchanged.

## Affected Capabilities

- `game-detail`

## Alternatives Considered

- Keeping the counting noun and reordering to `Anzahl Bewertungen: 5567`: rejected because it breaks the compact, parenthesized format used throughout the detail page.
- Using ICU plural messages: rejected because the current interpolation is fixed and a simple label change fully resolves the issue without added complexity.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] Localization changes
- [ ] New tests required
- [ ] New route/page added
