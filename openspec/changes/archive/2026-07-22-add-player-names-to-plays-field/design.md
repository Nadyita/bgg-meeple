# Design: Add player names to the Plays card field

## Overview

The feature adds an optional player-name list to the existing `Plays` metadata
line on collection cards. It reuses the locally cached plays already fetched by
the `plays-sync` capability.

## Domain changes

### `lib/domain/value_objects/card_layout_config.dart`

Add a new boolean field:

```dart
final bool showPlayerNamesOnPlays;
```

Update the constructor default, `copyWith`, and `props` list. The new flag is
independent of `hidePlaysOnZero`.

### `lib/domain/value_objects/card_field.dart`

No changes; `CardField.plays` remains the single field that renders the count
and the optional player suffix.

## Application layer changes

### New use case: `lib/application/use_cases/load_play_player_names_use_case.dart`

Responsibilities:

- Load all cached plays via `PlayStore.loadAll()`.
- Group players by `Play.thingId`.
- Collect non-empty, trimmed player names (`PlayPlayer.name`).
- Remove duplicates case-insensitively while preserving the first seen casing
  (e.g. `mark` and `Mark` become `Mark`).
- Sort alphabetically ascending case-insensitively.
- Return `Map<int, List<String>>` keyed by `thingId`.

This single bulk query avoids per-card database lookups and keeps the widget
layer free of store dependencies.

## Presentation layer changes

### `lib/presentation/blocs/collection/collection_bloc.dart`

- Add `LoadPlayPlayerNamesUseCase loadPlayPlayerNames` as a constructor
  dependency.
- After loading the collection items in `_onLoaded` and `_onSyncRequested`,
  call the use case and emit the resulting map in the state.
- Add the map to `CollectionSynced` handling if the sync event later carries it,
  or simply reload it after a sync completes.

### `lib/presentation/blocs/collection/collection_state.dart`

Add:

```dart
final Map<int, List<String>> playerNamesByGame;
```

Include it in `copyWith`, equality, and the default state as an empty map.

### `lib/presentation/widgets/collection_card.dart`

- Extend the constructor to accept `Map<int, List<String>> playerNamesByGame`.
- In `_playsLine`, look up `playerNamesByGame[item.thingId]` when
  `effectiveConfig.showPlayerNamesOnPlays` is true.
- If a non-empty list exists, append ` — Dine, Eva, Mark` to the count label.
- Keep the existing `hidePlaysOnZero` behavior: return `null` before any suffix
  is rendered when the count is zero and hiding is enabled.

### `lib/presentation/blocs/settings/settings_bloc.dart`

- Add a new `CardLayoutToggle.showPlayerNamesOnPlays` enum value.
- Handle it in `_onCardLayoutToggled` by calling
  `config.copyWith(showPlayerNamesOnPlays: value)`.

### `lib/presentation/blocs/settings/settings_event.dart`

- Add `showPlayerNamesOnPlays` to `CardLayoutToggle`.

### `lib/presentation/pages/settings_page.dart`

- Add a new `SwitchListTile` bound to `config.showPlayerNamesOnPlays` and the
  new toggle event.
- Extend `_fieldSuffix` for `CardField.plays` so that the reorderable field
  list shows a suffix such as "Spielernamen" / "Player names" when the option
  is enabled.

## Localization changes

### `lib/presentation/l10n/app_en.arb`

Add:

```json
"settingsShowPlayerNamesOnPlays": "Show player names",
"cardFieldPlaysPlayerNames": "Player names"
```

### `lib/presentation/l10n/app_de.arb`

Add:

```json
"settingsShowPlayerNamesOnPlays": "Spielernamen anzeigen",
"cardFieldPlaysPlayerNames": "Spielernamen"
```

Regenerate `app_localizations*.dart` via `flutter gen-l10n`.

## Dependency injection / wiring

### `lib/infrastructure/di/...` (existing service location)

Pass the new `LoadPlayPlayerNamesUseCase` into `CollectionBloc` wherever the
bloc is constructed.

## Testing

- Unit test the use case for unique sorting, case-insensitive deduplication,
  and null-name filtering.
- Unit test `CollectionCard` that the suffix appears only when the config flag
  and a matching player map entry exist.
- Unit test the settings BLoC toggle.
- Update golden/widget tests that assert the exact `Plays` label text.
