# Tasks for Rename app display name from BGG Meeple to MyMeeple

## 1. Planning

- [x] **1.1** Create OpenSpec change `rename-app-to-mymeeple`
- [x] **1.2** Draft `app-identity` capability spec
- [x] **1.3** Update `android-app-label` capability spec to require `MyMeeple`
- [x] **1.4** Write design.md covering affected files and out-of-scope identifiers

## 2. Implementation

- [x] **2.1** Replace `BGG Meeple` with `MyMeeple` in Flutter localization files (`app_en.arb`, `app_de.arb`, generated localizations)
- [x] **2.2** Replace `BGG Meeple` with `MyMeeple` in `lib/presentation/app.dart` doc comment
- [x] **2.3** Replace `BGG Meeple` with `MyMeeple` in `android/app/src/main/AndroidManifest.xml` application label
- [x] **2.4** Replace `BGG Meeple` with `MyMeeple` in `linux/runner/resources/com.bggmeeple.bgg_meeple.desktop`
- [x] **2.5** Replace `BGG Meeple` with `MyMeeple` in `README.md` (title, body, keystore examples)
- [x] **2.6** Replace `BGG Meeple` with `MyMeeple` in `REQUIREMENTS.md` (title, body, vision)

## 3. Tests

- [x] **3.1** Update `test/android/app_label_test.dart` to assert `MyMeeple`
- [x] **3.2** Run `dart analyze` and resolve any errors or warnings
- [x] **3.3** Run `dart test` (or `flutter test`) and ensure all tests pass

## 4. Validation

- [x] **4.1** Confirm no literal `BGG Meeple` remains in user-facing files
- [x] **4.2** Verify generated localization files are consistent with ARB sources
- [x] **4.3** Manual verification: check Android manifest label and Linux desktop entry
