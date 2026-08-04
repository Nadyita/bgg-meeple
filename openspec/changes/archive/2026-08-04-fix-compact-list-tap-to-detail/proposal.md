# Proposal: Fix compact list items not opening game detail

## Problem

When the user switches the collection page from card view to compact list view, tapping a list item does nothing. In card view, tapping a `CollectionCard` opens the game detail page via `_openGameDetail`. The compact list's `ListTile` currently has no `onTap` handler.

## Affected capability

- `collection-list` navigation.

## Proposed fix

Pass the detail-open callback into `_CompactCollectionList` and attach it to each `ListTile` via `onTap`. Behavior and routing should be identical to the card view: tapping an item navigates to `GameDetailPage` for that item.

## Scope

- `lib/presentation/pages/collection_page.dart`
- `test/presentation/pages/collection_page_test.dart`

## Out of scope

- No changes to `CollectionCard` or `GameDetailPage`.
- No data or business-logic changes.
