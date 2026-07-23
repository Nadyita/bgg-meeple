import '../../../domain/entities/collection_item.dart';
import '../../../domain/value_objects/collection_filter.dart';
import '../../../domain/value_objects/collection_sort.dart';

/// Events for [CollectionBloc].
sealed class CollectionEvent {
  const CollectionEvent();
}

/// Loads the locally cached collection.
class CollectionLoaded extends CollectionEvent {
  const CollectionLoaded();
}

/// Filters the visible collection by search text.
class CollectionSearchTextChanged extends CollectionEvent {
  const CollectionSearchTextChanged(this.searchText);

  final String searchText;
}

/// Updates the active collection filter criteria.
class CollectionFilterChanged extends CollectionEvent {
  const CollectionFilterChanged(this.filter);

  final CollectionFilter filter;
}

/// Updates the collection sort order.
class CollectionSortChanged extends CollectionEvent {
  const CollectionSortChanged(this.sort);

  final CollectionSort sort;
}

/// Replaces the displayed collection after a successful sync.
class CollectionSynced extends CollectionEvent {
  const CollectionSynced(this.items);

  final List<CollectionItem> items;
}

/// Reloads the card layout configuration without fetching collection data.
class CollectionCardLayoutReloaded extends CollectionEvent {
  const CollectionCardLayoutReloaded();
}

/// Triggers a BGG sync and reloads the cached collection afterwards.
class CollectionSyncRequested extends CollectionEvent {
  const CollectionSyncRequested();
}

/// Toggles the compact (table-only-name) view mode.
class CollectionCompactModeToggled extends CollectionEvent {
  const CollectionCompactModeToggled();
}

/// Clears the search query without touching filters or sort order.
class CollectionSearchCleared extends CollectionEvent {
  const CollectionSearchCleared();
}

/// Resets all filter criteria to their defaults without touching search or sort.
class CollectionFilterCleared extends CollectionEvent {
  const CollectionFilterCleared();
}

/// Clears search text, filters, and sort order back to their defaults.
class CollectionViewCleared extends CollectionEvent {
  const CollectionViewCleared();
}
