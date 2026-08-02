# game-detail delta spec

## Purpose

Extends the game detail page to show the cached game description at the top of the content, with the game image placed in the top-left corner and the description text wrapping around it.

## MODIFIED Requirements

### Requirement: Show game description on the detail page
The detail page SHALL show the game's description at the top of the content, before the existing detail fields. The game image SHALL be placed in the top-left corner and the description text SHALL wrap around it.

#### Scenario: Description appears at the top with wrapped image
- **GIVEN** a board game has a non-empty description
- **WHEN** the app shows the detail page
- **THEN** the game image is displayed in the top-left corner
- **AND** the description text flows around the image
- **AND** the description appears before the previously defined detail fields

#### Scenario: Missing description omits the section
- **GIVEN** a board game has no cached description
- **WHEN** the app shows the detail page
- **THEN** no description text or wrapping image placeholder is shown
- **AND** the remaining detail fields are still displayed in their defined order

### Requirement: Detail page only contains defined details
The detail page SHALL show only the details listed above.
No additional game metadata such as categories, mechanics, designers, publishers, weight, or families is displayed.

#### Scenario: No extra details are shown
- **WHEN** the app shows the detail page for a game
- **THEN** only the fields listed in the strict order are visible
- **AND** categories, mechanics, designers, publishers, weight, and any other game metadata are not shown
