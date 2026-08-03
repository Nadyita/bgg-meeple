import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sub_type.dart';
import 'package:bgg_meeple/domain/value_objects/inventory_location_filter.dart';
import 'package:bgg_meeple/domain/value_objects/player_count_filter_mode.dart';
import 'package:bgg_meeple/domain/value_objects/player_participation_filter.dart';
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

    test('updates playerParticipation', () {
      final updated = base.copyWith(
        playerParticipation: const {'Markus': PlayerParticipationFilter.played},
      );
      expect(updated.playerParticipation, const {
        'Markus': PlayerParticipationFilter.played,
      });
    });

    test('updates inventoryLocationFilters', () {
      final updated = base.copyWith(
        inventoryLocationFilters: const {
          'Keller': InventoryLocationFilter.matches,
        },
      );
      expect(updated.inventoryLocationFilters, const {
        'Keller': InventoryLocationFilter.matches,
      });
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
      expect(const CollectionFilter(minPlays: 1).isActive, isTrue);
      expect(const CollectionFilter(maxPlays: 10).isActive, isTrue);
    });

    test('is true when a player filter is not any', () {
      const filter = CollectionFilter(
        playerParticipation: {'Markus': PlayerParticipationFilter.played},
      );
      expect(filter.isActive, isTrue);
    });

    test('is true when an inventory location filter is not any', () {
      const filter = CollectionFilter(
        inventoryLocationFilters: {'Keller': InventoryLocationFilter.matches},
      );
      expect(filter.isActive, isTrue);
    });

    test('is false when all inventory location filters are any', () {
      const filter = CollectionFilter(
        inventoryLocationFilters: {'Keller': InventoryLocationFilter.any},
      );
      expect(filter.isActive, isFalse);
    });

    test('is false when all player filters are any', () {
      const filter = CollectionFilter(
        playerParticipation: {'Markus': PlayerParticipationFilter.any},
      );
      expect(filter.isActive, isFalse);
    });
  });

  group('CollectionFilter.clearPlayerFilters', () {
    test('resets known players to any and removes unknown players', () {
      const filter = CollectionFilter(
        playerParticipation: {
          'Markus': PlayerParticipationFilter.played,
          'Anna': PlayerParticipationFilter.notPlayed,
          'Obsolete': PlayerParticipationFilter.played,
        },
      );

      final cleared = filter.clearPlayerFilters(const {'markus', 'anna'});

      expect(cleared.playerParticipation, const {
        'Markus': PlayerParticipationFilter.any,
        'Anna': PlayerParticipationFilter.any,
      });
    });
  });

  group('CollectionFilter.playerCountFilterMode', () {
    test('defaults to publisher', () {
      expect(
        const CollectionFilter().playerCountFilterMode,
        PlayerCountFilterMode.publisher,
      );
    });

    test('updates via copyWith', () {
      const base = CollectionFilter();
      final updated = base.copyWith(
        playerCountFilterMode: PlayerCountFilterMode.recommended,
      );
      expect(updated.playerCountFilterMode, PlayerCountFilterMode.recommended);
      expect(updated.minPlayers, isNull);
    });

    test('preserves mode when only slider values are cleared', () {
      const base = CollectionFilter(
        minPlayers: 2,
        maxPlayers: 4,
        playerCountFilterMode: PlayerCountFilterMode.best,
      );
      final updated = base.copyWith(
        minPlayers: null,
        maxPlayers: null,
        clearMinPlayers: true,
        clearMaxPlayers: true,
      );
      expect(updated.playerCountFilterMode, PlayerCountFilterMode.best);
      expect(updated.minPlayers, isNull);
      expect(updated.maxPlayers, isNull);
    });
  });

  group('CollectionFilter JSON with player count mode', () {
    test('serializes only non-default values', () {
      const filter = CollectionFilter(
        minPlayers: 2,
        maxRating: 9.0,
        minPlays: 1,
        maxPlays: 5,
      );
      final json = filter.toJson();

      expect(json, containsPair('minPlayers', 2));
      expect(json, containsPair('maxRating', 9.0));
      expect(json, containsPair('minPlays', 1));
      expect(json, containsPair('maxPlays', 5));
      expect(json, containsPair('selectedSubTypes', []));
      expect(json, isNot(contains('maxPlayers')));
      expect(json, isNot(contains('minPlayTime')));
      expect(json, isNot(contains('playerParticipation')));
      expect(json, isNot(contains('inventoryLocationFilters')));
    });

    test('serializes playerParticipation including any entries', () {
      const filter = CollectionFilter(
        playerParticipation: {
          'Markus': PlayerParticipationFilter.played,
          'Anna': PlayerParticipationFilter.any,
          'Tom': PlayerParticipationFilter.notPlayed,
        },
      );
      final json = filter.toJson();

      expect(json['playerParticipation'], {
        'Markus': 'played',
        'Anna': 'any',
        'Tom': 'notPlayed',
      });
    });

    test('serializes inventoryLocationFilters', () {
      const filter = CollectionFilter(
        inventoryLocationFilters: {
          'Keller': InventoryLocationFilter.matches,
          'Wohnzimmer': InventoryLocationFilter.excludes,
        },
      );
      final json = filter.toJson();

      expect(json['inventoryLocationFilters'], {
        'Keller': 'matches',
        'Wohnzimmer': 'excludes',
      });
    });

    test('does not serialize empty inventoryLocationFilters', () {
      const filter = CollectionFilter();
      final json = filter.toJson();

      expect(json, isNot(contains('inventoryLocationFilters')));
    });

    test(
      'fromJson parses inventoryLocationFilters and ignores unknown values',
      () {
        final restored = CollectionFilter.fromJson({
          'inventoryLocationFilters': {
            'Keller': 'matches',
            'Wohnzimmer': 'excludes',
            'Eva': 'unknown',
          },
        });

        expect(restored.inventoryLocationFilters, {
          'Keller': InventoryLocationFilter.matches,
          'Wohnzimmer': InventoryLocationFilter.excludes,
        });
      },
    );

    test('fromJson tolerates int-like doubles for integer fields', () {
      final restored = CollectionFilter.fromJson({
        'minPlayers': 2.0,
        'maxPlayers': 4.0,
        'minPlays': 1.0,
        'maxPlays': 5.0,
      });

      expect(restored.minPlayers, 2);
      expect(restored.maxPlayers, 4);
      expect(restored.minPlays, 1);
      expect(restored.maxPlays, 5);
    });

    test('fromJson parses playerParticipation and ignores unknown values', () {
      final restored = CollectionFilter.fromJson({
        'playerParticipation': {
          'Markus': 'played',
          'Anna': 'unknown',
          'Tom': 'notPlayed',
        },
      });

      expect(restored.playerParticipation, {
        'Markus': PlayerParticipationFilter.played,
        'Tom': PlayerParticipationFilter.notPlayed,
      });
    });
    test('does not serialize default publisher mode', () {
      const filter = CollectionFilter(minPlayers: 2);
      final json = filter.toJson();

      expect(json, containsPair('minPlayers', 2));
      expect(json, isNot(contains('playerCountFilterMode')));
    });

    test('serializes non-default mode', () {
      const filter = CollectionFilter(
        playerCountFilterMode: PlayerCountFilterMode.best,
      );
      final json = filter.toJson();

      expect(json, containsPair('playerCountFilterMode', 'best'));
    });

    test('fromJson restores mode', () {
      final restored = CollectionFilter.fromJson({
        'playerCountFilterMode': 'recommended',
        'minPlayers': 3,
      });

      expect(restored.playerCountFilterMode, PlayerCountFilterMode.recommended);
      expect(restored.minPlayers, 3);
    });

    test('fromJson defaults to publisher when mode is missing', () {
      final restored = CollectionFilter.fromJson({'minPlayers': 3});

      expect(restored.playerCountFilterMode, PlayerCountFilterMode.publisher);
    });

    test('fromJson defaults to publisher for unknown mode values', () {
      final restored = CollectionFilter.fromJson({
        'playerCountFilterMode': 'unknown',
      });

      expect(restored.playerCountFilterMode, PlayerCountFilterMode.publisher);
    });
  });

  group('CollectionFilter.removeObsoleteInventoryLocationFilters', () {
    test(
      'keeps known locations at their current state and removes unknown ones',
      () {
        const filter = CollectionFilter(
          inventoryLocationFilters: {
            'Keller': InventoryLocationFilter.matches,
            'Wohnzimmer': InventoryLocationFilter.excludes,
            'Eva': InventoryLocationFilter.matches,
          },
        );

        final cleaned = filter.removeObsoleteInventoryLocationFilters(const {
          'Keller',
          'Wohnzimmer',
        });

        expect(cleaned.inventoryLocationFilters, const {
          'Keller': InventoryLocationFilter.matches,
          'Wohnzimmer': InventoryLocationFilter.excludes,
        });
      },
    );
  });

  group('CollectionFilter.resetInventoryLocationFilters', () {
    test('keeps all locations but sets their state to any', () {
      const filter = CollectionFilter(
        inventoryLocationFilters: {
          'Keller': InventoryLocationFilter.matches,
          'Wohnzimmer': InventoryLocationFilter.excludes,
        },
      );

      final reset = filter.resetInventoryLocationFilters();

      expect(reset.inventoryLocationFilters, const {
        'Keller': InventoryLocationFilter.any,
        'Wohnzimmer': InventoryLocationFilter.any,
      });
    });
  });

  group('CollectionFilter.copyWith play count', () {
    test('clears minPlays when requested', () {
      const base = CollectionFilter(minPlays: 1, maxPlays: 5);
      final updated = base.copyWith(clearMinPlays: true);
      expect(updated.minPlays, isNull);
      expect(updated.maxPlays, 5);
    });

    test('clears maxPlays when requested', () {
      const base = CollectionFilter(minPlays: 1, maxPlays: 5);
      final updated = base.copyWith(clearMaxPlays: true);
      expect(updated.maxPlays, isNull);
      expect(updated.minPlays, 1);
    });
  });
}
