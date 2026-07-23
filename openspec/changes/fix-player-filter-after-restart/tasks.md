# Tasks for Fix: Spielerfilter zeigt nach App-Neustart keine Treffer

## 1. Planning

- [x] **1.1** Review requirements in `search-and-filter` and `sort-and-view-state` specs
- [x] **1.2** Create OpenSpec change `fix-player-filter-after-restart`
- [x] **1.3** Write `proposal.md` describing motivation and affected capabilities
- [x] **1.4** Write `spec.md` under `openspec/specs/player-filter-persistence`
- [x] **1.5** Write `design.md` with interface and call-site changes

## 2. Implementation

- [x] **2.1** Refactor `CollectionBloc._apply` to accept `PlaysInfo playsInfo`
- [x] **2.2** Refactor `_matchesFilter` to accept `PlaysInfo playsInfo`
- [x] **2.3** Refactor `_effectivePlayCount` to accept `PlaysInfo playsInfo`
- [x] **2.4** Update all call sites in `CollectionBloc` to pass the correct `PlaysInfo`
- [x] **2.5** Add unit test for restored player filter after app restart

## 3. Validation

- [x] **3.1** Run `dart analyze` and ensure 0 errors, 0 warnings
- [x] **3.2** Run `dart test` and ensure all tests pass
- [x] **3.3** Run `openspec_validate_change` for `fix-player-filter-after-restart`

## 4. Documentation

- [x] **4.1** Link new `fix-player-filter-after-restart` delta spec in `REQUIREMENTS.md`
