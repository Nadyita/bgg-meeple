# Design: Simplify detail page to match spec

## Overview

After the `game-detail` spec was updated to require only a fixed set of details, this change removes all extra metadata from `GameDetailPage`. The goal is a clean, focused detail view that matches the updated spec exactly.

## Removed fields

The following fields are no longer rendered on the detail page:

- Description
- Categories
- Mechanics
- Designers
- Artists
- Publishers
- Families
- Minimum age
- Own rating (as a separate line)
- Geek rating / Average rating (as separate lines)
- Number of ratings (as a standalone line)
- Owned by / For trade / Wanted / Wishlisted counts
- Weight
- Language dependence
- Best player count
- Recommended player count
- BGG rank label (Rank is used instead)
- Collection status label (status is shown as chips next to the name)

## Kept fields (in strict order)

1. Game image (max 50% width, max 30% height)
2. Game name (bold, large)
3. Status badges next to the name
4. Small vertical spacer
5. Original name
6. Year published
7. Version
8. Players
9. Playing time
10. Rating
11. Rank
12. Plays

Additionally, the external BGG link in the app bar and the alternate/localized names toggle remain unchanged.

## Localization cleanup

Obsolete localization keys were removed from `app_en.arb` and `app_de.arb`, and `AppLocalizations` was regenerated.

## Testing approach

Widget tests verify that:
- The allowed details are still shown.
- Removed metadata such as description, categories, mechanics, designers, weight, and language dependence are not rendered.
- The strict order of fields is preserved.
