# Fix: Use collection image as primary source on game detail page

## Why

The game detail page currently prefers the full-size image returned by the `/xmlapi2/thing` endpoint over the image stored in the user's own collection. This change reverses that priority so the collection image is used first, with the `/thing` image kept only as a fallback when the collection has no image.

BoardGameGeek collection entries can reference edition-specific or localized images. The `/thing` image may represent a different language edition than the one in the user's collection, causing the detail page to show the wrong box art. Users expect the detail page to reflect their own collection, including the exact image BGG associates with their copy.

## What Changes

1. In `LoadGameDetailsUseCase`, change the image resolution from `boardGame?.imageUrl ?? collectionItem.imageUrl` to `collectionItem.imageUrl ?? boardGame?.imageUrl`.
2. Update the `GameDetails.imageUrl` doc comment to state that the collection image is preferred and the `/thing` image is the fallback.
3. Update the existing unit test that asserts the old priority and add explicit tests verifying the collection image wins when both sources are present, the `/thing` image is used as fallback, and no full image is loaded when neither source has one.

## Affected Capabilities

- `game-detail` – detail page must display the user's collection image before falling back to the generic `/thing` image.

## Alternatives Considered

- Always ignore the `/thing` image and use only the collection image. Rejected because some collection entries may not include a full-size image, and the `/thing` image is still better than no image at all.
- Merge images by trying the collection thumbnail first. Rejected because the detail page needs a full-size image, and the collection already provides one via `imageUrl`.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
