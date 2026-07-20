## ADDED Requirements

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
