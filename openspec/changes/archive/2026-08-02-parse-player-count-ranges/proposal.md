# Feature: Best und Recommended Spielerzahl als Min/Max-Range parsen

## Summary

Erweitere das Parsing der `/xmlapi2/thing`-Antwort so, dass die empfohlene und beste Spielerzahl aus der `poll-summary` als numerische Min/Max-Werte abgelegt werden. Das ermöglicht späteres Filtern nach konkreten Spielerzahlen. Die bestehenden String-Felder bleiben für die Anzeige erhalten. Wenn keine `poll-summary` vorhanden ist, wird aus dem `poll` selbst ein Fallback berechnet.

## Why

BGG stellt die beste und empfohlene Spielerzahl im `poll-summary`-Text bereit, z. B. `Best with 4–5 players` oder `Recommended with 3–7 players`. Bisher wird nur der erste Wert extrahiert oder die Werte als komma-separierter String gespeichert. Für zukünftige Filter wie „Zeige Spiele für genau 4 Spieler“ brauchen wir stabile numerische Min/Max-Felder.

## What Changes

- Neues Domain-Modell: `BoardGame` erhält `bestPlayerCountMin`, `bestPlayerCountMax`, `recommendedPlayerCountMin`, `recommendedPlayerCountMax`.
- XML-Parsing: `poll-summary`-Werte `bestwith` und `recommendedwith` werden in Min/Max geparst (`X`, `X-Y`, `X+`, `X-Y+`).
- Fallback: Wenn `poll-summary` fehlt, werden die Ranges aus dem Roh-`poll` berechnet.
- Datenbank: Schema-Bump mit vier neuen nullable Int-Spalten.
- UI: Detail-Seite zeigt die Spielerzahl als `Players X[-Y] Players` mit optionalen Best-/Recommended-Zusätzen.

## Affected Capabilities

- `bgg-thing-details` (modified)
- `game-detail` (modified)

## Proposed Solution

1. **Neue Domain-Felder**
   - `BoardGame.bestPlayerCountMin: int?`
   - `BoardGame.bestPlayerCountMax: int?`
   - `BoardGame.recommendedPlayerCountMin: int?`
   - `BoardGame.recommendedPlayerCountMax: int?`

2. **Parsing-Regeln aus `poll-summary`**
   - `bestwith`-Text parsen:
     - `X` → min = X, max = X
     - `X-Y` → min = X, max = Y
     - `X+` → min = X, max = null
     - `X-Y+` → min = X, max = null
   - `recommendedwith`-Text analog.
   - Als Trennzeichen zwischen Zahlen werden `–`, `-` und `—` akzeptiert.

3. **Fallback aus `poll`**
   - Wenn kein `bestwith`- oder `recommendedwith`-Wert vorhanden ist:
     - Best: Alle `numplayers`, bei denen `Best`-Votes maximal sind. Daraus min/max bilden.
     - Recommended: Aufeinanderfolgende `numplayers`, bei denen `Recommended`-Anteil ≥ 50 % ist. Daraus min/max bilden. Bei Lücken wird die längste zusammenhängende Kette genommen.

4. **Datenbank und UI**
   - Schema-Version erhöhen und vier neue Integer-Spalten hinzufügen.
   - Migration: Neue Spalten nullable, kein Datenverlust.
   - Detail-Seite zeigt `bestPlayerCount` und `recommendedPlayerCount` weiterhin als String an (z. B. aus Min/Max berechnet).

## Alternatives Considered

- Nur `bestPlayerCount` / `recommendedPlayerCount` als String behalten: Verworfen, weil Filter nach Spielerzahl dann schwierig.
- Nur aus dem `poll` berechnen und `poll-summary` ignorieren: Verworfen, weil `poll-summary` die offizielle BGG-Empfehlung darstellt und konsistentere Ranges liefert.

## Impact

- [x] Breaking changes (Entity-Änderung betrifft interne Schnittstellen)
- [x] Database migrations
- [ ] API changes
