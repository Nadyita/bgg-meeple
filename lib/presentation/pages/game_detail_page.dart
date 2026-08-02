import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:html_unescape/html_unescape.dart';

import '../../application/use_cases/load_game_details_use_case.dart';
import '../../domain/entities/board_game.dart';
import '../../domain/entities/collection_item.dart';

import '../../domain/value_objects/localized_name.dart';
import '../l10n/app_localizations.dart';

/// Detail page for a single collection item.
///
/// Shows every piece of information known about the game. Tapping the back
/// arrow, pressing Escape, or using the system back gesture/button returns to
/// the collection list.
class GameDetailPage extends StatefulWidget {
  const GameDetailPage({
    super.key,
    required this.thingId,
    required this.collId,
    required this.loadGameDetails,
  });

  final int thingId;
  final int collId;
  final LoadGameDetailsUseCase loadGameDetails;

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  GameDetails? _details;
  bool _isLoading = true;
  bool _showAllNames = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final details = await widget.loadGameDetails(widget.thingId, widget.collId);
    if (mounted) {
      setState(() {
        _details = details;
        _isLoading = false;
      });
    }
    // Background refresh may have updated the game store. Wait a short moment
    // and reload so the UI can pick up the new description/links if they
    // arrived while the page was already open.
    _refreshTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final refreshed = await widget.loadGameDetails(
        widget.thingId,
        widget.collId,
      );
      if (mounted && refreshed != null) {
        setState(() {
          _details = refreshed;
        });
      }
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _goBack();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: localizations.detailBackTooltip,
            onPressed: _goBack,
          ),
          title: Text(_title(localizations)),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: localizations.detailOpenBggTooltip,
              onPressed: () => _openBgg(context),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _details == null
            ? Center(child: Text(localizations.detailGameNotFound))
            : _buildContent(context, _details!),
      ),
    );
  }

  String _title(AppLocalizations localizations) {
    final item = _details?.collectionItem;
    if (item == null) return localizations.collectionTitle;
    return item.displayName(preferredLanguage: localizations.localeName);
  }

  Widget _buildContent(BuildContext context, GameDetails details) {
    final hasDescription =
        details.boardGame?.description != null &&
        details.boardGame!.description!.isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleAndStatus(
            details: details,
            showAllNames: _showAllNames,
            onToggleNames: () {
              setState(() {
                _showAllNames = !_showAllNames;
              });
            },
          ),
          const SizedBox(height: 16),
          if (hasDescription) _DescriptionAndImage(details: details),
          if (!hasDescription) _ImageHeader(details: details),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _DetailFields(details: details),
        ],
      ),
    );
  }

  Future<void> _openBgg(BuildContext context) async {
    final url = Uri.parse(
      'https://boardgamegeek.com/boardgame/${widget.thingId}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _DescriptionAndImage extends StatelessWidget {
  const _DescriptionAndImage({required this.details});

  final GameDetails details;
  static final _htmlUnescape = HtmlUnescape();

  @override
  Widget build(BuildContext context) {
    final description = _htmlUnescape.convert(details.boardGame!.description!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _DescriptionWithFloatingImage(
        image: _ImageHeader(details: details),
        description: description,
      ),
    );
  }
}

/// Renders [description] with [image] floating in the top-right corner.
///
/// The image is sized so that it never exceeds the height of the wrapped
/// description text, never exceeds half the available width, and is never
/// smaller than the thumbnail fallback size. The text starts at the top-left,
/// fills the space beside the image for as many lines as fit into the image's
/// height, then continues in full width below the image.
class _DescriptionWithFloatingImage extends StatelessWidget {
  const _DescriptionWithFloatingImage({
    required this.image,
    required this.description,
  });

  final Widget image;
  final String description;

  static const double _imageMaxWidthFraction = 0.5;
  static const double _minImageHeight = 120;
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final imageWidth = (availableWidth * _imageMaxWidthFraction).clamp(
          0.0,
          availableWidth,
        );
        final textColumnWidth = (availableWidth - imageWidth - _gap).clamp(
          0.0,
          availableWidth,
        );

        final fullTextHeight = _measureTextHeight(
          context,
          description,
          textStyle,
          availableWidth,
        );
        final sideTextHeight = _measureTextHeight(
          context,
          description,
          textStyle,
          textColumnWidth,
        );

        // The image should be at least as tall as the thumbnail fallback, but
        // never taller than the full description text (so there is always text
        // flowing beside and below it) and never taller than the screen allows.
        final screenHeight = MediaQuery.of(context).size.height;
        final maxImageHeight = min(fullTextHeight, screenHeight * 0.75);
        final imageHeight = maxImageHeight.clamp(
          _minImageHeight,
          double.infinity,
        );

        // If the text is short, place everything below the image rather than
        // creating a large empty column next to the image.
        if (sideTextHeight <= _minImageHeight || textColumnWidth <= 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: imageWidth,
                    maxHeight: imageHeight,
                  ),
                  child: image,
                ),
              ),
              const SizedBox(height: 12),
              Text(description, style: textStyle),
            ],
          );
        }

        final split = _splitDescription(
          context,
          description,
          textStyle,
          textColumnWidth,
          imageHeight,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(split.sideText, style: textStyle)),
                  const SizedBox(width: _gap),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: imageWidth,
                      maxHeight: imageHeight,
                    ),
                    child: image,
                  ),
                ],
              ),
            ),
            if (split.bottomText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(split.bottomText, style: textStyle),
            ],
          ],
        );
      },
    );
  }

  double _measureTextHeight(
    BuildContext context,
    String text,
    TextStyle? style,
    double maxWidth,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);

    return textPainter.size.height;
  }

  _TextSplit _splitDescription(
    BuildContext context,
    String text,
    TextStyle? style,
    double columnWidth,
    double columnHeight,
  ) {
    if (columnWidth <= 0) {
      return _TextSplit('', text);
    }

    final textPainter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );

    var low = 0;
    var high = text.length;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      textPainter.text = TextSpan(text: text.substring(0, mid), style: style);
      textPainter.layout(maxWidth: columnWidth);
      if (textPainter.size.height <= columnHeight) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }

    final sideEnd = low;
    if (sideEnd == 0 || sideEnd == text.length) {
      return _TextSplit(text, '');
    }

    var breakIndex = sideEnd;
    while (breakIndex < text.length && text[breakIndex] != ' ') {
      breakIndex++;
    }
    if (breakIndex == text.length) {
      return _TextSplit(text, '');
    }

    return _TextSplit(
      text.substring(0, breakIndex).trimRight(),
      text.substring(breakIndex + 1).trimLeft(),
    );
  }
}

class _TextSplit {
  const _TextSplit(this.sideText, this.bottomText);

  final String sideText;
  final String bottomText;
}

class _ImageHeader extends StatefulWidget {
  const _ImageHeader({required this.details});

  final GameDetails details;

  @override
  State<_ImageHeader> createState() => _ImageHeaderState();
}

class _ImageHeaderState extends State<_ImageHeader> {
  bool _showFullImage = false;

  @override
  void initState() {
    super.initState();
    _initializeFullImageState();
  }

  void _initializeFullImageState() {
    final localPath = widget.details.localImagePath;
    if (localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync()) {
      setState(() => _showFullImage = true);
      return;
    }

    final fullImageUrl = widget.details.imageUrl;
    if (fullImageUrl == null || fullImageUrl.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _precacheFullImage(fullImageUrl);
    });
  }

  Future<void> _precacheFullImage(String url) async {
    final provider = CachedNetworkImageProvider(url);
    await precacheImage(provider, context);
    if (mounted) {
      setState(() => _showFullImage = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.details.collectionItem;

    final thumbnailLocalPath = item.thumbnailLocalPath;
    final thumbnailUrl = item.thumbnailUrl;
    final fullImageUrl = widget.details.imageUrl;
    final localFullPath = widget.details.localImagePath;

    Widget? fullImageWidget;
    if (_showFullImage && fullImageUrl != null && fullImageUrl.isNotEmpty) {
      if (localFullPath != null &&
          localFullPath.isNotEmpty &&
          File(localFullPath).existsSync()) {
        fullImageWidget = _buildClippedImage(
          Image.file(
            File(localFullPath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _fallback(context),
          ),
        );
      } else {
        fullImageWidget = _buildClippedImage(
          CachedNetworkImage(
            imageUrl: fullImageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => _placeholder(),
            errorWidget: (context, url, error) => _fallback(context),
          ),
        );
      }
    }

    Widget? thumbnailWidget;
    if (thumbnailLocalPath != null &&
        thumbnailLocalPath.isNotEmpty &&
        File(thumbnailLocalPath).existsSync()) {
      thumbnailWidget = _buildClippedImage(
        Image.file(
          File(thumbnailLocalPath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _fallback(context),
        ),
      );
    } else if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      thumbnailWidget = _buildClippedImage(
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => _placeholder(),
          errorWidget: (context, url, error) => _fallback(context),
        ),
      );
    }

    final effectiveWidget = fullImageWidget ?? thumbnailWidget;

    if (effectiveWidget == null) {
      return _fallback(context);
    }

    return Align(alignment: Alignment.topRight, child: effectiveWidget);
  }

  Widget _buildClippedImage(Widget image) {
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: image);
  }

  Widget _placeholder() {
    return const SizedBox(
      height: 80,
      width: 80,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Icon(Icons.image_not_supported)),
    );
  }
}

class _TitleAndStatus extends StatelessWidget {
  const _TitleAndStatus({
    required this.details,
    required this.showAllNames,
    required this.onToggleNames,
  });

  final GameDetails details;
  final bool showAllNames;
  final VoidCallback onToggleNames;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final item = details.collectionItem;
    final boardGame = details.boardGame;

    final allNames = _allNames(item, boardGame);
    final primaryName = _primaryName(allNames, localizations.localeName);
    final alternateNames = allNames
        .where((n) => n.value != primaryName)
        .toList();
    final statusChips = _buildStatusChips(context, item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                primaryName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (statusChips.isNotEmpty)
              Wrap(spacing: 4, runSpacing: 4, children: statusChips),
          ],
        ),
        if (alternateNames.isNotEmpty) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: onToggleNames,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              showAllNames
                  ? localizations.detailAlternateNames(0).replaceAll('0', '')
                  : localizations.detailAlternateNames(alternateNames.length),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
        if (showAllNames && alternateNames.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: alternateNames
                .map(
                  (name) => Chip(
                    label: Text(name.value),
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  List<Chip> _buildStatusChips(BuildContext context, CollectionItem item) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        );
      }
      return Chip(
        label: Text(chip.label),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      );
    }).toList();
  }

  List<LocalizedName> _allNames(CollectionItem item, BoardGame? boardGame) {
    final names = <LocalizedName>[];
    final gameNames = boardGame?.names ?? [];
    final itemNames = item.names;

    for (final name in gameNames) {
      if (!names.any((n) => n.value == name.value)) {
        names.add(name);
      }
    }
    for (final name in itemNames) {
      if (!names.any((n) => n.value == name.value)) {
        names.add(name);
      }
    }
    return names;
  }

  String _primaryName(List<LocalizedName> names, String preferredLanguage) {
    if (names.isEmpty) return 'Unknown game';

    final localized = names.firstWhereOrNull(
      (name) =>
          name.language != null &&
          name.language!.toLowerCase() == preferredLanguage.toLowerCase() &&
          name.value.trim().isNotEmpty,
    );
    if (localized != null) return localized.value.trim();

    final primary = names.firstWhereOrNull(
      (name) => name.isPrimary && name.value.trim().isNotEmpty,
    );
    if (primary != null) return primary.value.trim();

    return names.first.value.trim();
  }
}

class _DetailFields extends StatelessWidget {
  const _DetailFields({required this.details});

  final GameDetails details;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final item = details.collectionItem;
    final game = details.boardGame;

    final fields = _buildFields(localizations, item, game);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }

  List<Widget> _buildFields(
    AppLocalizations localizations,
    CollectionItem item,
    BoardGame? game,
  ) {
    final fields = <Widget>[];

    // Strict order mandated by the game-detail spec.
    _addValueField(
      fields,
      localizations.detailOriginalName,
      _originalName(game?.names ?? item.names),
    );
    _addValueField(
      fields,
      localizations.detailYearPublished,
      _formatNullable(item.yearPublished),
    );
    if (item.version != null) {
      final version = item.version!;
      final yearSuffix = version.year != null ? ' (${version.year})' : '';
      _addValueField(
        fields,
        localizations.detailVersion,
        '${version.name}$yearSuffix',
      );
    }
    _addValueField(
      fields,
      localizations.detailPlayerCount,
      _formatPlayerCount(localizations, item, game),
    );
    _addValueField(
      fields,
      localizations.detailPlayingTime,
      _formatPlayTime(localizations, item, game),
    );
    _addValueField(
      fields,
      localizations.detailRating,
      _formatRating(localizations, item, game),
    );
    _addValueField(
      fields,
      localizations.detailRank,
      _formatNullable(item.bggRank),
    );
    _addValueField(
      fields,
      localizations.detailPlays,
      _formatNullable(item.numPlays),
    );

    if (fields.isEmpty) {
      return [Text(localizations.detailNotAvailable)];
    }

    return fields;
  }

  String? _originalName(List<LocalizedName> names) {
    if (names.isEmpty) return null;

    final primary = names.firstWhereOrNull(
      (name) => name.isPrimary && name.value.trim().isNotEmpty,
    );
    if (primary != null) return primary.value.trim();

    return names.first.value.trim();
  }

  String? _formatRating(
    AppLocalizations localizations,
    CollectionItem item,
    BoardGame? game,
  ) {
    final rating = item.bayesAverage ?? game?.bayesAverage;
    final userCount = item.geekRatingUserCount ?? game?.userCount;
    if (rating == null) return null;

    final buffer = StringBuffer();
    buffer.write(rating.toStringAsFixed(2));
    if (userCount != null) {
      buffer.write(' ($userCount ${localizations.detailUserCount})');
    }
    return buffer.toString();
  }

  void _addValueField(List<Widget> fields, String label, String? value) {
    if (value == null || value.isEmpty) return;
    fields.add(_KeyValueRow(label: label, value: value));
  }

  String? _formatNullable(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  String? _formatPlayerCount(
    AppLocalizations localizations,
    CollectionItem item,
    BoardGame? game,
  ) {
    final min = _readInt(item, game, 'minPlayers');
    final max = _readInt(item, game, 'maxPlayers');
    if (min == null && max == null) return null;
    if (min == max) return localizations.cardPlayerCountExact(min!);
    if (min == null) return localizations.cardPlayerCountRangeMaxOnly(max!);
    if (max == null) return localizations.cardPlayerCountRangeMinOnly(min);
    return localizations.cardPlayerCountRange(min, max);
  }

  String? _formatPlayTime(
    AppLocalizations localizations,
    CollectionItem item,
    BoardGame? game,
  ) {
    final min = _readInt(item, game, 'minPlayTime');
    final max = _readInt(item, game, 'maxPlayTime');
    if (min == null && max == null) return null;
    if (min == max) return localizations.cardPlayTimeExact(min!);
    if (min == null) return localizations.cardPlayTimeMaxOnly(max!);
    if (max == null) return localizations.cardPlayTimeMinOnly(min);
    return localizations.cardPlayTimeRange(min, max);
  }

  int? _readInt(CollectionItem item, BoardGame? game, String property) {
    final itemValue = switch (property) {
      'minPlayers' => item.minPlayers,
      'maxPlayers' => item.maxPlayers,
      'minPlayTime' => item.minPlayTime,
      'maxPlayTime' => item.maxPlayTime,
      _ => null,
    };
    if (itemValue != null) return itemValue;

    if (game == null) return null;
    return switch (property) {
      'minPlayers' => game.minPlayers,
      'maxPlayers' => game.maxPlayers,
      'minPlayTime' => game.minPlayTime,
      'maxPlayTime' => game.maxPlayTime,
      _ => null,
    };
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
