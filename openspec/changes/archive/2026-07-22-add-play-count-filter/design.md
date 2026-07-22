# Design: Filter collection by play count

## Overview

Add a play-count range filter to the collection filter panel. The filter works like the existing rating slider but with integer steps and a dynamic maximum.

## Domain changes

### `CollectionFilter` (`lib/domain/value_objects/collection_filter.dart`)

- Add `int? minPlays` and `int? maxPlays`.
- Update `isActive`, `copyWith`, `toJson`, `fromJson`, `props`, and `const` constructor defaults.
- Follow the existing nullable optional-filter pattern with `clearMinPlays` / `clearMaxPlays` flags.

## Application changes

### `LoadPlayPlayerNamesUseCase` (`lib/application/use_cases/load_play_player_names_use_case.dart`)

The current use case returns only the set of player names per game. The play-count filter needs the actual plays per game to evaluate player participation rules per play.

- Change the return type from `Map<int, List<String>>` to a new value object `PlaysInfo` that carries both:
  - `playerNamesByGame: Map<int, List<String>>`
  - `playsByGame: Map<int, List<Play>>`
- Rename the use case to `LoadPlaysInfoUseCase` to reflect the broader responsibility.
- Keep the existing player-name deduplication and sorting behavior.

### New value object `PlaysInfo` (`lib/domain/value_objects/plays_info.dart`)

- Immutable object with two maps keyed by `thingId`.
- Used by the BLoC and filter UI.

## Presentation changes

### `CollectionBloc` (`lib/presentation/blocs/collection/collection_bloc.dart`)

- Replace dependency on `LoadPlayPlayerNamesUseCase` with `LoadPlaysInfoUseCase`.
- Store `PlaysInfo` instead of `Map<int, List<String>>` in the state.
- Use `PlaysInfo.playsByGame` when calculating the effective play count during filtering.

### `CollectionState` (`lib/presentation/blocs/collection/collection_state.dart`)

- Replace `Map<int, List<String>> playerNamesByGame` with `PlaysInfo playsInfo`.
- Update `copyWith`, constructor defaults, and `props`.

### `CollectionPage` (`lib/presentation/pages/collection_page.dart`)

- Pass `playsInfo` to `_FilterPanel` and `_PlayerFilterSection`.
- Compute `maxPlays` from the full list of loaded collection items (`items.map((i) => i.numPlays ?? 0).max`).
- Add a `_PlayCountRangeSlider` widget below the `_RatingRangeSlider`.
- Wire `minPlays` / `maxPlays` from `CollectionFilter`.
- Update the player section to read player names from `playsInfo.playerNamesByGame`.

### `_FilterPanel`

- Receive `PlaysInfo` and compute `maxPlays`.
- Render `_PlayCountRangeSlider` when `maxPlays > 0`.
- Pass the dynamic max to the slider.

### New `_PlayCountRangeSlider`

- Stateless widget analogous to `_PlayerCountRangeSlider`.
- `min = 0`, `max = maxPlays`, `divisions = maxPlays`.
- Treats both handles at the extremes as "no filter" (null).

## Filtering logic

The existing `_matchesFilter` in `CollectionBloc` gets a new check after the rating filter:

```
effectivePlays = filter.playerParticipation has active entries
    ? count of plays in playsInfo.playsByGame[item.thingId] where play matches player filter rules
    : item.numPlays ?? 0

if minPlays != null and effectivePlays < minPlays -> exclude
if maxPlays != null and effectivePlays > maxPlays -> exclude
```

"matches player filter rules" is the same logic already used to decide whether an item passes the player participation filter, but applied to a single `Play` instead of the whole game.

## Persistence

`CollectionFilter.toJson` / `fromJson` already serialize nullable fields conditionally. Add `minPlays` and `maxPlays` following the same pattern. No new store needed.

## Localization

Add a label key `playCountLabel` to:
- `lib/presentation/l10n/app_de.arb`
- `lib/presentation/l10n/app_en.arb`
- regenerate `app_localizations*.dart` (or update manually if generation is not available).

Values:
- de: `"Partien"`
- en: `"Plays"`

## Dependency injection

Update `lib/infrastructure/di/service_locator.dart` to register `LoadPlaysInfoUseCase` instead of `LoadPlayPlayerNamesUseCase` and inject it into `CollectionBloc`.

## Testing

- Unit tests for `CollectionFilter` JSON round-trip with play-count values.
- Unit tests for `LoadPlaysInfoUseCase` grouping and player-name deduplication.
- BLoC tests for `_matchesFilter` covering:
  - no player filter, play-count range uses `numPlays`
  - with player filter, only matching plays counted
  - combined AND logic with rating / player count
- Widget tests for `_PlayCountRangeSlider` presence and interaction.

## Backwards compatibility

`CollectionFilter.fromJson` ignores unknown keys and missing values, so old persisted filters load safely with `minPlays` / `maxPlays` at null.
