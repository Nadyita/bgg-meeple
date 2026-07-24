# Tasks for Inventory-Location als konfigurierbares Kartenfeld

## 1. Domain & API

- [x] **1.1** Add `inventoryLocation` nullable `String` field to `CollectionItem` (constructor, fields, `copyWith`).
- [x] **1.2** Add `showprivate=1` to the query parameters in `BggApiClient.fetchCollection`.
- [x] **1.3** Parse `<privateinfo inventorylocation="...">` in `_parseCollectionItem` and trim whitespace; store empty values as `null`.

## 2. Persistence

- [x] **2.1** Add nullable `TextColumn inventoryLocation` to the `CollectionItems` table in `app_database.dart`.
- [x] **2.2** Bump `schemaVersion` to `9` and add a destructive migration from version `8` to `9`.
- [x] **2.3** Regenerate Drift code (`dart run build_runner build --delete-conflicting-outputs`).
- [x] **2.4** Map `inventoryLocation` in `DriftCollectionStore._toCollectionCompanion` and `_toEntity`.

## 3. Card Layout & Settings

- [x] **3.1** Add `inventoryLocation` to the `CardField` enum.
- [x] **3.2** Ensure `CardLayoutConfig` treats the new enum value as a normal configurable field (default off).
- [x] **3.3** Add translations for the new field label to `app_de.arb` and `app_en.arb`.
- [x] **3.4** Handle `CardField.inventoryLocation` in `settings_page.dart` label/suffix switch.

## 4. UI

- [x] **4.1** Add a metadata line in `CollectionCard` for `CardField.inventoryLocation`.
- [x] **4.2** Render the line only when `item.inventoryLocation` is non-null and non-empty.

## 5. Tests

- [x] **5.1** Extend `bgg_api_client_collection_test.dart` to verify `showprivate=1` in the request URL.
- [x] **5.2** Extend the same test to verify parsing of `<privateinfo inventorylocation="...">`, including trimming and missing/empty values.
- [x] **5.3** Extend or add a Drift collection store test to verify round-trip persistence of `inventoryLocation`.
- [x] **5.4** Extend `collection_card_test.dart` to verify the inventory location line is shown when present and hidden when absent.

## 6. Validation

- [x] **6.1** Run `dart analyze` and fix all errors/warnings.
- [x] **6.2** Run `dart test` and verify all tests pass.
- [x] **6.3** Manually verify the new field appears in the settings and on cards when a value is present.
