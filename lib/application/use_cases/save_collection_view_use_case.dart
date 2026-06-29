import '../../domain/ports/collection_view_store.dart';
import '../../domain/value_objects/collection_view.dart';

/// Saves the user's collection view state.
class SaveCollectionViewUseCase {
  const SaveCollectionViewUseCase(this._store);

  final CollectionViewStore _store;

  Future<void> call(CollectionView view) => _store.save(view);
}
