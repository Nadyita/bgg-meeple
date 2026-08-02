# Feature: Parse and display player count lists from BGG poll summaries

## Summary

Extend the BGG `/xmlapi2/thing` parser so it supports `poll-summary` values that contain a comma-separated list of player counts or player count ranges. Persist the original textual value and derive numeric min/max values for filtering. Update the detail page to show the original value with localized "Players" / "Spieler" labels.

## Motivation

Some BGG games return player count summaries that are not a single value or range, e.g. `Best with 6, 8 players` or `Recommended with 4, 6–10, 12 players`. The current parser only extracts the first numeric value and silently drops the rest, leading to misleading data (e.g. `recommended 4` when the real recommendation spans 4–12). We need to preserve the full summary text for display while still storing useful numeric bounds.

## Proposed Solution

1. Change the player-count range parser in `BggApiClient` so it finds **all** range expressions (`X`, `X-Y`, `X+`, `X-Y+`) in the summary text.
2. Derive `min` from the smallest lower bound and `max` from the largest upper bound. If any expression has a `+`, `max` is `null`.
3. Keep the original, cleaned summary text as the `bestPlayerCount` / `recommendedPlayerCount` display strings.
4. Update `GameDetailPage` so best/recommended are rendered using these stored display strings, appended with the localized `Players` / `Spieler` noun.

## Alternatives Considered

- Store only a synthetic single range for display. Rejected because it would lose the nuance BGG provides (e.g. `6, 8` vs `6-8`).
- Parse only the first value and ignore lists. Rejected because it produces obviously wrong information.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [x] API changes (XML parser behavior)
- [x] UI changes (detail page player count line)
