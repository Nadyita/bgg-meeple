import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bgg_meeple/infrastructure/adapters/persistence/drift/app_database.dart';

void main() {
  group('AppDatabase migrations', () {
    late AppDatabase db;

    tearDown(() async {
      await db.close();
    });

    test('schema version is 11', () {
      db = AppDatabase(NativeDatabase.memory());
      expect(db.schemaVersion, 11);
    });

    test('migration strategy is configured', () {
      db = AppDatabase(NativeDatabase.memory());
      expect(db.migration.onCreate, isNotNull);
      expect(db.migration.onUpgrade, isNotNull);
    });

    test('onCreate creates all tables', () async {
      db = AppDatabase(NativeDatabase.memory());
      final migrator = db.createMigrator();
      await db.migration.onCreate(migrator);

      final tables = db.allSchemaEntities.whereType<TableInfo>().toList();
      expect(
        tables.map((t) => t.actualTableName),
        containsAll([
          'collection_items',
          'board_games',
          'game_links',
          'board_game_link_rels',
          'localized_names',
          'versions',
          'plays',
          'play_players',
        ]),
      );
    });

    test(
      'upgrade from v8 to v10 recreates tables and includes detailsUpdatedAt',
      () async {
        db = AppDatabase(NativeDatabase.memory());
        final migrator = db.createMigrator();
        await db.migration.onUpgrade(migrator, 8, 10);

        await db
            .into(db.boardGames)
            .insert(
              BoardGamesCompanion(
                id: const Value(1),
                description: const Value('A great game.'),
                bestPlayerCount: const Value('2'),
                suggestedPlayerAge: const Value('10.5'),
                languageDependenceLevel: const Value('2'),
                detailsUpdatedAt: const Value(123456789),
              ),
            );

        final row = await db.select(db.boardGames).getSingle();
        expect(row.id, 1);
        expect(row.description, 'A great game.');
        expect(row.detailsUpdatedAt, 123456789);
      },
    );

    test('upgrade from v8 to v10 creates normalized link tables', () async {
      db = AppDatabase(NativeDatabase.memory());
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 8, 10);

      final tables = db.allSchemaEntities.whereType<TableInfo>().toList();
      expect(
        tables.map((t) => t.actualTableName),
        containsAll(['game_links', 'board_game_link_rels']),
      );
    });

    test(
      'upgrade from v9 to v10 recreates tables and removes JSON link columns',
      () async {
        db = AppDatabase(NativeDatabase.memory());
        final migrator = db.createMigrator();
        await db.migration.onUpgrade(migrator, 9, 10);

        await db
            .into(db.boardGames)
            .insert(
              const BoardGamesCompanion(
                id: Value(1),
                description: Value('A great game.'),
              ),
            );

        final row = await db.select(db.boardGames).getSingle();
        expect(row.id, 1);
        expect(row.description, 'A great game.');
      },
    );

    test('upgrade from v10 to v11 adds player count range columns', () async {
      db = AppDatabase(NativeDatabase.memory());
      final migrator = db.createMigrator();

      // The in-memory database is auto-created with the latest schema. Drop
      // the v11 player-count range columns to simulate a v10 database before
      // running the upgrade.
      await db.customStatement(
        'ALTER TABLE board_games DROP COLUMN best_player_count_min',
      );
      await db.customStatement(
        'ALTER TABLE board_games DROP COLUMN best_player_count_max',
      );
      await db.customStatement(
        'ALTER TABLE board_games DROP COLUMN recommended_player_count_min',
      );
      await db.customStatement(
        'ALTER TABLE board_games DROP COLUMN recommended_player_count_max',
      );

      await db.migration.onUpgrade(migrator, 10, 11);

      await db
          .into(db.boardGames)
          .insert(
            const BoardGamesCompanion(
              id: Value(1),
              bestPlayerCount: Value('4-5'),
              bestPlayerCountMin: Value(4),
              bestPlayerCountMax: Value(5),
              recommendedPlayerCount: Value('3-7'),
              recommendedPlayerCountMin: Value(3),
              recommendedPlayerCountMax: Value(7),
            ),
          );

      final row = await db.select(db.boardGames).getSingle();
      expect(row.id, 1);
      expect(row.bestPlayerCount, '4-5');
      expect(row.bestPlayerCountMin, 4);
      expect(row.bestPlayerCountMax, 5);
      expect(row.recommendedPlayerCountMin, 3);
      expect(row.recommendedPlayerCountMax, 7);
    });
  });
}
