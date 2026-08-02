import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/value_objects/game_link.dart';
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

    test('persists and restores normalized links', () async {
      final games = [
        const BoardGame(
          id: 13,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          links: [
            GameLink(bggId: 1, type: 'category', name: 'Strategy'),
            GameLink(bggId: 2, type: 'family', name: 'Catan Series'),
          ],
        ),
        const BoardGame(
          id: 14,
          names: [
            LocalizedName(value: 'Catan Jr.', language: null, isPrimary: true),
          ],
          links: [
            GameLink(bggId: 1, type: 'category', name: 'Strategy'),
            GameLink(bggId: 3, type: 'family', name: 'Junior Games'),
          ],
        ),
      ];

      await store.saveAll(games);
      final loaded = await store.loadAll();

      expect(loaded.length, 2);
      final first = loaded.firstWhere((g) => g.id == 13);
      expect(first.links.length, 2);
      expect(
        first.links,
        contains(const GameLink(bggId: 1, type: 'category', name: 'Strategy')),
      );
      expect(
        first.links,
        contains(
          const GameLink(bggId: 2, type: 'family', name: 'Catan Series'),
        ),
      );

      final second = loaded.firstWhere((g) => g.id == 14);
      expect(second.links.length, 2);
      expect(
        second.links,
        contains(const GameLink(bggId: 1, type: 'category', name: 'Strategy')),
      );

      final linkRows = await db.select(db.gameLinks).get();
      expect(linkRows.length, 3);
    });

    test('loadByIds returns only requested games with links', () async {
      final games = [
        const BoardGame(
          id: 1,
          names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
          links: [GameLink(bggId: 1, type: 'category', name: 'Strategy')],
        ),
        const BoardGame(
          id: 2,
          names: [LocalizedName(value: 'B', language: null, isPrimary: true)],
          links: [GameLink(bggId: 2, type: 'family', name: 'B Family')],
        ),
      ];

      await store.saveAll(games);
      final loaded = await store.loadByIds([2]);

      expect(loaded.length, 1);
      expect(loaded.first.id, 2);
      expect(loaded.first.links.length, 1);
      expect(
        loaded.first.links.first,
        const GameLink(bggId: 2, type: 'family', name: 'B Family'),
      );
    });

    test('clear removes all games, names and links', () async {
      final games = [
        const BoardGame(
          id: 1,
          names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
          links: [GameLink(bggId: 1, type: 'category', name: 'Strategy')],
        ),
      ];

      await store.saveAll(games);
      await store.clear();

      expect(await store.loadAll(), isEmpty);
      expect(await db.select(db.gameLinks).get(), isEmpty);
      expect(await db.select(db.boardGameLinkRels).get(), isEmpty);
    });

    test('persists and restores new detail fields', () async {
      final games = [
        const BoardGame(
          id: 13,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          description: 'A great game.',
          bestPlayerCount: '3',
          bestPlayerCountMin: 3,
          bestPlayerCountMax: 4,
          suggestedPlayerAge: '10.5',
          languageDependenceLevel: '2',
          recommendedPlayerCount: '3–4',
          recommendedPlayerCountMin: 3,
          recommendedPlayerCountMax: 4,
          detailsUpdatedAt: 123456789,
        ),
      ];

      await store.saveAll(games);
      final loaded = await store.loadAll();

      final game = loaded.first;
      expect(game.description, 'A great game.');
      expect(game.bestPlayerCount, '3');
      expect(game.bestPlayerCountMin, 3);
      expect(game.bestPlayerCountMax, 4);
      expect(game.suggestedPlayerAge, '10.5');
      expect(game.languageDependenceLevel, '2');
      expect(game.recommendedPlayerCount, '3–4');
      expect(game.recommendedPlayerCountMin, 3);
      expect(game.recommendedPlayerCountMax, 4);
      expect(game.detailsUpdatedAt, 123456789);
    });
  });
}
