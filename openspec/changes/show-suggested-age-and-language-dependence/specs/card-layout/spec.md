# card-layout delta spec

## Purpose

Extends the collection card so the configured minimum-age field shows the cached BGG thing value as a fallback and appends the community-suggested player age when available.

## MODIFIED Requirements

### Requirement: Minimum-age card field uses cached thing data as fallback

When `CardField.minAge` is enabled, the collection card SHALL display the minimum age. It SHALL prefer the value on the `CollectionItem`, but if that is missing, it SHALL fall back to the cached `BoardGame.minAge`.

#### Scenario: Collection item has no minimum age but cached thing does

- **GIVEN** a collection item with `minAge` set to `null`
- **AND** the cached `BoardGame` for the same game has `minAge` set to `10`
- **AND** `CardField.minAge` is enabled in the card layout
- **WHEN** the collection card is rendered
- **THEN** the card shows a minimum age of `10`

#### Scenario: Sync writes the thing's minimum age into the collection item

- **GIVEN** a collection item with `minAge` set to `null`
- **AND** the cached `BoardGame` for the same game has `minAge` set to `10`
- **WHEN** the collection is synced
- **THEN** the saved collection item has `minAge` set to `10`
- **AND** the card shows a minimum age of `10` without requiring a separate load-time fallback

### Requirement: Suggested player age appears inline after the minimum age

When `CardField.minAge` is enabled and a cached `BoardGame.suggestedPlayerAge` exists, the card SHALL append the suggested age after the minimum age using a thumbs-up icon and a non-breaking separator. The suggested age SHALL NOT be shown on its own if the minimum age is missing.

#### Scenario: Card shows minimum age and suggested age together

- **GIVEN** a collection item with `minAge` set to `8`
- **AND** the cached `BoardGame.suggestedPlayerAge` is `"10.0"`
- **AND** `CardField.minAge` is enabled
- **WHEN** the collection card is rendered
- **THEN** the metadata line reads like `Min age: 8 · 👍 10` with a separator dot between the minimum age and the suggested age suffix

#### Scenario: Suggested age is hidden when there is no minimum age

- **GIVEN** a collection item with `minAge` set to `null`
- **AND** the cached `BoardGame.minAge` is also `null`
- **AND** the cached `BoardGame.suggestedPlayerAge` is `"10.0"`
- **WHEN** the collection card is rendered
- **THEN** no age metadata line is shown

#### Scenario: Only minimum age is shown when suggestion is missing

- **GIVEN** a collection item with `minAge` set to `8`
- **AND** the cached `BoardGame.suggestedPlayerAge` is `null`
- **WHEN** the collection card is rendered
- **THEN** the metadata line shows the minimum age without a thumbs-up suffix

### Requirement: Collection XML stats attributes including minAge are parsed

The BGG `/xmlapi2/collection` endpoint provides player-count, play-time, and minimum-age attributes on the `<stats>` element. The app SHALL parse these attributes into the corresponding `CollectionItem` fields so that the collection card can display them without requiring a separate `/thing` fetch.

#### Scenario: Collection item includes minAge from collection stats

- **GIVEN** a BGG collection response contains an item with `<stats minplayers="2" maxplayers="4" minplaytime="30" maxplaytime="60" minage="8" ...>`
- **WHEN** the collection is parsed
- **THEN** the resulting `CollectionItem` has `minPlayers` set to `2`, `maxPlayers` set to `4`, `minPlayTime` set to `30`, `maxPlayTime` set to `60`, and `minAge` set to `8`

### Requirement: BoardGame.minAge is parsed from /thing XML value attribute

The `/xmlapi2/thing` endpoint represents `minage` as an element with a `value` attribute (e.g. `<minage value="10"/>`). The parser SHALL read the attribute value and store it as `BoardGame.minAge`.

#### Scenario: /thing XML minage value attribute is stored in BoardGame

- **GIVEN** a `/xmlapi2/thing` response contains `<minage value="10"/>`
- **WHEN** the game details are parsed
- **THEN** the resulting `BoardGame.minAge` is set to `10`

### Requirement: Stale cached thing details missing age data are refreshed on sync

When a cached `BoardGame` row is missing `minAge` or `suggestedPlayerAge`, `SyncCollectionUseCase` SHALL treat it as incomplete and refetch the game details from `/xmlapi2/thing` during the next sync. The refreshed values SHALL then be written into the synced `CollectionItem`s.

#### Scenario: Old cached game without minAge is refreshed during sync

- **GIVEN** a cached `BoardGame` with `minAge` set to `null` and `suggestedPlayerAge` set to `"10.0"`
- **AND** the collection contains an item for that game
- **WHEN** the collection is synced
- **THEN** the app fetches `/xmlapi2/thing` for that game
- **AND** the saved collection item receives the refreshed `minAge`

#### Scenario: Old cached game without suggestedPlayerAge is refreshed during sync

- **GIVEN** a cached `BoardGame` with `minAge` set to `8` and `suggestedPlayerAge` set to `null`
- **AND** the collection contains an item for that game
- **WHEN** the collection is synced
- **THEN** the app fetches `/xmlapi2/thing` for that game
- **AND** the saved collection item receives the refreshed `suggestedPlayerAge`
