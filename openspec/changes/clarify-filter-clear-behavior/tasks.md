# Tasks for Clarify clear-button responsibilities in search and filter UI

## 1. Planning

- [x] **1.1** Review `search-and-filter` and `sort-and-view-state` master specs
- [x] **1.2** Create OpenSpec change `clarify-filter-clear-behavior`
- [x] **1.3** Write `proposal.md` with motivation and affected capabilities
- [x] **1.4** Write delta specs under `openspec/changes/clarify-filter-clear-behavior/specs/`
- [x] **1.5** Write `design.md` with event model and handler design

## 2. Implementation

- [x] **2.1** Add `CollectionSearchCleared` and `CollectionFilterCleared` events to `collection_event.dart`
- [x] **2.2** Add `_onSearchCleared` and `_onFilterCleared` handlers to `collection_bloc.dart`
- [x] **2.3** Wire search-field clear button to `CollectionSearchCleared` in `collection_page.dart`
- [x] **2.4** Wire filter-panel clear button to `CollectionFilterCleared` in `collection_page.dart`

## 3. Validation

- [x] **3.1** Add/update unit tests for `CollectionSearchCleared` in `collection_bloc_test.dart`
- [x] **3.2** Add/update unit tests for `CollectionFilterCleared` in `collection_bloc_test.dart`
- [x] **3.3** Run `dart analyze` and ensure 0 errors, 0 warnings
- [x] **3.4** Run `dart test` and ensure all tests pass
- [x] **3.5** Run `openspec_validate_change` for `clarify-filter-clear-behavior`

## 4. Documentation

- [x] **4.1** Link new delta specs in `REQUIREMENTS.md`
