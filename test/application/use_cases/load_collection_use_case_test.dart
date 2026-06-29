import 'package:bgg_meeple/application/use_cases/load_collection_use_case.dart';
import 'package:bgg_meeple/domain/entities/collection_item.dart';
import 'package:bgg_meeple/domain/ports/collection_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCollectionStore extends Mock implements CollectionStore {}

void main() {
  group('LoadCollectionUseCase', () {
    late CollectionStore collectionStore;
    late LoadCollectionUseCase useCase;

    setUp(() {
      collectionStore = _MockCollectionStore();
      useCase = LoadCollectionUseCase(collectionStore);
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
    });

    test('returns empty list when cache is empty', () async {
      when(collectionStore.loadAll).thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
      verify(collectionStore.loadAll).called(1);
    });
  });
}
