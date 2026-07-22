import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/use_cases/load_card_layout_use_case.dart';
import '../../application/use_cases/load_collection_use_case.dart';
import '../../application/use_cases/load_collection_view_use_case.dart';
import '../../application/use_cases/load_credentials_use_case.dart';
import '../../application/use_cases/load_play_player_names_use_case.dart';
import '../../application/use_cases/load_game_details_use_case.dart';
import '../../application/use_cases/save_collection_view_use_case.dart';
import '../../application/use_cases/sync_collection_use_case.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/value_objects/collection_filter.dart';
import '../../domain/value_objects/collection_sort.dart';
import '../../domain/value_objects/collection_sub_type.dart';
import '../../domain/value_objects/play_time_steps.dart';
import '../../domain/value_objects/player_count_range.dart';
import '../../domain/value_objects/player_participation_filter.dart';
import '../../domain/value_objects/rating_steps.dart';
import '../../infrastructure/di/service_locator.dart';
import '../blocs/collection/collection_bloc.dart';
import '../blocs/collection/collection_event.dart';
import '../blocs/collection/collection_state.dart';
import '../cubits/theme_cubit.dart';
import '../l10n/app_localizations.dart';
import '../widgets/collection_card.dart';
import 'game_detail_page.dart';
import 'settings_page.dart';

/// Main page showing the user's BGG collection.
class CollectionPage extends StatelessWidget {
  const CollectionPage({
    super.key,
    required this.loadCollection,
    required this.loadGameDetails,
    required this.loadCardLayout,
    required this.loadCollectionView,
    required this.saveCollectionView,
    required this.loadCredentials,
    required this.loadPlayPlayerNames,
    required this.syncCollection,
  });

  final LoadCollectionUseCase loadCollection;
  final LoadGameDetailsUseCase loadGameDetails;
  final LoadCardLayoutUseCase loadCardLayout;
  final LoadCollectionViewUseCase loadCollectionView;
  final SaveCollectionViewUseCase saveCollectionView;
  final LoadCredentialsUseCase loadCredentials;
  final LoadPlayPlayerNamesUseCase loadPlayPlayerNames;
  final SyncCollectionUseCase syncCollection;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollectionBloc(
        loadCollection: loadCollection,
        loadCardLayout: loadCardLayout,
        loadCollectionView: loadCollectionView,
        saveCollectionView: saveCollectionView,
        loadCredentials: loadCredentials,
        loadPlayPlayerNames: loadPlayPlayerNames,
        syncCollection: syncCollection,
      )..add(const CollectionLoaded()),
      child: _CollectionView(loadGameDetails: loadGameDetails),
    );
  }
}

class _CollectionView extends StatefulWidget {
  const _CollectionView({required this.loadGameDetails});

  final LoadGameDetailsUseCase loadGameDetails;

  @override
  State<_CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<_CollectionView> {
  bool _filterPanelOpen = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bloc = context.read<CollectionBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.collectionTitle),
        actions: [
          BlocBuilder<CollectionBloc, CollectionState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isCompactMode ? Icons.view_list : Icons.view_module,
                ),
                tooltip: state.isCompactMode
                    ? localizations.compactModeDisableTooltip
                    : localizations.compactModeEnableTooltip,
                onPressed: () => context.read<CollectionBloc>().add(
                  const CollectionCompactModeToggled(),
                ),
              );
            },
          ),
          BlocBuilder<CollectionBloc, CollectionState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.sync),
                tooltip: localizations.syncLabel,
                onPressed: state.hasCredentials
                    ? () => context.read<CollectionBloc>().add(
                        const CollectionSyncRequested(),
                      )
                    : null,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: localizations.sortLabel,
            onPressed: () => _showSortBottomSheet(context, bloc.state.sort),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: localizations.settingsTitle,
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const _SyncProgress(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: BlocBuilder<CollectionBloc, CollectionState>(
              buildWhen: (previous, current) =>
                  previous.searchText != current.searchText,
              builder: (context, state) {
                if (_searchController.text != state.searchText) {
                  _searchController.text = state.searchText;
                }
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: localizations.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: localizations.clearSearchLabel,
                            onPressed: () {
                              _searchController.clear();
                              bloc.add(const CollectionViewCleared());
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _filterPanelOpen
                                ? Icons.filter_list_off
                                : Icons.filter_list,
                          ),
                          tooltip: localizations.filterLabel,
                          onPressed: () {
                            setState(() {
                              _filterPanelOpen = !_filterPanelOpen;
                            });
                          },
                        ),
                      ],
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    bloc.add(CollectionSearchTextChanged(value));
                    setState(() {});
                  },
                );
              },
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _filterPanelOpen
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.55,
                    ),
                    child: BlocBuilder<CollectionBloc, CollectionState>(
                      builder: (context, state) {
                        return SingleChildScrollView(
                          child: _FilterPanel(
                            filter: state.filter,
                            playerNamesByGame: state.playerNamesByGame,
                            onFilterChanged: (filter) {
                              bloc.add(CollectionFilterChanged(filter));
                            },
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: BlocBuilder<CollectionBloc, CollectionState>(
              builder: (context, state) {
                final localizations = AppLocalizations.of(context)!;
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final errorMessage = state.errorMessage(localizations);
                if (errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(errorMessage, textAlign: TextAlign.center),
                    ),
                  );
                }

                if (state.filteredItems.isEmpty) {
                  return Center(
                    child: Text(
                      state.items.isEmpty
                          ? localizations.collectionEmptyAfterSync
                          : state.filter.isActive
                          ? localizations.noGamesMatchFilters
                          : localizations.collectionEmptySearch,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    final bloc = context.read<CollectionBloc>();
                    bloc.add(const CollectionSyncRequested());
                    await bloc.stream.firstWhere((s) => s.isSyncing);
                    await bloc.stream.firstWhere((s) => !s.isSyncing);
                  },
                  child: state.isCompactMode
                      ? _CompactCollectionList(items: state.filteredItems)
                      : ListView.builder(
                          itemCount: state.filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = state.filteredItems[index];
                            return CollectionCard(
                              item: item,
                              config: state.cardLayout,
                              playerNamesByGame: state.playerNamesByGame,
                              onTap: () => _openGameDetail(context, item),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          loadCredentials: ServiceLocator.instance.loadCredentials,
          saveCredentials: ServiceLocator.instance.saveCredentials,
          login: ServiceLocator.instance.login,
          syncCollection: ServiceLocator.instance.syncCollection,
          loadCardLayout: ServiceLocator.instance.loadCardLayout,
          saveCardLayout: ServiceLocator.instance.saveCardLayout,
          onSyncCompleted: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
    if (context.mounted) {
      context.read<CollectionBloc>().add(const CollectionCardLayoutReloaded());
    }
  }

  void _openGameDetail(BuildContext context, CollectionItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameDetailPage(
          thingId: item.thingId,
          collId: item.collId ?? item.thingId,
          loadGameDetails: widget.loadGameDetails,
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context, CollectionSort initial) {
    final localizations = AppLocalizations.of(context)!;
    final bloc = context.read<CollectionBloc>();

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<CollectionBloc, CollectionState>(
            builder: (context, state) {
              final current = state.sort;
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.sortLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...SortBy.values.map(
                        (sortBy) => ListTile(
                          leading: Icon(
                            current.sortBy == sortBy
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                          ),
                          title: Text(_sortByLabel(localizations, sortBy)),
                          onTap: () {
                            context.read<CollectionBloc>().add(
                              CollectionSortChanged(
                                current.copyWith(sortBy: sortBy),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: Text(
                          current.ascending
                              ? localizations.ascending
                              : localizations.descending,
                        ),
                        value: current.ascending,
                        onChanged: (value) {
                          context.read<CollectionBloc>().add(
                            CollectionSortChanged(
                              current.copyWith(ascending: value),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _sortByLabel(AppLocalizations localizations, SortBy sortBy) {
    return switch (sortBy) {
      SortBy.name => localizations.sortByName,
      SortBy.playTime => localizations.sortByPlayTime,
      SortBy.bggRating => localizations.sortByBggRating,
      SortBy.year => localizations.sortByYear,
    };
  }
}

class _CompactCollectionList extends StatelessWidget {
  const _CompactCollectionList({required this.items});

  final List<CollectionItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          dense: true,
          title: Text(
            item.displayName(preferredLanguage: 'de'),
            style: theme.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

class _SyncProgress extends StatelessWidget {
  const _SyncProgress();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionBloc, CollectionState>(
      builder: (context, state) {
        if (!state.isSyncing) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(semanticsLabel: state.syncProgress),
              if (state.syncProgress != null) ...[
                const SizedBox(height: 4),
                Text(
                  state.syncProgress!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.filter,
    required this.playerNamesByGame,
    required this.onFilterChanged,
  });

  final CollectionFilter filter;
  final Map<int, List<String>> playerNamesByGame;
  final ValueChanged<CollectionFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CollectionSubType.values.map((subType) {
                final selected = filter.selectedSubTypes.contains(subType);
                return FilterChip(
                  label: Text(_subTypeLabel(localizations, subType)),
                  selected: selected,
                  onSelected: (_) => _toggleSubType(subType),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _PlayerCountRangeSlider(
              label: localizations.playerCountLabel,
              minPlayers: filter.minPlayers,
              maxPlayers: filter.maxPlayers,
              onChanged: (min, max) => onFilterChanged(
                filter.copyWith(
                  minPlayers: min,
                  maxPlayers: max,
                  clearMinPlayers: min == null,
                  clearMaxPlayers: max == null,
                ),
              ),
            ),
            _PlayTimeRangeSlider(
              label: localizations.playTimeLabel,
              minPlayTime: filter.minPlayTime,
              maxPlayTime: filter.maxPlayTime,
              onChanged: (min, max) => onFilterChanged(
                filter.copyWith(
                  minPlayTime: min,
                  maxPlayTime: max,
                  clearMinPlayTime: min == null,
                  clearMaxPlayTime: max == null,
                ),
              ),
            ),
            _RatingRangeSlider(
              label: localizations.ratingLabel,
              minRating: filter.minRating,
              maxRating: filter.maxRating,
              onChanged: (min, max) => onFilterChanged(
                filter.copyWith(
                  minRating: min,
                  maxRating: max,
                  clearMinRating: min == null,
                  clearMaxRating: max == null,
                ),
              ),
            ),
            _PlayerFilterSection(
              filter: filter,
              playerNamesByGame: playerNamesByGame,
              onFilterChanged: onFilterChanged,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onFilterChanged(
                  filter.clearPlayerFilters(_availablePlayerNamesLowerCase),
                ),
                child: Text(localizations.clearFiltersLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<String> get _availablePlayerNamesLowerCase {
    return playerNamesByGame.values
        .expand((names) => names)
        .map((name) => name.toLowerCase())
        .toSet();
  }

  void _toggleSubType(CollectionSubType subType) {
    final current = List<CollectionSubType>.of(filter.selectedSubTypes);
    if (current.contains(subType)) {
      current.remove(subType);
    } else {
      current.add(subType);
    }
    onFilterChanged(filter.copyWith(selectedSubTypes: current));
  }

  String _subTypeLabel(
    AppLocalizations localizations,
    CollectionSubType subType,
  ) {
    return switch (subType) {
      CollectionSubType.owned => localizations.subTypeOwned,
      CollectionSubType.preordered => localizations.subTypePreordered,
      CollectionSubType.wishlisted => localizations.subTypeWishlisted,
      CollectionSubType.wantToPlay => localizations.subTypeWantToPlay,
      CollectionSubType.wantToBuy => localizations.subTypeWantToBuy,
      CollectionSubType.previouslyOwned => localizations.subTypePreviouslyOwned,
      CollectionSubType.played => localizations.subTypePlayed,
      CollectionSubType.rated => localizations.subTypeRated,
      CollectionSubType.forTrade => localizations.subTypeForTrade,
      CollectionSubType.wantInTrade => localizations.subTypeWantInTrade,
      CollectionSubType.hasComment => localizations.subTypeHasComment,
    };
  }
}

class _PlayerFilterSection extends StatelessWidget {
  const _PlayerFilterSection({
    required this.filter,
    required this.playerNamesByGame,
    required this.onFilterChanged,
  });

  final CollectionFilter filter;
  final Map<int, List<String>> playerNamesByGame;
  final ValueChanged<CollectionFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final allPlayers = _allAvailablePlayers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          localizations.filterPlayerSectionTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...filter.playerParticipation.entries.map((entry) {
              final isMissing = !_isPlayerAvailable(entry.key);
              return _PlayerChip(
                playerName: entry.key,
                state: entry.value,
                isMissing: isMissing,
                onStateChanged: (newState) =>
                    _updatePlayerState(entry.key, newState),
                onRemoved: () => _removePlayer(entry.key),
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(localizations.filterAddPlayerLabel),
              onPressed: () => _openPlayerPicker(context, allPlayers),
            ),
          ],
        ),
      ],
    );
  }

  List<String> _allAvailablePlayers() {
    final seen = <String>{};
    final result = <String>[];
    for (final names in playerNamesByGame.values) {
      for (final name in names) {
        final lower = name.toLowerCase();
        if (seen.add(lower)) {
          result.add(name);
        }
      }
    }
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }

  bool _isPlayerAvailable(String playerName) {
    final lower = playerName.toLowerCase();
    return playerNamesByGame.values
        .expand((names) => names)
        .any((name) => name.toLowerCase() == lower);
  }

  void _updatePlayerState(String playerName, PlayerParticipationFilter state) {
    final updated = Map<String, PlayerParticipationFilter>.of(
      filter.playerParticipation,
    );
    updated[playerName] = state;
    onFilterChanged(filter.copyWith(playerParticipation: updated));
  }

  void _removePlayer(String playerName) {
    final updated = Map<String, PlayerParticipationFilter>.of(
      filter.playerParticipation,
    );
    updated.remove(playerName);
    onFilterChanged(filter.copyWith(playerParticipation: updated));
  }

  Future<void> _openPlayerPicker(
    BuildContext context,
    List<String> allPlayers,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        final existingLowerCase = filter.playerParticipation.keys
            .map((name) => name.toLowerCase())
            .toSet();
        final available = allPlayers
            .where((name) => !existingLowerCase.contains(name.toLowerCase()))
            .toList();
        return SimpleDialog(
          title: Text(localizations.filterPlayerPickerTitle),
          children: available.isEmpty
              ? [
                  SimpleDialogOption(
                    child: Text(localizations.noGamesMatchFilters),
                  ),
                ]
              : available
                    .map(
                      (name) => SimpleDialogOption(
                        onPressed: () => Navigator.of(context).pop(name),
                        child: Text(name),
                      ),
                    )
                    .toList(),
        );
      },
    );
    if (selected != null) {
      _updatePlayerState(selected, PlayerParticipationFilter.any);
      if (context.mounted) {
        final showHint = context.read<ThemeCubit>().state.showPlayerFilterHint;
        if (showHint) {
          final isTouch = Platform.isAndroid || Platform.isIOS;
          final message = isTouch
              ? localizations.filterPlayerHintTouch
              : localizations.filterPlayerHintPointer;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({
    required this.playerName,
    required this.state,
    required this.isMissing,
    required this.onStateChanged,
    required this.onRemoved,
  });

  final String playerName;
  final PlayerParticipationFilter state;
  final bool isMissing;
  final ValueChanged<PlayerParticipationFilter> onStateChanged;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    final isTouch = Platform.isAndroid || Platform.isIOS;

    return GestureDetector(
      onLongPress: isTouch ? onRemoved : null,
      child: InputChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(playerName),
            if (isMissing) ...[
              const SizedBox(width: 4),
              const Icon(Icons.sentiment_dissatisfied, size: 16),
            ],
          ],
        ),
        avatar: _stateIcon(),
        selected: state != PlayerParticipationFilter.any,
        showCheckmark: false,
        onSelected: (_) => _cycleState(),
        onDeleted: isTouch ? null : onRemoved,
        deleteIcon: isTouch ? null : const Icon(Icons.clear),
        backgroundColor: _backgroundColor(context),
        side: state == PlayerParticipationFilter.any
            ? BorderSide(color: Theme.of(context).dividerColor)
            : null,
      ),
    );
  }

  Widget? _stateIcon() {
    return switch (state) {
      PlayerParticipationFilter.any => null,
      PlayerParticipationFilter.played => const Icon(Icons.thumb_up, size: 18),
      PlayerParticipationFilter.notPlayed => const Icon(
        Icons.thumb_down,
        size: 18,
      ),
    };
  }

  Color? _backgroundColor(BuildContext context) {
    return switch (state) {
      PlayerParticipationFilter.any => Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha(100),
      PlayerParticipationFilter.played => Colors.green.withAlpha(40),
      PlayerParticipationFilter.notPlayed => Colors.red.withAlpha(40),
    };
  }

  void _cycleState() {
    final next = switch (state) {
      PlayerParticipationFilter.any => PlayerParticipationFilter.played,
      PlayerParticipationFilter.played => PlayerParticipationFilter.notPlayed,
      PlayerParticipationFilter.notPlayed => PlayerParticipationFilter.any,
    };
    onStateChanged(next);
  }
}

class _PlayerCountRangeSlider extends StatelessWidget {
  const _PlayerCountRangeSlider({
    required this.label,
    required this.minPlayers,
    required this.maxPlayers,
    required this.onChanged,
  });

  final String label;
  final int? minPlayers;
  final int? maxPlayers;
  final void Function(int? min, int? max) onChanged;

  @override
  Widget build(BuildContext context) {
    final min = PlayerCountRange.min.toDouble();
    final max = PlayerCountRange.max.toDouble();
    final divisions = PlayerCountRange.max - PlayerCountRange.min;

    final start = (minPlayers ?? PlayerCountRange.min).toDouble();
    final end = (maxPlayers ?? PlayerCountRange.max).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        RangeSlider(
          values: RangeValues(start, end),
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels('${start.toInt()}', '${end.toInt()}'),
          onChanged: (values) {
            final newMin = values.start.round();
            final newMax = values.end.round();
            onChanged(
              newMin == PlayerCountRange.min ? null : newMin,
              newMax == PlayerCountRange.max ? null : newMax,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('${start.toInt()}'), Text('${end.toInt()}')],
          ),
        ),
      ],
    );
  }
}

class _RatingRangeSlider extends StatelessWidget {
  const _RatingRangeSlider({
    required this.label,
    required this.minRating,
    required this.maxRating,
    required this.onChanged,
  });

  final String label;
  final double? minRating;
  final double? maxRating;
  final void Function(double? min, double? max) onChanged;

  @override
  Widget build(BuildContext context) {
    final divisions = RatingSteps.divisions;
    final min = RatingSteps.min;
    final max = RatingSteps.max;

    final start = minRating ?? min;
    final end = maxRating ?? max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        RangeSlider(
          values: RangeValues(start, end),
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels(start.toStringAsFixed(1), end.toStringAsFixed(1)),
          onChanged: (values) {
            final newMin = RatingSteps.snap(values.start);
            final newMax = RatingSteps.snap(values.end);
            onChanged(
              newMin == min ? null : newMin,
              newMax == max ? null : newMax,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(start.toStringAsFixed(1)),
              Text(end.toStringAsFixed(1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberFilterField extends StatefulWidget {
  const _NumberFilterField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  State<_NumberFilterField> createState() => _NumberFilterFieldState();
}

class _NumberFilterFieldState extends State<_NumberFilterField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value != null ? _formatValue(widget.value!) : '',
    );
  }

  @override
  void didUpdateWidget(_NumberFilterField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText = widget.value != null ? _formatValue(widget.value!) : '';
    if (_controller.text != newText) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(labelText: widget.label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        final parsed = double.tryParse(text.replaceAll(',', '.'));
        widget.onChanged(parsed);
      },
    );
  }

  String _formatValue(double value) {
    return value.toStringAsFixed(1);
  }
}

class _PlayTimeRangeSlider extends StatelessWidget {
  const _PlayTimeRangeSlider({
    required this.label,
    required this.minPlayTime,
    required this.maxPlayTime,
    required this.onChanged,
  });

  final String label;
  final int? minPlayTime;
  final int? maxPlayTime;
  final void Function(int? min, int? max) onChanged;

  @override
  Widget build(BuildContext context) {
    final steps = PlayTimeSteps.values;
    final maxIndex = steps.length - 1;

    final minIndex = PlayTimeSteps.indexOf(minPlayTime ?? steps.first) ?? 0;
    final maxIndexValue =
        PlayTimeSteps.indexOf(maxPlayTime ?? steps.last) ?? maxIndex;

    final min = RangeValues(minIndex.toDouble(), maxIndexValue.toDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        RangeSlider(
          values: min,
          min: 0,
          max: maxIndex.toDouble(),
          divisions: maxIndex,
          labels: RangeLabels(
            '${steps[minIndex]} min',
            '${steps[maxIndexValue]} min',
          ),
          onChanged: (values) {
            final newMin = PlayTimeSteps.minutesAt(values.start.round());
            final newMax = PlayTimeSteps.minutesAt(values.end.round());
            onChanged(
              newMin == steps.first ? null : newMin,
              newMax == steps.last ? null : newMax,
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${steps[minIndex]} min'),
              Text('${steps[maxIndexValue]} min'),
            ],
          ),
        ),
      ],
    );
  }
}
