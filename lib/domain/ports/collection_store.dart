import '../entities/collection_item.dart';

/// Port for persisting and querying the user's BGG collection locally.
abstract class CollectionStore {
  /// Replaces the locally cached collection with [items].
  Future<void> saveAll(List<CollectionItem> items);

  /// Returns all cached collection items.
  Future<List<CollectionItem>> loadAll();

  /// Deletes all cached collection items.
  Future<void> clear();
}
