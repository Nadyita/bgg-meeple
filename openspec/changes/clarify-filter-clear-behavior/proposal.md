# Proposal: Clarify clear-button responsibilities in search and filter UI

## Summary

The current collection screen uses two different clear controls with overlapping responsibilities. The search-field clear button resets the entire view state, while the filter-panel clear button only neutralizes player participation chips. This change clarifies and separates the responsibilities:

- The search-field clear button clears **only** the search query.
- The filter-panel clear button clears **all** filter criteria (sub-type selection, range sliders, player participation states) without touching the search query or sort order.
- The full view-state reset remains a dedicated action for search text, filters, and sort order combined.

## Motivation

- The current implementation of the search-field clear button dispatches `CollectionViewCleared`, which resets search text, filters, and sort order. This conflicts with the `search-and-filter` spec requirement that the search clear button only clears the query.
- The filter-panel "Clear" button calls `filter.clearPlayerFilters(...)`, which only sets players to `any` but leaves sub-type selections, range sliders, and other filter values untouched. This is inconsistent with the button label.
- Clarifying the behavior prevents user surprise and aligns the code with the spec-driven requirements.

## Affected Capabilities

- `search-and-filter` – clear-search and clear-filters controls.
- `sort-and-view-state` – clear-view action remains a separate, dedicated reset.

## Proposed Solution

- Introduce a dedicated `CollectionSearchCleared` event that clears only `searchText`.
- Introduce a dedicated `CollectionFilterCleared` event that resets `CollectionFilter` to its default while preserving `searchText` and `sort`.
- Keep `CollectionViewCleared` for resetting search text, filters, and sort order together.
- Update `collection_page.dart` to dispatch the correct events from the respective buttons.
- Add/update unit tests for the new Bloc handlers.

## Alternatives Considered

- Reuse `CollectionSearchTextChanged('')` for the search clear button. This works but is less explicit about intent and harder to test in isolation. A dedicated event is clearer.
- Keep the current `CollectionViewCleared` on the search clear button. Rejected because it violates the intended responsibility separation.

## Impact

- [x] Breaking changes (event model changes, UI behavior changes)
- [ ] Database migrations
- [ ] API changes
