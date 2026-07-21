import '../../domain/entities/play.dart';
import '../../domain/ports/bgg_api.dart';
import '../../domain/ports/credential_store.dart';
import '../../domain/ports/play_store.dart';
import 'sync_collection_use_case.dart';

/// Result of a successful plays sync.
class SyncPlaysResult {
  const SyncPlaysResult({required this.plays, required this.duration});

  final List<Play> plays;
  final Duration duration;
}

/// Syncs the user's BGG plays to the local cache.
///
/// Loads stored credentials, fetches all plays page by page, and replaces the
/// local play cache. Emits progress updates through [onProgress].
class SyncPlaysUseCase {
  const SyncPlaysUseCase(this._credentialStore, this._bggApi, this._playStore);

  final CredentialStore _credentialStore;
  final BggApi _bggApi;
  final PlayStore _playStore;

  Future<SyncPlaysResult> call({
    void Function(SyncProgress)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();

    final credentials = await _credentialStore.load();
    if (credentials == null || !credentials.isValid) {
      throw StateError('No valid BGG credentials configured');
    }

    final plays = await _bggApi.fetchPlays(credentials.username);
    // ignore: avoid_print
    print('[SyncPlaysUseCase] Fetched ${plays.length} plays');

    onProgress?.call(
      SyncProgress(phase: 'plays', loaded: plays.length, total: plays.length),
    );

    await _playStore.saveAll(plays);
    // ignore: avoid_print
    print('[SyncPlaysUseCase] Saved ${plays.length} plays');

    stopwatch.stop();
    return SyncPlaysResult(plays: plays, duration: stopwatch.elapsed);
  }
}
