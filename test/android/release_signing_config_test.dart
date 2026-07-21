import 'dart:io';

import 'package:test/test.dart';

void main() {
  final buildFile = File('android/app/build.gradle.kts');

  group('Android release signing configuration', () {
    test('build file exists', () {
      expect(
        buildFile.existsSync(),
        isTrue,
        reason: 'android/app/build.gradle.kts must exist',
      );
    });

    test('release signing config reads credentials from environment', () {
      final content = buildFile.readAsStringSync();

      expect(
        content.contains('create("release")'),
        isTrue,
        reason: 'release signing config must be declared',
      );
      expect(
        content.contains('BGG_MEEPL_KEYSTORE_PASSWORD'),
        isTrue,
        reason: 'release config must read keystore password from env',
      );
      expect(
        content.contains('BGG_MEEPL_KEY_PASSWORD'),
        isTrue,
        reason: 'release config must read key password from env',
      );
      expect(
        content.contains('BGG_MEEPL_KEY_ALIAS'),
        isTrue,
        reason: 'release config must read key alias from env',
      );
      expect(
        content.contains('BGG_MEEPL_KEYSTORE_PATH'),
        isTrue,
        reason: 'release config must read keystore path from env',
      );
    });

    test('release build type does not unconditionally use debug signing', () {
      final content = buildFile.readAsStringSync();

      // The old unconditional debug fallback must not be present.
      expect(
        !content.contains('signingConfig = signingConfigs.getByName("debug")'),
        isTrue,
        reason: 'release build type must not unconditionally use debug signing',
      );

      // It should select a config conditionally.
      expect(
        content.contains('signingConfigs.getByName("release")'),
        isTrue,
        reason: 'release build type must reference the release signing config',
      );
    });

    test(
      'release signing config handles absolute and relative keystore paths',
      () {
        final content = buildFile.readAsStringSync();

        expect(
          content.contains(
            'val envPath = System.getenv("BGG_MEEPL_KEYSTORE_PATH")',
          ),
          isTrue,
          reason: 'release config must read the keystore path from env',
        );
        expect(
          content.contains('if (envPath != null)'),
          isTrue,
          reason: 'release config must branch on whether an env path is set',
        );
        expect(
          content.contains('file(envPath)'),
          isTrue,
          reason: 'release config must use the env path directly when provided',
        );
        expect(
          content.contains('file("../keystore/bgg_meeple_release.keystore")'),
          isTrue,
          reason:
              'release config must fall back to a path relative to android/app/',
        );
      },
    );

    test('release workflow passes an absolute keystore path', () {
      final workflow = File('.github/workflows/release.yml').readAsStringSync();

      expect(
        workflow.contains(
          r'${{ github.workspace }}/android/keystore/bgg_meeple_release.keystore',
        ),
        isTrue,
        reason: 'release workflow must pass an absolute keystore path',
      );
    });

    test('.gitignore protects keystore files', () {
      final gitignore = File('android/.gitignore').readAsStringSync();

      expect(
        gitignore.contains('**/*.keystore') || gitignore.contains('*.keystore'),
        isTrue,
        reason: 'android/.gitignore must ignore keystore files',
      );
      expect(
        gitignore.contains('**/*.jks') || gitignore.contains('*.jks'),
        isTrue,
        reason: 'android/.gitignore must ignore jks files',
      );
      expect(
        gitignore.contains('keystore/'),
        isTrue,
        reason: 'android/.gitignore must ignore the CI keystore directory',
      );
    });

    test('release workflow trims and validates the decoded keystore', () {
      final workflow = File('.github/workflows/release.yml').readAsStringSync();

      expect(
        workflow.contains(r"tr -d '\n\r '"),
        isTrue,
        reason:
            'release workflow must strip whitespace/newlines from base64 secret',
      );
      expect(
        workflow.contains(r"| base64 -d"),
        isTrue,
        reason: 'release workflow must base64-decode the secret',
      );
      expect(
        workflow.contains('file android/keystore/bgg_meeple_release.keystore'),
        isTrue,
        reason:
            'release workflow should sanity-check the decoded keystore file',
      );
    });

    test('release workflow consumes the required secrets', () {
      final workflow = File('.github/workflows/release.yml').readAsStringSync();

      expect(
        workflow.contains('BGG_MEEPL_KEYSTORE_BASE64'),
        isTrue,
        reason: 'release workflow must reference BGG_MEEPL_KEYSTORE_BASE64',
      );
      expect(
        workflow.contains('BGG_MEEPL_KEYSTORE_PASSWORD'),
        isTrue,
        reason: 'release workflow must reference BGG_MEEPL_KEYSTORE_PASSWORD',
      );
      expect(
        workflow.contains('BGG_MEEPL_KEY_ALIAS'),
        isTrue,
        reason: 'release workflow must reference BGG_MEEPL_KEY_ALIAS',
      );
      expect(
        workflow.contains('BGG_MEEPL_KEY_PASSWORD'),
        isTrue,
        reason: 'release workflow must reference BGG_MEEPL_KEY_PASSWORD',
      );
    });
  });
}
