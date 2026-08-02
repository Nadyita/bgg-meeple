import 'dart:async';

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
/// Combines the collection item, the cached [BoardGame] details, lazily caches
/// the full game image, and triggers a background refresh of stale game
/// details when an API token is available.
class LoadGameDetailsUseCase {
  const LoadGameDetailsUseCase(
    this._collectionStore,
    this._gameStore,
    this._imageCache, {
    this.refreshDetails,
    this.hasApiToken = _defaultHasApiToken,
    this.now = _defaultNow,
  });

  final CollectionStore _collectionStore;
  final GameStore _gameStore;
  final ThumbnailCache _imageCache;

  /// Callback that fetches fresh `/thing` details for the given [thingId] and
  /// persists them. Called in the background when cached details are stale.
  final Future<void> Function(int thingId)? refreshDetails;

  /// Returns whether a valid API token is available. Overridable for testing.
  final Future<bool> Function() hasApiToken;

  /// Returns the current timestamp in milliseconds since epoch. Overridable for
  /// testing.
  final int Function() now;

  static Future<bool> _defaultHasApiToken() async => false;
  static int _defaultNow() => DateTime.now().millisecondsSinceEpoch;

  /// Runs the sync.
  Future<GameDetails?> call(int thingId, int collId) async {
    var collectionItem = await _collectionStore.loadById(thingId, collId);
    collectionItem ??= await _collectionStore.loadById(thingId, thingId);
    if (collectionItem == null) {
      return null;
    }

    final games = await _gameStore.loadByIds([thingId]);
    final boardGame = games.firstOrNull;

    final imageUrl = boardGame?.imageUrl ?? collectionItem.imageUrl;

    final localImagePath = await _imageCache.cache(imageUrl);

    unawaited(_maybeRefreshDetails(thingId, boardGame).catchError((_) => null));

    return GameDetails(
      collectionItem: collectionItem,
      boardGame: boardGame,
      imageUrl: imageUrl,
      localImagePath: localImagePath,
    );
  }

  Future<void> _maybeRefreshDetails(int thingId, BoardGame? boardGame) async {
    final refresh = refreshDetails;
    if (refresh == null) return;
    if (!await hasApiToken()) return;

    final updatedAt = boardGame?.detailsUpdatedAt;
    if (updatedAt != null) {
      final ageMs = now() - updatedAt;
      if (ageMs < const Duration(days: 30).inMilliseconds) return;
    }

    await refresh(thingId);
  }
}
