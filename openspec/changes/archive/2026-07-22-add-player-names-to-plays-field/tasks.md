# Tasks for Add player names to the Plays card field

## 1. Planning

- [x] **1.1** Review existing `plays-sync`, `collection-list`, and card-layout specs
- [x] **1.2** Create OpenSpec change `add-player-names-to-plays-field`
- [x] **1.3** Write capability spec `collection-card-plays-players`
- [x] **1.4** Write design.md with use-case/BLoC/widget/localization plan

## 2. Domain & Application

- [x] **2.1** Add `showPlayerNamesOnPlays` to `CardLayoutConfig`
- [x] **2.2** Create `LoadPlayPlayerNamesUseCase` that returns `Map<int, List<String>>`
- [x] **2.3** Write unit tests for the use case (unique sort, case-insensitive dedupe, null filtering)

## 3. Presentation

- [x] **3.1** Add `playerNamesByGame` to `CollectionState` and `CollectionBloc`
- [x] **3.2** Wire new use case into `CollectionBloc` construction and load flow
- [x] **3.3** Update `CollectionCard` to render the player-name suffix
- [x] **3.4** Add `showPlayerNamesOnPlays` toggle to `SettingsBloc` and `SettingsEvent`
- [x] **3.5** Add the new switch and field-list suffix to `SettingsPage`
- [x] **3.6** Add English and German localization strings and regenerate localizations
- [x] **3.7** Update dependency injection for `CollectionBloc`
- [x] **3.8** Write/update BLoC and widget tests

## 4. Validation

- [x] **4.1** Run `dart analyze` and fix all errors/warnings
- [x] **4.2** Run `dart test` and ensure all tests pass
- [ ] **4.3** Run manual UI verification on a device/emulator
- [x] **4.4** Run `openspec_validate_change` for `add-player-names-to-plays-field`
