# Tasks for Move number of played games to the bottom of the detail page

## 1. Planning

- [x] **1.1** Review existing `game-detail` spec and current field order in `game_detail_page.dart`
- [x] **1.2** Write delta spec for the new field order

## 2. Implementation

- [x] **2.1** Reorder detail fields in `lib/presentation/pages/game_detail_page.dart` to: Original name, Year published, Version, Players, Playing time, Min age, Language dependence, Rating, Rank, Plays
- [x] **2.2** Update widget/golden tests that assert the detail field order

## 3. Validation

- [x] **3.1** Run `dart analyze` and ensure 0 errors / 0 warnings
- [x] **3.2** Run `flutter test` and ensure all tests pass
- [x] **3.3** Manual verification: open a detail page and confirm Plays is the last field

## 4. Documentation

- [x] **4.1** Link the change in `REQUIREMENTS.md` after implementation
