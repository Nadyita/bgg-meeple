## MODIFIED Requirements

### Requirement: Manual BGG sync is available when an account is configured
The app SHALL display a clearly identifiable sync button or icon whenever a valid BGG account is configured. Tapping the sync control SHALL trigger a full sync of the user's collection, game details, versions, and plays.

#### Scenario: Sync button visible with credentials
- **WHEN** the user has saved BGG credentials
- **THEN** the main collection screen shows an enabled sync affordance

#### Scenario: Sync button triggers full sync
- **WHEN** the user taps the sync affordance
- **THEN** the app fetches the collection list, game details, versions, thumbnails, and plays

### Requirement: Sync caches data for offline use
All game, collection, version, thumbnail, and play data required by the app SHALL be stored locally so the app works without network access after a successful first sync.

#### Scenario: Collection is browsable offline after sync
- **WHEN** the device has no network connectivity after a successful sync
- **THEN** the app can still display and search the full collection, including thumbnails

### Requirement: Lazy sync with visible progress
Sync SHALL load the collection list first so the UI appears quickly. Game details, versions, thumbnails, and plays SHALL be fetched in batches respecting the BGG API limits, and a single visible progress indicator SHALL show the current sync progress.

#### Scenario: Collection list appears while details are still loading
- **WHEN** a sync starts
- **THEN** the collection list becomes visible as soon as possible and a single progress indicator updates until details, thumbnails, and plays complete

### Requirement: BGG remains the authoritative source
BGG SHALL remain the authoritative source for collection, game, and play data. The local cache is a copy and SHALL be replaced by fresh BGG data on the next successful sync.

#### Scenario: Sync overwrites local cache with BGG data
- **WHEN** a sync completes successfully
- **THEN** the local cache matches the current BGG collection, game, and play data

### Requirement: Local cache uses a reliable persistence layer
All locally cached game, collection, version, and play data SHALL be stored in a reliable persistence layer that supports offline queries (for example SQLite, Hive, ObjectBox, or shared preferences plus JSON).

#### Scenario: Offline query of cached data
- **WHEN** the device is offline after a successful sync
- **THEN** the app can query and display cached collection, game, version, and play data from the local store
