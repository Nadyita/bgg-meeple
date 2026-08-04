# Tasks: Fix compact list items not opening game detail

- [x] 1. Identify that `_CompactCollectionList` lacks an `onTap` callback
- [x] 2. Add `onTap` parameter to `_CompactCollectionList` and forward it to each `ListTile`
- [x] 3. Wire `_openGameDetail` into `_CompactCollectionList` from the card/list switch location
- [x] 4. Add/update widget test verifying compact list taps navigate to detail
- [x] 5. Run `dart analyze`
- [x] 6. Run `dart test` and ensure all tests pass
