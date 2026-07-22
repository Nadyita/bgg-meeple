# Tasks for Filter collection by play count

## 1. Planning

- [x] **1.1** Review existing filter and plays architecture
- [x] **1.2** Draft OpenSpec proposal, design, and updated search-and-filter spec

## 2. Domain layer

- [x] **2.1** Add `minPlays` and `maxPlays` to `CollectionFilter`
  - Update constructor, `isActive`, `copyWith`, `toJson`, `fromJson`, `props`
  - Add `clearMinPlays` / `clearMaxPlays` flags to `copyWith`
- [x] **2.2** Add `PlaysInfo` value object with `playerNamesByGame` and `playsByGame`

## 3. Application layer

- [x] **3.1** Rename `LoadPlayPlayerNamesUseCase` to `LoadPlaysInfoUseCase`
  - Return `PlaysInfo` instead of `Map<int, List<String>>`
  - Preserve deduplication/sorting behavior for player names
- [x] **3.2** Write unit tests for `LoadPlaysInfoUseCase`

## 4. Presentation layer

- [x] **4.1** Update `CollectionState` to hold `PlaysInfo`
- [x] **4.2** Update `CollectionBloc`
  - Inject `LoadPlaysInfoUseCase`
  - Use `PlaysInfo` for player participation and play-count filtering
  - Implement effective play count calculation per item
- [x] **4.3** Update `CollectionPage` and `_FilterPanel`
  - Pass `PlaysInfo` through the widget tree
  - Compute `maxPlays` from loaded collection items
  - Add `_PlayCountRangeSlider` directly below `_RatingRangeSlider`
- [x] **4.4** Create `_PlayCountRangeSlider` widget
- [x] **4.5** Add `playCountLabel` localization to `app_de.arb` and `app_en.arb`
- [x] **4.6** Regenerate/update `app_localizations*.dart`

## 5. Infrastructure / DI

- [x] **5.1** Update `service_locator.dart` to register `LoadPlaysInfoUseCase`
- [x] **5.2** Update `CollectionBloc` constructor call sites

## 6. Testing

- [x] **6.1** Unit tests for `CollectionFilter` JSON round-trip with play-count values
- [x] **6.2** Unit tests for `CollectionBloc` play-count filtering
  - No player filter uses `numPlays`
  - Player filter counts only matching plays
  - Combined AND logic with other filters
- [x] **6.3** Widget test for `_PlayCountRangeSlider` interaction

## 7. Validation

- [x] **7.1** Run `dart analyze` and fix all errors/warnings
- [x] **7.2** Run `dart test` and ensure all tests pass
- [x] **7.3** Run `openspec_validate_change` for `add-play-count-filter`
- [x] **7.4** Manual UI verification (open filter panel, move play-count slider)

## 8. Wrap-up

- [x] **8.1** Update `REQUIREMENTS.md` capability index link if needed
- [x] **8.2** Mark all tasks complete and request approval
- [ ] **8.3** Archive change with `openspec_archive_change`
