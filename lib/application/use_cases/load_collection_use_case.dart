import '../../domain/entities/collection_item.dart';
import '../../domain/entities/board_game.dart';
import '../../domain/ports/collection_store.dart';
import '../../domain/ports/game_store.dart';

/// Loads the cached BGG collection from local storage.
///
/// If a collection item is missing best/recommended player count values but
/// the cached board game has them, the values are copied onto the item so the
/// collection list can show them immediately without requiring a full resync.
class LoadCollectionUseCase {
  const LoadCollectionUseCase(this._collectionStore, this._gameStore);

  final CollectionStore _collectionStore;
  final GameStore _gameStore;

  Future<List<CollectionItem>> call() async {
    final items = await _collectionStore.loadAll();
    final thingIds = items.map((i) => i.thingId).toSet().toList();
    final games = thingIds.isEmpty
        ? <BoardGame>[]
        : await _gameStore.loadByIds(thingIds);
    final gamesById = {for (final game in games) game.id: game};

    return items.map((item) {
      final game = gamesById[item.thingId];
      if (game == null) return item;

      var result = item;
      if (!_hasPlayerCounts(item)) {
        result = result.copyWith(
          bestPlayerCount: game.bestPlayerCount,
          bestPlayerCountMin: game.bestPlayerCountMin,
          bestPlayerCountMax: game.bestPlayerCountMax,
          recommendedPlayerCount: game.recommendedPlayerCount,
          recommendedPlayerCountMin: game.recommendedPlayerCountMin,
          recommendedPlayerCountMax: game.recommendedPlayerCountMax,
        );
      }

      if (result.minAge == null && game.minAge != null) {
        result = result.copyWith(minAge: game.minAge);
      }
      if (result.suggestedPlayerAge == null &&
          game.suggestedPlayerAge != null) {
        result = result.copyWith(suggestedPlayerAge: game.suggestedPlayerAge);
      }

      return result;
    }).toList();
  }

  bool _hasPlayerCounts(CollectionItem item) {
    return item.bestPlayerCount != null || item.recommendedPlayerCount != null;
  }
}
