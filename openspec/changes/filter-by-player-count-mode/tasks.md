# Tasks for Filter collection by player count mode

## 1. Domain

- [x] **1.1** Add `PlayerCountFilterMode` enum with `publisher`, `recommended`, and `best`.
- [x] **1.2** Add `playerCountFilterMode` field to `CollectionFilter` (default `publisher`, included in `Equatable` props, `copyWith`, JSON).

## 2. Filtering Logic

- [x] **2.1** Update `CollectionBloc._apply()` to evaluate the player count range against `minPlayers`/`maxPlayers`, `recommendedPlayerCountMin`/`recommendedPlayerCountMax`, or `bestPlayerCountMin`/`bestPlayerCountMax` based on the mode.
- [x] **2.2** Treat items with missing values for the selected mode as non-matching when the filter is active.

## 3. UI

- [x] **3.1** Add a `SegmentedButton<PlayerCountFilterMode>` above the player count slider in `_FilterPanel`.
- [x] **3.2** Wire the segmented button to update `CollectionFilter.playerCountFilterMode` while preserving slider values.
- [x] **3.3** Add localized labels for the three segments to `app_de.arb` and `app_en.arb` and run `flutter gen-l10n`.

## 4. Persistence

- [x] **4.1** Verify that `CollectionFilter.toJson()` and `fromJson()` serialize/deserialize the new field correctly.
- [x] **4.2** Ensure the default value is `publisher` when absent in stored JSON.

## 5. Clear-Filter Behavior

- [x] **5.1** Verify that clearing filters resets the player count slider but keeps the selected mode.

## 6. Tests

- [x] **6.1** Add unit tests for `CollectionFilter` JSON round-trip with the new mode.
- [x] **6.2** Add `CollectionBloc` tests for filtering in `recommended` and `best` modes.
- [x] **6.3** Add widget tests for the segmented button in the filter panel.

## 7. Validation

- [x] **7.1** Run `dart analyze` and fix all errors/warnings.
- [x] **7.2** Run `dart test` and verify all tests pass.
- [x] **7.3** Manually verify switching modes, clearing filters, and persisting the mode.
