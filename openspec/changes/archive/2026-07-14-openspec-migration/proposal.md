## Why

The project already mandates an OpenSpec workflow in `AGENT.md`, but the actual requirements still live as a single monolithic `REQUIREMENTS.md`. Without per-capability specs there is no contract between design, implementation, and validation, and future changes cannot be tracked through the OpenSpec lifecycle. This change migrates the existing requirements into a proper OpenSpec spec tree and updates the project rules so the workflow is consistent and executable.

## What Changes

- Update `AGENT.md` to describe the concrete OpenSpec lifecycle, commands, and artifact order used by this project.
- Decompose `REQUIREMENTS.md` into capability-based OpenSpec specs under `openspec/specs/`.
- Keep `REQUIREMENTS.md` as a human-readable consolidated view that references the new specs (no functional behavior changes).
- Introduce no new app features; this is a documentation and process migration only.

## Capabilities

### New Capabilities

- `project-foundation`: Flutter project setup, internationalization, code-quality rules, architecture, and language conventions.
- `bgg-authentication`: BGG credential storage, session management, and manual API token handling.
- `bgg-sync`: Manual and pull-to-sync, lazy collection/game/version fetch, progress feedback, and offline cache behavior.
- `collection-list`: Card-based collection list, thumbnails, sub-type chips, and display-name/year logic.
- `search-and-filter`: Live search, expandable filter panel, combined filters, and rating/player/time range filters.
- `sort-and-view-state`: Sort order, persisted view/filter/search state, and compact view toggle.
- `game-detail`: Detail page, full-image caching, external BGG link, and alternate/localized names.
- `card-layout`: Configurable and reorderable card fields, font size setting, and metadata icons.
- `settings-and-theme`: Settings screen, dark/light mode toggle, and account/token inputs.
- `ci-cd`: GitHub Actions workflows for test gate, per-platform build, and release asset attachment.

### Modified Capabilities

- None. This change only structures existing requirements; no behavior changes.

## Impact

- `AGENT.md`: updated workflow instructions.
- `REQUIREMENTS.md`: restructured as a reference index that points to spec files.
- `openspec/specs/`: new capability directories and `spec.md` files.
- No source code, dependencies, or app behavior are affected.
