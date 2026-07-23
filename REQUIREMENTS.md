# BGG Meeple App – Requirements

Central requirements index for the Flutter app **BGG Meeple**.
The authoritative requirements are now maintained as OpenSpec capability specs under [`openspec/specs/`](openspec/specs/). This file keeps a consolidated human-readable index, project-level rules, and the change history.

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

## 2. Capability Index

Each capability links to its authoritative OpenSpec spec. Detailed acceptance criteria, scenarios, and future changes live in the spec files.

| Capability | Spec | Covered requirement IDs | Status |
|------------|------|--------------------------|--------|
| Project foundation | [`openspec/specs/project-foundation/spec.md`](openspec/specs/project-foundation/spec.md) | F01, NF01–NF04, T01–T02 | implemented |
| BGG authentication | [`openspec/specs/bgg-authentication/spec.md`](openspec/specs/bgg-authentication/spec.md) | F03–F04, F28, T05, NF07 | implemented |
| BGG sync | [`openspec/specs/bgg-sync/spec.md`](openspec/specs/bgg-sync/spec.md) | F05–F08, T03–T04, T06, T10–T11, NF05–NF06, UX04, UX09 | implemented |
| Collection list | [`openspec/specs/collection-list/spec.md`](openspec/specs/collection-list/spec.md) | F09–F13, F15, UX03, UX05–UX07, UX10 | implemented |
| Search and filter | [`openspec/specs/search-and-filter/spec.md`](openspec/specs/search-and-filter/spec.md) | F16–F24 | implemented |
| Sort and view state | [`openspec/specs/sort-and-view-state/spec.md`](openspec/specs/sort-and-view-state/spec.md) | F25–F26, UX08, T09 | implemented |
| Game detail | [`openspec/specs/game-detail/spec.md`](openspec/specs/game-detail/spec.md) | F27 | implemented |
| Card layout | [`openspec/specs/card-layout/spec.md`](openspec/specs/card-layout/spec.md) | F14, UX05–UX06 | implemented |
| Settings and theme | [`openspec/specs/settings-and-theme/spec.md`](openspec/specs/settings-and-theme/spec.md) | UX01–UX02, UX05 | implemented |
| CI/CD | [`openspec/specs/ci-cd/spec.md`](openspec/specs/ci-cd/spec.md) | NF10–NF12, T07–T08 | implemented |
| App icon | [`openspec/specs/app-icon/spec.md`](openspec/specs/app-icon/spec.md) | NF01, NF04 | implemented |
| Android app label | [`openspec/specs/android-app-label/spec.md`](openspec/specs/android-app-label/spec.md) | — | planned |
| Android release signing | [`openspec/specs/android-release-signing/spec.md`](openspec/specs/android-release-signing/spec.md) | NF13 | planned |
| Plays sync | [`openspec/specs/plays-sync/spec.md`](openspec/specs/plays-sync/spec.md) | — | planned |
| Collection card plays players | [`openspec/specs/collection-card-plays-players/spec.md`](openspec/specs/collection-card-plays-players/spec.md) | — | planned |

### Discarded requirements

| ID | Status | Reason |
|----|--------|--------|
| F19 | discarded | Filter by age was deemed not useful for this app |
| F23 | discarded | Combined into the own/BGG rating filter (F22) |

## 3. Non-Functional and Cross-Cutting Requirements

High-level non-functional expectations are defined in the capability specs above. The following cross-cutting requirements apply to the whole app:

- **Offline-first behavior** (`bgg-sync` spec, NF05): after a successful sync the app works without network.
- **Secure credential storage** (`bgg-authentication` spec, NF07): credentials and tokens use platform-appropriate secure storage.
- **Device-local view state only** (`sort-and-view-state` spec, NF08): game data is identical across devices; only view/filter/sort/search may differ.
- **Unit test coverage** (`project-foundation` spec, NF09): all business logic, data, and service layers have unit tests.
- **Responsive filtering performance** (`search-and-filter` spec, NF06): filtering and search update without noticeable delay for collections up to several hundred games.

## 4. Open Questions / Backlog

There are currently no open questions. All previously discussed questions have been answered and implemented; see the Change History for the resulting decisions.

### Known operational notes

- The `release.yml` workflow requires write permission to create GitHub releases. It explicitly declares `permissions: contents: write` on the release job. If a release upload still fails with `403 Resource not accessible by integration`, the repository's GitHub Actions settings (Settings → Actions → General → Workflow permissions) must be set to **Read and write permissions**, or a PAT with `repo` scope must be used instead of the default `GITHUB_TOKEN`.

## 5. Change History

| Date | Change |
|------|--------|
| 2026-07-23 | Clarified clear-button responsibilities in search/filter UI: the search-field X now clears only the query, the filter-panel "Clear" button resets all filter criteria to defaults, and `CollectionViewCleared` remains the dedicated full view-state reset. Delta specs: [`openspec/changes/clarify-filter-clear-behavior/specs/search-and-filter/spec.md`](openspec/changes/clarify-filter-clear-behavior/specs/search-and-filter/spec.md), [`openspec/changes/clarify-filter-clear-behavior/specs/sort-and-view-state/spec.md`](openspec/changes/clarify-filter-clear-behavior/specs/sort-and-view-state/spec.md) |
| 2026-07-23 | Fixed bug: persisted player participation filters now evaluate against the cached plays loaded during startup, so the collection list shows matching games instead of "No games match your filters." after an app restart. Delta spec: [`openspec/changes/fix-player-filter-after-restart/specs/search-and-filter/spec.md`](openspec/changes/fix-player-filter-after-restart/specs/search-and-filter/spec.md) |
| 2026-07-14 | Migrated monolithic `REQUIREMENTS.md` to OpenSpec capability specs under `openspec/specs/`; updated `AGENT.md` with concrete OpenSpec workflow and commands. |
| 2026-06-29 | Implemented F27 (game detail page): added `GameDetailPage` with full image, external BGG link, alternate names, and all known game fields; tapping a collection card navigates to the detail page; back arrow, Escape key, and system back gesture/button all close the page |
| 2026-06-29 | Enabled BGG XML API2 `/thing` in `BggApiClient` with API-bearer-token authentication and 20-id batching; extended `BoardGame`, `GameStore`, and Drift schema (v7) to persist description, categories, mechanics, designers, artists, publishers, families, weight, language dependence, and player-count polls |
| 2026-06-29 | Extended `SyncCollectionUseCase` to fetch and store full game details; added `LoadGameDetailsUseCase` that lazily caches the full game image when the detail page is opened |
| 2026-06-29 | Fixed sync failure under Linux: `BggSession` now stores an optional API bearer token parsed from the login response; `fetchGames` skips `/thing` calls when no token is available and uses `Authorization: Bearer` when a token exists; `SecureSessionStore` persists the token alongside cookies |
| 2026-06-29 | Fixed "Game not found" on detail page: `loadById` now falls back to matching by `thingId` when `collId` is zero or missing; `CollectionPage` normalizes `collId` before opening `GameDetailPage`; `LoadGameDetailsUseCase` retries lookup with `thingId` as fallback |
| 2026-06-29 | Improved detail page image handling: thumbnail is shown immediately, full image is loaded lazily and cached; image is constrained to max 50% width and 30% height of the screen |
| 2026-06-29 | Fixed detail page so that the full image URL is always passed to the UI even when not yet cached, ensuring `CachedNetworkImage` can load the high-resolution image in the background while the thumbnail is visible |
| 2026-06-29 | Implemented F28: added a manual BGG API token field in settings; the token is stored securely and merged into the BGG session so `/xmlapi2/thing` can be called when the login response does not include a bearer token. Updated `LoginUseCase` test stubs with `registerFallbackValue` for the new `BggSession` instance matching. |
| 2026-06-29 | Refined F27 acceptance criteria and implemented detail-page specifics: lazy full-image caching with thumbnail placeholder, external BGG link with open-in-new icon, expandable alternate/localized names list, and left-aligned image constrained to 50% width / 30% height. |
| 2026-06-29 | Marked T02 as implemented: internationalization uses `flutter_localizations` with generated ARB-based `AppLocalizations` for German and English. |
| 2026-06-29 | Adjusted `.github/workflows/release.yml` to declare `permissions: contents: write` explicitly on the release job and `contents: read` on the test job. Documented the 403 release-upload troubleshooting note in the Requirements. |
| 2026-06-27 | Fixed search scope: live search now only matches game names (custom name and BGG names), not version edition names; added `CollectionViewCleared` event so the search-field X clears search text, filters, and sort order together |
| 2026-06-27 | Fixed bug: persisted search text is now restored into the search field on startup, so users see why the collection list is filtered and can clear the query immediately |
| 2026-06-29 | Fixed Linux GitHub Actions builds: added `libsecret-1-dev` to all Linux build steps because `flutter_secure_storage_linux` requires it; updated README prerequisites and troubleshooting section |
| 2026-06-29 | Implemented NF10: CI now runs tests on every push; release workflow has an explicit test gate and only builds/attaches Android APK and Linux bundle when tests pass |
| 2026-06-29 | Changed release trigger from manual GitHub Release creation to tag-based automation: pushing any tag starting with `v` now creates a release with attached Android APK and Linux bundle; updated README with release instructions |
| 2026-06-29 | Fixed `release.yml` permission error: added `permissions: contents: write` to enable GitHub release creation; added `permissions: contents: read` to `ci.yml`; documented required repository setting in README and requirements |
| 2026-06-26 | Implemented F06 (pull-to-sync): added `CollectionSyncRequested` event to `CollectionBloc`, wired `SyncCollectionUseCase` into `CollectionPage`, and wrapped the collection list with `RefreshIndicator`; sync progress, errors, and reload are handled through `CollectionState` |
| 2026-06-26 | Marked UX06 as implemented: all configurable card metadata fields (player count, play time, plays, own rating, geek rating, min age, BGG rank) already render with dedicated Material icons in `CollectionCard` |
| 2026-06-26 | Implemented UX04: main app-bar sync icon is now disabled when no valid BGG credentials are stored; `CollectionBloc` tracks `hasCredentials` and `CollectionPage` enables the sync button only when credentials are present |
| 2026-06-26 | Fixed main app-bar sync icon: tapping it now triggers an immediate BGG sync via `CollectionSyncRequested` and shows a progress bar, instead of opening the settings screen |
| 2026-06-26 | Documented Android network-permission troubleshooting: on some Android distributions the network permission is not automatically granted even though `INTERNET` is declared in the manifest; users may need to enable network access manually in the app details screen when they see "Failed host lookup" |
| 2026-06-26 | Added a clear-search button (X) to the collection search field; it appears when search text is entered and clears the query and the persisted view state |
| 2026-06-26 | Built Android release APK locally (`flutter build apk --release`); produced `app-release.apk` (61.4MB). Extended GitHub Actions CI and release workflows to build and attach the Android APK alongside the Linux bundle; marked T01, NF11, and NF12 as implemented and updated README with Android build instructions |
| 2026-06-25 | Implemented collection list UI (F09, F16, UX03, UX07): card-based list, live search, player/time/plays/rating metadata, thumbnail display, sub-type chips; fixed display name/year logic and offline thumbnail cache |
| 2026-06-25 | Implemented filters and sorting (F17-F25, UX08): expandable filter panel with sub-type chips, age, player count, play time, own rating, and BGG rating filters; combined AND filtering with live search; sort by name/play time/BGG rating/year with ascending/descending toggle |
| 2026-06-25 | Completed card field selection (F14): `CardLayoutConfig` with toggleable/reorderable fields, persistence in shared preferences, settings UI, and full rendering in `CollectionCard`; extended `CollectionItem`, Drift cache, and BGG parser to extract and display `bggRank` and `geekRatingUserCount` |
| 2026-06-25 | Implemented F26 (persist search, filters, sort): added `CollectionView` value object, JSON serialization for `CollectionFilter` and `CollectionSort`, `CollectionViewStore` port, `SharedPreferencesCollectionViewStore` adapter, load/save use cases, and BLoC restore/persistence; sequential event handling in `CollectionBloc` prevents races between load and search/filter/sort events; added adapter, use-case, value-object, and BLoC tests |
| 2026-06-25 | UI refinement: moved the special "Plays" and "Geek rating" hints in the card-layout settings from a second subtitle line into parentheses after the field label, keeping all reorderable list tiles uniformly single-line and vertically centered |
| 2026-06-25 | Fixed startup crash caused by accessing `AppLocalizations` inside `BlocProvider.create` (InheritedWidget lookup in a non-listenable lifecycle). Error messages in `CollectionState` and `SettingsState` are now stored as localization builders and formatted by the UI layer. |
| 2026-06-25 | Fixed v4→v5 migration for `collId`: because `collId` is part of the new composite primary key and is NOT NULL, the migration now recreates all cache tables (data is repopulated on next sync) instead of adding the column in place |
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
| 2026-06-24 | Added T11: local cache schema must be versioned with tested migrations; fixed missing schemaVersion bump and migration strategy in Drift database |
