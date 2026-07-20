# Tasks for Simplify detail page to match spec

## 1. Planning

- [x] **1.1** Review updated `game-detail` spec requirements
- [x] **1.2** Identify fields to remove vs. keep

## 2. Implementation

- [x] **2.1** Remove extra detail fields from `GameDetailPage._DetailFields`
- [x] **2.2** Ensure remaining fields keep the strict spec order
- [x] **2.3** Remove unused helper methods and imports
- [x] **2.4** Remove obsolete localization keys from `app_en.arb` and `app_de.arb`
- [x] **2.5** Regenerate `AppLocalizations`

## 3. Testing

- [x] **3.1** Update existing widget tests to match the simplified layout
- [x] **3.2** Add test asserting that removed fields are not rendered
- [x] **3.3** Run `flutter test` and ensure all tests pass

## 4. Validation

- [x] **4.1** Run `dart analyze` and resolve all errors and warnings
- [x] **4.2** Run `openspec_validate_change simplify-detail-page`
- [x] **4.3** Request approval and archive the change
