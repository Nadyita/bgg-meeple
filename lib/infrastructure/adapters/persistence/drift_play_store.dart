import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../domain/entities/play.dart' as domain;
import '../../../domain/entities/play_player.dart' as domain;
import '../../../domain/ports/play_store.dart';
import 'drift/app_database.dart' as drift;

/// Drift-backed adapter for [PlayStore].
class DriftPlayStore implements PlayStore {
  DriftPlayStore(this._db);

  final drift.AppDatabase _db;

  @override
  Future<void> saveAll(List<domain.Play> plays) async {
    await _db.transaction(() async {
      await _db.delete(_db.playPlayers).go();
      await _db.delete(_db.plays).go();

      for (final play in plays) {
        final playCompanion = _toPlayCompanion(play);
        await _db.into(_db.plays).insert(playCompanion);

        for (final player in play.players) {
          final playerCompanion = _toPlayerCompanion(play.id, player);
          await _db.into(_db.playPlayers).insert(playerCompanion);
        }
      }
    });
  }

  @override
  Future<List<domain.Play>> loadAll() async {
    final playRows = await _db.select(_db.plays).get();
    return Future.wait(playRows.map(_toPlayEntity));
  }

  @override
  Future<List<domain.Play>> loadForGame(int thingId) async {
    final playRows = await (_db.select(
      _db.plays,
    )..where((p) => p.thingId.equals(thingId))).get();
    return Future.wait(playRows.map(_toPlayEntity));
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.playPlayers).go();
    await _db.delete(_db.plays).go();
  }

  drift.PlaysCompanion _toPlayCompanion(domain.Play play) {
    return drift.PlaysCompanion(
      id: Value(play.id),
      thingId: Value(play.thingId),
      gameName: Value(play.gameName),
      date: Value(play.date),
      quantity: Value(play.quantity),
      length: Value(play.length),
      incomplete: Value(play.incomplete),
      noWinStats: Value(play.noWinStats),
      location: Value(play.location),
      comments: Value(play.comments),
      subtypes: Value(_encodeList(play.subtypes)),
    );
  }

  drift.PlayPlayersCompanion _toPlayerCompanion(
    int playId,
    domain.PlayPlayer player,
  ) {
    return drift.PlayPlayersCompanion(
      playId: Value(playId),
      username: Value(player.username),
      userId: Value(player.userId),
      name: Value(player.name),
      startPosition: Value(player.startPosition),
      color: Value(player.color),
      score: Value(player.score),
      newPlayer: Value(player.newPlayer),
      rating: Value(player.rating),
      win: Value(player.win),
    );
  }

  Future<domain.Play> _toPlayEntity(drift.Play row) async {
    final playerRows = await (_db.select(
      _db.playPlayers,
    )..where((p) => p.playId.equals(row.id))).get();

    return domain.Play(
      id: row.id,
      thingId: row.thingId,
      gameName: row.gameName,
      date: row.date,
      quantity: row.quantity,
      length: row.length,
      incomplete: row.incomplete,
      noWinStats: row.noWinStats,
      location: row.location,
      comments: row.comments,
      subtypes: _decodeList(row.subtypes),
      players: playerRows.map(_toPlayerEntity).toList(),
    );
  }

  domain.PlayPlayer _toPlayerEntity(drift.PlayPlayer row) {
    return domain.PlayPlayer(
      username: row.username,
      userId: row.userId,
      name: row.name,
      startPosition: row.startPosition,
      color: row.color,
      score: row.score,
      newPlayer: row.newPlayer,
      rating: row.rating,
      win: row.win,
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
