# Tasks for Derive release version and build number from Git tag

## 1. Planning

- [x] **1.1** Review the existing `ci-cd` spec and `release.yml`
- [x] **1.2** Decide on `versionName` and `versionCode` derivation strategy

## 2. Implementation

- [x] **2.1** Add a step to `.github/workflows/release.yml` that extracts the version from `github.ref_name`
- [x] **2.2** Add a step that computes `versionCode` from the SemVer tag
- [x] **2.3** Pass `--build-name` and `--build-number` to `flutter build apk --release`

## 3. Validation

- [x] **3.1** Verify the workflow YAML is valid (e.g. `actionlint` or manual review)
- [x] **3.2** Create a test tag and push it to a fork or test repository to verify the resulting `versionName` and `versionCode`
- [x] **3.3** Document the release tag format in `README.md` or project docs

## 4. Completion

- [x] **4.1** Update OpenSpec task statuses
- [x] **4.2** Validate change with `openspec validate change derive-release-version-from-git-tag`
- [x] **4.3** Request approval and archive the change
