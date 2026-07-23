# Development Rules

This project uses OpenSpec for spec-driven development. The repository uses the default spec-driven schema (proposal → specs → design → tasks). You MUST follow the workflow below.

## Spec Authority

The authoritative requirements live as capability-based specs under `openspec/specs/<capability>/spec.md`.

`REQUIREMENTS.md` is a consolidated human-readable index. Link new specs there after creation, but never mutate it to justify implementation drift.

A spec is written ONCE during the planning phase of a change. It describes the target state, not the current code.

## OpenSpec Spec Format (Mandatory)

Every capability spec under `openspec/specs/<capability>/spec.md` MUST use delta headers. Plain requirement lists without delta headers are invalid and will fail validation.

Allowed top-level delta sections — exactly one of:
- `## ADDED Requirements`
- `## MODIFIED Requirements`
- `## REMOVED Requirements`
- `## RENAMED Requirements`

Inside each delta section, use requirement blocks like this:

```markdown
## ADDED Requirements

### Requirement: <Short Requirement Name>
<1-2 sentences describing the requirement>

#### Scenario: <Descriptive Scenario Name>
Given <precondition or context>
When <action or event>
Then <expected outcome>

#### Scenario: <Another Scenario if needed>
...
```

Rules:
- Every requirement MUST contain at least one `#### Scenario:` block.
- Scenario blocks MUST use the Given/When/Then structure.
- Do NOT write specs as plain narrative without delta headers.
- Do NOT nest requirements under bullet points; use `### Requirement:` headings inside the delta section.

### Incorrect (will fail validation)

```markdown
## New Requirements

We need a player filter that persists after restart.

- The filter should be saved locally
- The filter should restore on app launch
```

### Correct

```markdown
## ADDED Requirements

### Requirement: Persist player filter across app restarts
The app must retain the active player filter so users do not need to re-select it after reopening the app.

#### Scenario: Filter survives cold start
Given a player filter "Alice" is active
When the user fully closes and reopens the app
Then the player filter "Alice" is still applied
```

## Mandatory Workflow

Before any implementation, check existing OpenSpec changes with `openspec_list_changes`.

Create a new change with `openspec_create_change` if none exists for the current task.

Generate the change artifacts in order:

1. `proposal.md` — why the change is needed and which capabilities are affected.
2. `specs/**/*.md` — one spec per new or modified capability. New capabilities go under `openspec/specs/<capability>/spec.md`. These are created during planning, never edited during implementation.
3. `design.md` — how the change is implemented (only when architectural or cross-cutting decisions are needed).
4. `tasks.md` — implementation checklist with `- [ ]` tasks. Include test tasks here; they are not optional.

**After generating specs and BEFORE presenting tasks.md:**
- Validate the change with `openspec_validate_change <change-id>`.
- If validation fails with delta errors, STOP. Fix the spec files first (add missing delta headers or Scenario blocks).
- Only proceed to present tasks.md once validation passes.

Present tasks.md to the user and wait for explicit confirmation (e.g., "yes", "looks good", "implement this") before writing any code. Do not call any approval tools; wait for a chat message.

## Spec Self-Check before output

After writing any `specs/<capability>/spec.md`, verify mentally:
- [ ] Does the file contain one of the exact delta headers (`## ADDED Requirements`, `## MODIFIED Requirements`, `## REMOVED Requirements`, or `## RENAMED Requirements`)?
- [ ] Does every `### Requirement:` have at least one `#### Scenario:`?
- [ ] Do scenarios contain Given/When/Then?
- [ ] Are requirements written as `### Requirement:` headings inside the delta section, not as bullet points?

If any check fails, rewrite the spec immediately before continuing to the next artifact.

## Git Branching

Create and work on a dedicated Git branch named exactly like the change ID (e.g., `add-user-auth`). Every feature or change MUST live on its own branch; never implement multiple changes on the same branch and never commit directly to the default branch.

## Spec Integrity (Non-Negotiable)

`openspec/specs/<capability>/spec.md` files are the single source of truth. They are immutable during implementation.

If the code cannot match the spec: fix the code, NOT the spec.

If the spec is genuinely wrong or outdated: create a NEW change called `update-spec-<name>` or `fix-spec-<name>`, update the spec there, and start a fresh implementation change afterwards.

NEVER edit files under `openspec/specs/` directly during an implement-* or apply change.

## Code Quality (Non-Negotiable)

For every Dart/Flutter change:

- Write or update unit/widget tests before marking implementation tasks as complete.
- Run `dart test` (or `flutter test`). All tests MUST pass.
- Run `dart analyze`. Zero errors, zero warnings. Do not add `// ignore:` comments to suppress lints.
- Do not mark a change as complete or archive it while tests are failing or analysis has issues.

## Definition of Done

A change is only done when ALL of the following are true:

- [ ] Code implements the spec completely.
- [ ] Tests cover the new behavior and all tests pass.
- [ ] `dart analyze` is clean (0 errors, 0 warnings).
- [ ] `dart test` (or `flutter test`) exits with code 0.
- [ ] Manual verification in UI performed (if the change affects UI).

NEVER write code without an active OpenSpec change folder.
