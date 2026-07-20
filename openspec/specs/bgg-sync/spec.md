# bgg-sync Specification

## Purpose

Defines how the app authenticates with BoardGameGeek, fetches collection and game data on demand, respects BGG API limits, caches everything locally for offline use, and communicates sync progress and errors to the user. This capability covers both the background sync logic and the visible sync affordances on the collection screen.
## Requirements
### Requirement: Manual BGG sync is available when an account is configured
The app SHALL display a clearly identifiable sync button or icon whenever a valid BGG account is configured. Tapping the sync control SHALL trigger a full sync of the user's collection, game details, and versions.

#### Scenario: Sync button visible with credentials
- **WHEN** the user has saved BGG credentials
- **THEN** the main collection screen shows an enabled sync affordance

#### Scenario: Sync button triggers full sync
- **WHEN** the user taps the sync affordance
- **THEN** the app fetches the collection list, game details, versions, and thumbnails

### Requirement: Pull-to-sync on main list
Pulling down at the top of the main collection list SHALL trigger a BGG sync.

#### Scenario: Pull gesture starts sync
- **WHEN** the user pulls down at the top of the collection list
- **THEN** a sync operation starts and the refresh indicator reflects its state

### Requirement: Sync caches data for offline use
All game, collection, version, and thumbnail data required by the app SHALL be stored locally so the app works without network access after a successful first sync.

#### Scenario: Collection is browsable offline after sync
- **WHEN** the device has no network connectivity after a successful sync
- **THEN** the app can still display and search the full collection, including thumbnails

### Requirement: Lazy sync with visible progress
Sync SHALL load the collection list first so the UI appears quickly. Game details, versions, and thumbnails SHALL be fetched in batches respecting the BGG API limits, and a single visible progress indicator SHALL show the current sync progress.

#### Scenario: Collection list appears while details are still loading
- **WHEN** a sync starts
- **THEN** the collection list becomes visible as soon as possible and a single progress indicator updates until details/thumbnails complete

### Requirement: Sync respects BGG API limits
The app SHALL use the official BoardGameGeek XML API2 and SHALL respect the 20-item `thing` limit and the approximately 5-second rate limit.

#### Scenario: Thing requests are batched to 20 IDs
- **WHEN** more than 20 game details need to be fetched
- **THEN** the app splits the request into multiple `/xmlapi2/thing` calls with at most 20 IDs each

### Requirement: Sync provides status feedback
Sync operations SHALL clearly show loading, success, and error states to the user.

#### Scenario: Sync states are visible
- **WHEN** a sync is running, succeeds, or fails
- **THEN** the UI shows a corresponding loading, success, or error indicator

### Requirement: BGG remains the authoritative source
BGG SHALL remain the authoritative source for collection and game data. The local cache is a copy and SHALL be replaced by fresh BGG data on the next successful sync.

#### Scenario: Sync overwrites local cache with BGG data
- **WHEN** a sync completes successfully
- **THEN** the local cache matches the current BGG collection and game data

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

