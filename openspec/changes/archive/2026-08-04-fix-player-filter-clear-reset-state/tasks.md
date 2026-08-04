# Tasks: Reset player filters to any/gray on "Clear filters"

- [x] 1. Locate `_onFilterCleared` in `CollectionBloc` and identify why player chips disappear
- [x] 2. Update `_onFilterCleared` to keep all known players with `PlayerParticipationFilter.any`
- [x] 3. Add/update bloc test asserting player chips survive clear with `any` state
- [x] 4. Run `dart analyze`
- [x] 5. Run `dart test` and ensure all tests pass
