import '../../domain/ports/collection_view_store.dart';
import '../../domain/value_objects/collection_view.dart';

/// Loads the user's persisted collection view state.
class LoadCollectionViewUseCase {
  const LoadCollectionViewUseCase(this._store);

  final CollectionViewStore _store;

  Future<CollectionView> call() => _store.load();
}
