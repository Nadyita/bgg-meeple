import 'package:equatable/equatable.dart';

import 'collection_sub_type.dart';
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
    );
  }

  static PlayerParticipationFilter? _parseParticipationFilter(dynamic value) {
    if (value is! String) return null;
    return PlayerParticipationFilter.values
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
  ];
}
