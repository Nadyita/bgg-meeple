## ADDED Requirements

### Requirement: New plays-sync capability
A new `plays-sync` capability SHALL define how BGG plays are downloaded and cached locally.

#### Scenario: Capability exists
- **WHEN** the app is built
- **THEN** the `plays-sync` capability spec is present under `openspec/specs/plays-sync/spec.md` and describes the `/plays` endpoint integration

### Requirement: Plays downloaded during the normal sync flow
When a BGG account is configured and the user triggers a sync, the app SHALL
fetch all board-game plays in addition to the collection and game details.

#### Scenario: One sync refreshes collection, games, and plays
- **WHEN** the user starts a sync
- **THEN** the app downloads plays after the collection list and game details
  have been fetched, and persists them locally

### Requirement: Plays endpoint called with correct parameters
The app SHALL request `https://boardgamegeek.com/xmlapi2/plays` with
`username=<username>` and `subtype=boardgame`, paginating with `page=<page>`.

#### Scenario: Play request matches BGG API contract
- **WHEN** the app fetches plays for a configured user
- **THEN** the request uses the `plays` endpoint, includes the configured
  username, filters by `subtype=boardgame`, and increments `page` for each batch

### Requirement: All play pages fetched
The app SHALL read the `total` attribute of the first response and continue
requesting pages until every play has been downloaded.

#### Scenario: User has plays across multiple pages
- **WHEN** the play history spans more than one page
- **THEN** the app requests every page and returns the complete list of plays

### Requirement: Play data stored locally and kept offline
Every downloaded play SHALL be stored in the local cache with its date,
quantity, length, location, comments, linked game, subtypes, and players.

#### Scenario: Plays are available offline after sync
- **WHEN** the device has no network after a successful sync
- **THEN** the app can still read the full play history from the local cache

### Requirement: Sync shows play download progress
The sync progress indicator SHALL include a `plays` phase that reports how many
plays have been loaded so far.

#### Scenario: User sees plays phase during sync
- **WHEN** plays are being downloaded
- **THEN** the progress indicator shows the `plays` phase and the number of plays
  already loaded

### Requirement: BGG API limits respected while fetching plays
The app SHALL apply the same rate limiting and retry logic used for the
`/collection` and `/thing` endpoints to `/plays` requests.

#### Scenario: Multiple play pages are fetched safely
- **WHEN** many play pages must be downloaded
- **THEN** the app waits between requests and retries on HTTP 202, just like
  the other XML API2 calls

### Requirement: Local play cache authoritative after sync
On a successful sync the local play data SHALL be replaced by the current BGG
play history.

#### Scenario: Sync overwrites old plays
- **WHEN** a sync completes successfully
- **THEN** previously cached plays for the same user are replaced by the freshly
  downloaded plays
