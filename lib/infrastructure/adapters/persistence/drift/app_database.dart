import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Drift database that caches BGG collection, game details, version, and play data.
@DriftDatabase(
  tables: [
    CollectionItems,
    BoardGames,
    LocalizedNames,
    Versions,
    Plays,
    PlayPlayers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 8) {
          // Schema v8 adds play and play_player tables. Cache data is
          // repopulated on next sync, so we recreate all tables rather than
          // migrating in place.
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        }
      },
    );
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
  IntColumn get playingTime => integer().nullable()();
  IntColumn get minAge => integer().nullable()();
  RealColumn get bayesAverage => real().nullable()();
  RealColumn get averageRating => real().nullable()();
  IntColumn get userCount => integer().nullable()();
  IntColumn get numOwned => integer().nullable()();
  IntColumn get numTrading => integer().nullable()();
  IntColumn get numWanting => integer().nullable()();
  IntColumn get numWishing => integer().nullable()();
  RealColumn get averageWeight => real().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get categories => text().nullable()();
  TextColumn get mechanics => text().nullable()();
  TextColumn get designers => text().nullable()();
  TextColumn get artists => text().nullable()();
  TextColumn get publishers => text().nullable()();
  TextColumn get families => text().nullable()();
  TextColumn get languageDependence => text().nullable()();
  TextColumn get bestPlayerCount => text().nullable()();
  TextColumn get recommendedPlayerCount => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache for selected BGG versions/editions.
class Versions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bggVersionId => integer()();
  TextColumn get name => text()();
  IntColumn get year => integer().nullable()();
}

/// Local cache for a single logged BGG play.
class Plays extends Table {
  IntColumn get id => integer()();
  IntColumn get thingId => integer()();
  TextColumn get gameName => text()();
  TextColumn get date => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get length => integer().withDefault(const Constant(0))();
  BoolColumn get incomplete => boolean().withDefault(const Constant(false))();
  BoolColumn get noWinStats => boolean().withDefault(const Constant(false))();
  TextColumn get location => text().nullable()();
  TextColumn get comments => text().nullable()();
  TextColumn get subtypes =>
      text().withDefault(const Constant('[]')).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache for a player participating in a logged BGG play.
class PlayPlayers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playId =>
      integer().customConstraint('REFERENCES plays(id) NOT NULL')();
  TextColumn get username => text().nullable()();
  IntColumn get userId => integer().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get startPosition => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get score => text().nullable()();
  BoolColumn get newPlayer => boolean().withDefault(const Constant(false))();
  RealColumn get rating => real().nullable()();
  BoolColumn get win => boolean().withDefault(const Constant(false))();
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
