: Parse best/recommended player count ranges

## 1. Domain model

- [x] **1.1** Add `bestPlayerCountMin`, `bestPlayerCountMax`, `recommendedPlayerCountMin`, and `recommendedPlayerCountMax` to `BoardGame`.
- [x] **1.2** Keep `bestPlayerCount` and `recommendedPlayerCount` as display strings derived from the new range fields.

## 2. XML parsing

- [x] **2.1** Implement `_parsePlayerCountRange` that extracts min/max from strings like `X`, `X-Y`, `X+`, `X-Y+` with `–`, `-`, and `—` separators.
- [x] **2.2** Parse `bestwith` from `poll-summary` into `bestPlayerCountMin` / `bestPlayerCountMax`.
- [x] **2.3** Parse `recommendedwith` from `poll-summary` into `recommendedPlayerCountMin` / `recommendedPlayerCountMax`.
- [x] **2.4** Implement fallback logic from raw `poll` when `poll-summary` is missing.
  - Best: numplayers with highest `Best` votes.
  - Recommended: longest consecutive run of numplayers with `Recommended` share ≥ 50 %.
- [x] **2.5** Add/update unit tests for all range forms and fallback scenarios.

## 3. Database

- [x] **3.1** Add four nullable `IntColumn`s to `BoardGames`.
- [x] **3.2** Bump `schemaVersion` and add a migration that adds the columns (no data loss).
- [x] **3.3** Regenerate Drift code.

## 4. Persistence adapter

- [x] **4.1** Update `DriftGameStore._toGameCompanion` and `_toEntity` to write/read the new fields.

## 5. UI

- [x] **5.1** Update `_DetailFields` to format the player count line as `Players X[-Y] Players`, optionally appending `(Recommended: RX[-RY] Players, Best: BX[-BY] Players)` or abbreviated variants.
  - If best and recommended ranges both equal the base range, show only the base line.
  - If recommended equals best but differs from the base range, show `Players X[-Y] Players (Best: BX[-BY] Players)`.
  - If recommended differs from best, show both labels.
  - Use `+` when a max value is null.
- [x] **5.2** Update/add widget tests for the new player count line formatting.

## 6. Validation

- [x] **6.1** Run `dart analyze` and fix all errors/warnings.
- [x] **6.2** Run `flutter test` and verify all tests pass.
- [x] **6.3** Manually verify the detail page shows correct best/recommended strings for sample games.
