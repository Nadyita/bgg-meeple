import 'package:bgg_meeple/domain/entities/play.dart';
import 'package:bgg_meeple/domain/entities/play_player.dart';
import 'package:bgg_meeple/infrastructure/adapters/persistence/drift/app_database.dart'
    as drift;
import 'package:bgg_meeple/infrastructure/adapters/persistence/drift_play_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftPlayStore', () {
    late drift.AppDatabase db;
    late DriftPlayStore store;

    setUp(() {
      db = drift.AppDatabase(NativeDatabase.memory());
      store = DriftPlayStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('persists and restores plays with players', () async {
      final plays = [
        Play(
          id: 1,
          thingId: 13,
          gameName: 'Catan',
          date: '2026-07-18',
          quantity: 2,
          length: 90,
          location: 'Home',
          comments: 'Fun game',
          subtypes: const ['boardgame'],
          players: const [
            PlayPlayer(
              username: 'reidel',
              userId: 4650728,
              name: 'Mark',
              startPosition: '1',
              color: 'red',
              score: '10',
              newPlayer: true,
              rating: 8.0,
              win: true,
            ),
            PlayPlayer(name: 'Dine', score: '8'),
          ],
        ),
      ];

      await store.saveAll(plays);
      final loaded = await store.loadAll();

      expect(loaded, plays);
      expect(loaded.single.players.length, 2);
    });

    test('saveAll replaces previous plays', () async {
      await store.saveAll([
        const Play(id: 1, thingId: 13, gameName: 'Old', date: '2026-07-17'),
      ]);
      final newPlays = [
        const Play(id: 2, thingId: 14, gameName: 'New', date: '2026-07-18'),
      ];

      await store.saveAll(newPlays);
      final loaded = await store.loadAll();

      expect(loaded, newPlays);
    });

    test('loadForGame returns only plays for the given thing id', () async {
      final plays = [
        const Play(id: 1, thingId: 13, gameName: 'Catan', date: '2026-07-18'),
        const Play(id: 2, thingId: 42, gameName: 'Other', date: '2026-07-18'),
      ];

      await store.saveAll(plays);
      final loaded = await store.loadForGame(13);

      expect(loaded.length, 1);
      expect(loaded.single.thingId, 13);
    });

    test('clear removes all plays and players', () async {
      await store.saveAll([
        Play(
          id: 1,
          thingId: 13,
          gameName: 'Catan',
          date: '2026-07-18',
          players: const [PlayPlayer(name: 'Mark')],
        ),
      ]);

      await store.clear();

      expect(await store.loadAll(), isEmpty);
    });

    test('handles empty subtypes', () async {
      const play = Play(
        id: 1,
        thingId: 13,
        gameName: 'Catan',
        date: '2026-07-18',
      );

      await store.saveAll([play]);
      final loaded = await store.loadAll();

      expect(loaded.single.subtypes, isEmpty);
      expect(loaded.single, play);
    });
  });
}
