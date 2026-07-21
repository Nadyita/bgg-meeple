import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final pubspecFile = File('pubspec.yaml');
  final svgIconFile = File('assets/icon/app_icon.svg');
  final pngIconFile = File('assets/icon/app_icon.png');
  final generatorScript = File('scripts/generate_app_icon.py');
  final installScript = File('scripts/install_linux_desktop_files.sh');
  final desktopFile = File(
    'linux/runner/resources/com.bggmeeple.bgg_meeple.desktop',
  );

  group('App icon configuration', () {
    test('source SVG icon asset exists', () {
      expect(
        svgIconFile.existsSync(),
        isTrue,
        reason: 'assets/icon/app_icon.svg must exist',
      );
    });

    test('generated PNG icon asset exists', () {
      expect(
        pngIconFile.existsSync(),
        isTrue,
        reason: 'assets/icon/app_icon.png must exist',
      );
    });

    test('icon generator script exists', () {
      expect(
        generatorScript.existsSync(),
        isTrue,
        reason: 'scripts/generate_app_icon.py must exist',
      );
    });

    test('icon install script exists', () {
      expect(
        installScript.existsSync(),
        isTrue,
        reason: 'scripts/install_linux_desktop_files.sh must exist',
      );
    });

    test('Linux desktop entry file exists and references correct icon', () {
      expect(
        desktopFile.existsSync(),
        isTrue,
        reason: 'Linux desktop entry file must exist',
      );

      final content = desktopFile.readAsStringSync();
      expect(
        content.contains('Icon=com.bggmeeple.bgg_meeple'),
        isTrue,
        reason: 'desktop entry must reference the correct icon name',
      );
      expect(
        content.contains('StartupWMClass=com.bggmeeple.bgg_meeple'),
        isTrue,
        reason: 'desktop entry must set StartupWMClass to the application ID',
      );
    });

    test('pubspec declares the SVG icon asset', () {
      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent) as YamlMap;

      final flutterSection = pubspec['flutter'] as YamlMap?;
      expect(flutterSection, isNotNull, reason: 'flutter section is required');

      final assets = flutterSection!['assets'] as YamlList?;
      expect(assets, isNotNull, reason: 'assets list is required');
      expect(
        assets!.where((entry) => entry == 'assets/icon/app_icon.svg'),
        isNotEmpty,
        reason: 'assets/icon/app_icon.svg must be declared in pubspec.yaml',
      );
    });

    test(
      'pubspec declares flutter_launcher_icons config using generated PNG',
      () {
        final pubspecContent = pubspecFile.readAsStringSync();
        final pubspec = loadYaml(pubspecContent) as YamlMap;

        final iconConfig = pubspec['flutter_launcher_icons'] as YamlMap?;
        expect(
          iconConfig,
          isNotNull,
          reason: 'flutter_launcher_icons section is required',
        );

        expect(
          iconConfig!['android'],
          isTrue,
          reason: 'Android icon generation must be enabled',
        );
        expect(
          iconConfig['image_path'],
          'assets/icon/app_icon.png',
          reason: 'image_path must point to the generated PNG asset',
        );
        expect(
          iconConfig['linux'],
          isTrue,
          reason: 'Linux icon generation must be enabled',
        );
        expect(
          iconConfig['linux_icon_name'],
          'com.bggmeeple.bgg_meeple',
          reason: 'Linux icon name must match the application ID',
        );
      },
    );

    test('pubspec declares flutter_launcher_icons dev dependency', () {
      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent) as YamlMap;

      final devDependencies = pubspec['dev_dependencies'] as YamlMap?;
      expect(
        devDependencies,
        isNotNull,
        reason: 'dev_dependencies section is required',
      );
      expect(
        devDependencies!.containsKey('flutter_launcher_icons'),
        isTrue,
        reason: 'flutter_launcher_icons must be declared as a dev dependency',
      );
    });
  });
}
