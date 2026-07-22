import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/use_cases/load_card_layout_use_case.dart';
import '../../../application/use_cases/load_collection_use_case.dart';
import '../../../application/use_cases/load_collection_view_use_case.dart';
import '../../../application/use_cases/load_credentials_use_case.dart';
import '../../../application/use_cases/load_play_player_names_use_case.dart';
import '../../../application/use_cases/save_collection_view_use_case.dart';
import '../../../application/use_cases/sync_collection_use_case.dart';
import '../../../domain/entities/collection_item.dart';
import '../../../domain/value_objects/collection_filter.dart';
import '../../../domain/value_objects/collection_sort.dart';
import '../../../domain/value_objects/collection_sub_type.dart';
import '../../../domain/value_objects/collection_view.dart';
import 'collection_event.dart';
import 'collection_state.dart';

/// BLoC for the main collection list.
///
/// Loads the cached collection and applies search, filters, and sorting.
/// Persists the current view state (search text, filters, sort order) so it can
/// be restored on the next app start.
///
/// Error messages are stored as localization builders rather than pre-formatted
/// strings. This keeps the BLoC independent of [AppLocalizations] (an
/// InheritedWidget), which must not be accessed during BLoC construction or in
/// async event handlers that outlive the widget tree.
///
/// Routes all collection events through a single sequential transformer so that
/// async handlers (e.g. loading the collection) complete before dependent sync
/// handlers (e.g. search/filter/sort) read the loaded state. The default BLoC
/// transformer processes different event types concurrently, which would allow
/// a search event added right after [CollectionLoaded] to run before the items
/// are available.
EventTransformer<E> _sequential<E>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  CollectionBloc({
    required this.loadCollection,
    required this.loadCardLayout,
    required this.loadCollectionView,
    required this.saveCollectionView,
    required this.loadCredentials,
    required this.loadPlayPlayerNames,
    this.syncCollection,
  }) : super(const CollectionState()) {
    on<CollectionEvent>(_onEvent, transformer: _sequential());
  }

  final LoadCollectionUseCase loadCollection;
  final LoadCardLayoutUseCase loadCardLayout;
  final LoadCollectionViewUseCase loadCollectionView;
  final SaveCollectionViewUseCase saveCollectionView;
  final LoadCredentialsUseCase loadCredentials;
  final LoadPlayPlayerNamesUseCase loadPlayPlayerNames;
  final SyncCollectionUseCase? syncCollection;

  Future<void> _onEvent(
    CollectionEvent event,
    Emitter<CollectionState> emit,
  ) async {
    switch (event) {
      case CollectionLoaded():
        await _onLoaded(event, emit);
      case CollectionSearchTextChanged():
        _onSearchTextChanged(event, emit);
      case CollectionFilterChanged():
        _onFilterChanged(event, emit);
      case CollectionSortChanged():
        _onSortChanged(event, emit);
      case CollectionSynced():
        _onSynced(event, emit);
      case CollectionCardLayoutReloaded():
        await _onCardLayoutReloaded(event, emit);
      case CollectionSyncRequested():
        await _onSyncRequested(event, emit);
      case CollectionCompactModeToggled():
        _onCompactModeToggled(event, emit);
      case CollectionViewCleared():
        _onViewCleared(event, emit);
    }
  }

  Future<void> _onLoaded(
    CollectionLoaded event,
    Emitter<CollectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final items = await loadCollection();
      final cardLayout = await loadCardLayout();
      final view = await _loadViewOrDefault();
      final credentials = await loadCredentials();
      final playerNamesByGame = await loadPlayPlayerNames();
      emit(
        state.copyWith(
          isLoading: false,
          items: items,
          cardLayout: cardLayout,
          playerNamesByGame: playerNamesByGame,
          searchText: view.searchText,
          filter: view.filter,
          sort: view.sort,
          hasCredentials: credentials?.isValid ?? false,
          filteredItems: _apply(items, view.searchText, view.filter, view.sort),
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorBuilder: (localizations) =>
              localizations.errorLoadCollection(e.toString()),
        ),
      );
    }
  }

  void _onSearchTextChanged(
    CollectionSearchTextChanged event,
    Emitter<CollectionState> emit,
  ) {
    final newState = state.copyWith(
      searchText: event.searchText,
      filteredItems: _apply(
        state.items,
        event.searchText,
        state.filter,
        state.sort,
      ),
      clearError: true,
    );
    emit(newState);
    _persistViewState(newState);
  }

  void _onFilterChanged(
    CollectionFilterChanged event,
    Emitter<CollectionState> emit,
  ) {
    final newState = state.copyWith(
      filter: event.filter,
      filteredItems: _apply(
        state.items,
        state.searchText,
        event.filter,
        state.sort,
      ),
      clearError: true,
    );
    emit(newState);
    _persistViewState(newState);
  }

  void _onSortChanged(
    CollectionSortChanged event,
    Emitter<CollectionState> emit,
  ) {
    final newState = state.copyWith(
      sort: event.sort,
      filteredItems: _apply(
        state.items,
        state.searchText,
        state.filter,
        event.sort,
      ),
      clearError: true,
    );
    emit(newState);
    _persistViewState(newState);
  }

  void _onSynced(CollectionSynced event, Emitter<CollectionState> emit) {
    emit(
      state.copyWith(
        items: event.items,
        filteredItems: _apply(
          event.items,
          state.searchText,
          state.filter,
          state.sort,
        ),
        clearError: true,
      ),
    );
  }

  Future<CollectionView> _loadViewOrDefault() async {
    try {
      return await loadCollectionView();
    } on Exception {
      // A corrupt or missing stored view config must not break the collection
      // screen. Fall back to the default view state silently.
      return const CollectionView();
    }
  }

  Future<void> _onCardLayoutReloaded(
    CollectionCardLayoutReloaded event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      final cardLayout = await loadCardLayout();
      emit(state.copyWith(cardLayout: cardLayout, clearError: true));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          errorBuilder: (localizations) =>
              localizations.errorLoadCardLayout(e.toString()),
        ),
      );
    }
  }

  Future<void> _onSyncRequested(
    CollectionSyncRequested event,
    Emitter<CollectionState> emit,
  ) async {
    emit(
      state.copyWith(
        isSyncing: true,
        clearError: true,
        clearSyncProgress: true,
      ),
    );

    final useCase = syncCollection;
    if (useCase == null) {
      emit(
        state.copyWith(
          isSyncing: false,
          errorBuilder: (localizations) => localizations.errorSyncUnavailable,
        ),
      );
      return;
    }

    try {
      await useCase(
        onProgress: (progress) {
          emit(
            state.copyWith(
              syncProgress: '${progress.phase}: ${progress.loaded}',
            ),
          );
        },
      );
      final items = await loadCollection();
      final playerNamesByGame = await loadPlayPlayerNames();
      emit(
        state.copyWith(
          isSyncing: false,
          items: items,
          playerNamesByGame: playerNamesByGame,
          filteredItems: _apply(
            items,
            state.searchText,
            state.filter,
            state.sort,
          ),
          clearSyncProgress: true,
          clearError: true,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          isSyncing: false,
          clearSyncProgress: true,
          errorBuilder: (localizations) =>
              localizations.errorSyncFailed(e.toString()),
        ),
      );
    }
  }

  void _onCompactModeToggled(
    CollectionCompactModeToggled event,
    Emitter<CollectionState> emit,
  ) {
    final newState = state.copyWith(
      isCompactMode: !state.isCompactMode,
      clearError: true,
    );
    emit(newState);
  }

  void _onViewCleared(
    CollectionViewCleared event,
    Emitter<CollectionState> emit,
  ) {
    final newState = state.copyWith(
      searchText: '',
      filter: const CollectionFilter(),
      sort: const CollectionSort(),
      filteredItems: _apply(
        state.items,
        '',
        const CollectionFilter(),
        const CollectionSort(),
      ),
      clearError: true,
    );
    emit(newState);
    _persistViewState(newState);
  }

  void _persistViewState(CollectionState newState) {
    unawaited(
      _saveViewState(
        searchText: newState.searchText,
        filter: newState.filter,
        sort: newState.sort,
      ),
    );
  }

  Future<void> _saveViewState({
    required String searchText,
    required CollectionFilter filter,
    required CollectionSort sort,
  }) async {
    try {
      await saveCollectionView(
        CollectionView(searchText: searchText, filter: filter, sort: sort),
      );
    } on Exception {
      // Persistence failures must not break the collection screen or surface
      // an error to the user. The in-memory state is already emitted.
    }
  }

  List<CollectionItem> _apply(
    List<CollectionItem> items,
    String searchText,
    CollectionFilter filter,
    CollectionSort sort,
  ) {
    var result = items.where((item) {
      return _matchesSearch(item, searchText) && _matchesFilter(item, filter);
    }).toList();

    result = _sort(result, sort);
    return result;
  }

  bool _matchesSearch(CollectionItem item, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final searchable = _searchableText(item).toLowerCase();
    return searchable.contains(normalizedQuery);
  }

  String _searchableText(CollectionItem item) {
    final buffer = StringBuffer();
    if (item.customName != null && item.customName!.isNotEmpty) {
      buffer.write('${item.customName!} ');
    }
    for (final name in item.names) {
      if (name.value.isNotEmpty) {
        buffer.write('${name.value} ');
      }
    }
    return buffer.toString().trim();
  }

  bool _matchesFilter(CollectionItem item, CollectionFilter filter) {
    if (filter.selectedSubTypes.isNotEmpty) {
      final matchesAnySubType = filter.selectedSubTypes.any(
        (subType) => _matchesSubType(item, subType),
      );
      if (!matchesAnySubType) {
        return false;
      }
    }

    final itemMinPlayers = item.minPlayers ?? 1;
    final itemMaxPlayers = item.maxPlayers;
    if (filter.minPlayers != null &&
        itemMaxPlayers != null &&
        itemMaxPlayers < filter.minPlayers!) {
      return false;
    }
    if (filter.maxPlayers != null && itemMinPlayers > filter.maxPlayers!) {
      return false;
    }

    final effectivePlayTime = item.maxPlayTime ?? item.minPlayTime;
    if (filter.minPlayTime != null &&
        (effectivePlayTime == null ||
            effectivePlayTime < filter.minPlayTime!)) {
      return false;
    }
    if (filter.maxPlayTime != null &&
        (effectivePlayTime == null ||
            effectivePlayTime > filter.maxPlayTime!)) {
      return false;
    }

    final effectiveRating = item.ownRating ?? item.bayesAverage;
    if (filter.minRating != null &&
        (effectiveRating == null || effectiveRating < filter.minRating!)) {
      return false;
    }
    if (filter.maxRating != null &&
        (effectiveRating == null || effectiveRating > filter.maxRating!)) {
      return false;
    }

    return true;
  }

  bool _matchesSubType(CollectionItem item, CollectionSubType subType) {
    return switch (subType) {
      CollectionSubType.owned => item.isOwned,
      CollectionSubType.preordered => item.isPreordered,
      CollectionSubType.wishlisted => item.isWishlisted,
      CollectionSubType.wantToPlay => item.isWantToPlay,
      CollectionSubType.wantToBuy => item.isWantToBuy,
      CollectionSubType.previouslyOwned => item.isPrevOwned,
      CollectionSubType.played => item.isPlayed,
      CollectionSubType.rated => item.isRated,
      CollectionSubType.forTrade => item.isForTrade,
      CollectionSubType.wantInTrade => item.isWantInTrade,
      CollectionSubType.hasComment => item.hasComment,
    };
  }

  List<CollectionItem> _sort(List<CollectionItem> items, CollectionSort sort) {
    final sorted = List<CollectionItem>.of(items);
    final compare = _compareFor(sort.sortBy);

    sorted.sort((a, b) {
      final result = compare(a, b);
      return sort.ascending ? result : -result;
    });

    return sorted;
  }

  int Function(CollectionItem, CollectionItem) _compareFor(SortBy sortBy) {
    return switch (sortBy) {
      SortBy.name => (a, b) => _compareStrings(
        a.displayName(preferredLanguage: 'de'),
        b.displayName(preferredLanguage: 'de'),
      ),
      SortBy.playTime => (a, b) => _compareInts(
        a.maxPlayTime ?? a.minPlayTime ?? 0,
        b.maxPlayTime ?? b.minPlayTime ?? 0,
      ),
      SortBy.bggRating => (a, b) => _compareDoubles(
        a.bayesAverage ?? 0,
        b.bayesAverage ?? 0,
      ),
      SortBy.year => (a, b) => _compareInts(
        a.yearPublished ?? 0,
        b.yearPublished ?? 0,
      ),
    };
  }

  int _compareStrings(String a, String b) {
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  int _compareInts(int a, int b) => a.compareTo(b);

  int _compareDoubles(double a, double b) => a.compareTo(b);
}
