# game-detail Specification

## Purpose

Defines the game detail page that opens when a collection card is tapped, including the displayed game data, lazy full-image caching, external BGG link, alternate names, and the available close actions.
## Requirements
### Requirement: Tapping a card opens a detail page
Tapping a collection item SHALL open a game detail page for that game.

#### Scenario: Card tap navigates to detail
- **WHEN** the user taps a collection card
- **THEN** the app navigates to the detail page for that game

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
	* Players: <min players> - <max players>
	* One of
		* Playing time: <minplaytime> - <maxplaytime> Min
		* Playing time: <playtime> Min
	* Rating: <rating>.<bayesavg> (<rating>.<usersrated> votes)
	* Rank: <rating>.<ranks.[name=boardgame].value>
	* Plays: <numer of plays>

### Requirement: Detail page only contains defined details
The detail page SHALL show only the details listed above.
No additional game metadata is displayed.

#### Scenario: No extra details are shown
- **WHEN** the app shows the detail page for a game
- **THEN** only the fields listed in the strict order are visible
- **AND** description, categories, mechanics, designers, publishers, weight, and any other game metadata are not shown

### Requirement: Detail page shows cached full image behind thumbnail
The detail page SHALL show the game's thumbnail immediately. The full-resolution game image SHALL be loaded lazily, cached locally, and replace the thumbnail once available.

#### Scenario: Full image loads lazily
- **WHEN** the user opens a detail page
- **THEN** the thumbnail is shown immediately, the full image is loaded and cached in the background, and the full image replaces the thumbnail once loaded

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
