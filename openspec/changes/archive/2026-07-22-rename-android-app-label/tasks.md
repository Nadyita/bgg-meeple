# Tasks for Android app label from `bgg_meeple` to `BGG Meeple`

## 1. Planning

- [x] **1.1** Write or review `android-app-label` capability spec
- [x] **1.2** Create change branch `rename-android-app-label`

## 2. Implementation

- [x] **2.1** Update `android/app/src/main/AndroidManifest.xml` `android:label` to `BGG Meeple`
- [x] **2.2** Add Dart test that asserts the manifest label equals `BGG Meeple`

## 3. Integration

- [x] **3.1** Run `dart test` and verify all tests pass
- [x] **3.2** Run `dart analyze` and verify zero issues
- [x] **3.3** Update `REQUIREMENTS.md` capability index with the new spec
- [x] **3.4** Validate change with `openspec_validate_change`
