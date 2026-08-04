# Use float_column for natural text wrap around game image

## Why

The game detail page currently simulates a CSS-like float by measuring text
height and cutting the description string at the next space that fits beside the
image. The remaining text is rendered as a separate widget below the image.
Because the split only looks for a space, it can break inside phrases or proper
names, producing visually awkward results such as the line break before
"Captain's Mistress".

The `float_column` package provides a real float layout: text flows around a
floated widget as a single paragraph, using Flutter's own line breaking. This
eliminates the hard split and keeps phrases intact.

## What Changes

1. Add `float_column: ^4.1.0` to `pubspec.yaml`.
2. Replace `_DescriptionWithFloatingImage` and its helper classes in
   `lib/presentation/pages/game_detail_page.dart` with a `FloatColumn` whose
   children are a right-floated `_ImageHeader` and a single `WrappableText`
   for the decoded description.
3. Keep the existing visual constraints: image floats to the right, max width
   50 % of the column, minimum fallback height, max 75 % screen height, and the
   text starts at the top-left and continues full-width below the image.
4. Update the existing widget test that asserted the manual split to assert the
   new natural-wrap behavior instead.
5. Run `dart analyze` and `flutter test` and fix any issues.

## Alternatives Considered

- **Keep the manual split and improve it:** possible, but it would still be a
  reimplementation of text wrapping and would require handling edge cases such
  as soft hyphens, line breaks, and RTL text. Using a dedicated package is less
  code and more robust.
- **Use a different package:** no other actively maintained Flutter float-layout
  package with comparable feature set and test coverage was found.

## Impact

- [ ] Breaking changes – none; the UI behavior changes only in line-break
  quality.
- [ ] Database migrations – none.
- [ ] API changes – none.
- [x] New dependency: `float_column`.
