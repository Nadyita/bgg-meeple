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
    // ignore: avoid_print
    print('[SyncCollectionUseCase] Fetched ${items.length} collection items');
    onProgress?.call(
      SyncProgress(
        phase: 'collection',
        loaded: items.length,
        total: items.length,
      ),
    );

    final uniqueThingIds = items.map((i) => i.thingId).toSet().toList();
    // ignore: avoid_print
    print(
      '[SyncCollectionUseCase] Fetching details for ${uniqueThingIds.length} unique games',
    );
    final games = await _bggApi.fetchGames(uniqueThingIds);
    // ignore: avoid_print
    print('[SyncCollectionUseCase] Received ${games.length} games from /thing');
    onProgress?.call(
      SyncProgress(
        phase: 'details',
        loaded: games.length,
        total: uniqueThingIds.length,
      ),
    );

    await _collectionStore.saveAll(items);
    await _gameStore.saveAll(games);
    // ignore: avoid_print
    print(
      '[SyncCollectionUseCase] Saved ${items.length} items and ${games.length} games',
    );

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final localPath = await _thumbnailCache.cache(item.thumbnailUrl);
      if (localPath != null) {
        items[i] = item.copyWith(thumbnailLocalPath: localPath);
      }
      onProgress?.call(
        SyncProgress(phase: 'thumbnails', loaded: i + 1, total: items.length),
      );
    }

    await _collectionStore.saveAll(items);

    final syncPlays = this.syncPlays;
    if (syncPlays != null) {
      await syncPlays(onProgress: onProgress);
    }

    stopwatch.stop();
    return SyncResult(items: items, duration: stopwatch.elapsed);
  }

  Future<void> _ensureSession(BggCredentials credentials) async {
    final session = await _sessionStore.load();
    if (session != null && session.isValid) {
      return;
    }

    final newSession = await _bggApi.authenticate(credentials);
    await _sessionStore.save(newSession);
  }
}
