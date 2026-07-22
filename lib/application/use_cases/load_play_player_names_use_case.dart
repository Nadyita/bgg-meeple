import '../../domain/entities/play.dart';
import '../../domain/entities/play_player.dart';
import '../../domain/ports/play_store.dart';

/// Loads the unique, alphabetically sorted player names for every cached game.
///
/// Returns a map keyed by BGG thing id. Names are deduplicated case-insensitively
/// while preserving the casing of the first occurrence, sorted ascending by
/// lowercase name, and empty or missing names are omitted.
class LoadPlayPlayerNamesUseCase {
  const LoadPlayPlayerNamesUseCase(this._playStore);

  final PlayStore _playStore;

  Future<Map<int, List<String>>> call() async {
    final plays = await _playStore.loadAll();
    return _groupByGame(plays);
  }

  Map<int, List<String>> _groupByGame(List<Play> plays) {
    final namesByGame = <int, _NameBucket>{};

    for (final play in plays) {
      final bucket = namesByGame.putIfAbsent(play.thingId, _NameBucket.new);
      for (final player in play.players) {
        bucket.add(player);
      }
    }

    return {
      for (final entry in namesByGame.entries)
        if (entry.value.sortedNames().isNotEmpty)
          entry.key: entry.value.sortedNames(),
    };
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
