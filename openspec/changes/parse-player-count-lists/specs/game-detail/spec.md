# game-detail delta spec

## Purpose

Updates the player count line on the game detail page so best and recommended player counts are rendered with the original textual value from BGG, localized with the appropriate "Players" / "Spieler" label.

## MODIFIED Requirements

### Requirement: Show best and recommended player counts with the original BGG value
The detail page SHALL display best and recommended player counts using the stored `bestPlayerCount` / `recommendedPlayerCount` display strings from the `/thing` data, rather than synthesizing them from the numeric min/max fields.

#### Scenario: List of best player counts
- **GIVEN** `bestPlayerCount` is "6, 8" and the base range is 1–8 players
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 1 - 8 Players (Best: 6, 8 Players)`

#### Scenario: Mixed recommended list
- **GIVEN** `recommendedPlayerCount` is "4, 6-10, 12" and the base range is 1–12 players
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 1 - 12 Players (Recommended: 4, 6-10, 12 Players)`

### Requirement: Localize the player count value label
The detail page SHALL append a localized player count noun to the numeric/textual best and recommended values. In English the noun SHALL be "Players", in German "Spieler".

#### Scenario: English localization
- **GIVEN** the app locale is English
- **WHEN** a best value of "6, 8" is rendered
- **THEN** it shows `Best: 6, 8 Players`

#### Scenario: German localization
- **GIVEN** the app locale is German
- **WHEN** a best value of "6, 8" is rendered
- **THEN** it shows `Beste: 6, 8 Spieler`
