# Proposal: Fix trailing separator in game detail minimum age row

## Problem

In the game detail screen, the minimum-age row currently renders as `Min age: 8 ·` when the thing API does not provide a suggested player age. The trailing `·` separator is displayed because `_KeyValueRow` always inserts it whenever a `suffix` widget is provided, even when that suffix renders no visible content (`SizedBox.shrink()` from `_AgeSuffix`).

## Affected capability

- `game-detail` – rendering of the minimum/suggested age row.

## Proposed fix

Only pass the `_AgeSuffix` widget to `_KeyValueRow` when a suggested player age is actually available. This keeps `_KeyValueRow`'s generic separator logic unchanged and fixes the trailing separator for the age row specifically.

## Scope

- `lib/presentation/pages/game_detail_page.dart` – `_DetailFields._buildDetailFields`.

## Out of scope

- No changes to localization strings.
- No changes to BGG API parsing or domain models.
- No changes to the collection card rendering.
