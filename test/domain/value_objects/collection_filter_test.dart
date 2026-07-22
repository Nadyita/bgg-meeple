import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sub_type.dart';
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

  group('CollectionFilter JSON', () {
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
