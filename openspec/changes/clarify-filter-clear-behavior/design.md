# Design: Clarify clear-button responsibilities in search and filter UI

## Problem Statement

The current UI has two clear controls with inconsistent behavior:

1. **Search-field clear button** dispatches `CollectionViewCleared`, which resets search text, filters, and sort order. This is too broad.
2. **Filter-panel clear button** calls `filter.clearPlayerFilters(...)`, which only sets player participation states to `any` while leaving all other filter criteria active. This is too narrow.

## Design Decision

Introduce two new dedicated events and keep the existing `CollectionViewCleared` for the full reset:

| Control | Event | Effect |
|--------|-------|--------|
| Search-field clear button | `CollectionSearchCleared` | `searchText` → `''`, everything else unchanged |
| Filter-panel clear button | `CollectionFilterCleared` | `filter` → `CollectionFilter()`, `searchText` and `sort` unchanged |
| Dedicated view reset action | `CollectionViewCleared` | `searchText` → `''`, `filter` → `CollectionFilter()`, `sort` → `CollectionSort()` |

## Interface Changes

### `lib/presentation/blocs/collection/collection_event.dart`

Add:

```dart
/// Clears the search query without touching filters or sort order.
class CollectionSearchCleared extends CollectionEvent {
  const CollectionSearchCleared();
}

/// Resets all filter criteria to their defaults without touching search or sort.
class CollectionFilterCleared extends CollectionEvent {
  const CollectionFilterCleared();
}
```

### `lib/presentation/blocs/collection/collection_bloc.dart`

Add handlers:

```dart
void _onSearchCleared(...) {
  final newState = state.copyWith(
    searchText: '',
    filteredItems: _apply(state.items, '', state.filter, state.sort, state.playsInfo),
    clearError: true,
  );
  emit(newState);
  _persistViewState(newState);
}

void _onFilterCleared(...) {
  const clearedFilter = CollectionFilter();
  final newState = state.copyWith(
    filter: clearedFilter,
    filteredItems: _apply(state.items, state.searchText, clearedFilter, state.sort, state.playsInfo),
    clearError: true,
  );
  emit(newState);
  _persistViewState(newState);
}
```

### `lib/presentation/pages/collection_page.dart`

Update button bindings:

- Search-field clear button: `bloc.add(const CollectionSearchCleared())`
- Filter-panel clear button: `bloc.add(const CollectionFilterCleared())`

## Files to Modify

- `lib/presentation/blocs/collection/collection_event.dart`
- `lib/presentation/blocs/collection/collection_bloc.dart`
- `lib/presentation/pages/collection_page.dart`
- `test/presentation/blocs/collection_bloc_test.dart`

## Non-Goals

- No changes to persistence format.
- No changes to the filter model itself.
- No changes to the visual design of the buttons.
