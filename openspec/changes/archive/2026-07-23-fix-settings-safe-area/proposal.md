# Proposal: Fix Android navigation bar covering last settings item

## Summary

On Android devices, the bottom system navigation bar (three-button or gesture bar) partially obscures the last item on the Settings page, which is the BGG Rating (geek rating) field in the card layout section. This change ensures all settings content remains fully visible and scrollable above the system navigation bar.

## Motivation

Users cannot reliably see or interact with the bottom-most setting when the app runs on Android because `SettingsPage` currently applies a fixed `EdgeInsets.all(16)` padding to the scrollable content, ignoring the safe area insets required by the system UI. Wrapping the scroll view in a `SafeArea` (or otherwise respecting bottom insets) is a standard Flutter pattern for this scenario.

## Proposed Solution

Wrap the `SingleChildScrollView` in `_SettingsForm` with a `SafeArea` that keeps the existing 16 logical pixels padding on all sides while adding the bottom system inset when needed. This preserves the current visual spacing and makes the last list item fully reachable.

## Alternatives Considered

- Manually read `MediaQuery.of(context).viewPadding.bottom` and add it to the scroll padding. This works but is more verbose and easier to break if device orientation or window insets change.
- Add `SafeArea` only around the `ReorderableListView`. This would fix the card layout section but leave other potential overlap scenarios, and is inconsistent with the rest of the page.

The chosen approach uses `SafeArea` because it is the idiomatic Flutter widget for keeping content clear of system UI insets.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] UI/UX change (bug fix)
