## Context

This change only updates OpenSpec documentation artifacts (`REQUIREMENTS.md` index and existing capability specs). No code, dependencies, or app behavior change.

## Goals / Non-Goals

**Goals:**
- Correct the capability index in `REQUIREMENTS.md`.
- Add missing technical requirements to the `bgg-sync` spec.
- Replace placeholder `## Purpose` sections with meaningful descriptions.

**Non-Goals:**
- Any implementation changes.
- New dependencies or data migrations.

## Decisions

- `UX04` and `UX09` belong to `bgg-sync` because both the sync affordance and the single progress indicator are part of the sync user experience, not the list rendering.
- `T03`, `T10`, and `T11` are added to `bgg-sync` because persistence, thumbnail file cache, and schema versioning are implementation requirements that enable reliable sync and offline behavior.
- Purpose sections are kept concise (one paragraph) to describe the scope of each capability.

## Risks / Trade-offs

- [Risk] Future changes could reintroduce mapping drift → Mitigation: keep `REQUIREMENTS.md` as a strict index and review it whenever specs change.
