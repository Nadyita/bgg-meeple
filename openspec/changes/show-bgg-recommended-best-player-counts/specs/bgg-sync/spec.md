# bgg-sync delta spec

## Purpose

Ensures that the BGG-recommended and BGG-best player count ranges fetched via `/xmlapi2/thing` are copied onto the corresponding collection items during sync, so they can be displayed on collection cards without additional database joins.

## MODIFIED Requirements

### Requirement: Collection items receive best and recommended player counts during sync

When a collection sync fetches or refreshes `/xmlapi2/thing` details for a game, the app SHALL copy the game's `bestPlayerCount`, `bestPlayerCountMin`, `bestPlayerCountMax`, `recommendedPlayerCount`, `recommendedPlayerCountMin`, and `recommendedPlayerCountMax` values onto every collection item for that game.

#### Scenario: Sync enriches collection items with player counts

- **GIVEN** a collection item exists for game id `123`
- **AND** the `/xmlapi2/thing` response for game `123` contains `recommendedPlayerCount` "3 - 4" and `bestPlayerCount` "3"
- **WHEN** the collection sync completes
- **THEN** the collection item for game `123` stores the same recommended and best player count values

#### Scenario: Missing thing details leave player counts null

- **GIVEN** a collection item exists for game id `456`
- **AND** no `/xmlapi2/thing` details are fetched for game `456` (e.g. no API token)
- **WHEN** the collection sync completes
- **THEN** the collection item's recommended and best player count fields remain null

### Requirement: Player count refresh is backward compatible

Cached collection items that were synced before this change SHALL keep their existing values (or nulls) and SHALL NOT crash or require a full resync. The schema migration SHALL add nullable columns so existing rows remain valid.

#### Scenario: Old cache survives schema update

- **GIVEN** the local cache was created before this change
- **WHEN** the app upgrades and opens the existing cache
- **THEN** the migration adds the new columns
- **AND** existing collection items load with null recommended/best player counts
