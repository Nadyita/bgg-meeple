# Tasks for Fix Linux database path

## 1. Implementation

- [x] **1.1** Detect Linux desktop platform and build the XDG data path in `_databaseDirectory()`.
- [x] **1.2** Create the directory recursively if it does not exist.
- [x] **1.3** Keep using `getApplicationDocumentsDirectory()` on other platforms.

## 2. Tests

- [x] **2.1** Update/add unit test verifying the Linux database directory path.
- [x] **2.2** Run `flutter test` and fix failures.

## 3. Validation

- [x] **3.1** Run `dart analyze` and fix all errors/warnings.
- [x] **3.2** Manually verify on Linux desktop that the database is created under `~/.local/share/com.bggmeeple.bgg_meeple/databases/`.
