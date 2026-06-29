import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Drift database that caches BGG collection, game details and version data.
@DriftDatabase(tables: [CollectionItems, BoardGames, LocalizedNames, Versions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        }
        if (from == 2) {
          final hasColumn = await _hasColumn(
            m,
            collectionItems.actualTableName,
            collectionItems.primaryName.name,
          );
          if (!hasColumn) {
            await m.addColumn(collectionItems, collectionItems.primaryName);
          }
        }
        if (from == 3) {
          final hasColumn = await _hasColumn(
            m,
            collectionItems.actualTableName,
            collectionItems.thumbnailLocalPath.name,
          );
          if (!hasColumn) {
            await m.addColumn(
              collectionItems,
              collectionItems.thumbnailLocalPath,
            );
          }
        }
        if (from == 4) {
          // Added collId so the same game in different editions can be stored
          // as separate collection items. Because collId is part of the primary
          // key and must be NOT NULL, existing rows cannot be migrated in place.
          // The cache is a copy of BGG data, so we recreate all tables and let
          // the next sync repopulate them.
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        }
        if (from == 5) {
          final hasBggRank = await _hasColumn(
            m,
            collectionItems.actualTableName,
            collectionItems.bggRank.name,
          );
          if (!hasBggRank) {
            await m.addColumn(collectionItems, collectionItems.bggRank);
          }
          final hasUserCount = await _hasColumn(
            m,
            collectionItems.actualTableName,
            collectionItems.geekRatingUserCount.name,
          );
          if (!hasUserCount) {
            await m.addColumn(
              collectionItems,
              collectionItems.geekRatingUserCount,
            );
          }
        }
      },
    );
  }

  static Future<bool> _hasColumn(
    Migrator m,
    String tableName,
    String columnName,
  ) async {
    final result = await m.database
        .customSelect('PRAGMA table_info($tableName);')
        .get();
    return result.any((row) => row.read<String>('name') == columnName);
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'bgg_meeple_cache',
      native: const DriftNativeOptions(databaseDirectory: _databaseDirectory),
    );
  }
}

Future<Directory> _databaseDirectory() async {
  final dir = await getApplicationDocumentsDirectory();
  final dbDir = Directory(p.join(dir.path, 'databases'));
  if (!dbDir.existsSync()) {
    dbDir.createSync(recursive: true);
  }
  return dbDir;
}

/// Local cache for a single collection item.
class CollectionItems extends Table {
  IntColumn get thingId => integer()();
  IntColumn get collId => integer()();
  TextColumn get primaryName => text().nullable()();
  TextColumn get thumbnailLocalPath => text().nullable()();
  TextColumn get customName => text().nullable()();
  TextColumn get customImageUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  IntColumn get yearPublished => integer().nullable()();
  IntColumn get minPlayers => integer().nullable()();
  IntColumn get maxPlayers => integer().nullable()();
  IntColumn get minPlayTime => integer().nullable()();
  IntColumn get maxPlayTime => integer().nullable()();
  IntColumn get minAge => integer().nullable()();
  RealColumn get bayesAverage => real().nullable()();
  RealColumn get ownRating => real().nullable()();
  IntColumn get numPlays => integer().nullable()();
  IntColumn get bggRank => integer().nullable()();
  IntColumn get geekRatingUserCount => integer().nullable()();
  BoolColumn get isOwned => boolean().withDefault(const Constant(false))();
  BoolColumn get isPreordered => boolean().withDefault(const Constant(false))();
  BoolColumn get isWishlisted => boolean().withDefault(const Constant(false))();
  BoolColumn get isWantToPlay => boolean().withDefault(const Constant(false))();
  BoolColumn get isWantToBuy => boolean().withDefault(const Constant(false))();
  BoolColumn get isPrevOwned => boolean().withDefault(const Constant(false))();
  BoolColumn get isPlayed => boolean().withDefault(const Constant(false))();
  BoolColumn get isRated => boolean().withDefault(const Constant(false))();
  BoolColumn get isForTrade => boolean().withDefault(const Constant(false))();
  BoolColumn get isWantInTrade =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hasComment => boolean().withDefault(const Constant(false))();
  IntColumn get versionId =>
      integer().nullable().customConstraint('REFERENCES versions(id)')();

  @override
  Set<Column> get primaryKey => {thingId, collId};
}

/// Local cache for board game details (XML API2 /thing).
class BoardGames extends Table {
  IntColumn get id => integer()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  IntColumn get yearPublished => integer().nullable()();
  IntColumn get minPlayers => integer().nullable()();
  IntColumn get maxPlayers => integer().nullable()();
  IntColumn get minPlayTime => integer().nullable()();
  IntColumn get maxPlayTime => integer().nullable()();
  IntColumn get minAge => integer().nullable()();
  RealColumn get bayesAverage => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Localized or alternate names for a board game or version.
class LocalizedNames extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get boardGameId =>
      integer().nullable().customConstraint('REFERENCES board_games(id)')();
  IntColumn get versionId =>
      integer().nullable().customConstraint('REFERENCES versions(id)')();
  TextColumn get value => text()();
  TextColumn get language => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
}

/// Local cache for selected BGG versions/editions.
class Versions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bggVersionId => integer()();
  TextColumn get name => text()();
  IntColumn get year => integer().nullable()();
}
