# Proposal: Fix Android bottom navigation bar covering content

## Problem

On Android devices with on-screen navigation buttons, the bottom system gesture bar can cover the lowest content of each main screen:

- `CollectionPage`: the `ListView` / `_CompactCollectionList` extends to the bottom of the screen without respecting system insets.
- `GameDetailPage`: the `SingleChildScrollView` uses `EdgeInsets.all(16)` but never adds the bottom safe-area inset.
- `SettingsPage`: already wrapped in `SafeArea(minimum: EdgeInsets.all(16))`, but `minimum` only enforces a lower bound; it does not guarantee that the bottom system inset is added beyond the 16dp when the inset is larger.

## Affected capabilities

- `collection-list` – main list view.
- `game-detail` – scrollable detail content.
- `settings` – scrollable settings form.

## Proposed fix

Apply the idiomatic Flutter `SafeArea` pattern on all three pages so that scrollable content receives bottom padding equal to the system gesture/navigation-bar inset:

- `CollectionPage`: wrap the `Scaffold` body `Column` in `SafeArea(top: false, bottom: true)`. This adds the system bottom inset to the whole page body without affecting the top area under the app bar.
- `GameDetailPage`: wrap the `SingleChildScrollView` in `SafeArea` while keeping the existing 16dp content padding.
- `SettingsPage`: keep the existing `SafeArea(minimum: EdgeInsets.all(16))` and enable `bottom: true` so the system bottom inset is respected on top of the 16dp minimum padding.

Each SafeArea is given a unique `Key` so widget tests can locate the correct one (Scaffold creates additional internal SafeArea widgets).

## Out of scope

- No changes to data models, BGG parsing, or business logic.
