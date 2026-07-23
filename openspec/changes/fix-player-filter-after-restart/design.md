# Design: Fix: Spielerfilter zeigt nach App-Neustart keine Treffer

## Problem Statement

`CollectionBloc._onLoaded` erzeugt in einem einzigen `emit` den geladenen Zustand, inklusive `filteredItems`. Die Filterlogik liest `PlaysInfo` aus `state.playsInfo`, das in diesem Moment aber noch den initial leeren Wert (`const PlaysInfo()`) enthält. Die tatsächlich geladene `playsInfo` ist zwar als Parameter übergeben, wird aber nicht verwendet.

```
_onLoaded:
  items      = loadCollection()
  cardLayout = loadCardLayout()
  view       = loadCollectionView()
  playsInfo  = loadPlaysInfo()

  emit(
    state.copyWith(
      items: items,
      playsInfo: playsInfo,     // neu
      filteredItems: _apply(
        items,
        view.searchText,
        view.filter,
        view.sort,
      ),                         // _apply liest aber state.playsInfo -> noch leer!
    ),
  )
```

## Design Decision

Die internen Hilfsmethoden des `CollectionBloc` werden so umgestaltet, dass `PlaysInfo` ein expliziter Parameter wird. Damit wird die implizite Abhängigkeit vom aktuellen `state` aufgelöst und jeder Aufrufer kann die für die jeweilige Berechnung gültige `PlaysInfo` übergeben.

## Interface Changes

- `List<CollectionItem> _apply(..., PlaysInfo playsInfo)`
- `bool _matchesFilter(CollectionItem item, CollectionFilter filter, PlaysInfo playsInfo)`
- `int _effectivePlayCount(CollectionItem item, CollectionFilter filter, PlaysInfo playsInfo)`
- `_playMatchesPlayerFilter` bleibt unverändert, da sie nur `Play` und `CollectionFilter` benötigt.

## Call-Site Updates

| Method | PlaysInfo to pass |
|--------|-------------------|
| `_onLoaded` | freshly loaded `playsInfo` |
| `_onSyncRequested` | freshly loaded `playsInfo` |
| `_onSynced` | `state.playsInfo` |
| `_onSearchTextChanged` | `state.playsInfo` |
| `_onFilterChanged` | `state.playsInfo` |
| `_onSortChanged` | `state.playsInfo` |
| `_onViewCleared` | `state.playsInfo` |

## Test Additions

- Neuer Unit-Test im `collection_bloc_test.dart`:
  - Persistierter `CollectionView` mit `playerParticipation: {'Markus': PlayerParticipationFilter.played}`.
  - `loadPlaysInfo` liefert `PlaysInfo` mit einer Partie für Thing-ID 1, die „Markus“ enthält.
  - Erwartung: Nach `CollectionLoaded` enthält `filteredItems` genau dieses Spiel.
  - Optional zusätzlicher Test mit Play-Count-Range.

## Files to Modify

- `lib/presentation/blocs/collection/collection_bloc.dart`
- `test/presentation/blocs/collection_bloc_test.dart`

## Non-Goals

- Keine Änderungen an der UI.
- Keine Änderungen an der Persistierung von `CollectionView` oder `PlaysInfo`.
- Keine neuen Use Cases oder Datenbankmigrationen.
