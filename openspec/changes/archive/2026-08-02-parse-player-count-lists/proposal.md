# Feature: Parse and display player count lists from BGG poll summaries

## Why

Some BGG games return player count summaries that are not a single value or range, e.g. `Best with 6, 8 players` or `Recommended with 4, 6–10, 12 players`. The current parser only extracts the first numeric value and silently drops the rest, leading to misleading data.

## What Changes

- Extend the `/xmlapi2/thing` parser to handle comma-separated lists of player counts and ranges.
- Preserve the original summary text for display and derive numeric min/max bounds for filtering.
- Update the detail page to render the stored textual value with a localized "Players" / "Spieler" label.
- Bump the database schema to v12 and clear `detailsUpdatedAt` for all cached games so stale details are refreshed on the next sync.
