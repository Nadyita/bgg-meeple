# Tasks for Filter collection by inventory location

## 1. Domain & persistence

- [x] **1.1** Create `InventoryLocationFilter` enum (`any`, `matches`, `excludes`) with `cycle()` helper.
- [x] **1.2** Replace `selectedInventoryLocations` in `CollectionFilter` with `Map<String, InventoryLocationFilter> inventoryLocationFilters`.
- [x] **1.3** Update `CollectionFilter.copyWith`, `isActive`, `toJson`, `fromJson`, and `props` for tri-state location filters.
- [x] **1.4** Add unit tests for `CollectionFilter` JSON round-trip, `isActive`, and `copyWith` with tri-state location filters.

## 2. Filtering logic

- [x] **2.1** Extend `CollectionBloc._matchesFilter` to evaluate `matches` with OR and `excludes` with AND.
- [x] **2.2** Add BLoC-level tests covering `matches`, `excludes`, combined OR/AND, and AND combination with search text.

## 3. UI – filter panel

- [x] **3.1** Add localization keys for the new section (`filterLocationSectionTitle`, `filterAddLocationLabel`, `filterLocationPickerTitle`, `noLocationsAvailable`).
- [x] **3.2** Create `_LocationFilterSection` and `_LocationChip` in `collection_page.dart`, mirroring `_PlayerFilterSection` / `_PlayerChip` with tri-state cycling.
- [x] **3.3** Insert `_LocationFilterSection` into `_FilterPanel` above `_PlayerFilterSection`.
- [x] **3.4** Verify the picker lists all distinct, non-empty locations from the full collection, sorted case-insensitively, excluding already added ones.

## 4. Tests

- [x] **4.1** Add or extend widget tests for `collection_page.dart` verifying section title, picker opening, chip creation, state cycling, chip removal, and reset.
- [x] **4.2** Run `dart analyze` and fix all errors/warnings.
- [x] **4.3** Run `dart test` and verify all tests pass.

## 5. Manual verification

- [x] **5.1** Manually verify filter panel shows location chips, cycling works, and reset clears them.
