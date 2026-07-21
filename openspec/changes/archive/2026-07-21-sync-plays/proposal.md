# Change: Download and cache BGG plays

## Why

The app already downloads the user's BGG collection and game details, but it has
no access to the logged play history. BGG records every play with date,
quantity, length, location, comments, and players. Having this data locally is a
prerequisite for future features such as per-game play counts, play history,
and statistics, all without requiring a network call every time the user wants to
inspect them.

## What Changes

- Add a new `plays-sync` capability with an OpenSpec spec under
  `openspec/specs/plays-sync/spec.md`.
- Extend the `bgg-sync` spec so that a manual sync also fetches and caches plays.
- Introduce domain entities `Play` and `PlayPlayer` plus the `PlayStore` port.
- Add `BggApi.fetchPlays(String username)` and implement page-by-page XML
  parsing in `BggApiClient`, reusing the existing retry/rate-limit logic.
- Add `Plays` and `PlayPlayers` Drift tables, bump the schema version to `8`,
  and implement a destructive migration.
- Add `DriftPlayStore` and a new `SyncPlaysUseCase`.
- Wire `SyncPlaysUseCase` into `SyncCollectionUseCase` so one user-facing sync
  refreshes collection, games, thumbnails, and plays.
- Add unit tests for entities, XML parsing, use case, Drift store, and the
  schema migration.

## Affected Capabilities

- `plays-sync` (new)
- `bgg-sync` (extended)

## Impact

- [x] Database migrations (new `Plays` and `PlayPlayers` tables)
- [ ] Breaking changes
- [ ] API changes
- [x] New tests required
