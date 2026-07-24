# Filter collection by inventory location

## Summary

Add an inventory-location filter to the collection screen with a tri-state chip UI (analogous to the player participation filter). Each added location cycles through `any`, `matches`, and `excludes`. Multiple `matches` locations are combined with OR logic; multiple `excludes` locations are combined with AND logic. The filter is reset by the existing "Zurücksetzen" button.

## Motivation

- The app already reads, persists, and displays `inventoryLocation` from BGG as an optional card field.
- Users with many games stored in different rooms, boxes, or shelves want to quickly see "everything in the cellar" or "everything at Eva's place".
- A location is a discrete, known value per game, so a chip-based picker (like the player filter) is more discoverable and less error-prone than a free-text field.

## Affected Capabilities

- `search-and-filter` – Add a new filter criterion and UI section for inventory locations.
- `collection-list` – Filtered list must respect the new criterion.

## Proposed Solution

1. Create `InventoryLocationFilter` enum with `any`, `matches`, and `excludes` plus a `cycle()` helper.
2. Replace the previous `Set<String> selectedInventoryLocations` in `CollectionFilter` with `Map<String, InventoryLocationFilter> inventoryLocationFilters`.
3. Persist the new field in `CollectionFilter.toJson()` and restore it in `CollectionFilter.fromJson()`.
4. In `CollectionBloc._matchesFilter`, evaluate `matches` locations with OR logic and `excludes` locations with AND logic.
5. In `collection_page.dart`, add `_LocationFilterSection` and `_LocationChip` that mirror the player filter UX: tap to cycle states, long-press / delete icon to remove.
6. Place the new section directly above `_PlayerFilterSection` inside `_FilterPanel`.
7. Add localization keys for the section title, add button, picker title, and empty message.
8. Update tests to cover tri-state behavior, combined OR/AND logic, and UI state cycling.

## Alternatives Considered

- **Simple multi-select with OR only** – Rejected because it lacks the expressive "exclude this location" option and does not match the player-filter UX.
- **AND logic for multiple locations** – Rejected because a game can only have one location, which would always yield zero results for two different locations.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] Localization changes
