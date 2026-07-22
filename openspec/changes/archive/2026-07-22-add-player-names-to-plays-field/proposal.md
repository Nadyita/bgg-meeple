# Feature: Add player names to the Plays card field

## Summary

Extend the existing `Plays` card field so it can optionally list the unique,
case-insensitive alphabetically sorted names of all players that have ever
participated in logged plays for that game. When enabled, a card that shows
`Plays: 3` will also show the comma-separated player list, e.g. `Dine, Eva, Mark`.

## Motivation

The current `Plays` field only shows a count. Users would like to see at a glance
who they have already played a game with, without opening the detail screen.
This makes the collection list more informative and helps users pick games based
on who is present.

## Proposed Solution

1. Introduce a new per-game player-name lookup use case that reads the cached
   plays, collects every distinct player name per `thingId`, and returns them
   sorted alphabetically ascending.
2. Add a new card-layout toggle `showPlayerNamesOnPlays` that is independent of
   the existing `hidePlaysOnZero` setting.
3. Load the player-name map together with the collection in the collection BLoC
   and expose it through the collection state.
4. Render the names behind the play count in `CollectionCard` when the new
   option is enabled.
5. Add a corresponding switch on the Settings screen and update the localized
   labels for English and German.

## Alternatives Considered

- **Compute names inside the widget**: Rejected. Widgets should not depend on
  the play store directly; doing so would complicate testing and break the
  existing layered architecture.
- **Store the player list on `CollectionItem`**: Rejected. Player names are a
  derived view concern and do not belong on the collection entity.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] UI changes (settings screen, collection card)
- [x] New use case and BLoC state field
- [x] New localization strings
