# Proposal: Show suggested player age and language dependence from thing API

## Problem

The app already fetches and caches two useful community polls from the BGG `/xmlapi2/thing` endpoint:

- `suggested_playerage` — weighted average of the community-recommended minimum age.
- `language_dependence` — level of in-game text dependency as voted by the community.

Both values are stored in `BoardGame` and the local cache, but they are never shown to the user. In addition, the publisher-reported `minAge` does not currently appear on the collection card even though `CardField.minAge` is configurable, because the card reads the age from `CollectionItem.minAge` and the collection endpoint does not always provide it. The cached `BoardGame.minAge` is available after sync but is not consulted on the card.

## Goals

1. Make `suggestedPlayerAge` visible on the collection card right next to the minimum age, using a thumbs-up icon.
2. Make `suggestedPlayerAge` visible on the game-detail page in the same style.
3. Show `languageDependenceLevel` on the game-detail page as a human-readable label.
4. Ensure the configured minimum-age field on the collection card uses the cached `BoardGame.minAge` as a fallback when the collection item itself does not provide it.

## Affected capabilities

- `collection-card` — how metadata lines are rendered on a collection item.
- `game-detail` — how static game fields are rendered on the detail screen.

## Out of scope

- New filters or sort criteria.
- Editing stored data.
- Exposing `languageDependenceLevel` anywhere other than the detail screen.
