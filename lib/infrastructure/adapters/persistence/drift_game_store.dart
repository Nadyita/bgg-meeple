import 'dart:convert';

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
    if (games.isEmpty) return;

    await _db.transaction(() async {
      for (final game in games) {
        final companion = _toGameCompanion(game);
        await _db
            .into(_db.boardGames)
            .insert(companion, onConflict: DoUpdate((_) => companion));
      }

      final ids = games.map((g) => g.id).toList();
      await (_db.delete(
        _db.localizedNames,
      )..where((n) => n.boardGameId.isIn(ids))).go();

      for (final game in games) {
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
    if (ids.isEmpty) return [];
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
      playingTime: Value(game.playingTime),
      minAge: Value(game.minAge),
      bayesAverage: Value(game.bayesAverage),
      averageRating: Value(game.averageRating),
      userCount: Value(game.userCount),
      numOwned: Value(game.numOwned),
      numTrading: Value(game.numTrading),
      numWanting: Value(game.numWanting),
      numWishing: Value(game.numWishing),
      averageWeight: Value(game.averageWeight),
      description: Value(game.description),
      categories: Value(_encodeList(game.categories)),
      mechanics: Value(_encodeList(game.mechanics)),
      designers: Value(_encodeList(game.designers)),
      artists: Value(_encodeList(game.artists)),
      publishers: Value(_encodeList(game.publishers)),
      families: Value(_encodeList(game.families)),
      languageDependence: Value(game.languageDependence),
      bestPlayerCount: Value(game.bestPlayerCount),
      recommendedPlayerCount: Value(game.recommendedPlayerCount),
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
      playingTime: row.playingTime,
      minAge: row.minAge,
      bayesAverage: row.bayesAverage,
      averageRating: row.averageRating,
      userCount: row.userCount,
      numOwned: row.numOwned,
      numTrading: row.numTrading,
      numWanting: row.numWanting,
      numWishing: row.numWishing,
      averageWeight: row.averageWeight,
      description: row.description,
      categories: _decodeList(row.categories),
      mechanics: _decodeList(row.mechanics),
      designers: _decodeList(row.designers),
      artists: _decodeList(row.artists),
      publishers: _decodeList(row.publishers),
      families: _decodeList(row.families),
      languageDependence: row.languageDependence,
      bestPlayerCount: row.bestPlayerCount,
      recommendedPlayerCount: row.recommendedPlayerCount,
    );
  }

  String? _encodeList(List<String> values) {
    if (values.isEmpty) return null;
    return jsonEncode(values);
  }

  List<String> _decodeList(String? value) {
    if (value == null || value.isEmpty) return const [];
    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded.cast<String>();
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }
}
