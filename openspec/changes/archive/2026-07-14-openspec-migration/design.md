## Context

The project already declares an OpenSpec-driven workflow in `AGENT.md`, but the concrete requirements are still stored as a single `REQUIREMENTS.md` table. This makes it hard to reason about individual capabilities and to apply the OpenSpec artifact lifecycle (`proposal` → `specs` → `design` → `tasks`).

Current state:
- `AGENT.md` references OpenSpec commands but does not document the exact artifact order or how existing monolithic requirements map to specs.
- `REQUIREMENTS.md` contains 28 functional requirements, 12 non-functional requirements, 11 technical requirements, and 10 UI/UX requirements, plus project-level rules.
- `openspec/specs/` is empty.
- All application requirements are already implemented, so this migration is documentation-only.

## Goals / Non-Goals

**Goals:**
- Decompose `REQUIREMENTS.md` into capability-based specs under `openspec/specs/`.
- Update `AGENT.md` to describe the exact OpenSpec artifact order and commands used by this project.
- Keep `REQUIREMENTS.md` as a human-readable index that references the new spec files.
- Validate the new specs with `openspec validate`.

**Non-Goals:**
- No code changes.
- No new app features or dependency changes.
- No removal of historical information in `REQUIREMENTS.md` (change history is preserved).

## Decisions

- **Keep `REQUIREMENTS.md` as an index rather than deleting it.** The file already serves as a project-level contract. Removing it would break existing references and lose the change history. Instead, the requirement tables are converted into a concise index that links to `openspec/specs/<capability>/spec.md`.

- **Group requirements into 10 capabilities.** This balances granularity (each capability is a coherent, testable concern) with manageability (not hundreds of tiny specs).
  - Grouping by feature area (authentication, sync, list, search/filter, etc.) mirrors the existing domain boundaries in the hexagonal codebase.

- **Use only `## ADDED Requirements` sections.** All requirements are already implemented, so no deltas (`MODIFIED`/`REMOVED`) are needed. The migration captures the current behavior in spec form.

- **Keep acceptance criteria from `REQUIREMENTS.md` as scenarios.** Each original requirement maps to one or more OpenSpec scenarios using `WHEN`/`THEN` format. This makes the specs directly testable and preserves the original acceptance intent.

- **Update `AGENT.md` workflow steps to match the resolved OpenSpec schema.** The project's `config.yaml` uses the default `spec-driven` schema, whose artifact order is `proposal → specs → design → tasks`. The agent instructions are updated to reflect this order and to mention `openspec status` and `openspec validate`.

## Risks / Trade-offs

- [Risk] Specs become stale when `REQUIREMENTS.md` changes later → Mitigation: `REQUIREMENTS.md` is converted into an index that links to specs, so future edits should happen in the spec files first and then be summarized in `REQUIREMENTS.md`.
- [Risk] Duplication between specs and `REQUIREMENTS.md` → Mitigation: `REQUIREMENTS.md` only keeps a short reference table with IDs and links; detailed acceptance criteria live in specs.
- [Risk] `AGENT.md` rules contradict the OpenSpec schema → Mitigation: the updated `AGENT.md` explicitly references the `spec-driven` schema and the artifact order it defines.

## Migration Plan

1. Create capability directories under `openspec/specs/`.
2. Write one `spec.md` per capability using `## ADDED Requirements` and `### Requirement:` / `#### Scenario:` format.
3. Update `AGENT.md` with the concrete OpenSpec lifecycle and commands.
4. Restructure `REQUIREMENTS.md` to reference the new spec files while keeping legends, rules, vision, and change history.
5. Validate with `openspec validate change openspec-migration`.
6. Archive the change with `openspec archive openspec-migration`.

## Open Questions

- None. The scope is documentation-only and the existing requirements are stable.
