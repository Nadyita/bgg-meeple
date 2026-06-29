import '../value_objects/localized_name.dart';
import '../value_objects/version_info.dart';

/// Represents a single entry in the user's BGG collection.
class CollectionItem {
  const CollectionItem({
    required this.thingId,
    this.collId,
    this.version,
    this.customName,
    this.customImageUrl,
    required this.names,
    this.thumbnailUrl,
    this.thumbnailLocalPath,
    this.imageUrl,
    this.yearPublished,
    this.minPlayers,
    this.maxPlayers,
    this.minPlayTime,
    this.maxPlayTime,
    this.minAge,
    this.bayesAverage,
    this.geekRatingUserCount,
    this.ownRating,
    this.numPlays,
    this.bggRank,
    this.isOwned = false,
    this.isPreordered = false,
    this.isWishlisted = false,
    this.isWantToPlay = false,
    this.isWantToBuy = false,
    this.isPrevOwned = false,
    this.isPlayed = false,
    this.isRated = false,
    this.isForTrade = false,
    this.isWantInTrade = false,
    this.hasComment = false,
  });

  final int thingId;
  final int? collId;
  final VersionInfo? version;
  final String? customName;
  final String? customImageUrl;
  final List<LocalizedName> names;
  final String? thumbnailUrl;
  final String? thumbnailLocalPath;
  final String? imageUrl;
  final int? yearPublished;
  final int? minPlayers;
  final int? maxPlayers;
  final int? minPlayTime;
  final int? maxPlayTime;
  final int? minAge;
  final double? bayesAverage;
  final int? geekRatingUserCount;
  final double? ownRating;
  final int? numPlays;
  final int? bggRank;
  final bool isOwned;
  final bool isPreordered;
  final bool isWishlisted;
  final bool isWantToPlay;
  final bool isWantToBuy;
  final bool isPrevOwned;
  final bool isPlayed;
  final bool isRated;
  final bool isForTrade;
  final bool isWantInTrade;
  final bool hasComment;

  /// Returns the effective display name for this collection item.
  ///
  /// Priority:
  /// 1. Custom name set by the user in their BGG collection.
  /// 2. Localized name matching the preferred language.
  /// 3. Primary name from BGG.
  /// 4. First available name from BGG.
  /// 5. Fallback "Unknown game".
  ///
  /// The selected BGG version name is intentionally not used here: it
  /// describes the edition (e.g. "German first edition"), it is not the
  /// game's title.
  String displayName({required String preferredLanguage}) {
    if (customName != null && customName!.trim().isNotEmpty) {
      return customName!.trim();
    }

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

    if (names.isNotEmpty && names.first.value.trim().isNotEmpty) {
      return names.first.value.trim();
    }

    return 'Unknown game';
  }

  /// Returns the effective display year.
  ///
  /// Priority:
  /// 1. Year of the selected version (shown in the edition subtitle).
  /// 2. `yearPublished` from the base game.
  /// 3. `null`.
  ///
  /// If the version already has a year, the title line must not repeat it.
  int? displayYear() {
    if (version?.year != null) {
      return null;
    }
    return yearPublished;
  }

  CollectionItem copyWith({
    int? thingId,
    int? collId,
    VersionInfo? version,
    String? customName,
    String? customImageUrl,
    List<LocalizedName>? names,
    String? thumbnailUrl,
    String? thumbnailLocalPath,
    String? imageUrl,
    int? yearPublished,
    int? minPlayers,
    int? maxPlayers,
    int? minPlayTime,
    int? maxPlayTime,
    int? minAge,
    double? bayesAverage,
    int? geekRatingUserCount,
    double? ownRating,
    int? numPlays,
    int? bggRank,
    bool? isOwned,
    bool? isPreordered,
    bool? isWishlisted,
    bool? isWantToPlay,
    bool? isWantToBuy,
    bool? isPrevOwned,
    bool? isPlayed,
    bool? isRated,
    bool? isForTrade,
    bool? isWantInTrade,
    bool? hasComment,
  }) {
    return CollectionItem(
      thingId: thingId ?? this.thingId,
      collId: collId ?? this.collId,
      version: version ?? this.version,
      customName: customName ?? this.customName,
      customImageUrl: customImageUrl ?? this.customImageUrl,
      names: names ?? this.names,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      thumbnailLocalPath: thumbnailLocalPath ?? this.thumbnailLocalPath,
      imageUrl: imageUrl ?? this.imageUrl,
      yearPublished: yearPublished ?? this.yearPublished,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      minPlayTime: minPlayTime ?? this.minPlayTime,
      maxPlayTime: maxPlayTime ?? this.maxPlayTime,
      minAge: minAge ?? this.minAge,
      bayesAverage: bayesAverage ?? this.bayesAverage,
      geekRatingUserCount: geekRatingUserCount ?? this.geekRatingUserCount,
      ownRating: ownRating ?? this.ownRating,
      numPlays: numPlays ?? this.numPlays,
      bggRank: bggRank ?? this.bggRank,
      isOwned: isOwned ?? this.isOwned,
      isPreordered: isPreordered ?? this.isPreordered,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      isWantToPlay: isWantToPlay ?? this.isWantToPlay,
      isWantToBuy: isWantToBuy ?? this.isWantToBuy,
      isPrevOwned: isPrevOwned ?? this.isPrevOwned,
      isPlayed: isPlayed ?? this.isPlayed,
      isRated: isRated ?? this.isRated,
      isForTrade: isForTrade ?? this.isForTrade,
      isWantInTrade: isWantInTrade ?? this.isWantInTrade,
      hasComment: hasComment ?? this.hasComment,
    );
  }
}
