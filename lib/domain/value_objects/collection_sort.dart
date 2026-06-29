import 'package:equatable/equatable.dart';

/// Criterion by which the collection list can be sorted.
enum SortBy { name, playTime, bggRating, year }

/// Sort order for the collection list.
class CollectionSort extends Equatable {
  const CollectionSort({this.sortBy = SortBy.name, this.ascending = true});

  final SortBy sortBy;
  final bool ascending;

  CollectionSort copyWith({SortBy? sortBy, bool? ascending}) {
    return CollectionSort(
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Serializes the sort order to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {'sortBy': sortBy.name, 'ascending': ascending};
  }

  /// Deserializes a sort order from JSON.
  ///
  /// Unknown [SortBy] names fall back to [SortBy.name] and a missing ascending
  /// flag defaults to `true` so a corrupt stored config remains usable.
  factory CollectionSort.fromJson(Map<String, dynamic> json) {
    final sortByName = json['sortBy'] as String?;
    final sortBy = SortBy.values.firstWhere(
      (s) => s.name == sortByName,
      orElse: () => SortBy.name,
    );
    return CollectionSort(
      sortBy: sortBy,
      ascending: json['ascending'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [sortBy, ascending];
}
