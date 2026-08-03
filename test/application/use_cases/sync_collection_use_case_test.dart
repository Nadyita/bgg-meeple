import 'package:bgg_meeple/application/use_cases/sync_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/bgg_credentials.dart';
import 'package:bgg_meeple/domain/entities/bgg_session.dart';
import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/ports/bgg_api.dart';
import 'package:bgg_meeple/domain/ports/collection_store.dart';
import 'package:bgg_meeple/domain/ports/credential_store.dart';
import 'package:bgg_meeple/domain/ports/game_store.dart';
import 'package:bgg_meeple/domain/ports/session_store.dart';
import 'package:bgg_meeple/domain/ports/thumbnail_cache.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:bgg_meeple/infrastructure/adapters/api/bgg_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCredentialStore extends Mock implements CredentialStore {}

class _MockSessionStore extends Mock implements SessionStore {}

class _MockBggApi extends Mock implements BggApi {}

class _MockCollectionStore extends Mock implements CollectionStore {}

class _MockGameStore extends Mock implements GameStore {}

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
    late GameStore gameStore;
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
      gameStore = _MockGameStore();
      thumbnailCache = _MockThumbnailCache();
      useCase = SyncCollectionUseCase(
        credentialStore,
        sessionStore,
        bggApi,
        collectionStore,
        gameStore,
        thumbnailCache,
      );

      when(() => bggApi.fetchGames(any())).thenAnswer((_) async => []);
      when(() => gameStore.saveAll(any())).thenAnswer((_) async {});
      when(() => gameStore.loadByIds(any())).thenAnswer((_) async => []);
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

    test('skips /thing fetch when no API token is configured', () async {
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

      await useCase();

      verifyNever(() => bggApi.fetchGames(any()));
    });

    test('fetches /thing only for games missing details', () async {
      const credentialsWithToken = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
        apiToken: 'api-token',
      );
      final items = <CollectionItem>[
        const CollectionItem(thingId: 1, names: []),
        const CollectionItem(thingId: 2, names: []),
        const CollectionItem(thingId: 3, names: []),
      ];
      final cachedGames = [
        const BoardGame(
          id: 1,
          names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
          description: 'Already have this.',
          detailsUpdatedAt: 123456789,
          bestPlayerCountMin: 2,
          bestPlayerCountMax: 4,
          recommendedPlayerCountMin: 2,
          recommendedPlayerCountMax: 4,
        ),
        const BoardGame(
          id: 2,
          names: [LocalizedName(value: 'B', language: null, isPrimary: true)],
          description: 'Missing range fields.',
        ),
      ];
      final fetchedGames = [
        const BoardGame(
          id: 3,
          names: [LocalizedName(value: 'C', language: null, isPrimary: true)],
          description: 'Fetched from /thing.',
        ),
      ];

      when(credentialStore.load).thenAnswer((_) async => credentialsWithToken);
      when(sessionStore.load).thenAnswer((_) async => session);
      when(
        () => bggApi.fetchCollection('meepleUser'),
      ).thenAnswer((_) async => items);
      when(
        () => gameStore.loadByIds([1, 2, 3]),
      ).thenAnswer((_) async => cachedGames);
      when(
        () => bggApi.fetchGames([2, 3]),
      ).thenAnswer((_) async => fetchedGames);
      when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
      when(() => gameStore.saveAll(any())).thenAnswer((_) async {});
      when(() => thumbnailCache.cache(any())).thenAnswer((_) async => null);

      await useCase();

      verify(() => bggApi.fetchGames([2, 3])).called(1);
      verifyNever(() => bggApi.fetchGames([1]));
    });

    test('sets detailsUpdatedAt when /thing games are fetched', () async {
      const credentialsWithToken = BggCredentials(
        username: 'meepleUser',
        password: 'secret',
        apiToken: 'api-token',
      );
      final items = <CollectionItem>[
        const CollectionItem(thingId: 1, names: []),
      ];
      final fetchedGames = [
        const BoardGame(
          id: 1,
          names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
          description: 'Fetched from /thing.',
        ),
      ];

      when(credentialStore.load).thenAnswer((_) async => credentialsWithToken);
      when(sessionStore.load).thenAnswer((_) async => session);
      when(
        () => bggApi.fetchCollection('meepleUser'),
      ).thenAnswer((_) async => items);
      when(() => gameStore.loadByIds([1])).thenAnswer((_) async => []);
      when(() => bggApi.fetchGames([1])).thenAnswer((_) async => fetchedGames);
      when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
      when(() => gameStore.saveAll(any())).thenAnswer((_) async {});
      when(() => thumbnailCache.cache(any())).thenAnswer((_) async => null);

      await useCase();

      final captured =
          verify(() => gameStore.saveAll(captureAny())).captured.single
              as List<BoardGame>;
      expect(captured.length, 1);
      expect(captured.first.detailsUpdatedAt, isNotNull);
    });

    test(
      'copies best and recommended player counts to collection items',
      () async {
        const credentialsWithToken = BggCredentials(
          username: 'meepleUser',
          password: 'secret',
          apiToken: 'api-token',
        );
        final items = <CollectionItem>[
          const CollectionItem(thingId: 1, names: []),
          const CollectionItem(thingId: 2, names: []),
        ];
        final cachedGames = [
          const BoardGame(
            id: 1,
            names: [LocalizedName(value: 'A', language: null, isPrimary: true)],
            description: 'Already cached.',
            detailsUpdatedAt: 123456789,
            bestPlayerCount: '3',
            bestPlayerCountMin: 3,
            bestPlayerCountMax: 3,
            recommendedPlayerCount: '3 - 4',
            recommendedPlayerCountMin: 3,
            recommendedPlayerCountMax: 4,
          ),
        ];
        final fetchedGames = [
          const BoardGame(
            id: 2,
            names: [LocalizedName(value: 'B', language: null, isPrimary: true)],
            description: 'Fetched from /thing.',
            bestPlayerCount: '4',
            bestPlayerCountMin: 4,
            bestPlayerCountMax: 4,
            recommendedPlayerCount: '2 - 5',
            recommendedPlayerCountMin: 2,
            recommendedPlayerCountMax: 5,
          ),
        ];

        when(
          credentialStore.load,
        ).thenAnswer((_) async => credentialsWithToken);
        when(sessionStore.load).thenAnswer((_) async => session);
        when(
          () => bggApi.fetchCollection('meepleUser'),
        ).thenAnswer((_) async => items);
        when(
          () => gameStore.loadByIds([1, 2]),
        ).thenAnswer((_) async => cachedGames);
        when(
          () => bggApi.fetchGames([2]),
        ).thenAnswer((_) async => fetchedGames);
        when(() => collectionStore.saveAll(any())).thenAnswer((_) async {});
        when(() => gameStore.saveAll(any())).thenAnswer((_) async {});
        when(() => thumbnailCache.cache(any())).thenAnswer((_) async => null);

        await useCase();

        final captured =
            verify(() => collectionStore.saveAll(captureAny())).captured.first
                as List<CollectionItem>;
        expect(captured.length, 2);
        final first = captured.firstWhere((i) => i.thingId == 1);
        final second = captured.firstWhere((i) => i.thingId == 2);
        expect(first.bestPlayerCount, '3');
        expect(first.bestPlayerCountMin, 3);
        expect(first.bestPlayerCountMax, 3);
        expect(first.recommendedPlayerCount, '3 - 4');
        expect(first.recommendedPlayerCountMin, 3);
        expect(first.recommendedPlayerCountMax, 4);
        expect(second.bestPlayerCount, '4');
        expect(second.recommendedPlayerCount, '2 - 5');
      },
    );
  });
}
