This is a delta spec capturing the changes made to the `game-detail` capability.

## ADDED Requirements

### Requirement: Detail page only contains defined details
The detail page SHALL show only the details listed in the strict-order requirement.
No additional game metadata is displayed.

#### Scenario: No extra details are shown
- **WHEN** the app shows the detail page for a game
- **THEN** only the fields listed in the strict order are visible
- **AND** description, categories, mechanics, designers, publishers, weight, and any other game metadata are not shown
