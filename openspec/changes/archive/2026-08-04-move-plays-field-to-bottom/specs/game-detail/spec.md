# game-detail delta spec

## Purpose

Moves the played-games count (`Plays`) to the bottom of the detail field list on the game detail page.

## MODIFIED Requirements

### Requirement: Played-games count is the last detail field

The detail page SHALL display the remaining detail fields in the following vertical order: Original name, Year published, Version, Players, Playing time, Min age, Language dependence, Rating, Rank, Plays.

#### Scenario: Played-games count is the last field

- **GIVEN** a board game has values for min age, language dependence, rating, rank, and number of plays
- **WHEN** the app shows the detail page
- **THEN** the rows appear in this order: Min age, Language dependence, Rating, Rank, Plays
- **AND** Plays is the last detail field before the external BGG link

#### Scenario: Played-games count remains last when optional fields are missing

- **GIVEN** a board game has values for rating, rank, and number of plays, but no min age and no language dependence
- **WHEN** the app shows the detail page
- **THEN** Plays is still rendered after the earlier fields (Original name, Year published, Version, Players, Playing time, Rating, Rank)
- **AND** no detail field appears below Plays
