# Tasks for Show suggested player age and language dependence from thing API

## 1. Planning

- [x] **1.1** Review requirements and affected specs
- [x] **1.2** Confirm `BoardGame` already stores `suggestedPlayerAge`, `languageDependenceLevel`, and `minAge`

## 2. Domain / data layer

- [x] **2.1** Add `suggestedPlayerAge` field to `CollectionItem` entity and `copyWith`
- [x] **2.2** Add `suggestedPlayerAge` column to `CollectionItems` Drift table and bump schema version with migration
- [x] **2.3** Regenerate Drift code (`app_database.g.dart`) via `dart run build_runner build`
- [x] **2.4** Update `LoadCollectionUseCase` to merge `minAge` (fallback) and `suggestedPlayerAge` from cached `BoardGame` into each `CollectionItem`
- [x] **2.5** Update Drift mappers / companion code for the new column

## 3. Presentation – collection card

- [x] **3.1** Update `CollectionCard._minAgeLine` to read `item.minAge` (now back-filled from `BoardGame`) and append `item.suggestedPlayerAge` with a thumbs-up icon
- [x] **3.2** Keep the existing child-care icon for the minimum-age line and render the suggested age inline

## 4. Presentation – game detail

- [x] **4.1** Add a detail row for minimum age in `_DetailFields._buildFields`
- [x] **4.2** Append `BoardGame.suggestedPlayerAge` to the minimum-age row with a thumbs-up icon when available
- [x] **4.3** Add a detail row for `BoardGame.languageDependenceLevel` with human-readable labels
- [x] **4.4** Update player-count row on detail screen to show recommended/best counts as thumbs-up and trophy icon suffixes, matching the collection card style

## 5. Localization

- [x] **5.1** Add `detailMinAgeLabel` (de/en) for the detail-screen minimum-age row
- [x] **5.2** Add language-dependence level labels (1–5) in German and English
- [x] **5.3** Regenerate `AppLocalizations` via `flutter gen-l10n`

## 6. Tests

- [x] **6.1** Update `LoadCollectionUseCase` tests to verify `minAge` fallback and `suggestedPlayerAge` merge
- [x] **6.2** Add/update `CollectionCard` widget tests for the age line with and without suggested age
- [x] **6.3** Add/update `GameDetailPage` widget tests for age row, language-dependence row, and icon-style player-count suffixes
- [x] **6.4** Update `AppDatabase` migration test for schema v14 and new column
- [x] **6.5** Add test that collection XML `<stats>` attributes (minplayers, maxplayers, minplaytime, maxplaytime, minage) are parsed
- [x] **6.6** Add test that `SyncCollectionUseCase` refreshes cached `BoardGame` rows missing `minAge` or `suggestedPlayerAge`
- [x] **6.7** Fix `/thing` XML parser to read `minage` from `value` attribute and add regression test
- [x] **6.8** Run `flutter test` and fix failures

## 7. Validation

- [x] **7.1** Run `dart analyze` and resolve all errors/warnings
- [x] **7.2** Run `flutter gen-l10n` and verify no missing translations
- [x] **7.3** Run `flutter test` – all 375 tests pass
- [ ] **7.4** Manual UI verification: collection card shows min age + suggested age; detail page shows age and language dependence
- [ ] **7.5** Request review / approval for the change
