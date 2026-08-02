# Tasks for Fix: Detail-Seite – Bild floatet und HTML-Entities werden dekodiert

## 1. Dependencies

- [x] **1.1** Add `html_unescape: ^2.0.0` to `pubspec.yaml` and run `flutter pub get`.

## 2. Description decoding

- [x] **2.1** Replace the hand-rolled entity replacement in `_DescriptionAndImage` with `HtmlUnescape().convert(description)`.
- [x] **2.2** Add/update a widget test that verifies `\u0026shy;` and `\u0026amp;` are decoded in the displayed description.

## 3. Float layout

- [x] **3.1** Implement a `_DescriptionWithFloatingImage` widget using `LayoutBuilder` and `TextPainter`.
  - Use the actually available width (parent constraints) instead of `MediaQuery`.
  - Image max width: 50 % of available width.
  - Image height: at least thumbnail fallback height, at most the full description text height, capped at 75 % of screen height.
  - Text starts top-left beside the image, then continues in full width below the image.
  - Short descriptions fall back to image above full-width text.
- [x] **3.2** Update `_ImageHeader` so it respects external constraints instead of computing its own size from `MediaQuery`.
- [x] **3.3** Replace the existing `_DescriptionAndImage` `Wrap` layout with the new float widget.
- [x] **3.4** Add/update a widget test that verifies the description text appears and the image floats to the right.

## 4. Reorder detail page sections

- [x] **4.1** Move `_TitleAndStatus` (name + status chips + alternate names toggle) above the description/image block in `_buildContent`.
- [x] **4.2** Add a `Divider` between the description/image block and the detail fields.
- [x] **4.3** Add a widget test that verifies the title appears above the description.
- [x] **4.4** Align `_ImageHeader` content to top-right so it sits cleanly in the top-right corner of the description block.

## 5. Validation

- [x] **5.1** Run `dart analyze` and fix all errors/warnings.
- [x] **5.2** Run `flutter test` and verify all tests pass.
- [x] **5.3** Manually verify on Linux Desktop that the title is on top, description with right-floating image follows, and a divider separates description from detail fields.
