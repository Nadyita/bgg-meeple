# Tasks: Fix Android bottom navigation bar covering content

- [x] 1. Inspect current SafeArea/padding usage on collection, detail, and settings pages
- [x] 2. Add bottom SafeArea/padding to `CollectionPage` body
- [x] 3. Add bottom SafeArea/padding to `GameDetailPage` scrollable content
- [x] 4. Ensure `SettingsPage` bottom inset is respected beyond the 16dp minimum
- [x] 5. Add unique Keys to production SafeAreas for testability
- [x] 6. Add/update widget tests for bottom safe area behavior
- [x] 7. Run `dart analyze`
- [x] 8. Run `dart test` and ensure all tests pass
