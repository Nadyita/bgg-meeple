import 'dart:async';

import 'package:bgg_meeple/application/use_cases/load_game_details_use_case.dart';
import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/ports/collection_store.dart';
import 'package:bgg_meeple/domain/ports/game_store.dart';
import 'package:bgg_meeple/domain/ports/thumbnail_cache.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCollectionStore extends Mock implements CollectionStore {}

class _MockGameStore extends Mock implements GameStore {}

class _MockThumbnailCache extends Mock implements ThumbnailCache {}

void main() {
  group('LoadGameDetailsUseCase', () {
    late CollectionStore collectionStore;
    late GameStore gameStore;
    late ThumbnailCache imageCache;
    late LoadGameDetailsUseCase useCase;

    setUp(() {
      collectionStore = _MockCollectionStore();
      gameStore = _MockGameStore();
      imageCache = _MockThumbnailCache();
      useCase = LoadGameDetailsUseCase(collectionStore, gameStore, imageCache);
    });

    test('returns null when collection item is not found', () async {
      when(() => collectionStore.loadById(1, 1)).thenAnswer((_) async => null);

      final result = await useCase(1, 1);

      expect(result, isNull);
    });

    test(
      'returns details with collection image preferred over board game image',
      () async {
        const collectionItem = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          imageUrl: 'https://example.com/collection.png',
        );
        const boardGame = BoardGame(
          id: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          imageUrl: 'https://example.com/thing.png',
          description: 'A classic game.',
        );

        when(
          () => collectionStore.loadById(1, 1),
        ).thenAnswer((_) async => collectionItem);
        when(
          () => gameStore.loadByIds([1]),
        ).thenAnswer((_) async => [boardGame]);
        when(
          () => imageCache.cache('https://example.com/collection.png'),
        ).thenAnswer((_) async => '/cache/collection.png');

        final result = await useCase(1, 1);

        expect(result, isNotNull);
        expect(result!.collectionItem, collectionItem);
        expect(result.boardGame, boardGame);
        expect(result.imageUrl, 'https://example.com/collection.png');
        expect(result.localImagePath, '/cache/collection.png');
      },
    );

    test(
      'falls back to board game image when collection item has none',
      () async {
        const collectionItem = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
        );
        const boardGame = BoardGame(
          id: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          imageUrl: 'https://example.com/thing.png',
          description: 'A classic game.',
        );

        when(
          () => collectionStore.loadById(1, 1),
        ).thenAnswer((_) async => collectionItem);
        when(
          () => gameStore.loadByIds([1]),
        ).thenAnswer((_) async => [boardGame]);
        when(
          () => imageCache.cache('https://example.com/thing.png'),
        ).thenAnswer((_) async => '/cache/thing.png');

        final result = await useCase(1, 1);

        expect(result, isNotNull);
        expect(result!.imageUrl, 'https://example.com/thing.png');
        expect(result.localImagePath, '/cache/thing.png');
      },
    );

    test(
      'returns details without full image when no image is available',
      () async {
        const collectionItem = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          thumbnailUrl: 'https://example.com/thumb.png',
        );

        when(
          () => collectionStore.loadById(1, 1),
        ).thenAnswer((_) async => collectionItem);
        when(() => gameStore.loadByIds([1])).thenAnswer((_) async => []);
        when(() => imageCache.cache(null)).thenAnswer((_) async => null);

        final result = await useCase(1, 1);

        expect(result, isNotNull);
        expect(result!.imageUrl, isNull);
        expect(result.localImagePath, isNull);
        expect(
          result.collectionItem.thumbnailUrl,
          'https://example.com/thumb.png',
        );
      },
    );

    test(
      'triggers background refresh when details are stale and token is present',
      () async {
        const collectionItem = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
        );
        final boardGame = BoardGame(
          id: 1,
          names: const [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          detailsUpdatedAt: DateTime(2020).millisecondsSinceEpoch,
        );

        when(
          () => collectionStore.loadById(1, 1),
        ).thenAnswer((_) async => collectionItem);
        when(
          () => gameStore.loadByIds([1]),
        ).thenAnswer((_) async => [boardGame]);
        when(() => imageCache.cache(null)).thenAnswer((_) async => null);

        final completer = Completer<void>();
        var refreshedId = -1;
        final useCase = LoadGameDetailsUseCase(
          collectionStore,
          gameStore,
          imageCache,
          refreshDetails: (id) async {
            refreshedId = id;
            completer.complete();
          },
          hasApiToken: () async => true,
          now: () => DateTime(2020, 2).millisecondsSinceEpoch,
        );

        final result = await useCase(1, 1);

        expect(result, isNotNull);
        await completer.future;
        expect(refreshedId, 1);
      },
    );

    test('does not refresh when details are recent', () async {
      const collectionItem = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );
      final boardGame = BoardGame(
        id: 1,
        names: const [
          LocalizedName(value: 'Catan', language: null, isPrimary: true),
        ],
        detailsUpdatedAt: DateTime(2020, 1, 15).millisecondsSinceEpoch,
      );

      when(
        () => collectionStore.loadById(1, 1),
      ).thenAnswer((_) async => collectionItem);
      when(() => gameStore.loadByIds([1])).thenAnswer((_) async => [boardGame]);
      when(() => imageCache.cache(null)).thenAnswer((_) async => null);

      var refreshed = false;
      final useCase = LoadGameDetailsUseCase(
        collectionStore,
        gameStore,
        imageCache,
        refreshDetails: (_) async {
          refreshed = true;
        },
        hasApiToken: () async => true,
        now: () => DateTime(2020, 2).millisecondsSinceEpoch,
      );

      await useCase(1, 1);

      expect(refreshed, isFalse);
    });

    test('does not refresh without API token', () async {
      const collectionItem = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
      );

      when(
        () => collectionStore.loadById(1, 1),
      ).thenAnswer((_) async => collectionItem);
      when(() => gameStore.loadByIds([1])).thenAnswer((_) async => []);
      when(() => imageCache.cache(null)).thenAnswer((_) async => null);

      var refreshed = false;
      final useCase = LoadGameDetailsUseCase(
        collectionStore,
        gameStore,
        imageCache,
        refreshDetails: (_) async {
          refreshed = true;
        },
        hasApiToken: () async => false,
      );

      await useCase(1, 1);

      expect(refreshed, isFalse);
    });
  });
}
