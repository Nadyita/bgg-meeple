# Feature: Inventory-Location als konfigurierbares Kartenfeld

## Summary

Die App soll das BGG-Feld `inventorylocation` aus der Sammlung auslesen, lokal speichern und als optionales, konfigurierbares Feld auf den Sammlungskarten anzeigen. Das Feld wird nur angezeigt, wenn ein nicht-leerer Wert vorhanden ist.

## Motivation

- Nutzer, die ihre Sammlung in BGG mit einem Lagerort pflegen (z. B. „Keller", „Eva"), möchten diesen Ort direkt in der Übersicht sehen, ohne jedes Spiel einzeln zu öffnen.
- Das Feld ist Teil der privaten Sammlungsinformationen und wird von `/xmlapi2/collection` nur zurückgegeben, wenn der Parameter `showprivate=1` gesetzt ist.
- Die Anzeige soll analog zur Anzahl gespielter Partien erfolgen: konfigurierbar ein- und ausblendbar und bei leerem Wert automatisch verborgen.

## Affected Capabilities

- `bgg-sync` – Der Collection-Request muss `showprivate=1` senden und das Attribut `inventorylocation` aus `<privateinfo>` parsen.
- `card-layout` – Die Kartenlayout-Einstellungen erhalten ein neues, umschaltbares Feld `inventoryLocation`.
- `collection-list` – Die Sammlungskarten zeigen den Lagerort an, sobald ein Wert vorhanden ist.

## Proposed Solution

1. In `BggApiClient.fetchCollection` wird der Query-Parameter `showprivate=1` ergänzt.
2. In `_parseCollectionItem` wird das Element `<privateinfo>` ausgelesen und das Attribut `inventorylocation` mit `.trim()` bereinigt gespeichert. Leere Werte werden zu `null`.
3. `CollectionItem` erhält ein neues Feld `inventoryLocation` (nullable `String`).
4. In der Drift-Tabelle `CollectionItems` wird eine neue nullable Text-Spalte `inventoryLocation` hinzugefügt und die Schema-Version erhöht.
5. `DriftCollectionStore` mappt das neue Feld beim Schreiben und Lesen.
6. Der Enum `CardField` wird um `inventoryLocation` erweitert.
7. `CardLayoutConfig` behandelt das neue Feld als normales, konfigurierbares Feld (es ist in der Default-Liste nicht aktiv).
8. `CollectionCard` zeigt das Feld nur an, wenn `item.inventoryLocation` nicht `null` und nicht leer ist; ansonsten wird die Zeile ausgelassen (wie bei `hidePlaysOnZero`).
9. In den Einstellungen (`settings_page.dart`) wird die deutsche und englische Übersetzung für das neue Feld ergänzt.
10. Unit-/Widget-Tests prüfen das XML-Parsing, die Datenbank-Roundtrip und die bedingte Anzeige.

## Alternatives Considered

- **Lagerort immer anzeigen (auch wenn leer)**: Würde die Karten unübersichtlich machen und passt nicht zur gewünschten Anzeige-Logik.
- **Lagerort nicht konfigurierbar, sondern fest einblenden**: Würde die Benutzerfreiheit einschränken, die App sonst bei allen Metadaten-Feldern bietet.
- **Whitespace nicht entfernen**: BGG liefert oft Leerzeichen am Ende (z. B. `"Eva "`), daher muss der Wert bereinigt werden.

## Impact

- [ ] Breaking changes
- [x] Database migrations
- [x] API changes
