# Tasks for Use collection image as primary source on game detail page

## 1. Domain use case

- [x] **1.1** In `LoadGameDetailsUseCase.call`, change `final imageUrl = boardGame?.imageUrl ?? collectionItem.imageUrl;` to prefer `collectionItem.imageUrl` and fall back to `boardGame?.imageUrl`.
- [x] **1.2** Update the `GameDetails.imageUrl` documentation to state that the collection image is preferred and the `/thing` image is the fallback.

## 2. Tests

- [x] **2.1** Update the existing `LoadGameDetailsUseCase` unit test that verifies the cached image so it expects the collection image to be used when both `collectionItem.imageUrl` and `boardGame.imageUrl` are present.
- [x] **2.2** Add a unit test that verifies the `/thing` image is used as a fallback when the collection item has no `imageUrl`.
- [x] **2.3** Add a unit test that verifies no full image is loaded when neither source provides an `imageUrl`, with the thumbnail still available.

## 3. Validation

- [x] **3.1** Run `dart analyze` and fix all errors/warnings.
- [x] **3.2** Run `dart test` and verify all tests pass.
- [x] **3.3** Manually verify on a game detail page that the displayed image matches the collection edition.
