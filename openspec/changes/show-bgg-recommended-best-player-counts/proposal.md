# Feature: Show BGG recommended and best player counts on collection cards

## Summary

The app already fetches BGG-recommended and BGG-best player counts via `/xmlapi2/thing` and stores them on the `BoardGame` entity. This feature makes those values visible on collection cards by appending them to the existing player count line. Two new card-layout toggles in the settings screen let the user decide whether recommended and/or best counts are shown.

## Motivation

- The manufacturer player count (`minplayers`/`maxplayers`) does not always reflect the community consensus on BGG.
- BGG polls provide a "recommended with" and "best with" summary that helps users quickly judge how many players a game actually works for.
- Showing these values inline on the collection card keeps the UI compact while surfacing more useful information.

## Proposed Solution

1. Extend `CollectionItem` with the same best/recommended player count fields that already exist on `BoardGame`.
2. Add nullable columns to the `CollectionItems` Drift table and bump the schema version with an additive migration.
3. During collection sync, copy the best/recommended player counts from each fetched `BoardGame` onto the matching `CollectionItem`.
4. Add two booleans to `CardLayoutConfig`: `showRecommendedPlayerNumbers` and `showBestPlayerNumbers` (both off by default).
5. Add matching toggles in the settings card-layout section and persist them via the existing `CardLayoutConfig` store.
6. Update `CollectionCard` so the player count line appends the recommended and/or best values when enabled and present, using distinct icons/labels.
7. Add localized strings for the toggles and the inline labels.
8. Add/update unit and widget tests for parsing, persistence, settings state, and card rendering.

## Affected Capabilities

- `bgg-sync` – copies best/recommended player counts from `BoardGame` to `CollectionItem` during sync.
- `app-database` – adds nullable columns to `CollectionItems` and performs an additive migration.
- `card-layout` – adds two new toggles for showing recommended/best player numbers and persists them.
- `collection-list` – appends the values inline to the player count metadata line on collection cards.

## Alternatives Considered

- Load `BoardGame` details in the collection list and join them at UI time. Rejected because it would require an extra lookup per card and complicate filtering/sorting.
- Show recommended/best counts as separate metadata lines. Rejected because the request explicitly asks for them on the same line behind the player count.
- Use only textual `bestPlayerCount`/`recommendedPlayerCount` strings and ignore the numeric bounds. Rejected because the numeric bounds are already parsed and can give a cleaner display.

## Impact

- [ ] Breaking changes
- [x] Database migrations
- [ ] API changes
