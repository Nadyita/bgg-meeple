# Tasks for Design Details Page

## 1. Planning

- [x] **1.1** Review `game-detail` spec requirements
- [x] **1.2** Review existing collection-list integration and navigation
- [x] **1.3** Confirm design decisions with user before implementation

## 2. Implementation

- [x] **2.1** Add or update game detail route and navigation from collection card tap
- [x] **2.2** Implement detail page layout with strict content order (image, name, badges, metadata, external link, alternate names)
- [x] **2.3** Implement lazy full-image loading with local caching and thumbnail-to-full transition
- [x] **2.4** Implement external BoardGameGeek link with external-link icon
- [x] **2.5** Implement expandable alternate/localized names toggle
- [x] **2.6** Implement close actions: app-bar back arrow, Escape key (Linux Desktop), system back button/gesture

## 3. Testing

- [x] **3.1** Write unit tests for detail page view model/state logic
- [x] **3.2** Write widget tests for detail page layout and interactions
- [x] **3.3** Write tests for lazy image loading and caching behavior
- [x] **3.4** Write tests for external link and close actions
- [x] **3.5** Run `flutter test` and ensure all tests pass

## 4. Validation

- [x] **4.1** Run `dart analyze` and resolve all errors and warnings
- [x] **4.2** Manual UI verification on target platform(s)
- [x] **4.3** Update `REQUIREMENTS.md` link if the `game-detail` spec is new or changed
- [x] **4.4** Validate change with `openspec_validate_change design-details-page`
