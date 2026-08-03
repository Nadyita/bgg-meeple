import 'package:collection/collection.dart';

import '../../domain/entities/board_game.dart' as domain;
import '../../domain/entities/bgg_credentials.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/ports/bgg_api.dart';
import '../../domain/ports/collection_store.dart';
import '../../domain/ports/credential_store.dart';
import '../../domain/ports/game_store.dart';
import '../../domain/ports/session_store.dart';
import '../../domain/ports/thumbnail_cache.dart';
import '../../infrastructure/adapters/api/bgg_api_client.dart';
import 'sync_plays_use_case.dart';

/// Progress event emitted while a sync is running.
class SyncProgress {
  const SyncProgress({required this.phase, required this.loaded, this.total});

  /// Current sync phase, e.g. `collection`.
  final String phase;

  /// Number of items already processed in this phase.
  final int loaded;

  /// Total number of items expected in this phase, or `null` while unknown.
  final int? total;
}

/// Result of a successful collection sync.
class SyncResult {
  const SyncResult({required this.items, required this.duration});

  final List<CollectionItem> items;
  final Duration duration;
}

/// Syncs the user's BGG collection to the local cache.
///
/// Loads stored credentials, authenticates if needed, fetches the collection,
/// fetches full game details for every unique game, caches thumbnails, and
/// stores everything locally. Emits progress updates through [onProgress].
class SyncCollectionUseCase {
  const SyncCollectionUseCase(
    this._credentialStore,
    this._sessionStore,
    this._bggApi,
    this._collectionStore,
    this._gameStore,
    this._thumbnailCache, {
    this.syncPlays,
  });

  final CredentialStore _credentialStore;
  final SessionStore _sessionStore;
  final BggApi _bggApi;
  final CollectionStore _collectionStore;
  final GameStore _gameStore;
  final ThumbnailCache _thumbnailCache;
  final SyncPlaysUseCase? syncPlays;

  /// Runs the sync.
  Future<SyncResult> call({void Function(SyncProgress)? onProgress}) async {
    final stopwatch = Stopwatch()..start();

    final credentials = await _credentialStore.load();
    if (credentials == null || !credentials.isValid) {
      throw StateError('No valid BGG credentials configured');
    }

    try {
      await _ensureSession(credentials);
      return await _fetchAndStore(
        credentials: credentials,
        stopwatch: stopwatch,
        onProgress: onProgress,
      );
    } on BggSessionExpiredException {
      // The stored session may be invalid on this device (e.g. wrong cookie
      // parsing or expired cookies). Clear it and re-authenticate once.
      await _sessionStore.delete();
      final newSession = await _bggApi.authenticate(credentials);
      await _sessionStore.save(newSession);
      return await _fetchAndStore(
        credentials: credentials,
        stopwatch: stopwatch,
        onProgress: onProgress,
      );
    }
  }

  Future<SyncResult> _fetchAndStore({
    required BggCredentials credentials,
    required Stopwatch stopwatch,
    void Function(SyncProgress)? onProgress,
  }) async {
    final items = await _bggApi.fetchCollection(credentials.username);
    onProgress?.call(
      SyncProgress(
        phase: 'collection',
        loaded: items.length,
        total: items.length,
      ),
    );

    final uniqueThingIds = items.map((i) => i.thingId).toSet().toList();

    final cachedGames = await _gameStore.loadByIds(uniqueThingIds);
    final fetchedGames = credentials.hasApiToken
        ? await _fetchMissingDetails(uniqueThingIds, cachedGames)
        : <domain.BoardGame>[];
    final gamesByThingId = {
      for (final game in [...cachedGames, ...fetchedGames]) game.id: game,
    };

    onProgress?.call(
      SyncProgress(
        phase: 'details',
        loaded: cachedGames.length + fetchedGames.length,
        total: uniqueThingIds.length,
      ),
    );

    final enrichedItems = items
        .map(
          (item) => _mergeGamePlayerCounts(item, gamesByThingId[item.thingId]),
        )
        .toList();

    await _collectionStore.saveAll(enrichedItems);
    await _gameStore.saveAll(fetchedGames);

    for (var i = 0; i < enrichedItems.length; i++) {
      final item = enrichedItems[i];
      final localPath = await _thumbnailCache.cache(item.thumbnailUrl);
      if (localPath != null) {
        enrichedItems[i] = item.copyWith(thumbnailLocalPath: localPath);
      }
      onProgress?.call(
        SyncProgress(
          phase: 'thumbnails',
          loaded: i + 1,
          total: enrichedItems.length,
        ),
      );
    }

    await _collectionStore.saveAll(enrichedItems);

    final syncPlays = this.syncPlays;
    if (syncPlays != null) {
      await syncPlays(onProgress: onProgress);
    }

    stopwatch.stop();
    return SyncResult(items: enrichedItems, duration: stopwatch.elapsed);
  }

  Future<List<domain.BoardGame>> _fetchMissingDetails(
    List<int> uniqueThingIds,
    List<domain.BoardGame> cachedGames,
  ) async {
    if (uniqueThingIds.isEmpty) return [];

    final missingIds = uniqueThingIds.where((id) {
      final game = cachedGames.firstWhereOrNull((g) => g.id == id);
      if (game == null) return true;
      if (game.description.isEmptyOrNull) return true;
      // detailsUpdatedAt is cleared when the parser gains new data so stale
      // cached details are refreshed on the next sync.
      if (game.detailsUpdatedAt == null) return true;
      // Player-count ranges were added after initial /thing support; treat
      // cached details without them as incomplete so they are refreshed.
      if (game.bestPlayerCountMin == null &&
          game.recommendedPlayerCountMin == null) {
        return true;
      }
      return false;
    }).toList();

    if (missingIds.isEmpty) return [];

    final now = DateTime.now().millisecondsSinceEpoch;
    final games = await _bggApi.fetchGames(missingIds);
    return games.map((g) => g.copyWith(detailsUpdatedAt: now)).toList();
  }

  Future<void> _ensureSession(BggCredentials credentials) async {
    final session = await _sessionStore.load();
    if (session != null && session.isValid) {
      return;
    }

    final newSession = await _bggApi.authenticate(credentials);
    await _sessionStore.save(newSession);
  }

  CollectionItem _mergeGamePlayerCounts(
    CollectionItem item,
    domain.BoardGame? game,
  ) {
    if (game == null) return item;
    return item.copyWith(
      bestPlayerCount: game.bestPlayerCount,
      bestPlayerCountMin: game.bestPlayerCountMin,
      bestPlayerCountMax: game.bestPlayerCountMax,
      recommendedPlayerCount: game.recommendedPlayerCount,
      recommendedPlayerCountMin: game.recommendedPlayerCountMin,
      recommendedPlayerCountMax: game.recommendedPlayerCountMax,
    );
  }
}

extension _NullableStringExtension on String? {
  bool get isEmptyOrNull {
    final value = this;
    return value == null || value.trim().isEmpty;
  }
}
