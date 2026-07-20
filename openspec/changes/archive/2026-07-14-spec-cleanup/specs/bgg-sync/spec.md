## ADDED Requirements

### Requirement: Sync affordance is visible when an account is configured
A clearly identifiable sync icon or button SHALL be visible when a BGG account is configured. It SHALL be disabled or hidden when no account is set.

#### Scenario: Sync icon shown with credentials
- **WHEN** the user has saved valid BGG credentials
- **THEN** the main app bar shows an enabled sync icon

#### Scenario: Sync icon hidden without credentials
- **WHEN** no BGG account is configured
- **THEN** the sync icon is disabled or not shown

### Requirement: Single sync progress indicator
During a sync exactly one progress indicator SHALL be shown at the top of the main collection screen. No duplicate progress bars SHALL appear.

#### Scenario: One progress bar during sync
- **WHEN** a sync is in progress
- **THEN** exactly one progress indicator is visible at the top of the collection screen

### Requirement: Local cache uses a reliable persistence layer
All locally cached game, collection, and version data SHALL be stored in a reliable persistence layer that supports offline queries (for example SQLite, Hive, ObjectBox, or shared preferences plus JSON).

#### Scenario: Offline query of cached data
- **WHEN** the device is offline after a successful sync
- **THEN** the app can query and display cached collection, game, and version data from the local store

### Requirement: Thumbnails and images are cached as local files
Thumbnails and custom game images SHALL be cached locally using a custom file cache. Local file paths SHALL be persisted in the cache database so images remain available offline.

#### Scenario: Image cache survives app restart
- **WHEN** the app restarts after images have been downloaded during a previous sync
- **THEN** the cached image files are still available and the app knows their local paths

### Requirement: Local cache schema is versioned and migratable
The local cache schema SHALL be versioned. Every schema change SHALL bump `schemaVersion` and ship a tested `MigrationStrategy`. Destructive migrations are acceptable for cache-only data and must be documented.

#### Scenario: Schema update with migration
- **WHEN** the local cache schema is changed between app versions
- **THEN** `schemaVersion` is incremented and a migration or destructive recreation is applied on the next app start
