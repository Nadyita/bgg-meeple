import 'package:equatable/equatable.dart';

import '../../../domain/entities/collection_item.dart';
import '../../../domain/value_objects/card_layout_config.dart';
import '../../../domain/value_objects/collection_filter.dart';
import '../../../domain/value_objects/collection_sort.dart';
import '../../l10n/app_localizations.dart';

import '../../../domain/value_objects/plays_info.dart';

/// Description of an error that should be localized before it is shown to the
/// user. Storing a builder instead of a pre-formatted string keeps the BLoC
/// free of [AppLocalizations], which is an InheritedWidget and cannot be
/// safely accessed during BLoC construction.
typedef LocalizedErrorBuilder = String Function(AppLocalizations localizations);

/// State for [CollectionBloc].
class CollectionState extends Equatable {
  const CollectionState({
    this.isLoading = false,
    this.isSyncing = false,
    this.items = const [],
    this.filteredItems = const [],
    this.searchText = '',
    this.filter = const CollectionFilter(),
    this.sort = const CollectionSort(),
    this.cardLayout = const CardLayoutConfig(),
    this.playsInfo = const PlaysInfo(),
    this.hasCredentials = false,
    this.isCompactMode = false,
    this.syncProgress,
    this.errorBuilder,
  });

  final bool isLoading;
  final bool isSyncing;
  final List<CollectionItem> items;
  final List<CollectionItem> filteredItems;
  final String searchText;
  final CollectionFilter filter;
  final CollectionSort sort;
  final CardLayoutConfig cardLayout;
  final PlaysInfo playsInfo;
  final bool hasCredentials;
  final bool isCompactMode;
  final String? syncProgress;
  final LocalizedErrorBuilder? errorBuilder;

  /// Convenience accessor that formats the current error for the given locale.
  String? errorMessage(AppLocalizations localizations) =>
      errorBuilder?.call(localizations);

  CollectionState copyWith({
    bool? isLoading,
    bool? isSyncing,
    List<CollectionItem>? items,
    List<CollectionItem>? filteredItems,
    String? searchText,
    CollectionFilter? filter,
    CollectionSort? sort,
    CardLayoutConfig? cardLayout,
    PlaysInfo? playsInfo,
    bool? hasCredentials,
    bool? isCompactMode,
    String? syncProgress,
    LocalizedErrorBuilder? errorBuilder,
    bool clearError = false,
    bool clearSyncProgress = false,
  }) {
    return CollectionState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      searchText: searchText ?? this.searchText,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      cardLayout: cardLayout ?? this.cardLayout,
      playsInfo: playsInfo ?? this.playsInfo,
      hasCredentials: hasCredentials ?? this.hasCredentials,
      isCompactMode: isCompactMode ?? this.isCompactMode,
      syncProgress: clearSyncProgress
          ? null
          : (syncProgress ?? this.syncProgress),
      errorBuilder: clearError ? null : (errorBuilder ?? this.errorBuilder),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSyncing,
    items,
    filteredItems,
    searchText,
    filter,
    sort,
    cardLayout,
    playsInfo,
    hasCredentials,
    isCompactMode,
    syncProgress,
    errorBuilder,
  ];
}
