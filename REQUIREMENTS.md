# BGG Meeple App – Requirements

Central requirements documentation for the Flutter app **BGG Meeple**.
All agreed requirements are recorded here, prioritized, and assigned a status
so it is always transparent what is implemented, in progress, or still open.

---

## Status Legend

| Status | Meaning |
|--------|---------|
| `open` | Not started yet |
| `in progress` | Currently being implemented |
| `implemented` | Implemented and (ideally) tested |
| `discarded` | Deliberately not implemented, with reason |

## Priority Legend

| Priority | Meaning |
|----------|---------|
| `must` | Must be included in the first relevant release |
| `should` | Should be implemented soon |
| `could` | Can be added later |
| `wont` | Not planned for now |

## Project Language Rule

- **Source code, documentation, and all project artifacts:** English only.
- This ensures that international collaboration is possible at any time.
- The app itself must support multiple languages; initially German and English.

## No-AI-Emoji Rule

- AI-generated emojis (such as robot faces, sparkles, wands, stars, rockets, bulbs, etc.) are **not allowed** in any project file.
- This applies to source code, comments, documentation, READMEs, requirements, commit messages, issue/ticket content, and any other project artifact.
- Standard UI icons from Material Design or other icon sets are permitted when used for actual user-interface elements.

---

## 1. Vision & Target Audience

- **App name:** BGG Meeple
- **Technology:** Flutter (Android, Linux Desktop; Web optional if effort is justified)
- **Design system:** Material 3; no custom logo for now.
- **Primary development target:** Linux Desktop first (local testing environment), then Android.
- **Goal:** A personal offline-first BGG collection viewer that syncs and caches game data from BoardGameGeek (BGG) on demand.
- **Architecture:** Hexagonal architecture (ports and adapters) with Clean Code principles.
- **Development approach:** Test-first whenever possible — write unit tests before implementing business logic.
- **Core behavior:** The app logs into BGG with stored credentials, fetches the user's collection, game details, and selected versions, then caches everything locally. It only persists non-BGG state for the current view and filters. Once synced, the collection data is identical across devices; only the active view/filter may differ.
- **Target audience:** BoardGameGeek users who want a fast, offline-capable, searchable overview of their own board game collection on Android and Linux Desktop.

## 2. Functional Requirements

| ID | Status | Description | Acceptance Criteria | Priority |
|----|--------|-------------|---------------------|----------|
| F01 | implemented | Create Flutter project | Project builds and runs (`flutter run` works without errors on Android and Linux Desktop) | must |
| F02 | implemented | Multilingual app UI | App supports German and English; language can be switched or follows system language; all user-facing strings are externalized | must |
| F03 | implemented | BGG login credentials | User can enter and save BGG username and password on a dedicated settings screen; credentials are persisted securely and used to obtain a BGG session | must |
| F04 | implemented | BGG session management | App logs into BGG and reuses the session cookie for authenticated API calls; session is refreshed as needed | must |
| F05 | implemented | Manual BGG sync | A sync button/icon is available once a BGG account is configured; tapping it triggers a full sync of collection, game details, and versions | must |
| F06 | implemented | Pull-to-sync on main list | Pulling down at the top of the main collection list triggers a BGG sync | must |
| F07 | implemented | Local cache for offline use | All game, collection, version, and thumbnail data required by the app is stored locally so the app works without network access after first sync | must |
| F08 | implemented | Lazy sync with progress | Sync loads collection list first so the UI appears quickly; game details, versions, and thumbnails are fetched in batches (respecting API limits) with a visible progress indicator | must |
| F09 | implemented | Card-based collection list | Main screen shows a single, large, scrollable list of cards (not a table), one card per collection item; no pagination | must |
| F10 | implemented | Game name from BGG | Display name uses the board game's primary name; the selected version's name is shown as an edition subtitle, not as the title | must |
| F11 | implemented | Year as separate field | The year shown on the card comes from the selected version year, or falls back to `yearpublished` when no version year is available | must |
| F12 | implemented | Custom name override | If the user has set a custom name in their BGG collection, it always takes precedence over the version/name fallback | must |
| F13 | implemented | Thumbnail display and offline caching | Each card shows the game's thumbnail; thumbnails are downloaded during sync and cached as local files so they remain available offline; the UI prefers the local cached file and falls back to the network URL | must |
| F14 | implemented | Card field selection | Settings allow the user to choose which values appear on each card; configurable fields are thumbnail, version subtitle, player count, play time, plays (with "Hide on 0"), own rating, geek rating (with optional number of ratings), min age, and BGG rank; all fields except title and sub-type chips can be toggled; most fields are reorderable via drag-and-drop | should |
| F15 | implemented | Sub-type chips | Each card shows chips for the collection sub-types that apply to it (e.g. owned, wanted, wishlist, played); these match the user's BGG collection flags | must |
| F16 | implemented | Live search by name | A search field at the top of the main list filters the collection by game name case-insensitively as the user types | must |
| F17 | implemented | Expandable filter panel | A filter icon next to the search field expands/collapses additional filter controls (player count, play time range, rating, collection sub-types) | must |
| F18 | implemented | Filter by collection sub-type | Filter controls allow selecting which BGG collection sub-types to show; all sub-types are shown by default; OR logic applies when multiple are selected | must |
| F19 | discarded | Filter by minimum age | Filter by age was deemed not useful for this app | must |
| F20 | implemented | Filter by player count range | Filter controls use a two-handle range slider from 1 to 16 players; only games whose player range overlaps the selected range are shown; list updates immediately | must |
| F21 | implemented | Filter by play time range | Filter controls use a two-handle range slider with discrete steps (0, 5, 10, 15, 30, 45, 60, 90, 120, 240, 360, 480, 720 minutes); filters against effective play time (`maxplaytime` or `minplaytime`) | must |
| F22 | implemented | Filter by rating range | Filter controls use a two-handle range slider from 0 to 10 in 0.5 steps; uses the user's own rating when set, otherwise falls back to `bayesaverage`; only games whose effective rating falls within the selected range are shown; list updates immediately | should |
| F23 | discarded | Filter by BGG community rating | Combined with F22; a single minimum rating filter prefers own rating, then falls back to `bayesaverage` | should |
| F24 | implemented | Combined filters | Multiple filters and search can be active at the same time; all active criteria are combined with AND logic; list updates immediately | must |
| F25 | implemented | Sort collection list | User can sort the list by name (default), play time, BGG rating, or year; a toggle switches ascending/descending order | must |
| F26 | implemented | Persist view and filter state | Current search text, active filters, sort order, and scroll position are persisted locally and restored when the app restarts; this is the only device-local state | should |

## 3. Non-Functional Requirements

| ID | Status | Description | Acceptance Criteria | Priority |
|----|--------|-------------|---------------------|----------|
| NF01 | open | Code quality and maintainability | Clean project structure; sensible separation of UI, logic, and data; follows Clean Code principles | should |
| NF02 | implemented | Hexagonal architecture | Business logic is isolated from frameworks and external APIs through ports and adapters; UI, BGG API, and persistence are adapters | must |
| NF03 | implemented | Test-first development | Unit tests are written before or alongside the business logic they verify | must |
| NF04 | open | International collaboration readiness | All code, docs, comments, and issue/ticket content are written in English | must |
| NF05 | open | Offline-first behavior | App must remain usable for browsing, searching, and filtering after a successful sync, even without network; BGG remains the authoritative source | must |
| NF06 | open | Responsive filtering performance | Filtering and search must update the list without noticeable delay for collections up to several hundred games | should |
| NF07 | implemented | Secure credential storage | BGG credentials are stored using platform-appropriate secure storage (e.g. Keychain/Keystore or encrypted shared preferences) | must |
| NF08 | implemented | Device-local view state | The only data that may differ between devices are view settings, filters, search text, sort order, and selected card fields; game data is identical after sync | must |
| NF09 | implemented | Unit test coverage | All business logic, data, and service layers have unit tests; UI tests are added where they provide clear value | must |
| NF10 | implemented | CI build gate | GitHub Actions runs the full test suite on every push; the build/pipeline fails if any test fails; no artifacts are built unless all tests pass | must |
| NF11 | implemented | Continuous compilation | Every push triggers a GitHub Actions workflow that compiles the app for the supported target platforms | must |
| NF12 | implemented | Release asset attachment | Creating a GitHub Release triggers a workflow that builds release artifacts and attaches them to the release automatically | must |

## 4. Technical Requirements

| ID | Status | Description | Acceptance Criteria | Priority |
|----|--------|-------------|---------------------|----------|
| T01 | implemented | Flutter version and platforms | Uses current stable Flutter version; primary targets are Android and Linux Desktop; Web remains optional | must |
| T02 | open | Internationalization approach | Uses Flutter's recommended i18n solution (e.g. `flutter_localizations` / ARB files or a maintained package) | must |
| T03 | implemented | Local data persistence | Local cache uses a reliable persistence layer (e.g. SQLite, Hive, ObjectBox, or shared preferences plus JSON) that supports offline queries of game, collection, and version data | must |
| T04 | implemented | BGG API integration | App uses the official BoardGameGeek XML API2 to fetch collection, game details (thing), and version data; respects the 20-item thing limit and ~5-second rate limit | must |
| T05 | implemented | BGG login flow | App authenticates with BGG via username/password to obtain session cookies for private collection data | must |
| T06 | implemented | Sync status feedback | Sync operations show loading, success, and error states clearly to the user | should |
| T07 | implemented | GitHub Actions setup | Repository contains workflow definitions for test/build/release automation | must |
| T08 | implemented | Test framework | Uses Flutter's built-in test framework (`flutter test`) plus appropriate mocking packages for unit tests | must |
| T09 | implemented | View state persistence | Uses lightweight local storage (e.g. shared preferences or Hive) only for settings, filters, search text, sort order, and selected card fields | should |
| T10 | implemented | Thumbnail caching | Thumbnails and custom images are cached locally using a custom file cache; local paths are persisted in the cache database | must |
| T11 | implemented | Database schema versioning | Local cache schema is versioned; every schema change bumps `schemaVersion` and ships a tested `MigrationStrategy`; destructive migrations are acceptable for cache-only data and must be documented; current schema version is `6` | must |

## 5. UI/UX & Design

| ID | Status | Description | Acceptance Criteria | Priority |
|----|--------|-------------|---------------------|----------|
| UX01 | implemented | Settings screen | Dedicated screen accessible from the main view; contains BGG account inputs, dark/light mode toggle, and font size setting | must |
| UX02 | implemented | Theme mode toggle | User can switch between dark and light mode in settings; choice persists across app restarts | should |
| UX03 | implemented | Main list layout | Main collection list is a single continuous scrollable card list without pagination or virtual page breaks | must |
| UX04 | implemented | Sync affordance | A clearly identifiable sync icon/button is visible when a BGG account is configured; disabled/hidden when no account is set | must |
| UX05 | implemented | Font size setting | Settings screen offers 5 text size levels; the middle level corresponds to the normal/default text size; choice applies app-wide and persists across restarts | must |
| UX06 | implemented | Card metadata icons | Selected card fields are displayed with icons similar to the reference screenshot (player icon, clock icon, etc.) | should |
| UX07 | implemented | Sub-type chips | Collection sub-type chips appear at the bottom of each card (e.g. owned, wanted, wishlist, played); sub-type labels are kept in English because they are established BGG terms | must |
| UX08 | implemented | Sort toggle | A sort icon and an ascending/descending toggle are available in the main list app bar | must |
| UX09 | implemented | Single sync progress indicator | During a sync, exactly one progress indicator is shown at the top of the main collection screen; no duplicate progress bars appear | must |
| UX10 | implemented | Compact view toggle | The main app bar offers a toggle left of the sync button that switches between the existing card list and a compact table-style list showing only the game name; the toggle updates the list immediately | should |

## 6. Open Questions / Backlog

- Which platforms should be explicitly supported? (Android, Linux Desktop; Web optional if effort is justified)
- Should search/filter state persist when leaving and returning to the main screen? (Yes – covered by F26.)
- Which persistence adapter should be used for the local cache? Drift is prepared in `pubspec.yaml`; final schema to be designed. **Answered: Drift will be used as the local persistence adapter.**
- CI/CD gating: Should the full test suite run on every push to any branch, and should the release workflow re-run tests or wait for an external CI result? **Answered: CI runs on every push to any branch; the release workflow re-runs tests as an explicit `needs: test` gate so it is self-contained and works for releases created from any branch/tag.**
- How should a GitHub Release be created? **Answered: By pushing a Git tag starting with `v` (e.g. `v1.0.0`). This automatically triggers `release.yml`, which runs the test suite and then creates the release with the Android APK and Linux bundle attached. The workflow declares `permissions: contents: write`; if GitHub Actions does not have write permission in the repository settings, the release upload will fail with a 403 error.**
- Should pre-releases also receive Android and Linux release assets? **Answered: Yes, the workflow triggers for every tag starting with `v`, including pre-release tags such as `v1.0.0-beta.1`.**

## 7. Change History

| Date | Change |
|------|--------|
| 2026-06-24 | File created; added legend, base structure, and initial open requirements |
| 2026-06-24 | Added project-language rule, multilingual UI requirement, and internationalization technical requirement |
| 2026-06-24 | Defined core vision, offline-first behavior, BGG sync, collection list, filters/search, and settings requirements |
| 2026-06-24 | Added no-AI-emoji rule and font size setting requirement |
| 2026-06-24 | Added CI/CD requirements: unit tests, build gate, per-push compilation, release asset attachment |
| 2026-06-24 | Revised: Android + Linux Desktop primary, Web optional; no local game data persistence; BGG stays authoritative; view/filter state may be persisted |
| 2026-06-24 | Answered open questions: filters inline at top with expandable panel; all collection sub-types downloaded, filterable, default all visible; single account; Material 3; persist view state |
| 2026-06-24 | Major revision after BGG API review and UI mockup: added BGG login, version data, card layout, custom names/images, thumbnail caching, sort, card field selection, sub-type chips |
| 2026-06-24 | Decided: full sync only; Linux Desktop first; test-first approach; hexagonal architecture + Clean Code |
| 2026-06-24 | Scaffolded Flutter project with Linux/Android targets; added hexagonal folder structure, dependencies, localization, first domain tests, and Material 3 app shell |
| 2026-06-24 | Added GitHub Actions CI (test + build Linux) and release workflows; updated README with conventions and build instructions |
| 2026-06-24 | Implemented F03 + F04: BGG credentials/settings page, secure storage, BGG login adapter, session store, SettingsBloc with tests |
| 2026-06-24 | Started Phase 1: T03, T04, T05, T06, F05, F07, F08 set to in progress; decided on Drift for local cache |
| 2026-06-24 | Fixed real BGG sync: BGG XML API2 /collection requires all three cookies (bggusername, bggpassword, SessionID); BggApiClient now parses and stores all cookies, loads session from store, and implements both BggApi and AuthenticationService; disabled /thing fetch because it requires an application token; expanded CollectionItem with game details from collection response |
| 2026-06-25 | Added T11: local cache schema must be versioned with tested migrations; fixed missing schemaVersion bump and migration strategy in Drift database |
| 2026-06-25 | Fixed v4→v5 migration for `collId`: because `collId` is part of the new composite primary key and is NOT NULL, the migration now recreates all cache tables (data is repopulated on next sync) instead of adding the column in place |
| 2026-06-25 | Implemented collection list UI (F09, F16, UX03, UX07): card-based list, live search, player/time/plays/rating metadata, thumbnail display, sub-type chips; fixed display name/year logic and offline thumbnail cache |
| 2026-06-25 | Implemented filters and sorting (F17-F25, UX08): expandable filter panel with sub-type chips, age, player count, play time, own rating, and BGG rating filters; combined AND filtering with live search; sort by name/play time/BGG rating/year with ascending/descending toggle |
| 2026-06-26 | Implemented F06 (pull-to-sync): added `CollectionSyncRequested` event to `CollectionBloc`, wired `SyncCollectionUseCase` into `CollectionPage`, and wrapped the collection list with `RefreshIndicator`; sync progress, errors, and reload are handled through `CollectionState` |
| 2026-06-26 | Marked UX06 as implemented: all configurable card metadata fields (player count, play time, plays, own rating, geek rating, min age, BGG rank) already render with dedicated Material icons in `CollectionCard` |
| 2026-06-26 | Implemented UX04: main app-bar sync icon is now disabled when no valid BGG credentials are stored; `CollectionBloc` tracks `hasCredentials` and `CollectionPage` enables the sync button only when credentials are present |
| 2026-06-26 | Fixed main app-bar sync icon: tapping it now triggers an immediate BGG sync via `CollectionSyncRequested` and shows a progress bar, instead of opening the settings screen |
| 2026-06-26 | Documented Android network-permission troubleshooting: on some Android distributions the network permission is not automatically granted even though `INTERNET` is declared in the manifest; users may need to enable network access manually in the app details screen when they see "Failed host lookup" |
| 2026-06-26 | Added a clear-search button (X) to the collection search field; it appears when search text is entered and clears the query and the persisted view state |
| 2026-06-26 | Built Android release APK locally (`flutter build apk --release`); produced `app-release.apk` (61.4MB). Extended GitHub Actions CI and release workflows to build and attach the Android APK alongside the Linux bundle; marked T01, NF11, and NF12 as implemented and updated README with Android build instructions |
| 2026-06-25 | Completed card field selection (F14): `CardLayoutConfig` with toggleable/reorderable fields, persistence in shared preferences, settings UI, and full rendering in `CollectionCard`; extended `CollectionItem`, Drift cache, and BGG parser to extract and display `bggRank` and `geekRatingUserCount` |
| 2026-06-25 | Implemented F26 (persist search, filters, sort): added `CollectionView` value object, JSON serialization for `CollectionFilter` and `CollectionSort`, `CollectionViewStore` port, `SharedPreferencesCollectionViewStore` adapter, load/save use cases, and BLoC restore/persistence; sequential event handling in `CollectionBloc` prevents races between load and search/filter/sort events; added adapter, use-case, value-object, and BLoC tests |
| 2026-06-25 | UI refinement: moved the special "Plays" and "Geek rating" hints in the card-layout settings from a second subtitle line into parentheses after the field label, keeping all reorderable list tiles uniformly single-line and vertically centered |
| 2026-06-25 | Fixed startup crash caused by accessing `AppLocalizations` inside `BlocProvider.create` (InheritedWidget lookup in a non-listenable lifecycle). Error messages in `CollectionState` and `SettingsState` are now stored as localization builders and formatted by the UI layer. |
| 2026-06-27 | Implemented UX10: added a compact/table-view toggle left of the sync button in the main app bar; `CollectionBloc` tracks `isCompactMode`, the compact list shows only the game name, and a widget test verifies the toggle switches between card and compact views |
| 2026-06-27 | Fixed search scope: live search now only matches game names (custom name and BGG names), not version edition names; added `CollectionViewCleared` event so the search-field X clears search text, filters, and sort order together |
| 2026-06-27 | Fixed bug: persisted search text is now restored into the search field on startup, so users see why the collection list is filtered and can clear the query immediately |
| 2026-06-29 | Fixed Linux GitHub Actions builds: added `libsecret-1-dev` to all Linux build steps because `flutter_secure_storage_linux` requires it; updated README prerequisites and troubleshooting section |
| 2026-06-29 | Implemented NF10: CI now runs tests on every push; release workflow has an explicit test gate and only builds/attaches Android APK and Linux bundle when tests pass |
| 2026-06-29 | Changed release trigger from manual GitHub Release creation to tag-based automation: pushing any tag starting with `v` now creates a release with attached Android APK and Linux bundle; updated README with release instructions |
| 2026-06-29 | Fixed `release.yml` permission error: added `permissions: contents: write` to enable GitHub release creation; added `permissions: contents: read` to `ci.yml`; documented required repository setting in README and requirements |
