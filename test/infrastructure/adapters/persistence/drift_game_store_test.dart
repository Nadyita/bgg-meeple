import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/infrastructure/adapters/persistence/drift/app_database.dart'
    as drift;
import 'package:bgg_meeple/infrastructure/adapters/persistence/drift_game_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftGameStore', () {
    late drift.AppDatabase db;
    late DriftGameStore store;

    setUp(() {
      db = drift.AppDatabase(NativeDatabase.memory());
      store = DriftGameStore(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('persists and restores board games with names', () async {
      final games = [
        const BoardGame(
          id: 13,
          names: [
            LocalizedName(value: 'Catan', language: 'English', isPrimary: true),
            LocalizedName(
              value: 'Die Siedler von Catan',
              language: 'German',
              isPrimary: false,
            ),
          ],
          imageUrl: 'https://example.com/image.png',
          thumbnailUrl: 'https://example.com/thumb.png',
          yearPublished: 1995,
          minPlayers: 3,
          maxPlayers: 4,
          minPlayTime: 60,
          maxPlayTime: 120,
          minAge: 10,
          bayesAverage: 7.12,
        ),
      ];

      await store.saveAll(games);
      final loaded = await store.loadAll();

      expect(loaded.length, 1);
      final game = loaded.first;
      expect(game.id, 13);
      expect(game.names.length, 2);
      expect(game.names.first.value, 'Catan');
      expect(game.names.last.language, 'German');
      expect(game.yearPublished, 1995);
      expect(game.bayesAverage, 7.12);
    });

    test('loadByIds returns only requested games', () async {
      final games = [
        const BoardGame(
          id: 1,
          names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
        ),
        const BoardGame(
          id: 2,
          names: [LocalizedName(value: 'B', language: null, isPrimary: true)],
        ),
      ];

      await store.saveAll(games);
      final loaded = await store.loadByIds([2]);

      expect(loaded.length, 1);
      expect(loaded.first.id, 2);
    });

    test('clear removes all games and names', () async {
      final games = [
        const BoardGame(
          id: 1,
          names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
        ),
      ];

      await store.saveAll(games);
      await store.clear();

      expect(await store.loadAll(), isEmpty);
    });
  });
}
