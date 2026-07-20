# Tasks for Update game-detail spec to limit displayed details

## 1. Planning

- [x] **1.1** Identify the list of details that should remain visible
- [x] **1.2** Draft spec wording that makes the list exclusive

## 2. Spec Update

- [x] **2.1** Add the "Detail page only contains defined details" requirement to `openspec/specs/game-detail/spec.md`
- [x] **2.2** Add a scenario that verifies no extra metadata is shown
- [x] **2.3** Review the updated spec for consistency

## 3. Validation

- [x] **3.1** Run `openspec_validate_change update-spec-game-detail`
- [x] **3.2** Request approval for the spec change
- [x] **3.3** Archive the change once approved

## 4. Follow-up

- [ ] **4.1** Create implementation change to remove extra detail fields from `GameDetailPage`
- [ ] **4.2** Remove obsolete localization keys and update tests in the implementation change
