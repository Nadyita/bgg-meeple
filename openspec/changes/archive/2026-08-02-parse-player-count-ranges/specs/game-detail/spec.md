# game-detail delta spec

## Purpose

Updates the player count line on the game detail page to include best and recommended player ranges from the `/thing` data when they differ from the base player range.

## MODIFIED Requirements

### Requirement: Show combined player count information
The detail page SHALL display the player count as a single line that starts with the base range from `minPlayers`/`maxPlayers` and appends best and recommended ranges only when they differ from the base range or from each other.

#### Scenario: Best and recommended match the base range
- **GIVEN** the base range is 2–4 players, best is 2–4, and recommended is 2–4
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–4 Players`

#### Scenario: Best differs from base, recommended matches best
- **GIVEN** the base range is 2–5 players, best is 3–4, and recommended is 3–4
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–5 Players (Best: 3–4 Players)`

#### Scenario: Recommended differs from best
- **GIVEN** the base range is 2–7 players, recommended is 3–6, and best is 4–5
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–7 Players (Recommended: 3–6 Players, Best: 4–5 Players)`

#### Scenario: Open-ended best range
- **GIVEN** the base range is 2–7 players and best starts at 8 with no upper bound
- **WHEN** the detail page formats the line
- **THEN** it shows `Players 2–7 Players (Best: 8+ Players)`
