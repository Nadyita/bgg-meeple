import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../application/use_cases/load_card_layout_use_case.dart';
import '../../application/use_cases/load_collection_use_case.dart';
import '../../application/use_cases/load_collection_view_use_case.dart';
import '../../application/use_cases/load_credentials_use_case.dart';
import '../../application/use_cases/load_game_details_use_case.dart';
import '../../application/use_cases/load_theme_config_use_case.dart';
import '../../application/use_cases/login_use_case.dart';
import '../../application/use_cases/save_card_layout_use_case.dart';
import '../../application/use_cases/save_collection_view_use_case.dart';
import '../../application/use_cases/save_credentials_use_case.dart';
import '../../application/use_cases/save_theme_config_use_case.dart';
import '../../application/use_cases/sync_collection_use_case.dart';
import '../../application/use_cases/sync_plays_use_case.dart';
import '../../domain/ports/card_layout_store.dart';
import '../../domain/ports/collection_store.dart';
import '../../domain/ports/collection_view_store.dart';
import '../../domain/ports/credential_store.dart';
import '../../domain/ports/game_store.dart';
import '../../domain/ports/play_store.dart';
import '../../domain/ports/session_store.dart';
import '../../domain/ports/theme_store.dart';
import '../../domain/ports/thumbnail_cache.dart';
import '../adapters/api/bgg_api_client.dart';
import '../adapters/persistence/shared_preferences_card_layout_store.dart';
import '../adapters/persistence/shared_preferences_collection_view_store.dart';
import '../adapters/persistence/shared_preferences_theme_store.dart';
import '../adapters/cache/file_thumbnail_cache.dart';
import '../adapters/persistence/drift/app_database.dart';
import '../adapters/persistence/drift_collection_store.dart';
import '../adapters/persistence/drift_game_store.dart';
import '../adapters/persistence/drift_play_store.dart';
import '../adapters/security/secure_credential_store.dart';
import '../adapters/security/secure_session_store.dart';

/// Simple service locator that wires infrastructure adapters to use cases.
///
/// In a larger app this would be replaced by a proper DI framework.
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final FlutterSecureStorage _secureStorage;
  late final CredentialStore _credentialStore;
  late final SessionStore _sessionStore;
  late final BggApiClient _bggApi;
  late final AppDatabase _appDatabase;
  late final CollectionStore _collectionStore;
  late final GameStore gameStore;
  late final PlayStore _playStore;

  late final CardLayoutStore _cardLayoutStore;
  late final CollectionViewStore _collectionViewStore;
  late final ThemeStore _themeStore;

  late final ThumbnailCache _thumbnailCache;

  late final LoadCardLayoutUseCase loadCardLayout;
  late final SaveCardLayoutUseCase saveCardLayout;
  late final LoadCollectionViewUseCase loadCollectionView;
  late final SaveCollectionViewUseCase saveCollectionView;
  late final LoadThemeConfigUseCase loadThemeConfig;
  late final SaveThemeConfigUseCase saveThemeConfig;
  late final LoadCollectionUseCase loadCollection;
  late final LoadGameDetailsUseCase loadGameDetails;
  late final LoadCredentialsUseCase loadCredentials;
  late final SaveCredentialsUseCase saveCredentials;
  late final LoginUseCase login;
  late final SyncCollectionUseCase syncCollection;
  late final SyncPlaysUseCase _syncPlays;

  void initialize() {
    _secureStorage = const FlutterSecureStorage();
    _credentialStore = SecureCredentialStore(_secureStorage);
    _sessionStore = SecureSessionStore(_secureStorage);
    _bggApi = BggApiClient(sessionStore: _sessionStore);
    _appDatabase = AppDatabase();
    _collectionStore = DriftCollectionStore(_appDatabase);
    gameStore = DriftGameStore(_appDatabase);
    _playStore = DriftPlayStore(_appDatabase);
    _cardLayoutStore = SharedPreferencesCardLayoutStore();
    _collectionViewStore = SharedPreferencesCollectionViewStore();
    _themeStore = SharedPreferencesThemeStore();
    _thumbnailCache = FileThumbnailCache();

    loadCollection = LoadCollectionUseCase(_collectionStore);
    loadGameDetails = LoadGameDetailsUseCase(
      _collectionStore,
      gameStore,
      _thumbnailCache,
    );
    loadCardLayout = LoadCardLayoutUseCase(_cardLayoutStore);
    saveCardLayout = SaveCardLayoutUseCase(_cardLayoutStore);
    loadCollectionView = LoadCollectionViewUseCase(_collectionViewStore);
    saveCollectionView = SaveCollectionViewUseCase(_collectionViewStore);
    loadThemeConfig = LoadThemeConfigUseCase(_themeStore);
    saveThemeConfig = SaveThemeConfigUseCase(_themeStore);
    loadCredentials = LoadCredentialsUseCase(_credentialStore);
    saveCredentials = SaveCredentialsUseCase(_credentialStore);
    login = LoginUseCase(_credentialStore, _sessionStore, _bggApi);
    _syncPlays = SyncPlaysUseCase(_credentialStore, _bggApi, _playStore);
    syncCollection = SyncCollectionUseCase(
      _credentialStore,
      _sessionStore,
      _bggApi,
      _collectionStore,
      gameStore,
      _thumbnailCache,
      syncPlays: _syncPlays,
    );
  }
}
