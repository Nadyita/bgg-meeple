# Tasks for Fix detail page rating count label wording

## 1. Planning

- [x] **1.1** Review the `game-detail` spec requirement for the rating line
- [x] **1.2** Identify affected locale files and formatting code

## 2. Implementation

- [x] **2.1** Update German `detailUserCount` in `lib/presentation/l10n/app_de.arb`
- [x] **2.2** Update English `detailUserCount` in `lib/presentation/l10n/app_en.arb`
- [x] **2.3** Regenerate localization classes with `flutter gen-l10n`
- [x] **2.4** Verify the formatting code in `lib/presentation/pages/game_detail_page.dart` still produces correct output

## 3. Validation

- [x] **3.1** Add or update unit/widget tests covering the formatted rating string for both locales
- [x] **3.2** Run `dart analyze` and resolve any issues
- [x] **3.3** Run `flutter test` / `dart test` and ensure all tests pass
- [x] **3.4** Manual UI verification in German and English

## 4. Completion

- [x] **4.1** Update OpenSpec task statuses
- [x] **4.2** Validate change with `openspec_validate_change`
- [x] **4.3** Archive change with `openspec_archive_change`
