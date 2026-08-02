# bgg-thing-details Specification

## Purpose

Defines how the app enriches cached board game data via the authenticated BoardGameGeek `/xmlapi2/thing` endpoint when a user-provided API key is present. This includes parsing additional fields, normalizing BGG links in the local cache, and refreshing stale details lazily.

## Requirements

### Requirement: Fetch /thing details when description is missing during sync
When a valid API key is stored and a board game's description is missing or empty, the app SHALL fetch the game's `/xmlapi2/thing` data and persist the newly parsed fields.

#### Scenario: Sync fills missing description
- **GIVEN** the user has stored a valid BGG API key
- **AND** the local cache contains a board game with an empty or null description
- **WHEN** a collection sync runs
- **THEN** the app calls `/xmlapi2/thing` for that game
- **AND** stores description, best player count, suggested player age, language dependence level, and all supported BGG links

#### Scenario: Sync skips games that already have a description
- **GIVEN** the user has stored a valid BGG API key
- **AND** the local cache contains a board game with a non-empty description
- **WHEN** a collection sync runs
- **THEN** the app does not call `/xmlapi2/thing` for that game only to refresh details

### Requirement: Parse description from /thing XML
The app SHALL extract the game's description from `item/description` and store it as plain text.

#### Scenario: Description is parsed and stored
- **GIVEN** `/xmlapi2/thing` returns a game item containing a `description` element
- **WHEN** the app parses the response
- **THEN** the description text is stored on the cached board game

### Requirement: Parse best player count from poll summary
The app SHALL parse the `bestwith` value in `poll-summary[@name='suggested_numplayers']` into numeric `bestPlayerCountMin` and `bestPlayerCountMax` values. It SHALL support the forms `X`, `X-Y`, `X+`, and `X-Y+`.

#### Scenario: Single best player count
- **GIVEN** the `bestwith` value is "Best with 4 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 4 and `bestPlayerCountMax` is 4

#### Scenario: Closed best player count range
- **GIVEN** the `bestwith` value is "Best with 4–5 players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 4 and `bestPlayerCountMax` is 5

#### Scenario: Open-ended best player count
- **GIVEN** the `bestwith` value is "Best with 5+ players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 5 and `bestPlayerCountMax` is null

#### Scenario: Closed open-ended best player count range
- **GIVEN** the `bestwith` value is "Best with 8–18+ players"
- **WHEN** the app parses the summary
- **THEN** `bestPlayerCountMin` is 8 and `bestPlayerCountMax` is null

### Requirement: Parse recommended player count from poll summary
The app SHALL parse the `recommendedwith` value in `poll-summary[@name='suggested_numplayers']` into numeric `recommendedPlayerCountMin` and `recommendedPlayerCountMax` values, using the same rules as for the best player count.

#### Scenario: Closed recommended range
- **GIVEN** the `recommendedwith` value is "Recommended with 3–7 players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCountMin` is 3 and `recommendedPlayerCountMax` is 7

#### Scenario: Open-ended recommended range
- **GIVEN** the `recommendedwith` value is "Recommended with 8—18+ players"
- **WHEN** the app parses the summary
- **THEN** `recommendedPlayerCountMin` is 8 and `recommendedPlayerCountMax` is null

### Requirement: Accept different dash characters as range separators
The app SHALL treat en-dash (`–`), em-dash (`—`), and hyphen-minus (`-`) as equivalent range separators when parsing player count ranges.

#### Scenario: En-dash range
- **GIVEN** the summary value contains "4–5"
- **WHEN** the app parses the value
- **THEN** it extracts min 4 and max 5

### Requirement: Fall back to raw poll data when poll-summary is missing
When the `poll-summary` element is absent or does not contain a parseable value, the app SHALL compute best and recommended ranges from the raw `suggested_numplayers` poll.

#### Scenario: Best count fallback
- **GIVEN** no `poll-summary` is present
- **AND** the `poll` shows the highest number of `Best` votes at 4 players
- **WHEN** the app parses the poll
- **THEN** `bestPlayerCountMin` is 4 and `bestPlayerCountMax` is 4

#### Scenario: Recommended range fallback
- **GIVEN** no `poll-summary` is present
- **AND** the `poll` shows `Recommended` share ≥ 50 % for 3, 4, 5, and 6 players
- **WHEN** the app parses the poll
- **THEN** `recommendedPlayerCountMin` is 3 and `recommendedPlayerCountMax` is 6

### Requirement: Store player count ranges in the database
The app SHALL persist `bestPlayerCountMin`, `bestPlayerCountMax`, `recommendedPlayerCountMin`, and `recommendedPlayerCountMax` in the local cache so they can be used for filtering.

#### Scenario: Round-trip persistence
- **GIVEN** a parsed game has best range 4–5 and recommended range 3–7
- **WHEN** the game is saved and reloaded from the cache
- **THEN** all four numeric values are restored correctly

### Requirement: Parse weighted suggested player age
The app SHALL calculate the weighted average of all `result` entries in `item/poll[@name='suggested_playerage']`, using `value` as the age and `numvotes` as the weight. The result SHALL be stored as a string rounded to one decimal place (e.g. "9.5").

#### Scenario: Weighted age is calculated for Broom Service
- **GIVEN** `/xmlapi2/thing` returns a game item with a `suggested_playerage` poll
- **AND** the poll results are: value "6" with 1 vote, value "8" with 17 votes, value "10" with 25 votes, value "12" with 6 votes
- **WHEN** the app parses the response
- **THEN** the stored suggested player age is "9.5"

#### Scenario: Non-numeric age value is handled
- **GIVEN** `/xmlapi2/thing` returns a `suggested_playerage` poll containing a value such as "21 and up"
- **WHEN** the app parses the response
- **THEN** the non-numeric value contributes no weighted age and is ignored

### Requirement: Parse language dependence level
The app SHALL extract the language dependence level by selecting the `result` with the highest `numvotes` inside `item/poll[@name='language_dependence']` and storing its `level` attribute as a numeric string.

#### Scenario: Language dependence level is parsed
- **GIVEN** `/xmlapi2/thing` returns a `language_dependence` poll
- **AND** the result with the most votes has `level="2"`
- **WHEN** the app parses the response
- **THEN** the stored language dependence value is "2"

### Requirement: Parse BGG links with IDs and names
The app SHALL extract every `link` element from the `/thing` item and store each link's BGG `id` and `value` together with its `type`.

#### Scenario: Family links are stored with IDs and names
- **GIVEN** `/xmlapi2/thing` returns a game item with family links
- **AND** one link has `type="boardgamefamily"`, `id="45609"`, `value="Game: Broom Service"`
- **WHEN** the app parses the response
- **THEN** a link record with type `family`, bggId `45609`, and name `Game: Broom Service` is stored and associated with the game

#### Scenario: Multiple link types are supported
- **GIVEN** `/xmlapi2/thing` returns links of types `boardgamecategory`, `boardgamemechanic`, `boardgamefamily`, `boardgamedesigner`, `boardgameartist`, `boardgamepublisher`, `boardgameexpansion`, and `boardgameimplementation`
- **WHEN** the app parses the response
- **THEN** each link is stored with a normalized type (`category`, `mechanic`, `family`, `designer`, `artist`, `publisher`, `expansion`, `implementation`) and associated with the game

### Requirement: Normalize BGG links in the local cache
The app SHALL store BGG links in a normalized form: one link table containing the BGG id, type, and name, and one many-to-many relation table connecting games to links.

#### Scenario: Same link reused across games
- **GIVEN** two games share the same family link with bggId `58`
- **WHEN** both games are saved
- **THEN** only one `game_links` row exists for that family
- **AND** two relation rows connect each game to that link

#### Scenario: Loading a game restores all its links
- **GIVEN** a game was saved with category, mechanic, and family links
- **WHEN** the game is loaded from the cache
- **THEN** all links are restored with correct type, bggId, and name

### Requirement: Track when details were last updated
The app SHALL record a timestamp in milliseconds since epoch whenever `/thing` details are persisted for a game.

#### Scenario: Stored timestamp reflects last update
- **GIVEN** a game was just enriched from `/thing`
- **WHEN** the game is persisted
- **THEN** its `detailsUpdatedAt` field contains the current timestamp

### Requirement: Lazy refresh of stale details on detail page
When the user opens a game detail page and a valid API key is stored, the app SHALL fetch fresh `/thing` data in the background if the locally cached details are older than 30 days or have never been fetched. Existing cached data SHALL be shown immediately and updated once fresh data arrives.

#### Scenario: Stale details trigger background refresh
- **GIVEN** a game has cached details older than 30 days
- **AND** the user has stored a valid API key
- **WHEN** the user opens the game's detail page
- **THEN** the existing cached details are shown immediately
- **AND** a background request fetches fresh `/thing` data
- **AND** the page updates once the fresh data is persisted

#### Scenario: Recent details do not trigger refresh
- **GIVEN** a game has cached details updated within the last 30 days
- **AND** the user has stored a valid API key
- **WHEN** the user opens the game's detail page
- **THEN** the cached details are shown immediately
- **AND** no additional `/thing` request is made for that game

### Requirement: /thing requires a valid API token
The app SHALL only call `/xmlapi2/thing` when a valid API token is available. If no token is configured, the app SHALL not attempt the call and SHALL keep whatever data is already cached.

#### Scenario: Missing API token skips /thing call
- **GIVEN** the user has saved credentials but no API token
- **WHEN** a sync or detail page visit occurs
- **THEN** no `/xmlapi2/thing` request is made
- **AND** existing cached details remain unchanged
