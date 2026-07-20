# Design: Design Details Page

## Overview

This change implements the game detail page according to the `game-detail` spec. The page is the destination when a user taps a collection card and shows all known information about a single board game.

## Architecture

- The page remains a standalone `MaterialPageRoute` pushed from `CollectionPage._openGameDetail`.
- The existing `LoadGameDetailsUseCase` is reused. It already aggregates `CollectionItem`, `BoardGame`, and the cached full image path.
- No BLoC/Cubit is introduced: the page uses local `StatefulWidget` state for loading, the alternate-name toggle, and the full-image transition, matching the current lightweight page pattern.

## UI/UX Decisions

### Layout

- Content is scrollable (`SingleChildScrollView`) and top-aligned.
- The image is constrained to `maxWidth = 50% of screen width` and `maxHeight = 30% of screen height`.
- The image uses the local cached full image when already available; otherwise it starts from the thumbnail and lazily precaches/replaces with the full image using `CachedNetworkImage` and `precacheImage`.

### Title area

- The primary display name is shown in `headlineSmall` with bold weight, identical to the name shown in the collection overview.
- Collection status chips (owned, wishlist, etc.) are rendered in a `Wrap` directly next to the name, using the same labels and owned-highlighting as `CollectionCard`.
- A `SizedBox(height: 16)` separates the title/status block from the metadata fields.

### Metadata order

The detail fields follow the strict order required by the `game-detail` spec:

1. Original name
2. Year published
3. Version
4. Players
5. Playing time
6. Rating
7. Rank
8. Plays

Additional fields (description, categories, mechanics, designers, publishers, weight, etc.) are shown below this block.

### Rating formatting

The rating line uses the Bayes/average rating available on the collection item or board game and appends the number of ratings when known.

### External link

The app-bar action uses `Icons.open_in_new` and `url_launcher` to open `https://boardgamegeek.com/boardgame/<thingId>` in an external browser.

### Alternate names

A toggle button expands/collapses alternate and localized names. When expanded, the names are shown as `Chip`s.

### Close actions

- App-bar back arrow (`Navigator.pop`).
- Escape key on Linux Desktop via a `Focus` node with `onKeyEvent`.
- System back button/gesture handled automatically by `Navigator`.

## Testing Strategy

- Widget tests verify loading, back navigation, image display, status chips, original name, rating format, field order, and alternate-name toggle.
- `LoadGameDetailsUseCase` is mocked so tests run offline and fast.
