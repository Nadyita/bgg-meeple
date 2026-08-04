# game-detail delta spec

## Purpose

Changes the full-size image source priority on the game detail page so that the user's own collection image is preferred over the generic `/xmlapi2/thing` image, which may represent a different language edition.

## MODIFIED Requirements

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
