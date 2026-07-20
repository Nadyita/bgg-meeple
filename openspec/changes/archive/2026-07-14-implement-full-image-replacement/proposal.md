# Feature: Implement full image replacement on game detail page

## Summary

Update the game detail page so that the full-resolution game image replaces the thumbnail once it has finished loading and caching, instead of only loading in the background.

## Motivation

The current detail page immediately shows the thumbnail and starts loading the full image, but the thumbnail remains visible. This is confusing because the user sees a low-resolution image indefinitely even when a higher-resolution version is already available. The `game-detail` spec has been updated to require that the full image replaces the thumbnail once loaded.

## Proposed Solution

- Listen for completion of the full-image download/cache operation in the detail page.
- Cross-fade or directly swap the displayed image from thumbnail to full image once the full image is locally available.
- Keep the thumbnail visible while loading and handle errors gracefully (fallback stays on thumbnail).
- Add/update unit and widget tests that verify the replacement behavior.

## Alternatives Considered

- Always show both images stacked. Rejected because it wastes layout space and is visually confusing.
- Show the full image only on user action (for example a tap). Rejected because the spec requires automatic replacement after loading.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `game-detail`: Requirement "Detail page shows cached full image behind thumbnail" now requires the full image to replace the thumbnail after loading.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] UI behavior change
- [x] Test updates required
