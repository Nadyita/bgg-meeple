# game-detail Specification Update

## MODIFIED Requirements

### Requirement: Show game details in order
The detail page SHALL show the game information in the following vertical order:

1. The game name (identical to the name shown in the overview) in a bold and big font, followed by the status badges (owned, wishlist, etc.) on the same line.
2. Alternate and localized names behind a toggle.
3. The game description, with the game image placed in the top-right corner and the description text flowing around it as a single paragraph using normal line breaking. The description text SHALL be decoded so that HTML entities such as `\u0026shy;` are rendered as their intended characters.
4. A visual separator.
5. The remaining detail fields in the order: Original name, Year published, Version, Players, Playing time, Rating, Rank, Plays.

#### Scenario: Name and status appear above description
- **GIVEN** a board game has a name, status badges, and a description
- **WHEN** the app shows the detail page
- **THEN** the name and status badges are shown first
- **AND** the alternate names toggle appears directly below the name
- **AND** the description block appears below the name and alternate names toggle

#### Scenario: Description appears with image floating right
- **GIVEN** a board game has a non-empty description
- **WHEN** the app shows the detail page
- **THEN** the game image is displayed in the top-right corner of the description block
- **AND** the image is sized between the thumbnail fallback height and the full description text height, but never wider than half the available width or taller than three quarters of the screen height
- **AND** the description text starts at the top-left, fills the space beside the image, and continues in full width below the image as a single paragraph using normal line breaking
- **AND** phrases such as "The Captain's Mistress." are not broken in the middle by custom layout code

#### Scenario: HTML entities in the description are decoded
- **GIVEN** a board game description contains the HTML entity `\u0026shy;`
- **WHEN** the app shows the detail page
- **THEN** the entity is rendered as a soft-hyphen break opportunity and is not shown as literal `\u0026shy;`

#### Scenario: Missing description omits the section
- **GIVEN** a board game has no cached description
- **WHEN** the app shows the detail page
- **THEN** no description text or image placeholder is shown
- **AND** the remaining detail fields are still displayed in their defined order
