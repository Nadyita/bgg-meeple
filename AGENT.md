# Development Rules

This project uses OpenSpec for spec-driven development. The repository uses 
the default `spec-driven` schema (`proposal → specs → design → tasks`). 
You MUST follow the workflow below.

## Spec Authority

- The authoritative requirements live as capability-based specs under 
  `openspec/specs/<capability>/spec.md`.
- `REQUIREMENTS.md` is a consolidated human-readable index. Link new specs 
  there after creation, but never mutate it to justify implementation drift.
- A spec is written ONCE during the planning phase of a change. It describes 
  the target state, not the current code.

## Mandatory Workflow

1. Before any implementation, check existing OpenSpec changes with 
   `openspec_list_changes`.
2. Create a new change with `openspec_create_change` if none exists for the 
   current task.
3. Generate the change artifacts in order:
   - `proposal.md` — why the change is needed and which capabilities are 
     affected.
   - `specs/**/*.md` — one spec per new or modified capability. New 
     capabilities go under `openspec/specs/<capability>/spec.md`. These are 
     created during planning, never edited during implementation.
   - `design.md` — how the change is implemented (only when architectural 
     or cross-cutting decisions are needed).
   - `tasks.md` — implementation checklist with `- [ ]` tasks. Include 
     test tasks here; they are not optional.
4. Create and work on a dedicated Git branch named exactly like the 
   change ID (e.g. `add-user-auth`). Every feature or change MUST live on 
   its own branch; never implement multiple changes on the same branch and 
   never commit directly to the default branch.
5. Present `tasks.md` to the user and wait for explicit confirmation
   (e.g., "yes", "looks good", "implement this") before writing any code. 
   Do not call any approval tools; wait for a chat message.
6. Write tests alongside the implementation, not after. Every feature or 
   behavioral change MUST have corresponding test coverage.
7. Update task status with `openspec_update_task` as you complete work.
8. Validate with `openspec_validate_change` before finishing.
9. Archive completed changes with `openspec_archive_change`.

## Spec Integrity (Non-Negotiable)

`openspec/specs/<capability>/spec.md` files are the single source of truth.  
They are immutable during implementation.

- If the code cannot match the spec: fix the code, NOT the spec.
- If the spec is genuinely wrong or outdated: create a NEW change 
  called `update-spec-<name>` or `fix-spec-<name>`, update the spec there, 
  and start a fresh implementation change afterwards.
- NEVER edit files under `openspec/specs/` directly during an 
  `implement-*` or `apply` change.

## Code Quality (Non-Negotiable)

For every Dart/Flutter change:

- Write or update unit/widget tests **before** marking implementation tasks 
  as complete.
- Run `dart test` (or `flutter test`). All tests MUST pass.
- Run `dart analyze`. Zero errors, zero warnings. Do not add 
  `// ignore:` comments to suppress lints.
- Do not mark a change as complete or archive it while tests are failing 
  or analysis has issues.

## Definition of Done

A change is only done when ALL of the following are true:

- [ ] Code implements the spec completely.
- [ ] Tests cover the new behavior and all tests pass.
- [ ] `dart analyze` is clean (0 errors, 0 warnings).
- [ ] `dart test` (or `flutter test`) exits with code 0.
- [ ] Manual verification in UI performed (if the change affects UI).

NEVER write code without an active OpenSpec change folder.
