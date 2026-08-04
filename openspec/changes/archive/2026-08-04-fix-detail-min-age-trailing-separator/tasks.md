# Tasks: Fix trailing separator in game detail minimum age row

- [x] 1. Identify root cause in `_KeyValueRow` / `_AgeSuffix`
- [x] 2. Update `_DetailFields._buildDetailFields` to skip `_AgeSuffix` when no suggested age exists
- [x] 3. Add/update unit tests for the age row rendering
- [x] 4. Run `dart analyze` and fix any issues
- [x] 5. Run `dart test` and ensure all tests pass
