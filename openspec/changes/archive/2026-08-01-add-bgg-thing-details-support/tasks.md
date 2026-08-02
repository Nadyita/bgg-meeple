# Tasks for Feature: BGG /thing Details für Spiele mit API-Key

## 1. Domain model

- [x] **1.1** Add `GameLink` value object with `bggId`, `type`, and `name`.
- [x] **1.2** Add `detailsUpdatedAt`, `bestPlayerCount`, `suggestedPlayerAge`, and `languageDependenceLevel` to `BoardGame` entity; replace `categories`, `mechanics`, `families` with `List<GameLink> links`.

## 2. XML parsing

- [x] **2.1** Parse `description` from `item/description`.
- [x] **2.2** Parse `bestPlayerCount` from `poll-summary[@name='suggested_numplayers']/result[@name='bestwith']/@value` keeping only the numeric part.
- [x] **2.3** Parse `suggestedPlayerAge` as weighted average from `poll[@name='suggested_playerage']`, rounded to one decimal place as a string.
- [x] **2.4** Parse `languageDependenceLevel` from the `result` with most `numvotes` in `poll[@name='language_dependence']`.
- [x] **2.5** Parse all supported `link` elements (category, mechanic, family, designer, artist, publisher, expansion, implementation) into `GameLink` objects.

## 3. Database schema

- [x] **3.1** Add `detailsUpdatedAt IntColumn` to `BoardGames`; remove `categories`, `mechanics`, and `families` columns.
- [x] **3.2** Add `GameLinks` table (`id`, `type`, `bggId`, `name`).
- [x] **3.3** Add `BoardGameLinkRels` table (`gameId`, `linkId`).
- [x] **3.4** Bump `schemaVersion` and add destructive migration (cache data is repopulated on next sync).
- [x] **3.5** Regenerate Drift code.

## 4. Persistence adapter

- [x] **4.1** Update `DriftGameStore._toGameCompanion` to write new fields and skip old JSON link columns.
- [x] **4.2** Update `DriftGameStore._toEntity` to read `links` via the relation table and restore new fields.
- [x] **4.3** Implement upsert of `GameLinks` and `BoardGameLinkRels` in `saveAll`, reusing existing links across games.

## 5. Sync integration

- [x] **5.1** In `SyncCollectionUseCase`, after fetching the collection, identify games whose cached `description` is null/empty.
- [x] **5.2** Call `BggApi.fetchGames` only for those missing-description IDs when an API token is available.
- [x] **5.3** Persist fetched games with `detailsUpdatedAt` set to current time.

## 6. Detail page lazy refresh

- [x] **6.1** Extend `LoadGameDetailsUseCase` to accept a refresh callback and trigger it when `detailsUpdatedAt` is missing or older than 30 days and an API token is available.
- [x] **6.2** Load and show cached details immediately; refresh in the background and update the UI once new data is persisted.

## 7. UI

- [x] **7.1** Display the game description at the top of the detail page.
- [x] **7.2** Place the game image in the top-left corner with the description text wrapping around it.
- [x] **7.3** Hide the description section when no description is cached.

## 8. Tests

- [x] **8.1** Extend `bgg_api_client_fetch_games_test.dart` with XML parsing tests for description, best player count, suggested player age, language dependence level, and all link types.
- [x] **8.2** Add or extend `drift_game_store_test.dart` for round-trip persistence of new fields and normalized links.
- [x] **8.3** Add migration test for the new schema version.
- [x] **8.4** Add unit tests for `SyncCollectionUseCase` to verify `/thing` is only called for games missing a description.
- [x] **8.5** Add unit tests for `LoadGameDetailsUseCase` lazy refresh logic and the 30-day threshold.
- [x] **8.6** Update or add widget tests for the detail page description layout.

## 9. Validation

- [x] **9.1** Run `dart analyze` and fix all errors/warnings.
- [x] **9.2** Run `dart test` and verify all tests pass.
- [x] **9.3** Manually verify the description appears on the detail page and stale details refresh in the background.
