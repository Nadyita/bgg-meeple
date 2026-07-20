import '../../domain/entities/board_game.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/ports/collection_store.dart';
import '../../domain/ports/game_store.dart';
import '../../domain/ports/thumbnail_cache.dart';

/// Aggregated detail data for a single collection item.
class GameDetails {
  const GameDetails({
    required this.collectionItem,
    this.boardGame,
    this.imageUrl,
    this.localImagePath,
  });

  final CollectionItem collectionItem;
  final BoardGame? boardGame;

  /// Best available full-size image URL (from the cached board game details or
  /// from the collection item). May be `null` if no full image is known.
  final String? imageUrl;

  /// Local file path of the cached full-size image, or `null` if it has not
  /// been downloaded yet.
  final String? localImagePath;
}

/// Loads the full detail data for a collection item.
///
/// Combines the collection item, the cached [BoardGame] details, and lazily
/// caches the full game image so it is available offline on subsequent visits.
class LoadGameDetailsUseCase {
  const LoadGameDetailsUseCase(
    this._collectionStore,
    this._gameStore,
    this._imageCache,
  );

  final CollectionStore _collectionStore;
  final GameStore _gameStore;
  final ThumbnailCache _imageCache;

  Future<GameDetails?> call(int thingId, int collId) async {
    var collectionItem = await _collectionStore.loadById(thingId, collId);
    collectionItem ??= await _collectionStore.loadById(thingId, thingId);
    if (collectionItem == null) {
      // ignore: avoid_print
      print(
        '[LoadGameDetailsUseCase] Collection item not found for thingId=$thingId collId=$collId',
      );
      return null;
    }

    final games = await _gameStore.loadByIds([thingId]);
    final boardGame = games.firstOrNull;
    // ignore: avoid_print
    print(
      '[LoadGameDetailsUseCase] Loaded board game for thingId=$thingId: ${boardGame != null}',
    );

    final imageUrl = boardGame?.imageUrl ?? collectionItem.imageUrl;
    // ignore: avoid_print
    print('[LoadGameDetailsUseCase] Image URL for thingId=$thingId: $imageUrl');

    final localImagePath = await _imageCache.cache(imageUrl);
    // ignore: avoid_print
    print(
      '[LoadGameDetailsUseCase] Cached image path for thingId=$thingId: $localImagePath',
    );

    return GameDetails(
      collectionItem: collectionItem,
      boardGame: boardGame,
      imageUrl: imageUrl,
      localImagePath: localImagePath,
    );
  }
}
