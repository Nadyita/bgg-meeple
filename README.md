# BGG Meeple

A personal offline-first BoardGameGeek collection viewer built with Flutter.

## Supported platforms

- Linux Desktop (primary development target)
- Android (supported)
- Web (optional, to be evaluated)

## Development

### Prerequisites

- Flutter SDK (stable channel)
- For Linux builds:
  - clang
  - cmake
  - ninja-build
  - pkg-config
  - libgtk-3-dev
  - liblzma-dev
  - libsecret-1-dev
- For Android builds:
  - Android SDK (platform-tools, build-tools, Android platform)
  - JDK 17 or later

### Build and run on Linux

```bash
flutter pub get
flutter run -d linux
```

### Build for Android

```bash
flutter build apk --release
```

The release APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

When no release signing credentials are configured, the build falls back to the debug signing key. This is fine for local testing, but release artifacts that are distributed to users must be signed with the project's release keystore.

### Android release signing

Release builds must be signed with the shared project keystore so that users can install updates over existing versions. The keystore file and passwords are **never committed** to the repository.

#### Required secrets

- `BGG_MEEPL_KEYSTORE_BASE64`: Base64-encoded content of `bgg_meeple_release.keystore`
- `BGG_MEEPL_KEYSTORE_PASSWORD`: Keystore password
- `BGG_MEEPL_KEY_ALIAS`: Key alias (default: `bgg_meeple`)
- `BGG_MEEPL_KEY_PASSWORD`: Key password

#### Creating the release keystore

Run the following command once and keep the resulting file in a safe place. Losing the keystore makes it impossible to publish updates to existing installations.

```bash
keytool -genkey -v \
  -keystore bgg_meeple_release.keystore \
  -alias bgg_meeple \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_KEYSTORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD \
  -dname "CN=BGG Meeple, O=BGG Meeple, C=DE"
```

#### Encode the keystore for GitHub Actions

Use `base64` **without line wrapping** and avoid copying trailing newlines:

```bash
base64 -w 0 bgg_meeple_release.keystore
```

Copy the entire single-line output and paste it into the `BGG_MEEPL_KEYSTORE_BASE64` GitHub secret. Do not add spaces or line breaks. If the secret contains whitespace, the workflow strips it, but a clean secret prevents decoding errors.

#### Configuring GitHub Actions

1. Go to **Settings → Secrets and variables → Actions** in the GitHub repository.
2. Add the four secrets listed above.

The `release.yml` workflow decodes the keystore, builds a signed APK, and removes the decoded file after the build.

#### Building a signed release locally

If you have the keystore file locally, you can build a signed release APK by exporting the credentials:

```bash
export BGG_MEEPL_KEYSTORE_PATH=/path/to/bgg_meeple_release.keystore
export BGG_MEEPL_KEYSTORE_PASSWORD=YOUR_KEYSTORE_PASSWORD
export BGG_MEEPL_KEY_ALIAS=bgg_meeple
export BGG_MEEPL_KEY_PASSWORD=YOUR_KEY_PASSWORD
flutter build apk --release
```

### Create a release

Releases are created automatically from Git tags that start with `v`:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

This triggers the `release.yml` workflow, which runs the full test suite and then builds and attaches:

- `bgg-meeple-android.apk`
- `bgg-meeple-linux-<tag>.tar.gz`

Only tags matching `v*` trigger a release. Tests must pass before any artifact is built or attached.

If the workflow fails with `403 Resource not accessible by integration` while creating the GitHub release, make sure the repository allows write access for GitHub Actions:
**Settings → Actions → General → Workflow permissions → Read and write permissions**.
The `release.yml` workflow requests `contents: write` permission for creating releases and uploading assets.

### Run tests

```bash
flutter test
```

### Troubleshooting

#### Android: "Failed host lookup" / cannot log in

The app declares `INTERNET` and `ACCESS_NETWORK_STATE` in `android/app/src/main/AndroidManifest.xml`.
On standard Android these permissions are granted automatically. Some custom ROMs or manufacturer skins
(e.g. GrapheneOS, CalyxOS, certain Xiaomi/OnePlus builds) treat network access as a manual permission.

If you see `ClientSocketException` or `Failed host lookup: 'boardgamegeek.com'` on a real device
while the browser works, open the Android app details for **BGG Meeple** and make sure that
**Network access** / **Internet** is allowed.

BGG credentials and session cookies are stored via [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage), which uses platform-specific secure storage:

- Android: encrypted SharedPreferences / Keystore
- iOS / macOS: Keychain
- Linux: `libsecret`
- Windows: Credential Locker / DPAPI

For local Linux development, make sure `libsecret-1-dev` (and the corresponding runtime library, usually `libsecret-1-0`) is installed. The Linux build will fail with `FindPkgConfig` errors if the development headers are missing.

## Architecture

The app follows hexagonal architecture (ports and adapters) with Clean Code principles. Business logic is isolated from frameworks and external APIs. Unit tests are written before or alongside the business logic.

## Localization

The app supports English and German. User-facing strings are externalized into ARB files in `lib/presentation/l10n/`.

## Continuous Integration

GitHub Actions workflows are defined in `.github/workflows/`:

- `ci.yml`: runs tests and builds the Linux and Android apps on every push and pull request.
- `release.yml`: triggered by pushing a tag starting with `v`; runs tests, builds Linux and Android release artifacts, and attaches them to a new GitHub Release.
  The Android APK is attached as `bgg-meeple-android.apk`, the Linux bundle as `bgg-meeple-linux-<tag>.tar.gz`.
  Tests must pass before any artifact is built.

## Project conventions

- All source code, documentation, comments, and project artifacts are written in English.
- AI-generated emojis are not used anywhere in the project.
- Standard Material Design icons are used for UI elements.
