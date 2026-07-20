# Feature: Design Details Page

## Summary

Implement the game detail page that is opened when a user taps a collection card. The page displays all known game data, lazy-loads and caches the full-resolution image, provides an external BoardGameGeek link, shows alternate and localized names behind a toggle, and supports multiple close actions.

## Motivation

The `game-detail` spec defines a central part of the user experience: the transition from the collection overview into a rich detail view for a selected board game. Users need quick access to full game information, an improved image viewing experience, external references, and localized name discovery. The collection list already shows cards; now the detail destination must be implemented.

## Proposed Solution

Add a new detail route/page that receives a game identifier and renders the following content in the exact order required by the spec:

1. Game image, constrained to a maximum of 50% screen width and 30% screen height, with the thumbnail shown immediately while the full-resolution image is loaded lazily and cached locally, replacing the thumbnail once available.
2. Game name in a bold, large font, identical to the name shown in the collection overview.
3. Status badges (owned, wishlist, etc.) directly next to the name.
4. A small vertical spacer separating the name from the remaining details.
5. Metadata lines: original name, year published, primary version, player count, playing time, rating with vote count, board-game rank, and number of plays.
6. External BGG link with a clearly identifiable external-link icon that opens the game's BoardGameGeek page in an external browser.
7. Expandable toggle for alternate and localized game names.

Close support is implemented via the app-bar back arrow, the Escape key on Linux Desktop, and the system back button or gesture, all returning the user to the collection list.

## Affected Capabilities

- `game-detail`
- `collection-list` (navigation source)

## Alternatives Considered

- Bottom sheet instead of a full page: rejected because the spec explicitly describes a navigable detail page with an app bar and back actions.
- In-place expansion in the list: rejected because it does not satisfy the requirement to show all details in a dedicated view.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] UI/UX changes
- [x] New tests required
- [x] New route/page added
