import 'package:bgg_meeple/application/use_cases/load_collection_view_use_case.dart';
import 'package:bgg_meeple/application/use_cases/save_collection_view_use_case.dart';
import 'package:bgg_meeple/domain/ports/collection_view_store.dart';
import 'package:bgg_meeple/domain/value_objects/collection_filter.dart';
import 'package:bgg_meeple/domain/value_objects/collection_sort.dart';
import 'package:bgg_meeple/domain/value_objects/collection_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCollectionViewStore extends Mock implements CollectionViewStore {}

void main() {
  group('LoadCollectionViewUseCase', () {
    late CollectionViewStore store;
    late LoadCollectionViewUseCase useCase;

    setUp(() {
      store = _MockCollectionViewStore();
      useCase = LoadCollectionViewUseCase(store);
    });

    test('returns view from store', () async {
      const view = CollectionView(
        searchText: 'car',
        sort: CollectionSort(sortBy: SortBy.playTime, ascending: false),
      );
      when(store.load).thenAnswer((_) async => view);

      final result = await useCase();

      expect(result, view);
      verify(store.load).called(1);
    });
  });

  group('SaveCollectionViewUseCase', () {
    late CollectionViewStore store;
    late SaveCollectionViewUseCase useCase;

    setUp(() {
      store = _MockCollectionViewStore();
      useCase = SaveCollectionViewUseCase(store);
    });

    test('saves view to store', () async {
      const view = CollectionView(
        searchText: 'catan',
        filter: CollectionFilter(minPlayers: 2),
      );
      when(() => store.save(view)).thenAnswer((_) async {});

      await useCase(view);

      verify(() => store.save(view)).called(1);
    });
  });
}
