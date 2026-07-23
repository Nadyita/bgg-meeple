# Tasks for Split Android release APK by ABI for smaller Obtanium downloads

## 1. Planning

- [x] **1.1** Confirm that per-ABI APKs reduce download size for Obtanium users
- [x] **1.2** Decide on `--split-per-abi` in `release.yml` instead of a universal APK
- [ ] **1.3** Validate OpenSpec change before implementation

### 2. Implementation

- [x] **2.1** Update `.github/workflows/release.yml` to build with `flutter build apk --release --split-per-abi`
- [x] **2.2** Update release asset upload step to attach the three per-ABI APKs
- [x] **2.3** Remove the single `app-release.apk` rename/upload step
- [x] **2.4** Update `.github/workflows/ci.yml` to build and upload split APKs

### 3. Verification

- [x] **3.1** Run `flutter build apk --release --split-per-abi` locally and confirm artifact names
- [x] **3.2** Verify that `app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, and `app-x86_64-release.apk` are produced
- [x] **3.3** Update `README.md` build instructions to mention `--split-per-abi`
- [x] **3.4** Run `flutter analyze` and `flutter test`

### 4. Review

- [x] **4.1** Validate OpenSpec change after implementation
- [x] **4.2** Validate OpenSpec change after implementation (validation passed)
- [x] **4.3** Request approval and archive change
