import '../../domain/entities/collection_item.dart';
import '../../domain/ports/collection_store.dart';

/// Loads the cached BGG collection from local storage.
class LoadCollectionUseCase {
  const LoadCollectionUseCase(this._collectionStore);

  final CollectionStore _collectionStore;

  Future<List<CollectionItem>> call() async {
    return _collectionStore.loadAll();
  }
}
