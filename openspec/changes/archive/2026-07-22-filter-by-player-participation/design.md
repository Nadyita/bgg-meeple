# Design: Filter collection by player participation

## Overview

The new player participation filter lives in the existing filter panel on the collection screen. It reuses the already loaded per-game player name data (`Map<int, List<String>>`) produced by `LoadPlayPlayerNamesUseCase`. No play loading logic changes.

## Domain model

### `PlayerParticipationFilter`

New enum in `lib/domain/value_objects/player_participation_filter.dart`:

```dart
enum PlayerParticipationFilter {
  any,
  played,
  notPlayed,
}
```

### `CollectionFilter`

Add a new field:

```dart
final Map<String, PlayerParticipationFilter> playerParticipation;
```

- Default value in the const constructor: `const {}`.
- `copyWith` gains a `Map<String, PlayerParticipationFilter>? playerParticipation` parameter.
- `toJson` serializes the map as `{"Markus": "played"}`.
- `fromJson` parses the map and ignores unknown enum values.
- `isActive` returns `true` if the map contains at least one non-`any` entry.
- `props` includes the map.

## Application / BLoC

### `CollectionBloc._matchesFilter`

After the existing criteria, evaluate player participation:

1. Look up the list of player names for the current item: `playerNamesByGame[item.id] ?? []`.
2. For each entry in `filter.playerParticipation`:
   - Compare the stored player name case-insensitively against the game’s player list.
   - For `played`: require a match; otherwise reject.
   - For `notPlayed`: require no match; otherwise reject.
   - For `any`: no effect.

A small helper extension or private method handles case-insensitive set membership.

## UI

### `_FilterPanel`

A new section below the rating slider:

- Header row with the localized label "Spieler" (or the existing localization key).
- An "add player" button (text or icon). Pressing it opens a bottom sheet / dialog listing all known players sorted alphabetically. Players already present in the current filter are omitted or disabled.
- Each added player is shown as a chip.

### Chip states

| State | Visual |
|-------|--------|
| `any` | Outlined chip, greyed / muted background, name still readable |
| `played` | Filled green chip with check icon |
| `notPlayed` | Filled red chip with cross icon |

Tapping the chip cycles the state: `any → played → notPlayed → any`.

### Chip removal

- On touch-primary devices: long-press removes the chip.
- On pointer-primary devices (mouse / stylus / trackpad): a small close icon on the chip removes it.
- The input device is detected via `PointerDeviceKind` from the latest pointer event / `MediaQuery` data, not only `Platform.isX`.

### Obsolete player hint

If a persisted player no longer appears in any loaded play (e.g. the user deleted plays), the chip is still shown with a small frown icon overlay to indicate the player is missing from current data. The filter itself behaves as `any` in that case.

### Snackbar hint

Each time a player is added, a short snackbar is shown:

- Touch: "Zum Entfernen lange auf den Spieler tippen."
- Pointer: "Zum Entfernen auf das X tippen."

The snackbar is only shown if the "Show player filter hint" setting is enabled. The default is enabled.

## Reset behavior

The filter panel’s reset button clears all numeric/range/sub-type filters. For player filters it:

1. Sets every currently known player to `any`.
2. Removes chips whose players no longer appear in any loaded play (frown icon players).

This lets users who always filter by the same player keep that player in the panel and simply toggle between states without re-adding them.

## Persistence

The new map is part of `CollectionFilter`, which is part of `CollectionView`. `CollectionViewStore` persists and restores it automatically. Unknown enum values during deserialization are ignored, so corrupt data cannot crash the screen.

## Settings

A new boolean setting is added under settings. The value is stored with the existing settings persistence mechanism (currently `SharedPreferences` via the settings store). The setting key and UI label are added to the settings screen.

## Localization

New keys needed:

- Add-player button label
- Player filter section title
- Empty player picker hint
- Snackbar hint (touch and pointer variants)
- Settings toggle label

## Testing

- Unit tests for `CollectionFilter` serialization and `isActive`.
- Unit tests for `_matchesFilter` player logic in `CollectionBloc`.
- Widget tests for the chip state cycling.
- Widget tests for add/remove player interactions.
