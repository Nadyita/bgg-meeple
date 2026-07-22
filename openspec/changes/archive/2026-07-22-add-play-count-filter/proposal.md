# Proposal: Filter collection by play count

## Summary

Add a play-count range slider to the collection filter panel so users can filter games by how many times they have been played.

## Motivation

Users with large collections want to quickly find games they have played very often or rarely/never played. A dedicated play-count filter, combined with the existing player participation filter, makes this possible.

## Proposed Solution

Extend the existing `search-and-filter` capability with a new play-count filter.

- Add `minPlays` / `maxPlays` to `CollectionFilter`.
- When no player participation filter is active, use `numPlays` from the collection item.
- When player participation filters are active, count only plays whose player set matches the configured participation rules, then filter by that count.
- Render a min/max `RangeSlider` in the filter panel directly below the rating slider. The slider minimum is always `0`, the maximum is derived from the largest `numPlays` value among all loaded collection items.
- Persist and restore the new filter fields via `CollectionFilter.toJson` / `fromJson`.

## Alternatives Considered

- Dynamic maximum based on currently visible items: rejected because it causes the slider bounds to jump while the user drags.
- Counting `Play.quantity` sums instead of play entries: rejected per user request.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
