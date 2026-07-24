# Design: Filter collection by inventory location

## Domain changes

### New enum `InventoryLocationFilter`

Created in `lib/domain/value_objects/inventory_location_filter.dart`:

```dart
enum InventoryLocationFilter {
  any,
  matches,
  excludes;

  InventoryLocationFilter cycle() { ... }
}
```

### `CollectionFilter`

Replace the previous `Set<String> selectedInventoryLocations` with:

```dart
final Map<String, InventoryLocationFilter> inventoryLocationFilters;
```

- `isActive` is true when any entry is not `any`.
- `copyWith` supports replacing the whole map.
- `toJson()` writes the map only when non-empty.
- `fromJson()` reads the map and ignores unknown enum values.

## Filtering logic

In `CollectionBloc._matchesFilter`:

```dart
final itemLocation = item.inventoryLocation?.trim();
final matchesLocations = ... entries with value == matches;
final excludesLocations = ... entries with value == excludes;

if (matchesLocations.isNotEmpty &&
    (itemLocation == null || itemLocation.isEmpty || !matchesLocations.contains(itemLocation))) {
  return false;
}

if (excludesLocations.isNotEmpty &&
    itemLocation != null && itemLocation.isNotEmpty &&
    excludesLocations.contains(itemLocation)) {
  return false;
}
```

## UI changes

### `_FilterPanel` in `collection_page.dart`

Still passes the full `items` list to `_LocationFilterSection`.

### New `_LocationFilterSection` and `_LocationChip`

Structurally identical to `_PlayerFilterSection` / `_PlayerChip`:

- Shows removable chips for every added location.
- Each chip cycles through `any` → `matches` (green thumbs-up) → `excludes` (red thumbs-down) → `any` on tap.
- Long-press on touch or delete icon on pointer removes the chip.
- The add-location chip opens a `SimpleDialog` listing distinct non-empty locations not already added.

## State persistence

No new persistence layer. `CollectionFilter` is already serialized inside `CollectionView`.

## Testing

1. Unit tests for `CollectionFilter` JSON round-trip and `isActive` with tri-state location filters.
2. Unit tests for `InventoryLocationFilter.cycle`.
3. BLoC tests covering `matches`, `excludes`, combined `matches` OR, combined `excludes` AND, and AND with search.
4. Widget tests verifying chip addition, state cycling, and reset.
