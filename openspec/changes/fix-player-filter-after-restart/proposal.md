# Proposal: Fix: Spielerfilter zeigt nach App-Neustart keine Treffer

## Summary

Wenn ein Spielerpartizipations-Filter aktiv ist und die App beendet und neu gestartet wird, zeigt die Sammlungsliste fälschlicherweise „Keine Spiele entsprechen den Filtern.“ an, obwohl passende Spiele vorhanden sind. Dieser Change korrigiert die Initialisierungsreihenfolge im `CollectionBloc` so, dass die geladenen Partien beim erstmaligen Anwenden eines persistierten Spielerfilters berücksichtigt werden.

## Motivation

- Benutzerbericht: Nach Filter nach einem Spieler, App-Beendung und Neustart erscheint die Meldung „Keine Spiele entsprechen den Filtern.“
- Ursache: `CollectionBloc._onLoaded` berechnet `filteredItems` in einem einzigen `state.copyWith(...)`. Die Filterlogik greift dabei auf `state.playsInfo` zu, das im alten Zustand noch leer ist, obwohl die frisch geladenen Partien als Parameter übergeben werden.
- Dies ist ein Regression-ähnlicher Fehler in der Wiederherstellung des View-States und betrifft alle Plattformen (Android, iOS, Linux, Windows, macOS), da der `CollectionBloc` plattformunabhängig ist.

## Affected Capabilities

- `search-and-filter` – Spielerpartizipations-Filter müssen zuverlässig funktionieren, auch wenn sie aus dem persistierten View-State wiederhergestellt werden.
- `sort-and-view-state` – Die Wiederherstellung von Suchtext, Filter und Sortierung muss konsistent mit den geladenen Daten erfolgen.

## Proposed Solution

- `CollectionBloc._apply`, `_matchesFilter` und `_effectivePlayCount` so umbauen, dass `PlaysInfo` explizit übergeben wird, statt implizit aus dem aktuellen `state` zu lesen.
- Alle Aufrufer passen ihren Aufruf an und übergeben entweder die gerade geladene `playsInfo` oder `state.playsInfo`.
- Einen neuen Unit-Test ergänzen, der einen persistierten Spielerfilter zusammen mit geladenen Partien simuliert und prüft, dass das richtige Spiel im Neustart-Zustand sichtbar ist.

## Alternatives Considered

- **Zweistufiges Emit in `_onLoaded`**: Zuerst `playsInfo` in den State schreiben, dann in einem zweiten Schritt `filteredItems` berechnen. Das ist weniger sauber, weil es einen kurzen Zwischenzustand erzeugt, in dem das UI möglicherweise flackert.
- **Lazy-Filterung nach `_onLoaded`**: Ein separates Event auslösen. Fügt un nötige Komplexität hinzu und verzögert die Anzeige.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
