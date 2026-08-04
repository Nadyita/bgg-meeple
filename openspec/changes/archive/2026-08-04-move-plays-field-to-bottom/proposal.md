# Change: Move number of played games to the bottom of the detail page

## Summary

Re-order the detail fields on the game detail page to the following vertical order:

1. Original name
2. Year published
3. Version
4. Players
5. Playing time
6. Min age
7. Language dependence
8. Rating
9. Rank
10. Plays

## Motivation

Currently the played-games count sits between **Rank** and **Min age**. The user wants the primary game metadata first, then community/BGG-related values (`Rating`, `Rank`), and the number of played games as the very last field.

## Affected Capabilities

- `game-detail` — ordering of the detail rows.

## Proposed Solution

1. Update the `game-detail` capability spec so that the strict field order ends with **Plays**.
2. Reorder the `_addValueField` calls in `_DetailFields._buildFields` (`lib/presentation/pages/game_detail_page.dart`) so that the `detailPlays` row is appended after the language-dependence row.
3. Update existing widget/golden tests that assert the field order.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
