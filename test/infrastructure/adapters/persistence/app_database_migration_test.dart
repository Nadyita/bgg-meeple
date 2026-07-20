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

    test('schema version is 7', () {
      db = AppDatabase(NativeDatabase.memory());
      expect(db.schemaVersion, 7);
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
          'localized_names',
          'versions',
        ]),
      );
    });

    test(
      'upgrade from v6 to v7 recreates tables with new game detail columns',
      () async {
        db = AppDatabase(NativeDatabase.memory());
        final migrator = db.createMigrator();
        await db.migration.onUpgrade(migrator, 6, 7);

        await db
            .into(db.boardGames)
            .insert(
              BoardGamesCompanion(
                id: const Value(1),
                description: const Value('A great game.'),
                categories: const Value('["Strategy"]'),
                mechanics: const Value('["Worker Placement"]'),
                designers: const Value('["Uwe Rosenberg"]'),
                artists: const Value('["Klemens Franz"]'),
                publishers: const Value('["Lookout Games"]'),
                families: const Value('["Harvest"]'),
                languageDependence: const Value('Some necessary text'),
                bestPlayerCount: const Value('2'),
                recommendedPlayerCount: const Value('1, 2, 3'),
              ),
            );

        final row = await db.select(db.boardGames).getSingle();
        expect(row.id, 1);
        expect(row.description, 'A great game.');
        expect(row.categories, '["Strategy"]');
      },
    );
  });
}
