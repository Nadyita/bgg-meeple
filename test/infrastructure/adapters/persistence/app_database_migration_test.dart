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

    test('schema version is 6', () {
      db = AppDatabase(NativeDatabase.memory());
      expect(db.schemaVersion, 6);
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

    test('upgrade from v1 to v2 recreates all tables', () async {
      db = AppDatabase(NativeDatabase.memory());
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 1, 2);

      // Verify the tables are usable by inserting a full row with every column.
      final versionId = await db
          .into(db.versions)
          .insert(
            VersionsCompanion.insert(bggVersionId: 12345, name: 'Test Edition'),
          );
      await db
          .into(db.collectionItems)
          .insert(
            CollectionItemsCompanion(
              thingId: const Value(42),
              collId: const Value(42),
              customName: const Value('Custom name'),
              customImageUrl: const Value('https://example.com/image.png'),
              thumbnailUrl: const Value('https://example.com/thumb.png'),
              imageUrl: const Value('https://example.com/full.png'),
              yearPublished: const Value(2024),
              minPlayers: const Value(1),
              maxPlayers: const Value(4),
              minPlayTime: const Value(30),
              maxPlayTime: const Value(120),
              minAge: const Value(12),
              bayesAverage: const Value(7.5),
              ownRating: const Value(8.0),
              numPlays: const Value(5),
              isOwned: const Value(true),
              isPreordered: const Value(true),
              isWishlisted: const Value(true),
              isWantToPlay: const Value(true),
              isWantToBuy: const Value(true),
              isPrevOwned: const Value(true),
              isPlayed: const Value(true),
              isRated: const Value(true),
              isForTrade: const Value(true),
              isWantInTrade: const Value(true),
              hasComment: const Value(true),
              versionId: Value(versionId),
            ),
          );

      final row = await db.select(db.collectionItems).getSingle();
      expect(row.thingId, 42);
      expect(row.customName, 'Custom name');
      expect(row.yearPublished, 2024);
      expect(row.bayesAverage, 7.5);
      expect(row.versionId, versionId);
    });

    test('upgrade from v2 to v3 adds primaryName column', () async {
      db = AppDatabase(NativeDatabase.memory());
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 2, 3);

      await db
          .into(db.collectionItems)
          .insert(
            CollectionItemsCompanion(
              thingId: const Value(1),
              collId: const Value(1),
              primaryName: const Value('Catan'),
            ),
          );

      final row = await db.select(db.collectionItems).getSingle();
      expect(row.primaryName, 'Catan');
    });

    test('upgrade from v3 to v4 adds thumbnailLocalPath column', () async {
      db = AppDatabase(NativeDatabase.memory());
      final migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 3, 4);

      await db
          .into(db.collectionItems)
          .insert(
            CollectionItemsCompanion(
              thingId: const Value(1),
              collId: const Value(1),
              thumbnailLocalPath: const Value('/cache/1.png'),
            ),
          );

      final row = await db.select(db.collectionItems).getSingle();
      expect(row.thumbnailLocalPath, '/cache/1.png');
    });

    test(
      'upgrade from v4 to v5 recreates tables for collId primary key change',
      () async {
        db = AppDatabase(NativeDatabase.memory());
        final migrator = db.createMigrator();
        await db.migration.onUpgrade(migrator, 4, 5);

        // After recreating, a row with the new primary key must be insertable.
        await db
            .into(db.collectionItems)
            .insert(
              CollectionItemsCompanion(
                thingId: const Value(1),
                collId: const Value(42),
              ),
            );
        await db
            .into(db.collectionItems)
            .insert(
              CollectionItemsCompanion(
                thingId: const Value(1),
                collId: const Value(43),
              ),
            );

        final rows = await db.select(db.collectionItems).get();
        expect(rows.length, 2);
      },
    );

    test(
      'upgrade from v5 to v6 adds bggRank and geekRatingUserCount columns',
      () async {
        db = AppDatabase(NativeDatabase.memory());
        final migrator = db.createMigrator();
        await db.migration.onUpgrade(migrator, 5, 6);

        await db
            .into(db.collectionItems)
            .insert(
              CollectionItemsCompanion(
                thingId: const Value(1),
                collId: const Value(1),
                bggRank: const Value(42),
                geekRatingUserCount: const Value(12345),
              ),
            );

        final row = await db.select(db.collectionItems).getSingle();
        expect(row.bggRank, 42);
        expect(row.geekRatingUserCount, 12345);
      },
    );
  });
}
