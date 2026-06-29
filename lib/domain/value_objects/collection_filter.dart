import 'package:equatable/equatable.dart';

import 'collection_sub_type.dart';

/// Filter criteria for the collection list.
///
/// A `null` value means "no filter" for the corresponding criterion.
/// Sub-type filters use OR logic within the list and AND logic with all
/// other criteria.
class CollectionFilter extends Equatable {
  const CollectionFilter({
    this.selectedSubTypes = const [],
    this.minPlayers,
    this.maxPlayers,
    this.minPlayTime,
    this.maxPlayTime,
    this.minRating,
    this.maxRating,
  });

  final List<CollectionSubType> selectedSubTypes;
  final int? minPlayers;
  final int? maxPlayers;
  final int? minPlayTime;
  final int? maxPlayTime;
  final double? minRating;
  final double? maxRating;

  bool get isActive {
    return selectedSubTypes.isNotEmpty ||
        minPlayers != null ||
        maxPlayers != null ||
        minPlayTime != null ||
        maxPlayTime != null ||
        minRating != null ||
        maxRating != null;
  }

  CollectionFilter copyWith({
    List<CollectionSubType>? selectedSubTypes,
    int? minPlayers,
    int? maxPlayers,
    int? minPlayTime,
    int? maxPlayTime,
    double? minRating,
    double? maxRating,
    bool clearMinPlayers = false,
    bool clearMaxPlayers = false,
    bool clearMinPlayTime = false,
    bool clearMaxPlayTime = false,
    bool clearMinRating = false,
    bool clearMaxRating = false,
  }) {
    return CollectionFilter(
      selectedSubTypes: selectedSubTypes ?? this.selectedSubTypes,
      minPlayers: clearMinPlayers ? null : (minPlayers ?? this.minPlayers),
      maxPlayers: clearMaxPlayers ? null : (maxPlayers ?? this.maxPlayers),
      minPlayTime: clearMinPlayTime ? null : (minPlayTime ?? this.minPlayTime),
      maxPlayTime: clearMaxPlayTime ? null : (maxPlayTime ?? this.maxPlayTime),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      maxRating: clearMaxRating ? null : (maxRating ?? this.maxRating),
    );
  }

  /// Serializes the filter to a JSON-compatible map.
  ///
  /// Only non-default values are included to keep the stored payload small and
  /// stable. Missing keys are treated as "no filter" when deserializing.
  Map<String, dynamic> toJson() {
    return {
      'selectedSubTypes': selectedSubTypes.map((s) => s.name).toList(),
      if (minPlayers != null) 'minPlayers': minPlayers,
      if (maxPlayers != null) 'maxPlayers': maxPlayers,
      if (minPlayTime != null) 'minPlayTime': minPlayTime,
      if (maxPlayTime != null) 'maxPlayTime': maxPlayTime,
      if (minRating != null) 'minRating': minRating,
      if (maxRating != null) 'maxRating': maxRating,
    };
  }

  /// Deserializes a filter from JSON.
  ///
  /// Unknown [CollectionSubType] names and malformed optional values are ignored
  /// so a corrupt stored config cannot break the collection screen.
  factory CollectionFilter.fromJson(Map<String, dynamic> json) {
    final subTypeNames =
        (json['selectedSubTypes'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        [];
    final selectedSubTypes = CollectionSubType.values
        .where((s) => subTypeNames.contains(s.name))
        .toList();

    int? jsonInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return null;
    }

    double? jsonDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return null;
    }

    return CollectionFilter(
      selectedSubTypes: selectedSubTypes,
      minPlayers: jsonInt(json['minPlayers']),
      maxPlayers: jsonInt(json['maxPlayers']),
      minPlayTime: jsonInt(json['minPlayTime']),
      maxPlayTime: jsonInt(json['maxPlayTime']),
      minRating: jsonDouble(json['minRating']),
      maxRating: jsonDouble(json['maxRating']),
    );
  }

  @override
  List<Object?> get props => [
    selectedSubTypes,
    minPlayers,
    maxPlayers,
    minPlayTime,
    maxPlayTime,
    minRating,
    maxRating,
  ];
}
