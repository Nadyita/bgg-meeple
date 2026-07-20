# Tasks for implement-full-image-replacement

## 1. Analysis

- [x] **1.1** Inspect current detail page image state/BLoC and identify where full-image loading completion is reported.
- [x] **1.2** Determine how the cached full-image file path is exposed to the UI.

## 2. State/UI changes

- [x] **2.1** Add a distinct UI state for "full image loaded and ready" in the detail page image widget.
- [x] **2.2** Implement swap from thumbnail to full image when the full image becomes locally available.
- [x] **2.3** Ensure the thumbnail remains visible if the full image fails to load or is not yet cached.

## 3. Tests

- [x] **3.1** Add/update widget test for thumbnail-to-full-image replacement.
- [x] **3.2** Add test for error/fallback case where thumbnail stays visible.
- [x] **3.3** Run the full test suite and fix regressions.

## 4. Validation and archive

- [x] **4.1** Validate the change with `openspec_validate_change`.
- [x] **4.2** Archive the change with `openspec_archive_change`.
