# Fix: Detail-Seite – Bild floatet und HTML-Entities werden dekodiert

## Summary

Korrigiere zwei sichtbare Fehler auf der Spiel-Detail-Seite:

1. Das Spielbild soll links oben in der Ecke „floaten“ und der Beschreibungstext soll rechts daneben beginnen und unter dem Bild weiterlaufen. Aktuell wird der Text komplett unter dem Bild angezeigt.
2. BGG-Beschreibungen enthalten HTML-Entities wie `&shy;`, `&rsquo;`, `&amp;` etc. Diese sollen vor der Anzeige zu lesbaren Zeichen dekodiert werden.

## Motivation

Die Detail-Seite ist die erste visuelle Rückmeldung der neuen `/thing`-Details. Der Nutzer hat manuell festgestellt, dass das Layout nicht dem gewünschten „Text fließt um das Bild herum“-Verhalten entspricht und dass HTML-Entities in der Beschreibung sichtbar bleiben. Beides muss behoben werden, bevor die Feature abgeschlossen ist.

## Affected Capabilities

- `game-detail` (modified) – Präzisiert das Description-Layout und fügt das Dekodieren von HTML-Entities hinzu.

## Proposed Solution

1. **HTML-Entity-Dekodierung**
   - Füge die Dependency `html_unescape` hinzu.
   - Dekodiere die Beschreibung in der Detail-Seite vor der Anzeige.
   - `&shy;` (soft hyphen) wird in Unicode-U+00AD dekodiert; sichtbare Entities wie `&amp;` werden in ihr Klartext-Äquivalent umgewandelt.

2. **Float-Layout**
   - Ersetze den aktuellen `Wrap`-Ansatz durch ein `LayoutBuilder`-basiertes Widget, das die tatsächlich verfügbare Breite nutzt (statt `MediaQuery.of(context).size.width`, das die Padding-Breite ignoriert).
   - Berechne über `TextPainter`, wie viele Textzeilen neben dem Bild passen.
   - Zeige diese Zeilen rechts neben dem Bild an; den restlichen Text in voller Breite darunter.
   - Bild hat max. 40 % der verfügbaren Breite und max. 220 logische Pixel Höhe.

## Alternatives Considered

- **Einfacher `Wrap` nebeneinander:** Verworfen, weil es kein echtes Float-Verhalten liefert (Text läuft nicht unter das Bild).
- **HTML-Entities händisch ersetzen:** Verworfen, weil BGG-Beschreibungen eine große Bandbreite an Entities enthalten können; `html_unescape` ist klein, getestet und wartungsarm.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] UI/UX refinement
- [x] New dependency (`html_unescape`)
