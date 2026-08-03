import 'package:bgg_meeple/application/use_cases/load_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/board_game.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/ports/collection_store.dart';
import 'package:bgg_meeple/domain/ports/game_store.dart';
import 'package:bgg_meeple/domain/value_objects/localized_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCollectionStore extends Mock implements CollectionStore {}

class _MockGameStore extends Mock implements GameStore {}

class _BoardGameFake extends Fake implements BoardGame {}

void main() {
  group('LoadCollectionUseCase', () {
    late CollectionStore collectionStore;
    late GameStore gameStore;
    late LoadCollectionUseCase useCase;

    setUpAll(() {
      registerFallbackValue(_BoardGameFake());
    });

    setUp(() {
      collectionStore = _MockCollectionStore();
      gameStore = _MockGameStore();
      useCase = LoadCollectionUseCase(collectionStore, gameStore);
      when(() => gameStore.loadByIds(any())).thenAnswer((_) async => []);
    });

    test('returns all cached collection items', () async {
      const items = [
        CollectionItem(thingId: 1, names: []),
        CollectionItem(thingId: 2, names: []),
      ];
      when(collectionStore.loadAll).thenAnswer((_) async => items);

      final result = await useCase();

      expect(result, equals(items));
      verify(collectionStore.loadAll).called(1);
      verify(() => gameStore.loadByIds([1, 2])).called(1);
    });

    test('returns empty list when cache is empty', () async {
      when(collectionStore.loadAll).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
      verify(collectionStore.loadAll).called(1);
      verifyNever(() => gameStore.loadByIds(any()));
    });

    test('backfills missing player counts from cached board games', () async {
      const items = [
        CollectionItem(thingId: 1, names: [], minPlayers: 3, maxPlayers: 16),
        CollectionItem(
          thingId: 2,
          names: [],
          minPlayers: 1,
          maxPlayers: 4,
          recommendedPlayerCount: '2 - 3',
        ),
      ];
      final games = [
        const BoardGame(
          id: 1,
          names: [
            LocalizedName(value: 'Activity', language: null, isPrimary: true),
          ],
          recommendedPlayerCount: '4, 6-10, 12',
          recommendedPlayerCountMin: 4,
          recommendedPlayerCountMax: 12,
          bestPlayerCount: '6, 8',
          bestPlayerCountMin: 6,
          bestPlayerCountMax: 8,
        ),
      ];
      when(collectionStore.loadAll).thenAnswer((_) async => items);
      when(() => gameStore.loadByIds([1, 2])).thenAnswer((_) async => games);

      final result = await useCase();

      expect(result.length, 2);
      final first = result.firstWhere((i) => i.thingId == 1);
      expect(first.recommendedPlayerCount, '4, 6-10, 12');
      expect(first.bestPlayerCount, '6, 8');
      final second = result.firstWhere((i) => i.thingId == 2);
      expect(second.recommendedPlayerCount, '2 - 3');
      expect(second.bestPlayerCount, isNull);
    });
  });
}
