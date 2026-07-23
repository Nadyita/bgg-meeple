# Feature: Split Android release APK by ABI for smaller Obtanium downloads

## Summary

Build and publish per-ABI Android APKs instead of a single universal APK, so users who install via Obtanium only download the native libraries their device actually needs.

## Motivation

The current `app-release.apk` produced by `flutter build apk --release` bundles native libraries for `arm64-v8a`, `armeabi-v7a`, and `x86_64` into one file. Analysis of the latest build shows:

| APK | Size |
|-----|------|
| `app-release.apk` (universal) | 60 MB |
| `app-arm64-v8a-release.apk` | 22 MB |
| `app-armeabi-v7a-release.apk` | 19 MB |
| `app-x86_64-release.apk` | 23 MB |

Users installing through Obtanium receive the universal APK regardless of device architecture, wasting bandwidth and storage. Splitting by ABI matches the way other Flutter projects distribute direct APK downloads and lets Obtanium pick the correct artifact.

## Proposed Solution

1. Change the GitHub Actions `release.yml` workflow to build with `--split-per-abi`.
2. Upload the three resulting per-ABI APKs as release assets instead of renaming a single `app-release.apk`.
3. Optionally keep an `app-release.apk` universal fallback, but the primary Obtanium asset should be the per-ABI APKs.
4. Update local build documentation (`README.md`) to mention `--split-per-abi`.

## Alternatives Considered

- **App Bundle (`appbundle`)**: Better for Google Play because Play delivers the right ABI/DPI split automatically, but Obtanium downloads direct APKs from GitHub, so an AAB is not useful as the primary Obtanium artifact. We can still build an AAB alongside the split APKs in the future.
- **ABI filter in `build.gradle.kts`**: Setting `splits.abi.isUniversalApk = false` achieves the same output, but `--split-per-abi` is the idiomatic Flutter command-line option and keeps the Android build file simpler.

## Impact

- [ ] Breaking changes
- [ ] Database migrations
- [ ] API changes
- [x] CI/CD / release artifact changes
- [x] Documentation updates
