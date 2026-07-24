/// State of an inventory-location filter chip.
///
/// - [any] - the location does not affect the result.
/// - [matches] - only games stored at this location are shown.
/// - [excludes] - games stored at this location are hidden.
enum InventoryLocationFilter {
  any,
  matches,
  excludes;

  /// Returns the next state when the user taps a location chip.
  InventoryLocationFilter cycle() {
    return switch (this) {
      InventoryLocationFilter.any => InventoryLocationFilter.matches,
      InventoryLocationFilter.matches => InventoryLocationFilter.excludes,
      InventoryLocationFilter.excludes => InventoryLocationFilter.any,
    };
  }
}
