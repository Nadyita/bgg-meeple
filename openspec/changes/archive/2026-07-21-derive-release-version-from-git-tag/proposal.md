# Change: Derive release version and build number from Git tag

## Summary

Release builds created by GitHub Actions currently ignore the pushed Git tag and use the static `version: 1.0.0+1` from `pubspec.yaml`. As a result, an APK built for tag `v1.2.3` still reports version `1.0.0` on Android. This change updates the release workflow so that the Android `versionName` and `versionCode` are derived from the Git tag.

## Why

The version shown in the installed app must match the version of the GitHub Release. Otherwise users cannot verify which release they are running, and release notes become unreliable.

## What Changes

Update `.github/workflows/release.yml` to extract the version and build number from the pushed tag before building the Android release:

- `versionName`: tag name with the leading `v` removed, e.g. `1.2.3`.
- `versionCode`: a monotonically increasing integer derived from the tag, e.g. `10203` for `1.2.3` using the formula `major * 1000000 + minor * 1000 + patch`.
- Pass both values to `flutter build apk` using `--build-name` and `--build-number`.

Local builds are intentionally left unchanged; they continue to use the value from `pubspec.yaml`.

## Affected Capabilities

- `ci-cd`

## Alternatives Considered

- Updating `pubspec.yaml` manually for every release: rejected because it is error-prone and duplicates information already present in Git tags.
- Deriving `versionCode` from `git rev-list --count HEAD`: rejected because it is not directly visible from the SemVer tag and can differ between branches.
- Using a dedicated release-script file: rejected because the change is small enough to live inline in the workflow.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] CI/CD changes
- [ ] New tests required
- [ ] New route/page added
