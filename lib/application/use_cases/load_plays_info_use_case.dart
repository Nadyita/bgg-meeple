import '../../domain/entities/play.dart';
import '../../domain/entities/play_player.dart';
import '../../domain/ports/play_store.dart';
import '../../domain/value_objects/plays_info.dart';

/// Loads aggregated play information for every cached game.
///
/// Returns a [PlaysInfo] with two maps keyed by BGG thing id:
///
/// - [PlaysInfo.playerNamesByGame]: unique, alphabetically sorted player names,
///   deduplicated case-insensitively while preserving the casing of the first
///   occurrence. Empty or missing names are omitted.
/// - [PlaysInfo.playsByGame]: the raw cached plays for the game, in the order
///   returned by the store.
///
/// This allows the collection filter to evaluate both aggregate player
/// participation and per-play filters such as play count.
class LoadPlaysInfoUseCase {
  const LoadPlaysInfoUseCase(this._playStore);

  final PlayStore _playStore;

  Future<PlaysInfo> call() async {
    final plays = await _playStore.loadAll();
    return _groupByGame(plays);
  }

  PlaysInfo _groupByGame(List<Play> plays) {
    final namesByGame = <int, _NameBucket>{};
    final playsByGame = <int, List<Play>>{};

    for (final play in plays) {
      playsByGame.putIfAbsent(play.thingId, () => []).add(play);
      final bucket = namesByGame.putIfAbsent(play.thingId, _NameBucket.new);
      for (final player in play.players) {
        bucket.add(player);
      }
    }

    return PlaysInfo(
      playerNamesByGame: {
        for (final entry in namesByGame.entries)
          if (entry.value.sortedNames().isNotEmpty)
            entry.key: entry.value.sortedNames(),
      },
      playsByGame: playsByGame,
    );
  }
}

/// Keeps the first-seen casing for each player name while deduplicating
/// case-insensitively.
class _NameBucket {
  final Map<String, String> _canonicalToOriginal = {};

  void add(PlayPlayer player) {
    final name = player.name;
    if (name == null || name.trim().isEmpty) return;

    final trimmed = name.trim();
    final lower = trimmed.toLowerCase();
    _canonicalToOriginal.putIfAbsent(lower, () => trimmed);
  }

  List<String> sortedNames() {
    final sorted = List<String>.of(_canonicalToOriginal.values);
    sorted.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }
}
