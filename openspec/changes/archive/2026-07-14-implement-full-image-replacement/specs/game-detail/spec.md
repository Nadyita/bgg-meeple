## MODIFIED Requirements

### Requirement: Detail page shows cached full image behind thumbnail
The detail page SHALL show the game's thumbnail immediately. The full-resolution game image SHALL be loaded lazily, cached locally, and replace the thumbnail once available.

#### Scenario: Full image loads lazily
- **WHEN** the user opens a detail page
- **THEN** the thumbnail is shown immediately, the full image is loaded and cached in the background, and the full image replaces the thumbnail once loaded
