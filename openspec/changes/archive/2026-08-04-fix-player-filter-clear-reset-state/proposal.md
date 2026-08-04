# Proposal: Reset player filters to any/gray on "Clear filters"

## Problem

Tapping the "Clear filters" / "Zurücksetzen" button in the filter panel currently removes all player participation chips from the active filter. The expected behavior is the same as for inventory location chips: each player chip should remain visible but be reset to the neutral `any` (gray) state.

## Affected capability

- `search-and-filter` – filter clear behavior.

## Root cause

`CollectionBloc._onFilterCleared` constructs a new `CollectionFilter` that only preserves the `playerCountFilterMode` and resets `inventoryLocationFilters`. It leaves `playerParticipation` at the default empty map, so the UI no longer has any player chips to render.

## Proposed fix

When clearing filters, keep every known player in the `playerParticipation` map and set each value to `PlayerParticipationFilter.any`. This mirrors `CollectionFilter.resetInventoryLocationFilters()` and aligns the player-filter behavior with the location-filter behavior.

## Scope

- `lib/presentation/blocs/collection/collection_bloc.dart` – `_onFilterCleared`.
- `test/presentation/blocs/collection_bloc_test.dart` – add/update bloc test for `CollectionFilterCleared`.

## Out of scope

- No UI page changes; the existing UI already handles `PlayerParticipationFilter.any` correctly.
- No domain model changes needed.
