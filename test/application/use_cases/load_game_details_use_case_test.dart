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

    test('returns details with board game and cached image', () async {
      const collectionItem = CollectionItem(
        thingId: 1,
        collId: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        imageUrl: 'https://example.com/image.png',
      );
      const boardGame = BoardGame(
        id: 1,
        names: [LocalizedName(value: 'Catan', language: null, isPrimary: true)],
        imageUrl: 'https://example.com/full.png',
        description: 'A classic game.',
      );

      when(
        () => collectionStore.loadById(1, 1),
      ).thenAnswer((_) async => collectionItem);
      when(() => gameStore.loadByIds([1])).thenAnswer((_) async => [boardGame]);
      when(
        () => imageCache.cache('https://example.com/full.png'),
      ).thenAnswer((_) async => '/cache/full.png');

      final result = await useCase(1, 1);

      expect(result, isNotNull);
      expect(result!.collectionItem, collectionItem);
      expect(result.boardGame, boardGame);
      expect(result.localImagePath, '/cache/full.png');
    });

    test(
      'falls back to collection item image when board game has none',
      () async {
        const collectionItem = CollectionItem(
          thingId: 1,
          collId: 1,
          names: [
            LocalizedName(value: 'Catan', language: null, isPrimary: true),
          ],
          imageUrl: 'https://example.com/image.png',
        );

        when(
          () => collectionStore.loadById(1, 1),
        ).thenAnswer((_) async => collectionItem);
        when(() => gameStore.loadByIds([1])).thenAnswer((_) async => []);
        when(
          () => imageCache.cache('https://example.com/image.png'),
        ).thenAnswer((_) async => '/cache/image.png');

        final result = await useCase(1, 1);

        expect(result!.localImagePath, '/cache/image.png');
      },
    );
  });
}
