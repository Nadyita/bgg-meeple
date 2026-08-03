# Tasks for Show BGG recommended and best player counts on collection cards

## 0. Design

- [x] **0.1** Decide icons for recommended (`Icons.thumb_up`) and best (`Icons.emoji_events`) values.

## 1. Domain & Sync

- [x] **1.1** Add nullable best/recommended player count fields to `CollectionItem` (constructor, fields, `copyWith`).
- [x] **1.2** In `SyncCollectionUseCase`, after fetching game details, copy the six player count fields from each `BoardGame` to every matching `CollectionItem`.
- [x] **1.3** Ensure sync treats collection items without enriched details as valid (nulls are acceptable).

## 2. Database & Persistence

- [x] **2.1** Add nullable columns for `bestPlayerCount`, `bestPlayerCountMin`, `bestPlayerCountMax`, `recommendedPlayerCount`, `recommendedPlayerCountMin`, and `recommendedPlayerCountMax` to the `CollectionItems` table in `app_database.dart`.
- [x] **2.2** Bump `schemaVersion` and add an additive migration that adds the new columns and preserves existing rows.
- [x] **2.3** Regenerate Drift code (`dart run build_runner build --delete-conflicting-outputs`).
- [x] **2.4** Map the new fields in `DriftCollectionStore._toCollectionCompanion` and `_toEntity`.

## 3. Card Layout Settings

- [x] **3.1** Add `showRecommendedPlayerNumbers` and `showBestPlayerNumbers` booleans to `CardLayoutConfig` (default `false`, included in `Equatable` props, `copyWith`).
- [x] **3.2** Extend `CardLayoutToggle` enum with `showRecommendedPlayerNumbers` and `showBestPlayerNumbers`.
- [x] **3.3** Handle the new toggles in `SettingsBloc._onCardLayoutToggled`.
- [x] **3.4** Add two `SwitchListTile`s to the card-layout section of `settings_page.dart`.
- [x] **3.5** Add localized labels for the new toggles to `app_de.arb` and `app_en.arb` and run code generation.

## 4. Collection Card UI

- [x] **4.1** Pass the new `CardLayoutConfig` flags into the player count metadata line in `CollectionCard`.
- [x] **4.2** Build an inline suffix for the player count line that appends the recommended and/or best values when enabled, present, and the player count field is shown.
- [x] **4.3** Use distinct icons for recommended (`Icons.thumb_up`) and best (`Icons.emoji_events`) values.
- [x] **4.4** Ensure the compact list view remains unchanged.

## 5. Tests

- [x] **5.1** Extend or add sync use-case tests to verify best/recommended player counts are copied from `BoardGame` to `CollectionItem`.
- [x] **5.2** Extend Drift collection store tests to verify round-trip persistence of the new player count fields.
- [x] **5.3** Add `SettingsBloc` tests for the new card layout toggles.
- [x] **5.4** Extend `collection_card_test.dart` to verify the player count line shows/hides recommended and best values based on config and data.
- [x] **5.5** Add localized string tests if needed.

## 6. Validation

- [x] **6.1** Run `dart analyze` and fix all errors/warnings.
- [x] **6.2** Run `dart test` and verify all tests pass.
- [ ] **6.3** Manually verify the toggles in settings and the inline player count labels on collection cards.
