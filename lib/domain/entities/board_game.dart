import '../value_objects/game_link.dart';
import '../value_objects/localized_name.dart';

/// Represents the static details of a board game fetched from BGG.
class BoardGame {
  const BoardGame({
    required this.id,
    required this.names,
    this.imageUrl,
    this.thumbnailUrl,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.minPlayTime,
    this.maxPlayTime,
    this.playingTime,
    this.minAge,
    this.bayesAverage,
    this.averageRating,
    this.userCount,
    this.numOwned,
    this.numTrading,
    this.numWanting,
    this.numWishing,
    this.averageWeight,
    this.description,
    this.links = const [],
    this.languageDependenceLevel,
    this.bestPlayerCount,
    this.suggestedPlayerAge,
    this.recommendedPlayerCount,
    this.detailsUpdatedAt,
  });

  final int id;
  final List<LocalizedName> names;
  final String? imageUrl;
  final String? thumbnailUrl;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final int? minPlayTime;
  final int? maxPlayTime;
  final int? playingTime;
  final int? minAge;
  final double? bayesAverage;
  final double? averageRating;
  final int? userCount;
  final int? numOwned;
  final int? numTrading;
  final int? numWanting;
  final int? numWishing;
  final double? averageWeight;
  final String? description;
  final List<GameLink> links;
  final String? languageDependenceLevel;
  final String? bestPlayerCount;
  final String? suggestedPlayerAge;
  final String? recommendedPlayerCount;
  final int? detailsUpdatedAt;

  String displayName({required String preferredLanguage}) {
    if (names.isEmpty) return 'Unknown game';

    final localized = names.where(
      (name) =>
          name.language != null &&
          name.language!.toLowerCase() == preferredLanguage.toLowerCase() &&
          name.value.trim().isNotEmpty,
    );
    if (localized.isNotEmpty) {
      return localized.first.value.trim();
    }

    final primary = names.where(
      (name) => name.isPrimary && name.value.trim().isNotEmpty,
    );
    if (primary.isNotEmpty) {
      return primary.first.value.trim();
    }

    return names.first.value.trim();
  }

  BoardGame copyWith({
    int? id,
    List<LocalizedName>? names,
    String? imageUrl,
    String? thumbnailUrl,
    int? yearPublished,
    int? minPlayers,
    int? maxPlayers,
    int? minPlayTime,
    int? maxPlayTime,
    int? playingTime,
    int? minAge,
    double? bayesAverage,
    double? averageRating,
    int? userCount,
    int? numOwned,
    int? numTrading,
    int? numWanting,
    int? numWishing,
    double? averageWeight,
    String? description,
    List<GameLink>? links,
    String? languageDependenceLevel,
    String? bestPlayerCount,
    String? suggestedPlayerAge,
    String? recommendedPlayerCount,
    int? detailsUpdatedAt,
  }) {
    return BoardGame(
      id: id ?? this.id,
      names: names ?? this.names,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      yearPublished: yearPublished ?? this.yearPublished,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      minPlayTime: minPlayTime ?? this.minPlayTime,
      maxPlayTime: maxPlayTime ?? this.maxPlayTime,
      playingTime: playingTime ?? this.playingTime,
      minAge: minAge ?? this.minAge,
      bayesAverage: bayesAverage ?? this.bayesAverage,
      averageRating: averageRating ?? this.averageRating,
      userCount: userCount ?? this.userCount,
      numOwned: numOwned ?? this.numOwned,
      numTrading: numTrading ?? this.numTrading,
      numWanting: numWanting ?? this.numWanting,
      numWishing: numWishing ?? this.numWishing,
      averageWeight: averageWeight ?? this.averageWeight,
      description: description ?? this.description,
      links: links ?? this.links,
      languageDependenceLevel:
          languageDependenceLevel ?? this.languageDependenceLevel,
      bestPlayerCount: bestPlayerCount ?? this.bestPlayerCount,
      suggestedPlayerAge: suggestedPlayerAge ?? this.suggestedPlayerAge,
      recommendedPlayerCount:
          recommendedPlayerCount ?? this.recommendedPlayerCount,
      detailsUpdatedAt: detailsUpdatedAt ?? this.detailsUpdatedAt,
    );
  }

  @override
  String toString() {
    return 'BoardGame(id: $id, names: $names)';
  }
}
