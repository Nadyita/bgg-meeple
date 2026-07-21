import '../entities/play.dart';

/// Port for locally caching and querying BGG plays.
abstract class PlayStore {
  /// Replaces the cached plays with [plays].
  Future<void> saveAll(List<Play> plays);

  /// Loads all cached plays.
  Future<List<Play>> loadAll();

  /// Loads all cached plays for a specific game.
  Future<List<Play>> loadForGame(int thingId);

  /// Clears all cached plays and players.
  Future<void> clear();
}
