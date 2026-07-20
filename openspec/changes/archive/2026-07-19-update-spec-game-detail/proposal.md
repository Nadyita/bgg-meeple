# Change: Update game-detail spec to limit displayed details

## Summary

Update the `game-detail` capability spec so that the detail page only shows the explicitly listed set of details. No additional metadata (description, categories, mechanics, designers, publishers, weight, etc.) is rendered.

## Motivation

The current `game-detail` spec describes a strict order of details but does not explicitly forbid additional fields. The implementation therefore shows many extra details that are not part of the intended design. This change makes the spec unambiguous: only the listed fields are displayed.

## Proposed Solution

Add a new requirement to `openspec/specs/game-detail/spec.md` that states:

- The detail page SHALL show only the details listed in the strict-order requirement.
- No additional game metadata is displayed.

The scenario for this requirement verifies that extra fields such as description, categories, mechanics, designers, publishers, and weight are not rendered.

## Affected Capabilities

- `game-detail`

## Alternatives Considered

- Leave the spec open and only adjust the UI: rejected because it leaves the door open for future implementations to drift again.
- List every forbidden field explicitly in the requirement: rejected in favor of a concise blanket rule that refers to the existing ordered list.

## Impact

- [x] Specification change
- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [ ] UI/UX changes (covered by follow-up implementation change)
- [ ] New tests required (covered by follow-up implementation change)
- [ ] New route/page added
