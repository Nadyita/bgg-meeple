import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final pubspecFile = File('pubspec.yaml');
  final iconFile = File('assets/icon/app_icon.png');

  group('App icon configuration', () {
    test('source icon asset exists', () {
      expect(
        iconFile.existsSync(),
        isTrue,
        reason: 'assets/icon/app_icon.png must exist',
      );
    });

    test('pubspec declares the icon asset', () {
      final pubspecContent = pubspecFile.readAsStringSync();
      final pubspec = loadYaml(pubspecContent) as YamlMap;

      final flutterSection = pubspec['flutter'] as YamlMap?;
      expect(flutterSection, isNotNull, reason: 'flutter section is required');

      final assets = flutterSection!['assets'] as YamlList?;
      expect(assets, isNotNull, reason: 'assets list is required');
      expect(
        assets!.where((entry) => entry == 'assets/icon/app_icon.png'),
        isNotEmpty,
        reason: 'assets/icon/app_icon.png must be declared in pubspec.yaml',
      );
    });

    test('pubspec declares flutter_launcher_icons config', () {
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
        reason: 'image_path must point to the source asset',
      );
      expect(
        iconConfig['linux'],
        isTrue,
        reason: 'Linux icon generation must be enabled',
      );
    });

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
