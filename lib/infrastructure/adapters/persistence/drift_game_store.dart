import 'package:drift/drift.dart';

import '../../../domain/entities/board_game.dart' as domain;
import '../../../domain/ports/game_store.dart';
import '../../../domain/value_objects/game_link.dart';
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

      await _syncLinks(games);
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
    await _db.delete(_db.boardGameLinkRels).go();
    await _db.delete(_db.gameLinks).go();
    await _db.delete(_db.localizedNames).go();
    await _db.delete(_db.boardGames).go();
  }

  Future<void> _syncLinks(List<domain.BoardGame> games) async {
    final ids = games.map((g) => g.id).toList();
    await (_db.delete(
      _db.boardGameLinkRels,
    )..where((r) => r.gameId.isIn(ids))).go();

    final allLinks = <GameLink>{};
    for (final game in games) {
      allLinks.addAll(game.links);
    }

    final linkIdsByKey = <String, int>{};
    for (final link in allLinks) {
      final companion = drift.GameLinksCompanion(
        type: Value(link.type),
        bggId: Value(link.bggId),
        name: Value(link.name),
      );
      final linkId = await _db
          .into(_db.gameLinks)
          .insert(companion, onConflict: DoUpdate((_) => companion));
      linkIdsByKey['${link.type}:${link.bggId}'] = linkId;
    }

    for (final game in games) {
      for (final link in game.links) {
        final linkId = linkIdsByKey['${link.type}:${link.bggId}'];
        if (linkId == null) continue;
        await _db
            .into(_db.boardGameLinkRels)
            .insert(
              drift.BoardGameLinkRelsCompanion(
                gameId: Value(game.id),
                linkId: Value(linkId),
              ),
            );
      }
    }
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
      languageDependenceLevel: Value(game.languageDependenceLevel),
      bestPlayerCount: Value(game.bestPlayerCount),
      bestPlayerCountMin: Value(game.bestPlayerCountMin),
      bestPlayerCountMax: Value(game.bestPlayerCountMax),
      suggestedPlayerAge: Value(game.suggestedPlayerAge),
      recommendedPlayerCount: Value(game.recommendedPlayerCount),
      recommendedPlayerCountMin: Value(game.recommendedPlayerCountMin),
      recommendedPlayerCountMax: Value(game.recommendedPlayerCountMax),
      detailsUpdatedAt: Value(game.detailsUpdatedAt),
    );
  }

  Future<domain.BoardGame> _toEntity(drift.BoardGame row) async {
    final names = await (_db.select(
      _db.localizedNames,
    )..where((n) => n.boardGameId.equals(row.id))).get();

    final linkRows = await (_db.select(_db.gameLinks).join([
      innerJoin(
        _db.boardGameLinkRels,
        _db.boardGameLinkRels.linkId.equalsExp(_db.gameLinks.id),
      ),
    ])..where(_db.boardGameLinkRels.gameId.equals(row.id))).get();

    final links = linkRows
        .map(
          (r) => GameLink(
            bggId: r.readTable(_db.gameLinks).bggId,
            type: r.readTable(_db.gameLinks).type,
            name: r.readTable(_db.gameLinks).name,
          ),
        )
        .toList();

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
      links: links,
      languageDependenceLevel: row.languageDependenceLevel,
      bestPlayerCount: row.bestPlayerCount,
      bestPlayerCountMin: row.bestPlayerCountMin,
      bestPlayerCountMax: row.bestPlayerCountMax,
      suggestedPlayerAge: row.suggestedPlayerAge,
      recommendedPlayerCount: row.recommendedPlayerCount,
      recommendedPlayerCountMin: row.recommendedPlayerCountMin,
      recommendedPlayerCountMax: row.recommendedPlayerCountMax,
      detailsUpdatedAt: row.detailsUpdatedAt,
    );
  }
}
