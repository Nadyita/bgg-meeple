This is a delta spec capturing the changes made to the `game-detail` capability.

## ADDED Requirements

### Requirement: Detail page labels are concise and grammatically correct
All labels used on the detail page SHALL be concise and fit their interpolation context. Labels that are appended directly to a numeric value SHALL be plain nouns and SHALL NOT repeat counting words such as "Anzahl" or "Number of".

#### Scenario: User count label fits the parenthesized rating format
- **WHEN** the app shows the rating together with the user count
- **THEN** the formatted line uses a short, grammatically correct label after the number, e.g. `6.19 (5567 votes)` in English
- **AND** the German equivalent reads as `6.19 (5567 Bewertungen)`
