import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/collection_item.dart';
import '../../domain/value_objects/card_field.dart';
import '../../domain/value_objects/card_layout_config.dart';
import '../l10n/app_localizations.dart';

/// Card widget displaying a single collection item.
class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.item,
    this.config,
    this.playerNamesByGame,
    this.onTap,
  });

  final CollectionItem item;
  final CardLayoutConfig? config;
  final Map<int, List<String>>? playerNamesByGame;
  final VoidCallback? onTap;

  CardLayoutConfig get _config => config ?? const CardLayoutConfig();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final effectiveConfig = _config;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (effectiveConfig.showThumbnail) ...[
                    _Thumbnail(
                      url: item.thumbnailUrl,
                      localPath: item.thumbnailLocalPath,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_versionSubtitle != null &&
                            effectiveConfig.showVersionSubtitle) ...[
                          const SizedBox(height: 2),
                          Text(
                            _versionSubtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        ..._buildMetadataLines(context, effectiveConfig),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _buildSubTypeChips(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMetadataLines(
    BuildContext context,
    CardLayoutConfig effectiveConfig,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final lines = <Widget>[];
    var lastAdded = false;

    for (final field in effectiveConfig.fieldOrder) {
      if (!effectiveConfig.isEnabled(field)) continue;

      final line = _metadataLineFor(
        field,
        effectiveConfig,
        localizations,
        context,
      );
      if (line == null) continue;

      if (lastAdded) {
        lines.add(const SizedBox(height: 4));
      }
      lines.add(line);
      lastAdded = true;
    }

    return lines;
  }

  Widget? _metadataLineFor(
    CardField field,
    CardLayoutConfig effectiveConfig,
    AppLocalizations localizations,
    BuildContext context,
  ) {
    return switch (field) {
      CardField.playerCount => _playerCountLine(effectiveConfig, localizations),
      CardField.playTime => _MetadataLine(
        icon: Icons.schedule,
        text: _playTimeText(localizations),
      ),
      CardField.plays => _playsLine(effectiveConfig, localizations),
      CardField.ownRating => _ownRatingLine(localizations),
      CardField.geekRating => _geekRatingLine(effectiveConfig, localizations),
      CardField.minAge => _minAgeLine(context, localizations),
      CardField.bggRank => _bggRankLine(localizations),
      CardField.inventoryLocation => _inventoryLocationLine(localizations),
    };
  }

  Widget? _ownRatingLine(AppLocalizations localizations) {
    final rating = item.ownRating;
    if (rating == null) return null;
    return _MetadataLine(
      icon: Icons.star,
      text: localizations.cardOwnRatingLabel(rating.toStringAsFixed(2)),
    );
  }

  Widget? _geekRatingLine(
    CardLayoutConfig effectiveConfig,
    AppLocalizations localizations,
  ) {
    final rating = item.bayesAverage;
    final userCount = item.geekRatingUserCount;

    if (rating == null) {
      return _MetadataLine(
        icon: Icons.star,
        text: localizations.cardGeekRatingMissing,
      );
    }

    var text = localizations.cardGeekRatingLabel(rating.toStringAsFixed(2));
    if (effectiveConfig.showGeekRatingUserCount && userCount != null) {
      text += ' ($userCount)';
    }
    return _MetadataLine(icon: Icons.star, text: text);
  }

  Widget? _minAgeLine(BuildContext context, AppLocalizations localizations) {
    final age = item.minAge;
    if (age == null) return null;

    final suggested = item.suggestedPlayerAge;
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final style = Theme.of(context).textTheme.bodySmall;

    return Row(
      children: [
        Icon(Icons.child_care, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(localizations.cardMinAgeLabel(age), style: style),
              if (suggested != null && suggested.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text('·', style: style),
                const SizedBox(width: 4),
                Icon(Icons.thumb_up, size: 14, color: iconColor),
                const SizedBox(width: 2),
                Text(suggested, style: style),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget? _bggRankLine(AppLocalizations localizations) {
    final rank = item.bggRank;
    if (rank == null) return null;
    return _MetadataLine(
      icon: Icons.format_list_numbered,
      text: localizations.cardBggRankLabel(rank),
    );
  }

  Widget? _playsLine(CardLayoutConfig config, AppLocalizations localizations) {
    final plays = item.numPlays ?? 0;
    if (config.hidePlaysOnZero && plays == 0) return null;

    var text = localizations.cardPlaysLabel(plays);
    if (config.showPlayerNamesOnPlays) {
      final names = playerNamesByGame?[item.thingId];
      if (names != null && names.isNotEmpty) {
        text += ' — ${names.join(', ')}';
      }
    }
    return _MetadataLine(icon: Icons.casino, text: text);
  }

  Widget? _inventoryLocationLine(AppLocalizations localizations) {
    final location = item.inventoryLocation;
    if (location == null || location.isEmpty) return null;
    return _MetadataLine(
      icon: Icons.location_on,
      text: localizations.cardInventoryLocationLabel(location),
    );
  }

  String get _displayName {
    final year = item.displayYear();
    final base = item.displayName(preferredLanguage: 'de');
    return year != null ? '$base ($year)' : base;
  }

  String? get _versionSubtitle {
    final versionName = item.version?.name.trim();
    final versionYear = item.version?.year;
    if (versionName == null || versionName.isEmpty) {
      return null;
    }
    if (versionYear == null) {
      return versionName;
    }
    final yearString = versionYear.toString();
    if (versionName.endsWith(yearString)) {
      final trimmed = versionName
          .substring(0, versionName.length - yearString.length)
          .trim();
      return trimmed.isNotEmpty ? '$trimmed ($yearString)' : versionName;
    }
    return '$versionName ($versionYear)';
  }

  Widget? _playerCountLine(
    CardLayoutConfig config,
    AppLocalizations localizations,
  ) {
    final min = item.minPlayers;
    final max = item.maxPlayers;
    String baseText;
    if (min == null && max == null) {
      baseText = localizations.cardPlayerCountMissing;
    } else if (min == max) {
      baseText = localizations.cardPlayerCountExact(min!);
    } else if (min == null) {
      baseText = localizations.cardPlayerCountRangeMaxOnly(max!);
    } else if (max == null) {
      baseText = localizations.cardPlayerCountRangeMinOnly(min);
    } else {
      baseText = localizations.cardPlayerCountRange(min, max);
    }

    final recommended = config.showRecommendedPlayerNumbers
        ? item.recommendedPlayerCount
        : null;
    final best = config.showBestPlayerNumbers ? item.bestPlayerCount : null;

    if (recommended == null && best == null) {
      return _MetadataLine(icon: Icons.people, text: baseText);
    }

    final baseMin = min;
    final baseMax = max;
    final bestMin = item.bestPlayerCountMin;
    final bestMax = item.bestPlayerCountMax;
    final recommendedMin = item.recommendedPlayerCountMin;
    final recommendedMax = item.recommendedPlayerCountMax;

    final bestSameAsBase = _playerCountRangesEqual(
      baseMin,
      baseMax,
      bestMin,
      bestMax,
    );
    final recommendedSameAsBase = _playerCountRangesEqual(
      baseMin,
      baseMax,
      recommendedMin,
      recommendedMax,
    );
    final recommendedSameAsBest = _playerCountRangesEqual(
      bestMin,
      bestMax,
      recommendedMin,
      recommendedMax,
    );

    final showBest = best != null && !bestSameAsBase;
    final showRecommended =
        recommended != null && !recommendedSameAsBase && !recommendedSameAsBest;

    if (!showBest && !showRecommended) {
      return _MetadataLine(icon: Icons.people, text: baseText);
    }

    return _InlinePlayerCountLine(
      baseText: baseText,
      recommendedText: showRecommended ? recommended : null,
      bestText: showBest ? best : null,
    );
  }

  bool _playerCountRangesEqual(int? minA, int? maxA, int? minB, int? maxB) {
    // Without numeric bounds on either side we cannot reliably decide whether
    // two display strings describe the same range, so we keep both visible.
    if (minA == null && maxA == null || minB == null && maxB == null) {
      return false;
    }
    return minA == minB && maxA == maxB;
  }

  String _playTimeText(AppLocalizations localizations) {
    final min = item.minPlayTime;
    final max = item.maxPlayTime;
    if (min == null && max == null) return localizations.cardPlayTimeMissing;
    if (min == max) return localizations.cardPlayTimeExact(min!);
    if (min == null) return localizations.cardPlayTimeMaxOnly(max!);
    if (max == null) return localizations.cardPlayTimeMinOnly(min);
    return localizations.cardPlayTimeRange(min, max);
  }

  List<Widget> _buildSubTypeChips(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final chips = <({String label, bool isOwned})>[];

    if (item.isOwned) {
      chips.add((label: localizations.subTypeOwned, isOwned: true));
    }
    if (item.isPreordered) {
      chips.add((label: localizations.subTypePreordered, isOwned: false));
    }
    if (item.isWishlisted) {
      chips.add((label: localizations.subTypeWishlisted, isOwned: false));
    }
    if (item.isWantToPlay) {
      chips.add((label: localizations.subTypeWantToPlay, isOwned: false));
    }
    if (item.isWantToBuy) {
      chips.add((label: localizations.subTypeWantToBuy, isOwned: false));
    }
    if (item.isPrevOwned) {
      chips.add((label: localizations.subTypePreviouslyOwned, isOwned: false));
    }
    if (item.isPlayed) {
      chips.add((label: localizations.subTypePlayed, isOwned: false));
    }
    if (item.isRated) {
      chips.add((label: localizations.subTypeRated, isOwned: false));
    }
    if (item.isForTrade) {
      chips.add((label: localizations.subTypeForTrade, isOwned: false));
    }
    if (item.isWantInTrade) {
      chips.add((label: localizations.subTypeWantInTrade, isOwned: false));
    }
    if (item.hasComment) {
      chips.add((label: localizations.subTypeHasComment, isOwned: false));
    }

    return chips.map((chip) {
      if (chip.isOwned) {
        return Chip(
          label: Text(chip.label),
          backgroundColor: colorScheme.primaryContainer,
          labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        );
      }
      return Chip(label: Text(chip.label));
    }).toList();
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url, this.localPath});

  final String? url;
  final String? localPath;

  @override
  Widget build(BuildContext context) {
    final local = localPath;
    if (local != null && local.isNotEmpty && File(local).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(local),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(context),
        ),
      );
    }

    if (url == null || url!.isEmpty) {
      return _fallback(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: Colors.grey.shade300,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image_not_supported),
    );
  }
}

class _InlinePlayerCountLine extends StatelessWidget {
  const _InlinePlayerCountLine({
    required this.baseText,
    this.recommendedText,
    this.bestText,
  });

  final String baseText;
  final String? recommendedText;
  final String? bestText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = <InlineSpan>[TextSpan(text: baseText)];

    void addSegment(IconData icon, String text) {
      children.add(const TextSpan(text: ' · '));
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 2),
              Text(text, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    final recommended = recommendedText;
    if (recommended != null) addSegment(Icons.thumb_up, recommended);
    final best = bestText;
    if (best != null) addSegment(Icons.emoji_events, best);

    return Row(
      children: [
        Icon(Icons.people, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: theme.textTheme.bodySmall,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
