# Tasks for Download and cache BGG plays

## 1. Planning

- [x] **1.1** Create OpenSpec change `sync-plays`
- [x] **1.2** Write `proposal.md`
- [x] **1.3** Write capability spec `openspec/specs/plays-sync/spec.md`
- [x] **1.4** Write `design.md`
- [x] **1.5** Link new spec in `REQUIREMENTS.md`

## 2. Domain Layer

- [x] **2.1** Add `Play` entity in `lib/domain/entities/play.dart`
- [x] **2.2** Add `PlayPlayer` entity in `lib/domain/entities/play_player.dart`
- [x] **2.3** Add `PlayStore` port in `lib/domain/ports/play_store.dart`
- [x] **2.4** Extend `BggApi` port with `fetchPlays(String username)`

## 3. Infrastructure Layer

- [x] **3.1** Add `Plays` and `PlayPlayers` tables to `app_database.dart`
- [x] **3.2** Bump schema version to `8` and add destructive migration for `from < 8`
- [x] **3.3** Regenerate Drift code (`app_database.g.dart`)
- [x] **3.4** Implement `DriftPlayStore` in `lib/infrastructure/adapters/persistence/drift_play_store.dart`
- [x] **3.5** Implement `fetchPlays` pagination and XML parsing in `bgg_api_client.dart`
- [x] **3.6** Add `fetchPlays` path constant and retry/rate-limit handling

## 4. Application Layer

- [x] **4.1** Add `SyncPlaysUseCase` in `lib/application/use_cases/sync_plays_use_case.dart`
- [x] **4.2** Extend `SyncCollectionUseCase` to optionally run `SyncPlaysUseCase` after thumbnails
- [x] **4.3** Wire `SyncPlaysUseCase` and `DriftPlayStore` in the service locator

## 5. Tests

- [x] **5.1** Unit tests for `Play` and `PlayPlayer` entities
- [x] **5.2** Unit tests for `/plays` XML parsing including pagination edge cases
- [x] **5.3** Unit tests for `SyncPlaysUseCase`
- [x] **5.4** Unit tests for `DriftPlayStore`
- [x] **5.5** Unit tests for schema v7 → v8 migration

## 6. Validation

- [x] **6.1** Run `dart analyze` with zero errors and zero warnings
- [x] **6.2** Run `dart test` with all tests passing
- [x] **6.3** Validate the change with `openspec_validate_change sync-plays`
