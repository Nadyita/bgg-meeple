# Proposal: Filter collection by player participation

## Why

Users often want to find a suitable game by checking whether specific players have already played it or still need to try it. The current filter panel supports search, collection sub-types, player count, play time, and rating, but offers no way to filter by the players who participated in logged plays.

This change adds per-player participation filters to the collection screen so users can quickly restrict the list to games a particular player has played or has not yet played.

## Affected capabilities

- `search-and-filter` — extends filter criteria with player participation.
- `sort-and-view-state` — persists the new filter values in the collection view state.
- `settings-and-theme` — adds a toggle to disable the add-player hint snackbar.

## Scope

1. Extend `CollectionFilter` with a map of player names to participation states.
2. Apply the new criteria in the collection BLoC using existing per-game player name data.
3. Add a player filter section to the filter panel with a player picker, state chips, and platform-adaptive removal.
4. Show a one-time-or-configurable snackbar hint after adding a player.
5. Persist the state via the existing `CollectionViewStore` and update tests.

## Out of scope

- Filtering by BGG username; the first version uses display names only.
- Changing how plays are loaded or stored.
- Global default filter presets.
