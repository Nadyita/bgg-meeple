import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/ports/bgg_api.dart';
import 'package:bgg_meeple/domain/ports/collection_store.dart';
import 'package:bgg_meeple/domain/ports/credential_store.dart';
import 'package:bgg_meeple/domain/ports/session_store.dart';
import 'package:bgg_meeple/domain/ports/thumbnail_cache.dart';
import 'package:bgg_meeple/infrastructure/adapters/api/bgg_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCredentialStore extends Mock implements CredentialStore {}

class _MockSessionStore extends Mock implements SessionStore {}

class _MockBggApi extends Mock implements BggApi {}

class _MockCollectionStore extends Mock implements CollectionStore {}

class _MockThumbnailCache extends Mock implements ThumbnailCache {}

class _BggCredentialsFake extends Fake implements BggCredentials {}

class _BggSessionFake extends Fake implements BggSession {}

class _CollectionItemsFake extends Fake implements List<CollectionItem> {}

void main() {
  group('SyncCollectionUseCase', () {
    late CredentialStore credentialStore;
    late SessionStore sessionStore;
    late BggApi bggApi;
    late CollectionStore collectionStore;
    late ThumbnailCache thumbnailCache;
    late SyncCollectionUseCase useCase;

    setUpAll(() {
      registerFallbackValue(_BggCredentialsFake());
      registerFallbackValue(_BggSessionFake());
      registerFallbackValue(_CollectionItemsFake());
      registerFallbackValue(const CollectionItem(thingId: 1, names: []));
    });

    setUp(() {
      credentialStore = _MockCredentialStore();
      sessionStore = _MockSessionStore();
      bggApi = _MockBggApi();
      collectionStore = _MockCollectionStore();
      thumbnailCache = _MockThumbnailCache();
      useCase = SyncCollectionUseCase(
        credentialStore,
        sessionStore,
        bggApi,
        collectionStore,
        thumbnailCache,
      );
    });

    const credentials = BggCredentials(
      username: 'meepleUser',
      password: 'secret',
    );
    const session = BggSession(
      sessionCookies: 'bggusername=u; bggpassword=p; SessionID=s',
    );

    test('throws when no credentials are configured', () async {
      when(credentialStore.load).thenAnswer((_) async => null);

      expect(() => useCase(), throwsA(isA<StateError>()));
    });

    test('throws when credentials are invalid', () async {
      when(credentialStore.load).thenAnswer(
        (_) async => const BggCredentials(username: '', password: 'secret'),
      );

      expect(() => useCase(), throwsA(isA<StateError>()));
    });

    test('authenticates when no valid session exists', () async {
      final items = <CollectionItem>[
        const CollectionItem(thingId: 1, names: []),
      ];

      when(credentialStore.load).thenAnswer((_) async => credentials);
      when(sessionStore.load).thenAnswer((_) async => null);
      when(
        () => bggApi.authenticate(credentials),
      ).thenAnswer((_) async => session);
      when(() => sessionStore.save(any())).thenAnswer((_) async {});
      when(
        () => bggApi.fetchCollection('meepleUser'),
      ).thenAnswer((_) async => items);
      when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
      when(() => thumbnailCache.cache(any())).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result.items, items);
      verify(() => bggApi.authenticate(credentials)).called(1);
      verify(() => sessionStore.save(session)).called(1);
    });

    test('reuses existing valid session without re-authenticating', () async {
      final items = <CollectionItem>[
        const CollectionItem(thingId: 1, names: []),
      ];

      when(credentialStore.load).thenAnswer((_) async => credentials);
      when(sessionStore.load).thenAnswer((_) async => session);
      when(
        () => bggApi.fetchCollection('meepleUser'),
      ).thenAnswer((_) async => items);
      when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
      when(() => thumbnailCache.cache(any())).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result.items, items);
      verifyNever(() => bggApi.authenticate(any()));
      verifyNever(() => sessionStore.save(any()));
    });

    test('re-authenticates and retries when session expired (401)', () async {
      final items = <CollectionItem>[
        const CollectionItem(thingId: 1, names: []),
      ];
      var fetchCallCount = 0;

      when(credentialStore.load).thenAnswer((_) async => credentials);
      when(sessionStore.load).thenAnswer((_) async => session);
      when(() => bggApi.fetchCollection('meepleUser')).thenAnswer((_) async {
        fetchCallCount++;
        if (fetchCallCount == 1) {
          throw const BggSessionExpiredException('expired');
        }
        return items;
      });
      when(() => sessionStore.delete()).thenAnswer((_) async {});
      when(
        () => bggApi.authenticate(credentials),
      ).thenAnswer((_) async => session);
      when(() => sessionStore.save(any())).thenAnswer((_) async {});
      when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
      when(() => thumbnailCache.cache(any())).thenAnswer((_) async => null);

      final result = await useCase();

      expect(result.items, items);
      expect(fetchCallCount, 2);
      verify(() => sessionStore.delete()).called(1);
      verify(() => bggApi.authenticate(credentials)).called(1);
      verify(() => sessionStore.save(session)).called(1);
    });

    test('caches thumbnails for fetched items', () async {
      final items = <CollectionItem>[
        const CollectionItem(
          thingId: 1,
          names: [],
          thumbnailUrl: 'https://example.com/thumb1.png',
        ),
        const CollectionItem(
          thingId: 2,
          names: [],
          thumbnailUrl: 'https://example.com/thumb2.png',
        ),
      ];
      final progressUpdates = <SyncProgress>[];

      when(credentialStore.load).thenAnswer((_) async => credentials);
      when(sessionStore.load).thenAnswer((_) async => session);
      when(
        () => bggApi.fetchCollection('meepleUser'),
      ).thenAnswer((_) async => items);
      when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
      when(
        () => thumbnailCache.cache(any()),
      ).thenAnswer((_) async => '/local/path.png');

      await useCase(onProgress: progressUpdates.add);

      verify(
        () => thumbnailCache.cache('https://example.com/thumb1.png'),
      ).called(1);
      verify(
        () => thumbnailCache.cache('https://example.com/thumb2.png'),
      ).called(1);
      verify(
        () => collectionStore.saveAll(
          any(
            that: isA<List<CollectionItem>>().having(
              (list) =>
                  list.every((i) => i.thumbnailLocalPath == '/local/path.png'),
              'all thumbnails cached',
              isTrue,
            ),
          ),
        ),
      ).called(2);
      expect(progressUpdates.any((p) => p.phase == 'thumbnails'), isTrue);
    });

    test('emits progress updates', () async {
      final items = <CollectionItem>[
        const CollectionItem(thingId: 1, names: []),
        const CollectionItem(thingId: 2, names: []),
      ];
      final progressUpdates = <SyncProgress>[];

      when(credentialStore.load).thenAnswer((_) async => credentials);
      when(sessionStore.load).thenAnswer((_) async => session);
      when(
        () => bggApi.fetchCollection('meepleUser'),
      ).thenAnswer((_) async => items);
      when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
      when(() => thumbnailCache.cache(any())).thenAnswer((_) async => null);

      await useCase(onProgress: progressUpdates.add);

      expect(progressUpdates.length, 3);
      expect(progressUpdates[0].phase, 'collection');
      expect(progressUpdates[0].loaded, 2);
      expect(progressUpdates[0].total, 2);
      expect(progressUpdates[1].phase, 'thumbnails');
      expect(progressUpdates[1].loaded, 1);
      expect(progressUpdates[1].total, 2);
      expect(progressUpdates[2].phase, 'thumbnails');
      expect(progressUpdates[2].loaded, 2);
      expect(progressUpdates[2].total, 2);
    });
  });
}
