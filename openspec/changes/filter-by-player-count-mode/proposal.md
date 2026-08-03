# Feature: Filter collection by player count mode (publisher/recommended/best)

## Summary

The player count filter currently only considers the publisher-specified `minPlayers`/`maxPlayers`. This feature adds a segmented button to the filter panel so users can switch the filter to match the BGG-recommended or BGG-best player count ranges instead.

## Motivation

- A game may officially support 1–6 players, but the BGG community may recommend 3–4 and consider 4 the best. Users want to filter their collection by the community consensus rather than the publisher range.
- The data is already cached on collection items after the previous change, so it can be used for filtering without additional lookups.

## Proposed Solution

1. Introduce a `PlayerCountFilterMode` enum with values `publisher`, `recommended`, and `best`.
2. Add the enum to `CollectionFilter` with a default of `publisher`.
3. Persist the mode in `CollectionView` serialization.
4. Update `CollectionBloc` filtering so the player count range is evaluated against the selected source.
5. Add a `SegmentedButton<PlayerCountFilterMode>` above the existing player count slider in the filter panel.
6. Keep the slider values when the mode changes; only the evaluation source changes.
7. Ensure clearing filters resets the slider values but keeps the selected mode.
8. Add localized labels for the three segments.
9. Write tests for serialization, filtering, and UI interaction.

## Affected Capabilities

- `search-and-filter` – adds the player count filter mode and updates filtering logic.
- `card-layout` – remains independent; only documents the separation of concerns.

## Alternatives Considered

- Separate sliders for publisher/recommended/best. Rejected because it would clutter the filter panel and make overlapping filters confusing.
- Dropdown instead of segmented button. Rejected per user preference for segmented button.
- Persist mode as part of card layout. Rejected because it is a filter/view state concern, not a display preference.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] Serialized view state changes
