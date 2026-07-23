# Tasks for fix-settings-safe-area

## 1. Planning

- [x] **1.1** Confirm root cause (fixed padding ignores bottom safe area)
- [x] **1.2** Decide on `SafeArea` approach

## 2. Implementation

- [x] **2.1** Wrap `SingleChildScrollView` in `_SettingsForm` with `SafeArea` (keep 16 padding)
- [x] **2.2** Update existing widget tests if they assert exact padding geometry

## 3. Validation

- [x] **3.1** Run `dart analyze` (zero errors/warnings)
- [x] **3.2** Run `flutter test` (all tests pass)
- [x] **3.3** Validate change with `openspec_validate_change`
