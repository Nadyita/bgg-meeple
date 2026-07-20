## 1. Update project rules

- [x] 1.1 Update `AGENT.md` to describe the OpenSpec artifact order and commands for the `spec-driven` schema.
- [x] 1.2 Add project context to `openspec/config.yaml` if useful for future AI-generated artifacts.

## 2. Create capability specs

- [x] 2.1 Create capability spec covering F01, NF01–NF04, T01, T02, and project rules.
- [x] 2.2 Create capability spec covering F03–F04, F28, T05, and NF07.
- [x] 2.3 Create capability spec covering F05–F08, T04, T06, NF05, and NF06.
- [x] 2.4 Create capability spec covering F09–F13, F15, UX03–UX07, and UX10.
- [x] 2.5 Create capability spec covering F16–F24.
- [x] 2.6 Create capability spec covering F25–F26, UX08, and T09.
- [x] 2.7 Create capability spec covering F27.
- [x] 2.8 Create capability spec covering F14, UX05, and UX06.
- [x] 2.9 Create capability spec covering UX01–UX02 and UX05.
- [x] 2.10 Create capability spec covering NF10–NF12, T07, and T08.

## 3. Restructure consolidated requirements

- [x] 3.1 Convert `REQUIREMENTS.md` requirement tables into a concise index that links to the new capability specs.
- [x] 3.2 Preserve legends, project rules, vision, non-functional rules, and change history in `REQUIREMENTS.md`.

## 4. Validate and archive

- [x] 4.1 Run `openspec status --change openspec-migration` to verify all artifacts are complete.
- [x] 4.2 Run `openspec validate openspec-migration --type change` to validate the change.
- [ ] 4.3 Archive the change with `openspec archive openspec-migration`.
