import 'package:equatable/equatable.dart';

import 'collection_filter.dart';
import 'collection_sort.dart';

/// Persisted user view state for the collection list.
///
/// This is the only device-local state that is restored across app restarts.
/// It intentionally does not include the collection items themselves; BGG
/// remains the authoritative source for game data (see NF05 / NF08).
class CollectionView extends Equatable {
  const CollectionView({
    this.searchText = '',
    this.filter = const CollectionFilter(),
    this.sort = const CollectionSort(),
  });

  final String searchText;
  final CollectionFilter filter;
  final CollectionSort sort;

  CollectionView copyWith({
    String? searchText,
    CollectionFilter? filter,
    CollectionSort? sort,
  }) {
    return CollectionView(
      searchText: searchText ?? this.searchText,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }

  /// Serializes the view state to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'searchText': searchText,
      'filter': filter.toJson(),
      'sort': sort.toJson(),
    };
  }

  /// Deserializes a view state from JSON.
  ///
  /// Missing or malformed nested objects fall back to their default values so a
  /// corrupt stored config cannot break the collection screen.
  factory CollectionView.fromJson(Map<String, dynamic> json) {
    CollectionFilter filter = const CollectionFilter();
    final filterJson = json['filter'];
    if (filterJson is Map<String, dynamic>) {
      filter = CollectionFilter.fromJson(filterJson);
    }

    CollectionSort sort = const CollectionSort();
    final sortJson = json['sort'];
    if (sortJson is Map<String, dynamic>) {
      sort = CollectionSort.fromJson(sortJson);
    }

    return CollectionView(
      searchText: json['searchText'] as String? ?? '',
      filter: filter,
      sort: sort,
    );
  }

  @override
  List<Object?> get props => [searchText, filter, sort];
}
