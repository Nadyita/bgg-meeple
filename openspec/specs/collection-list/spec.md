# collection-list Specification

## Purpose

Defines how the user's BoardGameGeek collection is presented as a scrollable, card-based list, including display-name logic, year handling, offline thumbnails, collection sub-type chips, and the optional compact table view.

## Requirements
### Requirement: Main screen shows a card-based collection list
The main screen SHALL show a single, large, continuous scrollable list of cards with one card per collection item. The list SHALL NOT paginate or introduce virtual page breaks.

#### Scenario: Collection renders as scrollable cards
- **WHEN** the user opens the main screen after a sync
- **THEN** a scrollable list of collection cards is displayed without pagination controls

### Requirement: Card title uses the correct game name
The card title SHALL use the board game's primary BGG name. The selected version's name SHALL appear as an edition subtitle and SHALL NOT replace the title. If the user has set a custom name in their BGG collection, that custom name SHALL take precedence over the version/name fallback.

#### Scenario: Custom name overrides all other names
- **WHEN** the user has a custom name in their BGG collection for a game
- **THEN** the card displays the custom name as the title

#### Scenario: Version name appears as subtitle
- **WHEN** the user has selected a version but has no custom name
- **THEN** the title is the primary BGG name and the version name appears as a subtitle

### Requirement: Card year uses version year with fallback
The year shown on the card SHALL come from the selected version year, or fall back to `yearpublished` when no version year is available.

#### Scenario: Year fallback works
- **WHEN** a collection item has no selected version year
- **THEN** the card shows the game's `yearpublished`

### Requirement: Thumbnails are displayed and cached offline
Each card SHALL show the game's thumbnail. Thumbnails SHALL be downloaded during sync and cached as local files so they remain available offline. The UI SHALL prefer the local cached file and fall back to the network URL when no local copy exists.

#### Scenario: Thumbnail visible offline
- **WHEN** the user views the collection without network access after a successful sync
- **THEN** each card still shows its cached thumbnail

### Requirement: Collection sub-type chips are shown
Each card SHALL show chips for the collection sub-types that apply to it (for example owned, wanted, wishlist, played) matching the user's BGG collection flags. The chip labels SHALL remain in English because they are established BGG terms.

#### Scenario: Sub-type chips match BGG collection flags
- **WHEN** a collection item is marked as owned and played in BGG
- **THEN** the card shows chips for owned and played

### Requirement: Compact table-style view toggle
The main app bar SHALL offer a toggle that switches the list between the standard card view and a compact table-style list showing only the game name.

#### Scenario: Toggle updates list immediately
- **WHEN** the user toggles the compact view control
- **THEN** the collection list switches to the selected view mode immediately

