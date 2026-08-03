import 'package:equatable/equatable.dart';

import 'collection_sub_type.dart';
import 'inventory_location_filter.dart';
import 'player_participation_filter.dart';

/// Filter criteria for the collection list.
///
/// A `null` value means "no filter" for the corresponding criterion.
/// Sub-type filters use OR logic within the list and AND logic with all
/// other criteria. Player participation filters use AND logic with each
/// other and with all other criteria.
class CollectionFilter extends Equatable {
  const CollectionFilter({
    this.selectedSubTypes = const [],
    this.minPlayers,
    this.maxPlayers,
    this.minPlayTime,
    this.maxPlayTime,
    this.minRating,
    this.maxRating,
    this.minPlays,
    this.maxPlays,
    this.playerParticipation = const {},
    this.inventoryLocationFilters = const {},
  });

  final List<CollectionSubType> selectedSubTypes;
  final int? minPlayers;
  final int? maxPlayers;
  final int? minPlayTime;
  final int? maxPlayTime;
  final double? minRating;
  final double? maxRating;
  final int? minPlays;
  final int? maxPlays;

  /// Per-player participation filter.
  ///
  /// The key is the player display name. A missing player means the player's
  /// participation is irrelevant. Only non-[PlayerParticipationFilter.any]
  /// entries affect filtering.
  final Map<String, PlayerParticipationFilter> playerParticipation;

  /// Per-location inventory filter.
  ///
  /// The key is the location name. [InventoryLocationFilter.any] means the
  /// location does not affect the result. [InventoryLocationFilter.matches]
  /// keeps only games stored at that location. [InventoryLocationFilter.excludes]
  /// hides games stored at that location. Multiple `matches` locations are
  /// combined with OR logic; multiple `excludes` locations are combined with
  /// AND logic.
  final Map<String, InventoryLocationFilter> inventoryLocationFilters;

  bool get isActive {
    return selectedSubTypes.isNotEmpty ||
        minPlayers != null ||
        maxPlayers != null ||
        minPlayTime != null ||
        maxPlayTime != null ||
        minRating != null ||
        maxRating != null ||
        minPlays != null ||
        maxPlays != null ||
        playerParticipation.values.any(
          (v) => v != PlayerParticipationFilter.any,
        ) ||
        inventoryLocationFilters.values.any(
          (v) => v != InventoryLocationFilter.any,
        );
  }

  CollectionFilter copyWith({
    List<CollectionSubType>? selectedSubTypes,
    int? minPlayers,
    int? maxPlayers,
    int? minPlayTime,
    int? maxPlayTime,
    double? minRating,
    double? maxRating,
    int? minPlays,
    int? maxPlays,
    Map<String, PlayerParticipationFilter>? playerParticipation,
    Map<String, InventoryLocationFilter>? inventoryLocationFilters,
    bool clearMinPlayers = false,
    bool clearMaxPlayers = false,
    bool clearMinPlayTime = false,
    bool clearMaxPlayTime = false,
    bool clearMinRating = false,
    bool clearMaxRating = false,
    bool clearMinPlays = false,
    bool clearMaxPlays = false,
  }) {
    return CollectionFilter(
      selectedSubTypes: selectedSubTypes ?? this.selectedSubTypes,
      minPlayers: clearMinPlayers ? null : (minPlayers ?? this.minPlayers),
      maxPlayers: clearMaxPlayers ? null : (maxPlayers ?? this.maxPlayers),
      minPlayTime: clearMinPlayTime ? null : (minPlayTime ?? this.minPlayTime),
      maxPlayTime: clearMaxPlayTime ? null : (maxPlayTime ?? this.maxPlayTime),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      maxRating: clearMaxRating ? null : (maxRating ?? this.maxRating),
      minPlays: clearMinPlays ? null : (minPlays ?? this.minPlays),
      maxPlays: clearMaxPlays ? null : (maxPlays ?? this.maxPlays),
      playerParticipation: playerParticipation ?? this.playerParticipation,
      inventoryLocationFilters:
          inventoryLocationFilters ?? this.inventoryLocationFilters,
    );
  }

  /// Returns a copy with every known player set to [PlayerParticipationFilter.any]
  /// and every player not present in [availablePlayers] removed.
  CollectionFilter clearPlayerFilters(Set<String> availablePlayers) {
    final cleaned = <String, PlayerParticipationFilter>{};
    for (final entry in playerParticipation.entries) {
      if (availablePlayers.contains(entry.key.toLowerCase())) {
        cleaned[entry.key] = PlayerParticipationFilter.any;
      }
    }
    return copyWith(playerParticipation: cleaned);
  }

  /// Returns a copy with every known location kept at its current state and
  /// every location not present in [availableLocations] removed.
  CollectionFilter removeObsoleteInventoryLocationFilters(
    Set<String> availableLocations,
  ) {
    final cleaned = <String, InventoryLocationFilter>{};
    for (final entry in inventoryLocationFilters.entries) {
      if (availableLocations.contains(entry.key)) {
        cleaned[entry.key] = entry.value;
      }
    }
    return copyWith(inventoryLocationFilters: cleaned);
  }

  /// Returns a copy with all inventory-location filter values set to [any]
  /// while keeping every added location.
  CollectionFilter resetInventoryLocationFilters() {
    return copyWith(
      inventoryLocationFilters: {
        for (final key in inventoryLocationFilters.keys)
          key: InventoryLocationFilter.any,
      },
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
      if (minPlays != null) 'minPlays': minPlays,
      if (maxPlays != null) 'maxPlays': maxPlays,
      if (playerParticipation.isNotEmpty)
        'playerParticipation': {
          for (final entry in playerParticipation.entries)
            entry.key: entry.value.name,
        },
      if (inventoryLocationFilters.isNotEmpty)
        'inventoryLocationFilters': {
          for (final entry in inventoryLocationFilters.entries)
            entry.key: entry.value.name,
        },
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

    final participationJson = json['playerParticipation'];
    final Map<String, PlayerParticipationFilter> playerParticipation;
    if (participationJson is Map<String, dynamic>) {
      playerParticipation = {
        for (final entry in participationJson.entries)
          if (_parseParticipationFilter(entry.value) != null)
            entry.key: _parseParticipationFilter(entry.value)!,
      };
    } else {
      playerParticipation = const {};
    }

    final locationFiltersJson = json['inventoryLocationFilters'];
    final Map<String, InventoryLocationFilter> inventoryLocationFilters;
    if (locationFiltersJson is Map<String, dynamic>) {
      inventoryLocationFilters = {
        for (final entry in locationFiltersJson.entries)
          if (_parseInventoryLocationFilter(entry.value) != null)
            entry.key: _parseInventoryLocationFilter(entry.value)!,
      };
    } else {
      inventoryLocationFilters = const {};
    }

    return CollectionFilter(
      selectedSubTypes: selectedSubTypes,
      minPlayers: jsonInt(json['minPlayers']),
      maxPlayers: jsonInt(json['maxPlayers']),
      minPlayTime: jsonInt(json['minPlayTime']),
      maxPlayTime: jsonInt(json['maxPlayTime']),
      minRating: jsonDouble(json['minRating']),
      maxRating: jsonDouble(json['maxRating']),
      minPlays: jsonInt(json['minPlays']),
      maxPlays: jsonInt(json['maxPlays']),
      playerParticipation: playerParticipation,
      inventoryLocationFilters: inventoryLocationFilters,
    );
  }

  static PlayerParticipationFilter? _parseParticipationFilter(dynamic value) {
    if (value is! String) return null;
    return PlayerParticipationFilter.values
        .where((e) => e.name == value)
        .firstOrNull;
  }

  static InventoryLocationFilter? _parseInventoryLocationFilter(dynamic value) {
    if (value is! String) return null;
    return InventoryLocationFilter.values
        .where((e) => e.name == value)
        .firstOrNull;
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
    minPlays,
    maxPlays,
    playerParticipation,
    inventoryLocationFilters,
  ];
}
