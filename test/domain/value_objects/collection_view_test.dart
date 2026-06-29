import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sort.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sub_type.dart';
import 'package:bgg_meeple/domain/value_objects/collection_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CollectionFilter JSON', () {
    test('round-trips default filter', () {
      const filter = CollectionFilter();
      final json = filter.toJson();
      final restored = CollectionFilter.fromJson(json);
      expect(restored, filter);
      expect(restored.isActive, false);
    });

    test('round-trips fully populated filter', () {
      const filter = CollectionFilter(
        selectedSubTypes: [
          CollectionSubType.owned,
          CollectionSubType.wishlisted,
        ],
        minPlayers: 2,
        maxPlayers: 4,
        minPlayTime: 30,
        maxPlayTime: 120,
        minRating: 7.0,
        maxRating: 9.5,
      );
      final json = filter.toJson();
      final restored = CollectionFilter.fromJson(json);
      expect(restored, filter);
      expect(restored.isActive, true);
    });

    test('ignores unknown sub-type names', () {
      final json = {
        'selectedSubTypes': ['owned', 'unknownSubtype', 'played'],
      };
      final restored = CollectionFilter.fromJson(json);
      expect(restored.selectedSubTypes, [
        CollectionSubType.owned,
        CollectionSubType.played,
      ]);
    });

    test('tolerates malformed numeric values', () {
      final json = {
        'minPlayers': 'not-a-number',
        'maxPlayers': null,
        'minRating': 7.5,
      };
      final restored = CollectionFilter.fromJson(json);
      expect(restored.minPlayers, isNull);
      expect(restored.maxPlayers, isNull);
      expect(restored.minRating, 7.5);
    });
  });

  group('CollectionSort JSON', () {
    test('round-trips default sort', () {
      const sort = CollectionSort();
      final json = sort.toJson();
      final restored = CollectionSort.fromJson(json);
      expect(restored, sort);
    });

    test('round-trips descending BGG rating sort', () {
      const sort = CollectionSort(sortBy: SortBy.bggRating, ascending: false);
      final json = sort.toJson();
      final restored = CollectionSort.fromJson(json);
      expect(restored, sort);
    });

    test('falls back to name ascending for unknown sortBy', () {
      final restored = CollectionSort.fromJson({'sortBy': 'invalid'});
      expect(restored.sortBy, SortBy.name);
      expect(restored.ascending, true);
    });
  });

  group('CollectionView JSON', () {
    test('round-trips default view', () {
      const view = CollectionView();
      final json = view.toJson();
      final restored = CollectionView.fromJson(json);
      expect(restored, view);
    });

    test('round-trips populated view', () {
      const view = CollectionView(
        searchText: 'catan',
        filter: CollectionFilter(
          selectedSubTypes: [CollectionSubType.owned],
          minPlayers: 2,
          maxPlayers: 4,
        ),
        sort: CollectionSort(sortBy: SortBy.bggRating, ascending: false),
      );
      final json = view.toJson();
      final restored = CollectionView.fromJson(json);
      expect(restored, view);
    });

    test('gracefully handles corrupt nested objects', () {
      final restored = CollectionView.fromJson({
        'searchText': 'catan',
        'filter': 'not-a-map',
        'sort': 42,
      });
      expect(restored.searchText, 'catan');
      expect(restored.filter, const CollectionFilter());
      expect(restored.sort, const CollectionSort());
    });
  });
}
