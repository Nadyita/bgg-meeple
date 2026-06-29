import '../entities/board_game.dart';

/// Port for persisting and querying board game details locally.
abstract class GameStore {
  /// Replaces or inserts the given games into the local cache.
  Future<void> saveAll(List<BoardGame> games);

  /// Loads all cached games.
  Future<List<BoardGame>> loadAll();

  /// Loads the subset of cached games with the given [ids].
  Future<List<BoardGame>> loadByIds(List<int> ids);

  /// Deletes all cached games.
  Future<void> clear();
}
