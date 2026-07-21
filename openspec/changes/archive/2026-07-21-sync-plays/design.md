# Design: Download and cache BGG plays

## Overview

This change adds a new `plays-sync` capability. The existing collection sync flow
will be extended to download the user's full BGG play history after games and
thumbnails have been cached.

## Domain Model

### `Play`

Represents a single logged BGG play:

- `id` – BGG play id (`play/@id`)
- `thingId` – BGG object id of the played game (`item/@objectid`)
- `gameName` – name of the played game (`item/@name`)
- `date` – play date (`play/@date`)
- `quantity` – number of times played (`play/@quantity`, default `1`)
- `length` – reported play length in minutes (`play/@length`, default `0`)
- `incomplete` – flag from `play/@incomplete`
- `noWinStats` – flag from `play/@nowinstats`
- `location` – `play/@location`
- `comments` – text content of `<comments>`
- `subtypes` – values from `<subtypes>/<subtype>`
- `players` – list of `PlayPlayer`

### `PlayPlayer`

Represents one participant in a play:

- `username` – BGG username (`player/@username`)
- `userId` – BGG user id (`player/@userid`)
- `name` – display name (`player/@name`)
- `startPosition` – `player/@startposition`
- `color` – `player/@color`
- `score` – `player/@score` (kept as string because BGG allows arbitrary score formats)
- `newPlayer` – `player/@new`
- `rating` – `player/@rating` as double
- `win` – `player/@win`

## Ports

### `BggApi`

Add one method:

```dart
Future<List<Play>> fetchPlays(String username);
```

The implementation:

1. Builds `https://boardgamegeek.com/xmlapi2/plays?username=<username>&subtype=boardgame&page=1`.
2. Reads `plays/@total` from the first response to know the total count.
3. Continues with `page=2, 3, ...` until all plays are fetched.
4. Uses the existing `_getWithRetry` helper so HTTP 202 and 401/403 handling stays identical to `/collection` and `/thing`.

### `PlayStore`

New domain port:

```dart
abstract class PlayStore {
  Future<void> saveAll(List<Play> plays);
  Future<List<Play>> loadAll();
  Future<List<Play>> loadForGame(int thingId);
  Future<void> clear();
}
```

`saveAll` replaces the cached play set: it first clears all plays and players, then inserts the new rows.

## Infrastructure

### Drift schema

Add two tables to `app_database.dart`:

- `Plays` – one row per play.
- `PlayPlayers` – one row per player, with a foreign key to `Plays.id`.

String lists (`subtypes`) are stored as a JSON-encoded text column to keep the schema simple and avoid an extra table.

Bump `schemaVersion` from `7` to `8`. Because this is cache-only data, the migration strategy will drop and recreate all tables when `from < 8`.

### Drift Play Store

Implement `PlayStore` in `lib/infrastructure/adapters/persistence/drift_play_store.dart`. It maps between `Play`/`PlayPlayer` and the generated Drift companions.

## Application Layer

### `SyncPlaysUseCase`

New use case responsible for one play sync run:

```dart
class SyncPlaysUseCase {
  const SyncPlaysUseCase(this._credentialStore, this._bggApi, this._playStore);
  Future<SyncPlaysResult> call({void Function(SyncProgress)? onProgress});
}
```

It loads credentials, fetches all plays page by page, emits progress events, and persists the result.

### Integration into existing sync

`SyncCollectionUseCase` gains an optional `SyncPlaysUseCase? syncPlays` parameter. After the thumbnail phase finishes it calls `syncPlays?.call(onProgress: ...)` so a single user-facing sync action refreshes collection, games, thumbnails, and plays. If `syncPlays` is null the behavior is unchanged.

The service locator wires `SyncPlaysUseCase` and passes it to `SyncCollectionUseCase`.

## Presentation

No UI changes are required for this milestone. The existing progress indicator will simply show the new `plays` phase while plays are downloading.

## Testing

- Unit tests for the `/plays` XML parser.
- Unit tests for `SyncPlaysUseCase` using a fake `BggApi` and in-memory `PlayStore`.
- Unit tests for `DriftPlayStore` with an in-memory Drift database.
- Unit tests for the destructive schema migration from v7 to v8.
