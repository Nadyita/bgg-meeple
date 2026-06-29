import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sub_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CollectionFilter.copyWith', () {
    const base = CollectionFilter(
      selectedSubTypes: [CollectionSubType.owned],
      minPlayers: 2,
      maxPlayers: 4,
    );

    test('clears minPlayers when requested', () {
      final updated = base.copyWith(clearMinPlayers: true);
      expect(updated.minPlayers, isNull);
      expect(updated.maxPlayers, 4);
    });

    test('clears maxPlayers when requested', () {
      final updated = base.copyWith(clearMaxPlayers: true);
      expect(updated.maxPlayers, isNull);
      expect(updated.minPlayers, 2);
    });

    test('clears all range bounds when requested', () {
      final updated = base.copyWith(
        clearMinPlayers: true,
        clearMaxPlayers: true,
      );
      expect(updated.minPlayers, isNull);
      expect(updated.maxPlayers, isNull);
      expect(updated.selectedSubTypes, [CollectionSubType.owned]);
    });
  });

  group('CollectionFilter.isActive', () {
    test('is false for default filter', () {
      expect(const CollectionFilter().isActive, isFalse);
    });

    test('is true when any sub-type is selected', () {
      const filter = CollectionFilter(
        selectedSubTypes: [CollectionSubType.owned],
      );
      expect(filter.isActive, isTrue);
    });

    test('is true when any numeric bound is set', () {
      expect(const CollectionFilter(minPlayers: 1).isActive, isTrue);
      expect(const CollectionFilter(maxPlayTime: 120).isActive, isTrue);
      expect(const CollectionFilter(minRating: 7.0).isActive, isTrue);
    });
  });

  group('CollectionFilter JSON', () {
    test('serializes only non-default values', () {
      const filter = CollectionFilter(minPlayers: 2, maxRating: 9.0);
      final json = filter.toJson();

      expect(json, containsPair('minPlayers', 2));
      expect(json, containsPair('maxRating', 9.0));
      expect(json, containsPair('selectedSubTypes', []));
      expect(json, isNot(contains('maxPlayers')));
      expect(json, isNot(contains('minPlayTime')));
    });

    test('fromJson tolerates int-like doubles for integer fields', () {
      final restored = CollectionFilter.fromJson({
        'minPlayers': 2.0,
        'maxPlayers': 4.0,
      });

      expect(restored.minPlayers, 2);
      expect(restored.maxPlayers, 4);
    });
  });
}
