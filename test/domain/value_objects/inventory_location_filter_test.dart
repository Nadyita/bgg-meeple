import 'package:bgg_meeple/domain/value_objects/inventory_location_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryLocationFilter.cycle', () {
    test('cycles from any to matches', () {
      expect(
        InventoryLocationFilter.any.cycle(),
        InventoryLocationFilter.matches,
      );
    });

    test('cycles from matches to excludes', () {
      expect(
        InventoryLocationFilter.matches.cycle(),
        InventoryLocationFilter.excludes,
      );
    });

    test('cycles from excludes to any', () {
      expect(
        InventoryLocationFilter.excludes.cycle(),
        InventoryLocationFilter.any,
      );
    });
  });
}
