# Feature: BGG /thing Details für Spiele mit API-Key

## Summary

Erweitere die App so, dass bei vorhandenem BGG-API-Key fehlende Spiel-Details über `/xmlapi2/thing` ergänzt werden. Dabei werden Description, bestwith-Spielerzahl, gewichtetes empfohlenes Spieleralter, Sprachabhängigkeits-Level und alle BGG-Links (Kategorien, Mechaniken, Familien, Designer, etc.) mit ihren IDs lokal gespeichert. Die Detail-Seite zeigt die Description prominent an und aktualisiert Details im Hintergrund, wenn sie älter als 30 Tage sind.

## Motivation

Viele Spiele-Details, die über die öffentliche Collection-API nicht oder nur unvollständig geliefert werden, sind für die App nützlich (z.B. Description für die Detail-Seite, Kategorien/Mechaniken für spätere Filter). BGG stellt diese Daten über `/xmlapi2/thing` bereit, aber dieser Endpunkt erfordert einen registrierten API-Key. Der API-Key soll weiterhin als Benutzer-Setting gespeichert werden (nicht eingebaut), damit die App öffentlich veröffentlicht werden kann. Sobald ein Key hinterlegt ist, sollen fehlende Details automatisch nachgeholt werden.

## Affected Capabilities

- `bgg-thing-details` (new) – Defines parsing of `/xmlapi2/thing`, normalized link storage, and lazy refresh of stale details.
- `game-detail` (modified) – Adds the game description to the detail page with a wrapping image layout.

## Proposed Solution

1. **XML-Parsing für `/thing` erweitern**
   - Description aus `item/description`.
   - Beste Spielerzahl aus `poll-summary[@name='suggested_numplayers']/result[@name='bestwith']/@value` (nur Zahl, z.B. "4" oder "5+").
   - Gewichtetes empfohlenes Spieleralter aus `poll[@name='suggested_playerage']` als String mit einer Nachkommastelle.
   - Sprachabhängigkeit als numerisches Level des `result` mit den meisten `numvotes`.
   - BGG-Links (category, mechanic, family, designer, artist, publisher, expansion, implementation) mit `id` und `value`.

2. **Datenbank-Schema erweitern**
   - `BoardGames` bekommt `detailsUpdatedAt` (int, Millisekunden seit Epoch); die JSON-Spalten `categories`, `mechanics`, `families` entfallen.
   - Neue Tabelle `GameLinks(id, type, bggId, name)`.
   - Neue Verknüpfungstabelle `BoardGameLinkRels(gameId, linkId)`.
   - `BoardGame`-Entity verwendet `List<GameLink>` statt drei `List<String>`-Felder.

3. **Aktualisierungsstrategie**
   - **Sync:** Ruft `/thing` nur für Spiele auf, deren `description` leer oder null ist.
   - **Detail-Seite:** Ruft `/thing` im Hintergrund auf, wenn `detailsUpdatedAt` fehlt oder älter als 30 Tage ist. Vorhandene Daten werden sofort angezeigt und danach aktualisiert.

4. **UI**
   - Die Detail-Seite zeigt die Description ganz oben an.
   - Das Spielbild wird links oben in der Ecke platziert; der Description-Text fließt drum herum.

## Alternatives Considered

- **Unnormalisierte Speicherung der Links als JSON:** Verworfen, weil späteres Suchen/Filter nach Kategorie, Mechanik oder Familie deutlich schwieriger wird.
- **Nur die drei explizit genannten Link-Typen (category, mechanic, family) speichern:** Verworfen, weil Designer/Artist/Publisher/Expansions ähnlich geparst werden und die zusätzliche Datenmenge vernachlässigbar ist.

## Impact

- [x] Breaking changes (Entity-Änderung betrifft interne Schnittstellen)
- [x] Database migrations (Schema-Version wird erhöht, Cache-Tabellen werden neu erstellt)
- [ ] API changes
