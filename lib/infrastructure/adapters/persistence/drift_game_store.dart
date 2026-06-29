import 'package:drift/drift.dart';

import '../../../domain/entities/board_game.dart' as domain;
import '../../../domain/ports/game_store.dart';
import '../../../domain/value_objects/localized_name.dart';
import 'drift/app_database.dart' as drift;

/// Drift-backed adapter for [GameStore].
class DriftGameStore implements GameStore {
  DriftGameStore(this._db);

  final drift.AppDatabase _db;

  @override
  Future<void> saveAll(List<domain.BoardGame> games) async {
    await _db.transaction(() async {
      for (final game in games) {
        final companion = _toGameCompanion(game);
        await _db
            .into(_db.boardGames)
            .insert(companion, onConflict: DoUpdate((_) => companion));

        await _db.delete(_db.localizedNames).go();
        for (final name in game.names) {
          await _db
              .into(_db.localizedNames)
              .insert(
                drift.LocalizedNamesCompanion.insert(
                  boardGameId: Value(game.id),
                  value: name.value,
                  language: Value(name.language),
                  isPrimary: Value(name.isPrimary),
                ),
              );
        }
      }
    });
  }

  @override
  Future<List<domain.BoardGame>> loadAll() async {
    final rows = await _db.select(_db.boardGames).get();
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<List<domain.BoardGame>> loadByIds(List<int> ids) async {
    final rows = await (_db.select(
      _db.boardGames,
    )..where((g) => g.id.isIn(ids))).get();
    return Future.wait(rows.map(_toEntity));
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.localizedNames).go();
    await _db.delete(_db.boardGames).go();
  }

  drift.BoardGamesCompanion _toGameCompanion(domain.BoardGame game) {
    return drift.BoardGamesCompanion(
      id: Value(game.id),
      imageUrl: Value(game.imageUrl),
      thumbnailUrl: Value(game.thumbnailUrl),
      yearPublished: Value(game.yearPublished),
      minPlayers: Value(game.minPlayers),
      maxPlayers: Value(game.maxPlayers),
      minPlayTime: Value(game.minPlayTime),
      maxPlayTime: Value(game.maxPlayTime),
      minAge: Value(game.minAge),
      bayesAverage: Value(game.bayesAverage),
    );
  }

  Future<domain.BoardGame> _toEntity(drift.BoardGame row) async {
    final names = await (_db.select(
      _db.localizedNames,
    )..where((n) => n.boardGameId.equals(row.id))).get();

    return domain.BoardGame(
      id: row.id,
      names: names
          .map(
            (n) => LocalizedName(
              value: n.value,
              language: n.language,
              isPrimary: n.isPrimary,
            ),
          )
          .toList(),
      imageUrl: row.imageUrl,
      thumbnailUrl: row.thumbnailUrl,
      yearPublished: row.yearPublished,
      minPlayers: row.minPlayers,
      maxPlayers: row.maxPlayers,
      minPlayTime: row.minPlayTime,
      maxPlayTime: row.maxPlayTime,
      minAge: row.minAge,
      bayesAverage: row.bayesAverage,
    );
  }
}
