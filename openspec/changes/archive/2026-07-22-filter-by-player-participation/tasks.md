# Tasks: Filter collection by player participation

## 1. Planning and spec

- [x] 1.1 Create OpenSpec change `filter-by-player-participation`
- [x] 1.2 Write proposal.md
- [x] 1.3 Write search-and-filter delta spec
- [x] 1.4 Write settings-and-theme delta spec
- [x] 1.5 Write design.md
- [x] 1.6 Validate change with `openspec_validate_change`

## 2. Domain model

- [x] 2.1 Create `lib/domain/value_objects/player_participation_filter.dart`
- [x] 2.2 Extend `CollectionFilter` with `playerParticipation` field
- [x] 2.3 Update `CollectionFilter.toJson` and `fromJson`
- [x] 2.4 Update `CollectionFilter.isActive` and `props`
- [x] 2.5 Add unit tests for `CollectionFilter` serialization and behavior

## 3. Filter logic

- [x] 3.1 Add case-insensitive player name lookup helper in `CollectionBloc`
- [x] 3.2 Extend `_matchesFilter` with player participation evaluation
- [x] 3.3 Add unit tests for player filter scenarios (played, notPlayed, combined, case-insensitive)

## 4. Settings

- [x] 4.1 Add "show player filter hint" boolean to settings store/model
- [x] 4.2 Add toggle to settings screen
- [x] 4.3 Add localization keys and German translations
- [x] 4.4 Add widget/unit tests for settings persistence

## 5. UI

- [x] 5.1 Add player filter section to `_FilterPanel`
- [x] 5.2 Implement player picker bottom sheet / dialog
- [x] 5.3 Implement tristate player chip (any/played/notPlayed)
- [x] 5.4 Implement long-press removal on touch and close icon on pointer
- [x] 5.5 Show frown icon for players no longer present in plays
- [x] 5.6 Show snackbar hint after adding a player, respecting settings
- [x] 5.7 Update filter reset to clear player states but keep known players, remove obsolete players
- [x] 5.8 Add localization keys and German translations
- [x] 5.9 Add widget tests for add, toggle, remove, and reset interactions

## 6. Validation

- [x] 6.1 Run `dart analyze` and fix all errors/warnings
- [x] 6.2 Run `dart test` and ensure all tests pass
- [x] 6.3 Run `openspec_validate_change` and resolve issues
- [x] 6.4 Manual verification on Android/desktop if possible

## 7. Wrap up

- [x] 7.1 Update task statuses as completed
- [x] 7.2 Request approval / archive change
