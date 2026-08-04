# Tasks for Use float_column for natural text wrap around game image

## 1. Planning

- [x] **1.1** Create OpenSpec change `use-float-column-for-game-description`.
- [x] **1.2** Write proposal explaining motivation and solution.
- [x] **1.3** Write delta spec updating the game-detail description layout requirement.

## 2. Implementation

- [x] **2.1** Add `float_column: ^4.1.0` to `pubspec.yaml` and run `flutter pub get`.
- [x] **2.2** Replace `_DescriptionWithFloatingImage`, `_TextSplit`, `_measureTextHeight`, and `_splitDescription` in `lib/presentation/pages/game_detail_page.dart` with a `FloatColumn` layout.
- [x] **2.3** Keep the right-floated image, max width 50 %, minimum height fallback, and top alignment.
- [x] **2.4** Ensure the description is still HTML-unescaped before rendering.
- [x] **2.5** Verify the missing-description branch still hides the whole section.

## 3. Verification

- [x] **3.1** Update `test/presentation/pages/game_detail_page_test.dart` to assert natural wrap behavior instead of the previous hard split.
- [x] **3.2** Run `dart analyze` and resolve all errors and warnings.
- [x] **3.3** Run `flutter test` and ensure all tests pass.
- [x] **3.4** Visually verify on a device/emulator that descriptions such as the Connect Four text no longer break phrases like "The Captain's Mistress."
