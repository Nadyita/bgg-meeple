# Tasks for Parse and display player count lists from BGG poll summaries

## 1. XML parsing

- [x] **1.1** Change `_parsePlayerCountRange` in `BggApiClient` to find all range expressions in a summary value.
- [x] **1.2** Derive overall `min` from the smallest lower bound and `max` from the largest upper bound, with `max` null if any expression is open-ended.
- [x] **1.3** Return a cleaned display string that preserves the original list text (e.g. "4, 6-10, 12").
- [x] **1.4** Update fallback legacy parsers to produce comparable list strings where appropriate.

## 2. Detail page UI

- [x] **2.1** Add L10n keys for the best/recommended value labels: English `Players` / German `Spieler`.
- [x] **2.2** Change `_formatPlayerCount` in `GameDetailPage` to use the stored `bestPlayerCount` / `recommendedPlayerCount` display strings with localized nouns.
- [x] **2.3** Keep abbreviation logic (hide suffix if best/recommended equal base range).

## 3. Tests

- [x] **3.1** Add/extend unit tests in `bgg_api_client_fetch_games_test.dart` for comma-separated lists and mixed ranges.
- [x] **3.2** Update/extend widget tests in `game_detail_page_test.dart` for list rendering and German localization.
- [x] **3.3** Run `flutter test` and fix failures.

## 4. Validation

- [x] **4.1** Run `dart analyze` and fix all errors/warnings.
- [x] **4.2** Run `flutter test` and verify all tests pass.
- [x] **4.3** Manual verification with a game that returns comma-separated player counts.
