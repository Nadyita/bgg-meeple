import 'package:bgg_meeple/application/use_cases/load_plays_info_use_case.dart';
import 'package:bgg_meeple/domain/entities/play.dart';
import 'package:bgg_meeple/domain/entities/play_player.dart';
import 'package:bgg_meeple/domain/ports/play_store.dart';
import 'package:bgg_meeple/domain/value_objects/plays_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayStore extends Mock implements PlayStore {}

void main() {
  group('LoadPlaysInfoUseCase', () {
    late _MockPlayStore store;
    late LoadPlaysInfoUseCase useCase;

    setUp(() {
      store = _MockPlayStore();
      useCase = LoadPlaysInfoUseCase(store);
    });

    test('returns sorted unique player names and plays per game', () async {
      final play1 = _play(
        id: 1,
        thingId: 1,
        players: [
          const PlayPlayer(name: 'Mark'),
          const PlayPlayer(name: 'Dine'),
        ],
      );
      final play2 = _play(
        id: 2,
        thingId: 1,
        players: [
          const PlayPlayer(name: 'Eva'),
          const PlayPlayer(name: 'Dine'),
        ],
      );
      final play3 = _play(
        id: 3,
        thingId: 2,
        players: [const PlayPlayer(name: 'Mark')],
      );
      when(store.loadAll).thenAnswer((_) async => [play1, play2, play3]);

      final result = await useCase();

      expect(
        result,
        PlaysInfo(
          playerNamesByGame: const {
            1: ['Dine', 'Eva', 'Mark'],
            2: ['Mark'],
          },
          playsByGame: {
            1: [play1, play2],
            2: [play3],
          },
        ),
      );
    });

    test(
      'deduplicates names case-insensitively preserving first casing',
      () async {
        final play = _play(
          id: 1,
          thingId: 1,
          players: [
            const PlayPlayer(name: 'mark'),
            const PlayPlayer(name: 'Mark'),
            const PlayPlayer(name: 'dine'),
          ],
        );
        when(store.loadAll).thenAnswer((_) async => [play]);

        final result = await useCase();

        expect(
          result,
          PlaysInfo(
            playerNamesByGame: const {
              1: ['dine', 'mark'],
            },
            playsByGame: {
              1: [play],
            },
          ),
        );
      },
    );

    test('ignores players with null or empty names', () async {
      final play = _play(
        id: 1,
        thingId: 1,
        players: [
          const PlayPlayer(name: 'Dine'),
          const PlayPlayer(name: ''),
          const PlayPlayer(name: '   '),
          const PlayPlayer(),
        ],
      );
      when(store.loadAll).thenAnswer((_) async => [play]);

      final result = await useCase();

      expect(
        result,
        PlaysInfo(
          playerNamesByGame: const {
            1: ['Dine'],
          },
          playsByGame: {
            1: [play],
          },
        ),
      );
    });

    test('returns empty info when no plays are cached', () async {
      when(store.loadAll).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, const PlaysInfo());
    });

    test(
      'omits game from playerNamesByGame when all player names are empty',
      () async {
        final play = _play(
          id: 1,
          thingId: 1,
          players: [const PlayPlayer(name: '')],
        );
        when(store.loadAll).thenAnswer((_) async => [play]);

        final result = await useCase();

        expect(result.playerNamesByGame, isEmpty);
        expect(result.playsByGame[1], [play]);
      },
    );
  });
}

Play _play({
  required int id,
  required int thingId,
  required List<PlayPlayer> players,
}) {
  return Play(
    id: id,
    thingId: thingId,
    gameName: 'Game $thingId',
    date: '2026-01-01',
    players: players,
  );
}
