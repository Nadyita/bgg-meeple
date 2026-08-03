import 'package:equatable/equatable.dart';

import 'card_field.dart';

/// User-configurable layout of a collection card.
///
/// Only the title and sub-type chips are always shown. Everything else can
/// be toggled and most fields can be reordered via drag-and-drop.
class CardLayoutConfig extends Equatable {
  const CardLayoutConfig({
    this.showThumbnail = true,
    this.showVersionSubtitle = true,
    this.enabledFields = const [
      CardField.playerCount,
      CardField.playTime,
      CardField.plays,
      CardField.ownRating,
      CardField.geekRating,
      CardField.minAge,
      CardField.inventoryLocation,
    ],
    this.fieldOrder = const [
      CardField.playerCount,
      CardField.playTime,
      CardField.plays,
      CardField.ownRating,
      CardField.geekRating,
      CardField.minAge,
      CardField.bggRank,
      CardField.inventoryLocation,
    ],
    this.hidePlaysOnZero = true,
    this.showGeekRatingUserCount = false,
    this.showPlayerNamesOnPlays = false,
    this.showRecommendedPlayerNumbers = false,
    this.showBestPlayerNumbers = false,
  });

  final bool showThumbnail;
  final bool showVersionSubtitle;
  final List<CardField> enabledFields;
  final List<CardField> fieldOrder;
  final bool hidePlaysOnZero;
  final bool showGeekRatingUserCount;
  final bool showPlayerNamesOnPlays;
  final bool showRecommendedPlayerNumbers;
  final bool showBestPlayerNumbers;

  bool isEnabled(CardField field) => enabledFields.contains(field);

  CardLayoutConfig copyWith({
    bool? showThumbnail,
    bool? showVersionSubtitle,
    List<CardField>? enabledFields,
    List<CardField>? fieldOrder,
    bool? hidePlaysOnZero,
    bool? showGeekRatingUserCount,
    bool? showPlayerNamesOnPlays,
    bool? showRecommendedPlayerNumbers,
    bool? showBestPlayerNumbers,
  }) {
    return CardLayoutConfig(
      showThumbnail: showThumbnail ?? this.showThumbnail,
      showVersionSubtitle: showVersionSubtitle ?? this.showVersionSubtitle,
      enabledFields: enabledFields ?? this.enabledFields,
      fieldOrder: fieldOrder ?? this.fieldOrder,
      hidePlaysOnZero: hidePlaysOnZero ?? this.hidePlaysOnZero,
      showGeekRatingUserCount:
          showGeekRatingUserCount ?? this.showGeekRatingUserCount,
      showPlayerNamesOnPlays:
          showPlayerNamesOnPlays ?? this.showPlayerNamesOnPlays,
      showRecommendedPlayerNumbers:
          showRecommendedPlayerNumbers ?? this.showRecommendedPlayerNumbers,
      showBestPlayerNumbers:
          showBestPlayerNumbers ?? this.showBestPlayerNumbers,
    );
  }

  @override
  List<Object?> get props => [
    showThumbnail,
    showVersionSubtitle,
    enabledFields,
    fieldOrder,
    hidePlaysOnZero,
    showGeekRatingUserCount,
    showPlayerNamesOnPlays,
    showRecommendedPlayerNumbers,
    showBestPlayerNumbers,
  ];
}
