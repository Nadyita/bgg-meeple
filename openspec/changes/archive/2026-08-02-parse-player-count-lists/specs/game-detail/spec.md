# game-detail delta spec

## Purpose

Updates the player count line on the game detail page so best and recommended player counts are rendered with the original textual value from BGG, localized with the appropriate "Players" / "Spieler" label.

## MODIFIED Requirements

### Requirement: Show combined player count information
The detail page SHALL display the player count as a single line that starts with the base range from `minPlayers`/`maxPlayers` and appends best and recommended ranges only when they differ from the base range or from each other. Best and recommended values SHALL be rendered using the stored textual value from BGG, appended with the localized "Players" / "Spieler" label.

#### Scenario: Best and recommended match the base range
- **GIVEN** the base range is 2–4 players, best is 2–4, and recommended is 2–4
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–4 Players`

#### Scenario: Best differs from base, recommended matches best
- **GIVEN** the base range is 2–5 players, best is 3–4, and recommended is 3–4
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–5 Players (Best: 3-4 Players)`

#### Scenario: Recommended differs from best
- **GIVEN** the base range is 2–7 players, recommended is 3–6, and best is 4–5
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–7 Players (Recommended: 3-6 Players, Best: 4-5 Players)`

#### Scenario: Open-ended best range
- **GIVEN** the base range is 2–7 players and best starts at 8 with no upper bound
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–7 Players (Best: 8+ Players)`

#### Scenario: Comma-separated best and recommended lists
- **GIVEN** the base range is 1–12 players, best is "6, 8", and recommended is "4, 6-10, 12"
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 1 - 12 Players (Recommended: 4, 6-10, 12 Players, Best: 6, 8 Players)`

#### Scenario: German localization for player count lists
- **GIVEN** the app locale is German
- **AND** the base range is 1–12 players, best is "6, 8", and recommended is "4, 6-10, 12"
- **WHEN** the detail page formats the line
- **THEN** it shows `Spieler 1 - 12 Spieler (Empfohlen: 4, 6-10, 12 Spieler, Beste: 6, 8 Spieler)`
