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
    ],
    this.fieldOrder = const [
      CardField.playerCount,
      CardField.playTime,
      CardField.plays,
      CardField.ownRating,
      CardField.geekRating,
      CardField.minAge,
      CardField.bggRank,
    ],
    this.hidePlaysOnZero = true,
    this.showGeekRatingUserCount = false,
  });

  final bool showThumbnail;
  final bool showVersionSubtitle;
  final List<CardField> enabledFields;
  final List<CardField> fieldOrder;
  final bool hidePlaysOnZero;
  final bool showGeekRatingUserCount;

  bool isEnabled(CardField field) => enabledFields.contains(field);

  CardLayoutConfig copyWith({
    bool? showThumbnail,
    bool? showVersionSubtitle,
    List<CardField>? enabledFields,
    List<CardField>? fieldOrder,
    bool? hidePlaysOnZero,
    bool? showGeekRatingUserCount,
  }) {
    return CardLayoutConfig(
      showThumbnail: showThumbnail ?? this.showThumbnail,
      showVersionSubtitle: showVersionSubtitle ?? this.showVersionSubtitle,
      enabledFields: enabledFields ?? this.enabledFields,
      fieldOrder: fieldOrder ?? this.fieldOrder,
      hidePlaysOnZero: hidePlaysOnZero ?? this.hidePlaysOnZero,
      showGeekRatingUserCount:
          showGeekRatingUserCount ?? this.showGeekRatingUserCount,
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
  ];
}
