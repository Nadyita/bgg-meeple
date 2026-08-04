# game-detail Specification

## Purpose

Defines the game detail page that opens when a collection card is tapped, including the displayed game data, description layout, lazy full-image caching, external BGG link, alternate names, and the available close actions.
## Requirements
### Requirement: Tapping a card opens a detail page
Tapping a collection item SHALL open a game detail page for that game.

#### Scenario: Card tap navigates to detail
- **WHEN** the user taps a collection card
- **THEN** the app navigates to the detail page for that game

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

### Requirement: Show all details on the detail page
The detail page SHALL show the details in a specific order.

#### Scenario: Game details are in strict order
- **WHEN** the app shows the detail page for a game
- **THEN** the order must be the following:
	* The image of the game in the following size:
		* Maximum 50% width of the screen
		* Maximum 30% height of the screen
	* Name of the game (identical to the name shown in the overview) in a bold and big font
	* the badges of all status (owned, wishlist, etc.) right next to the name
	* A *little* vertical space to separate the name from the rest
	* Original name: <originalname>
	* Year published: <yearpublished>
	* Version: <primary version>.<name>
	* Players: <base player range> [ (Recommended: <recommended range>, Best: <best range>) ]
	* One of
		* Playing time: <minplaytime> - <maxplaytime> Min
		* Playing time: <playtime> Min
	* Rating: <rating>.<bayesavg> (<rating>.<usersrated> votes)
	* Rank: <rating>.<ranks.[name=boardgame].value>
	* Plays: <numer of plays>

### Requirement: Detail page only contains defined details
The detail page SHALL show only the details listed above.
No additional game metadata such as categories, mechanics, designers, publishers, weight, or families is displayed.

#### Scenario: No extra details are shown
- **WHEN** the app shows the detail page for a game
- **THEN** only the fields listed in the strict order are visible
- **AND** categories, mechanics, designers, publishers, weight, and any other game metadata are not shown

### Requirement: Detail page shows cached full image behind thumbnail

The detail page SHALL use the full-size image from the user's collection (`CollectionItem.imageUrl`) as the primary image source. The full-size image from the `/xmlapi2/thing` response (`BoardGame.imageUrl`) SHALL only be used as a fallback when the collection item has no image.

#### Scenario: Full image loads lazily
- **WHEN** the user opens a detail page
- **THEN** the thumbnail is shown immediately, the full image is loaded and cached in the background, and the full image replaces the thumbnail once loaded

#### Scenario: Collection image overrides thing image
- **GIVEN** a collection item has `imageUrl` `https://collection.example/cover.png`
- **AND** the cached `/thing` details for the same game have `imageUrl` `https://thing.example/cover.png`
- **WHEN** the detail page loads the full-size image
- **THEN** the detail page displays `https://collection.example/cover.png`

#### Scenario: Thing image is used when collection has no image
- **GIVEN** a collection item has no `imageUrl`
- **AND** the cached `/thing` details for the same game have `imageUrl` `https://thing.example/cover.png`
- **WHEN** the detail page loads the full-size image
- **THEN** the detail page displays `https://thing.example/cover.png`

#### Scenario: No image when neither source has one
- **GIVEN** a collection item has no `imageUrl`
- **AND** there are no cached `/thing` details for the game
- **WHEN** the detail page loads the full-size image
- **THEN** the detail page shows no full-size image and falls back to the thumbnail if available

### Requirement: Detail page provides external BGG link
The detail page SHALL provide a link to the corresponding BoardGameGeek page with a clearly identifiable external-link icon.

#### Scenario: External link opens BGG page
- **WHEN** the user taps the external BGG link
- **THEN** the BGG page for the game is opened in an external browser

### Requirement: Detail page shows alternate and localized names
The detail page SHALL display all alternate and localized game names behind a toggle.

#### Scenario: Toggle reveals alternate names
- **WHEN** the user expands the alternate names section
- **THEN** all alternate and localized names for the game are shown

### Requirement: Detail page can be closed in multiple ways
The detail page SHALL be closable via the app-bar back arrow, the Escape key, or the system back button or gesture.

#### Scenario: Escape key closes detail page
- **WHEN** the user presses the Escape key on Linux Desktop
- **THEN** the detail page closes and the collection list is shown

### Requirement: Detail page labels are concise and grammatically correct
All labels used on the detail page SHALL be concise and fit their interpolation context. Labels that are appended directly to a numeric value SHALL be plain nouns and SHALL NOT repeat counting words such as "Anzahl" or "Number of".

#### Scenario: User count label fits the parenthesized rating format
- **WHEN** the app shows the rating together with the user count
- **THEN** the formatted line uses a short, grammatically correct label after the number, e.g. `6.19 (5567 votes)` in English
- **AND** the German equivalent reads as `6.19 (5567 Bewertungen)`

