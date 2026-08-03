# game-detail delta spec

## Purpose

Adds the community-suggested player age and the language-dependence level to the game detail screen.

## MODIFIED Requirements

### Requirement: Suggested player age is shown next to the minimum age on the detail screen

The game-detail screen SHALL display the `BoardGame.suggestedPlayerAge` directly after the minimum age when both values are available, using a thumbs-up icon.

#### Scenario: Detail screen shows suggested age inline

- **GIVEN** the cached `BoardGame` has `minAge` set to `8`
- **AND** the cached `BoardGame.suggestedPlayerAge` is `"10.0"`
- **WHEN** the game-detail screen is opened
- **THEN** the detail fields include a row like `Min age: 8 · 👍 10` with a separator dot before the suggested age suffix

#### Scenario: Missing suggested age hides the thumbs-up suffix

- **GIVEN** the cached `BoardGame` has `minAge` set to `8`
- **AND** the cached `BoardGame.suggestedPlayerAge` is `null`
- **WHEN** the game-detail screen is opened
- **THEN** the detail row shows only `Min age: 8`

#### Scenario: Missing minimum age hides the row entirely

- **GIVEN** the cached `BoardGame` has `minAge` set to `null`
- **AND** the cached `BoardGame.suggestedPlayerAge` is `"10.0"`
- **WHEN** the game-detail screen is opened
- **THEN** no age row is shown

### Requirement: Language dependence is shown with fixed labels

The game-detail screen SHALL display the `BoardGame.languageDependenceLevel` as a human-readable label when the value is present. The label SHALL be chosen from the following fixed mapping:

- `"1"`: "No necessary in-game text" (German: "Kein Text im Spiel")
- `"2"`: "Some necessary text - easily memorized or small crib sheet" (German: "Wenig Text im Spiel - leicht zu merken oder kleine Spickzettel")
- `"3"`: "Moderate in-game text - needs crib sheet or paste ups" (German: "Moderate Menge Text im Spiel - Spickzettel oder Ergänzungen nötig")
- `"4"`: "Extensive use of text - massive conversion needed to be playable" (German: "Umfangreicher Text im Spiel - große Anpassungen nötig, um spielbar zu sein")
- `"5"`: "Unplayable in another language" (German: "In anderen Sprachen unspielbar")

Unknown level values SHALL be displayed verbatim if the value is non-empty; a missing or empty value SHALL hide the row.

#### Scenario: Language dependence level 1 is shown

- **GIVEN** the cached `BoardGame.languageDependenceLevel` is `"1"`
- **WHEN** the game-detail screen is opened
- **THEN** the detail fields include a row like `Language: No necessary in-game text`

#### Scenario: Language dependence level 3 is shown in German

- **GIVEN** the cached `BoardGame.languageDependenceLevel` is `"3"`
- **AND** the app locale is German
- **WHEN** the game-detail screen is opened
- **THEN** the detail fields include a row like `Sprache: Mittlerer Spieltext - Spickzettel oder Ergänzungen nötig`

#### Scenario: Language dependence is hidden when unavailable

- **GIVEN** the cached `BoardGame.languageDependenceLevel` is `null`
- **WHEN** the game-detail screen is opened
- **THEN** no language-dependence row is shown

### Requirement: Player count row uses icon suffixes for recommended and best counts

When the game-detail screen shows a base player-count range and either a recommended or best player-count range from `/thing`, the row SHALL append the recommended value with a thumbs-up icon and the best value with a trophy icon, separated by a dot. Text labels such as `Recommended:` or `Best:` SHALL NOT be rendered.

#### Scenario: Detail screen shows recommended and best counts as icon suffixes

- **GIVEN** the collection item has `minPlayers` set to `2` and `maxPlayers` set to `7`
- **AND** the cached `BoardGame.recommendedPlayerCount` is `"3-6"`
- **AND** the cached `BoardGame.bestPlayerCount` is `"4-5"`
- **WHEN** the game-detail screen is opened
- **THEN** the players row shows the base range `2 - 7 Players`
- **AND** a thumbs-up icon followed by `3-6` appears after a separator dot
- **AND** a trophy icon followed by `4-5` appears after a separator dot

#### Scenario: Detail screen hides redundant recommended count when it equals best

- **GIVEN** the cached `BoardGame.recommendedPlayerCount` equals the cached `BoardGame.bestPlayerCount`
- **WHEN** the game-detail screen is opened
- **THEN** only the best suffix (trophy icon) is shown
- **AND** the redundant recommended suffix is not shown
