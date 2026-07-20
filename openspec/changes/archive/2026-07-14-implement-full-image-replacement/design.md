## Context

The game detail page currently displays the cached thumbnail immediately and starts loading the full-resolution image in the background, but the thumbnail stays on screen. The updated `game-detail` spec now requires the full image to replace the thumbnail once it is available.

## Goals / Non-Goals

**Goals:**
- Show the thumbnail immediately while the full image loads.
- Replace the thumbnail with the full image as soon as the full image is cached locally.
- Keep error handling simple: on failure, the thumbnail remains visible.

**Non-Goals:**
- Changing how images are fetched or cached.
- Adding animations beyond a simple cross-fade or direct swap.
- Modifying the detail page layout significantly.

## Decisions

- **Use the existing image-loading abstraction.** The app already has a `LoadGameDetailsUseCase` and a cached image mechanism. We reuse that and add a completion callback or state transition in the BLoC/Presenter layer.

- **State representation:** The detail page image state SHALL have at least three states: `thumbnail`, `loadingFull`, and `fullImage`. The UI renders the appropriate widget for each state.

- **Replacement strategy:** Once the full image file is available locally, the UI SHALL switch from `CachedNetworkImage` (thumbnail URL) to a widget that displays the local full image. A short cross-fade is acceptable but not required.

- **Testing:** Add a widget test that verifies the detail page initially shows the thumbnail widget and later shows the full-image widget after the BLoC/Presenter emits the full-image state.

## Risks / Trade-offs

- [Risk] Full image fails to load → Mitigation: keep thumbnail visible and do not leave an empty placeholder.
- [Risk] Layout shift when swapping aspect ratios → Mitigation: constrain both images to the same max width/height and use `BoxFit.contain`.
