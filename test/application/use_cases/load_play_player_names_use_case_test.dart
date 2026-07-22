import 'package:bgg_meeple/application/use_cases/load_play_player_names_use_case.dart';
import 'package:bgg_meeple/domain/entities/play.dart';
import 'package:bgg_meeple/domain/entities/play_player.dart';
import 'package:bgg_meeple/domain/ports/play_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayStore extends Mock implements PlayStore {}

void main() {
  group('LoadPlayPlayerNamesUseCase', () {
    late _MockPlayStore store;
    late LoadPlayPlayerNamesUseCase useCase;

    setUp(() {
      store = _MockPlayStore();
      useCase = LoadPlayPlayerNamesUseCase(store);
    });

    test('returns sorted unique player names per game', () async {
      when(store.loadAll).thenAnswer(
        (_) async => [
          _play(
            thingId: 1,
            players: [
              const PlayPlayer(name: 'Mark'),
              const PlayPlayer(name: 'Dine'),
            ],
          ),
          _play(
            thingId: 1,
            players: [
              const PlayPlayer(name: 'Eva'),
              const PlayPlayer(name: 'Dine'),
            ],
          ),
          _play(thingId: 2, players: [const PlayPlayer(name: 'Mark')]),
        ],
      );

      final result = await useCase();

      expect(result, {
        1: ['Dine', 'Eva', 'Mark'],
        2: ['Mark'],
      });
    });

    test(
      'deduplicates names case-insensitively preserving first casing',
      () async {
        when(store.loadAll).thenAnswer(
          (_) async => [
            _play(
              thingId: 1,
              players: [
                const PlayPlayer(name: 'mark'),
                const PlayPlayer(name: 'Mark'),
                const PlayPlayer(name: 'dine'),
              ],
            ),
          ],
        );

        final result = await useCase();

        expect(result, {
          1: ['dine', 'mark'],
        });
      },
    );

    test('ignores players with null or empty names', () async {
      when(store.loadAll).thenAnswer(
        (_) async => [
          _play(
            thingId: 1,
            players: [
              const PlayPlayer(name: 'Dine'),
              const PlayPlayer(name: ''),
              const PlayPlayer(name: '   '),
              const PlayPlayer(),
            ],
          ),
        ],
      );

      final result = await useCase();

      expect(result, {
        1: ['Dine'],
      });
    });

    test('returns empty map when no plays are cached', () async {
      when(store.loadAll).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('omits game when all player names are empty', () async {
      when(store.loadAll).thenAnswer(
        (_) async => [
          _play(thingId: 1, players: [const PlayPlayer(name: '')]),
        ],
      );

      final result = await useCase();

      expect(result, isEmpty);
    });
  });
}

Play _play({required int thingId, required List<PlayPlayer> players}) {
  return Play(
    id: 1,
    thingId: thingId,
    gameName: 'Game $thingId',
    date: '2026-01-01',
    players: players,
  );
}
