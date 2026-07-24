# search-and-filter delta spec

## Purpose

Adds inventory-location filtering to the collection screen with a tri-state chip UI analogous to the player participation filter. Each added location cycles through `any` (no effect), `matches` (game must be stored here), and `excludes` (game must not be stored here).

## ADDED Requirements

### Requirement: Filter by inventory location

The filter controls SHALL allow the user to add inventory locations and, for each added location, choose one of three states:

- `any` (default) — the location does not affect the result.
- `matches` — only games stored at this location are shown.
- `excludes` — games stored at this location are hidden.

Multiple `matches` locations SHALL be combined with OR logic. Multiple `excludes` locations SHALL be combined with AND logic. `matches` and `excludes` groups SHALL be combined with each other and with all other filters using AND logic.

#### Scenario: Filter by a single location

Given the collection contains "Catan" at "Keller" and "Carcassonne" at "Wohnzimmer"
When the user adds "Keller" with state `matches`
Then only "Catan" is shown

#### Scenario: Filter by multiple locations uses OR logic

Given the collection contains "Catan" at "Keller", "Carcassonne" at "Wohnzimmer", and "Azul" at "Eva"
When the user adds "Keller" and "Wohnzimmer" with state `matches`
Then "Catan" and "Carcassonne" are shown, but "Azul" is not

#### Scenario: Exclude a single location

Given the collection contains "Catan" at "Keller", "Carcassonne" at "Wohnzimmer", and "Azul" at "Eva"
When the user adds "Keller" with state `excludes`
Then "Carcassonne" and "Azul" are shown, but "Catan" is not

#### Scenario: Exclude multiple locations uses AND logic

Given the collection contains "Catan" at "Keller", "Carcassonne" at "Wohnzimmer", and "Azul" at "Eva"
When the user adds "Keller" and "Wohnzimmer" with state `excludes`
Then only "Azul" is shown

#### Scenario: Games without a location are excluded by positive matches filter

Given the collection contains "Catan" at "Keller" and "Ticket to Ride" with no inventory location
When the user adds "Keller" with state `matches`
Then only "Catan" is shown

#### Scenario: Games without a location pass an excludes filter

Given the collection contains "Catan" at "Keller" and "Ticket to Ride" with no inventory location
When the user adds "Keller" with state `excludes`
Then "Ticket to Ride" is shown and "Catan" is not

#### Scenario: Location filter combines with other filters using AND logic

Given the user searches for "Ca" and adds "Keller" with state `matches`
When the list is updated
Then only games whose name contains "Ca" and whose inventory location is "Keller" are shown

### Requirement: Location filter picker shows available locations

The filter panel SHALL provide a picker listing every distinct, non-empty inventory location currently present in the loaded collection. Locations already added to the filter SHALL be omitted from the picker.

#### Scenario: Picker lists available locations

Given the loaded collection contains inventory locations "Keller" and "Wohnzimmer"
When the user opens the location picker
Then "Keller" and "Wohnzimmer" are shown as selectable options

#### Scenario: Already added locations are hidden from picker

Given the user has already added "Keller" to the filter
When the user opens the location picker
Then "Keller" is not shown, but "Wohnzimmer" is still shown

### Requirement: Location filter chip cycles through states

Tapping a location chip in the filter panel SHALL cycle its state in the order `any` → `matches` → `excludes` → `any`. Long-pressing (touch) or using the delete icon (pointer) SHALL remove the chip from the filter.

#### Scenario: Chip cycles through states

Given the user added "Keller" to the location filter
When the user taps the "Keller" chip three times
Then the state cycles from `matches` to `excludes` and back to `any`

### Requirement: Location filter is cleared by reset

The existing "Zurücksetzen" button in the filter panel SHALL set every added inventory-location filter to `any` without removing the location chips. It SHALL also remove any location that is no longer present in the loaded collection.

#### Scenario: Reset sets location filters to any

Given the user added "Keller" with state `matches`
When the user taps "Zurücksetzen"
Then the "Keller" chip remains visible but is set to `any`
And the full collection is shown

#### Scenario: Reset removes obsolete locations

Given the loaded collection no longer contains the location "Keller"
And the persisted filter contains "Keller" with state `matches`
When the filter panel is opened or the collection finishes loading
Then the "Keller" chip is removed because the location no longer exists

### Requirement: Location filter chips are cleaned up when the collection changes

When the collection is loaded or synced, any inventory-location filter entry whose location is not present in the loaded items SHALL be removed automatically. Known locations SHALL remain but their state SHALL only change when the user interacts with the chip.

#### Scenario: Unknown location is dropped after sync

Given the user added "Keller" with state `matches`
And a sync removes all games stored at "Keller"
When the sync completes
Then "Keller" is removed from the location filter

### Requirement: Player filters combine with existing filters using AND logic

Player participation filters SHALL be combined with search text, collection sub-types, player count, play time, rating, play count, and inventory location using AND logic.

#### Scenario: Search and player filter together

Given the user searches for "Catan" and adds player "Markus" with state played
When the list is updated
Then only games whose name contains "Catan" and which contain Markus are shown
