import '../value_objects/collection_view.dart';

/// Port for persisting the user's collection view state.
///
/// Stores search text, active filters, and sort order so the collection screen
/// can restore its last view across app restarts.
abstract class CollectionViewStore {
  Future<CollectionView> load();
  Future<void> save(CollectionView view);
}
