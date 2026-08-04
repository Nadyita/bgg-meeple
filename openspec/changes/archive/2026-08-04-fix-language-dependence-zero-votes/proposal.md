# Proposal: Fix language dependence parser when all votes are zero

## Problem

The `_languageDependenceLevel` parser in `BggApiClient` selects the `result` with the highest `numvotes` inside the `language_dependence` poll. It initializes `winnerVotes` to `-1`, so any result with `numvotes="0"` still wins. When BGG returns a poll where `totalvotes="0"` and every option has zero votes, the parser incorrectly returns level `"1"` (the first option). This causes the detail screen to show "No necessary in-game text" / "Kein Text im Spiel" even though no community vote exists.

## Affected capability

- `bgg-thing-details` – parsing of `language_dependence` level.

## Proposed fix

Change the parser to treat zero votes as "no winner". Only return a level when at least one result has a positive vote count. When all votes are zero, return `null` so the detail row is hidden.

## Scope

- `lib/infrastructure/adapters/api/bgg_api_client.dart` – `_languageDependenceLevel`.
- `test/infrastructure/adapters/api/bgg_api_client_fetch_games_test.dart` – add regression test.

## Out of scope

- UI mapping strings remain unchanged.
- No database schema changes.
